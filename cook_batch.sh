#!/bin/bash

# cook_batch.sh - build a bunch of UCE files using saucepan and a manifest file

usage()
{
    echo
    echo "Usage: `basename $0` [-k|--keep-existing] [-m|--manifest <manifest_file>] [-p|--prefix]"
    echo
}

# Where the script lives
script_dir=`dirname $0`

# The character that separates individual fields in our manifest file
separator="|"

# String to indicate we don't want to use any flags
no_flags_indicator="--"

manifest_file="${script_dir}/batch.manifest"
use_prefix=false
prefix=""
keep_existing=false

# Parse out command-line options
while (( "$#" ))
do
    case "$1" in
        -h)
            usage
            exit 0
            ;;
        -m|--manifest)
            manifest_file="$2"
            if [ "${manifest_file}" == "" ]
            then
                echo "ERROR: No manifest file name specified"
                usage
                exit 1
            elif [ ! -f "${manifest_file}" ]
            then
                echo "ERROR: Could not find manifest file ${manifest_file}"
                exit 1
            fi
            shift 2
            ;;
        -p|--prefix)
            use_prefix=true
            shift
            ;;
        -k|--keep-existing)
            keep_existing=true
            shift
            ;;
        -*|--*) # unrecognized arguments
            echo "ERROR: Unrecognized argument $1"
            usage
            exit 1
            ;;
    esac
done

current_core=""
current_params=""
use_builtin_core=false

while IFS= read -r line
do
    if [[ "${line}" =~ ^#:.* ]]
    then
        # this is a prefix we want to apply to anything that follows
        prefix="`echo "${line}" | cut -c 3-`"
        continue
    fi

    if [[ "${line}" == "" ]] || [[ "${line}" =~ ^#.* ]]
    then
        # skip empty lines and comments
        continue
    fi

    if [[ "${line}" =~ ^\[.*\] ]]
    then
        # This line is in brackets, so it describes the core that the
        # subsequent UCEs will use
        current_core=`echo "${line}" | cut -f2 -d[ | cut -f1 -d${separator}`
        current_params=`echo "${line}" | cut -f2 -d${separator} | cut -f1 -d]`

        # Allow the use of "--" to specify no flags, just to be consistent with
        # the format for individual games
        if [[ "${current_params}" == "${no_flags_indicator}" ]]
        then
            current_params=""
        fi

        if [[ "${current_core}" =~ ^builtin_.* ]]
        then
            use_builtin_core=true
            current_core=`echo "${current_core}" | cut -f2 -d_`
        else
            use_builtin_core=false
        fi
        continue
    else
        # This line describes a UCE to build
        game_name="`echo "${line}" | cut -f1 -d${separator}`"
        if [ "${use_prefix}" == "true" ]
        then
            game_name="${prefix}${game_name}"
        fi
        rom_name=`echo "${line}" | cut -f2 -d${separator}`
        param_overrides=`echo "${line}" | cut -f3 -d${separator}`

        params="${current_params}"
        if [ "${param_overrides}" != "" ]
        then
            if [ "${param_overrides}" == "${no_flags_indicator}" ]
            then
                params=""
            else
                params="${param_overrides}"
            fi
        fi
        if [ "${keep_existing}" == "true" ]
        then
            params="${params} -k"
        fi
        if [ "${use_builtin_core}" == "true" ]
        then
            command_line="./saucepan.sh -s ${current_core} ${params} \"${game_name}\" \"${rom_name}\""
        else
            command_line="./saucepan.sh -c ${current_core} ${params} \"${game_name}\" \"${rom_name}\""
        fi

        # Actually build the UCE here
        eval ${command_line}
        if [[ $? -ne 0 ]]
        then
            echo "WARNING: "${game_name}" failed to build correctly."
        fi
    fi 
done < "${manifest_file}"

exit 0
