#!/bin/bash

# build_batch_manifest.sh - search through ROM directories to construct a manifest file

usage()
{
    echo
    echo "Usage: `basename $0` [arguments]..."
    echo
    echo "Arguments:"
    echo "  -a|--append"
    echo "      Add to the end of the manifest file rather than overwriting it."
    echo
    echo "  -d|--directory <directory>"
    echo "      Instead of looking through all default game directories, search the"
    echo "      specified directory only."
    echo
}

# Where the script lives
script_dir=`dirname $0`

# The character that separates individual fields in our manifest file
separator="|"

# String to indicate we don't want to use any flags
no_flags_indicator="--"

# Our manifest file
manifest_file="${script_dir}/batch.manifest"

# The core we assume we'll use if none is specified
default_core="mame2003_plus_libretro.so"

# List of stock cores available in the ALU
stock_core_list="atari2600 colecovision genesis mame2003plus mame2010 nes snes"

# The main ROMs directory
src_dir_roms="${script_dir}/resources/roms"

# Append the file or overwrite it?
append_file=false

# A user-specified directory to search for ROMs. If this is set, we don't look through
# the resource directories.
search_dir=""

# Parse out command-line options
while (( "$#" ))
do
    case "$1" in
        -h)
            usage
            exit 0
            ;;
        -a|--append)
            append_file=true
            shift
            ;;
        -d|--directory)
            search_dir="$2"
            if [ "${search_dir}" == "" ]
            then
                echo "ERROR: No directory specified."
                usage
                exit 1
            else
                if [ ! -d "${search_dir}" ]
                then
                    echo "ERROR: Directory \"${search_dir}\" does not exist"
                    exit 1
                fi
            fi
            shift 2
            ;;
        -*|--*) # unrecognized arguments
            echo "ERROR: Unrecognized argument $1"
            usage
            exit 1
            ;;
    esac
done

if [ "${append_file}" == "false" ] || [ ! -f "${manifest_file}" ]
then
    # Write our header comment at the top of a new manifest file
    echo "# Manifest file for saucepan batch cooker" > "${manifest_file}"
fi

if [ "${search_dir}" != "" ]
then
    # The user specified a directory to search, so we're only going to look there
    echo "Searching user-specified directory \"${search_dir}\""
    echo "Assuming default core "${default_core}" for any ROMs found"

    echo "[${default_core}${separator}${no_flags_indicator}]" >> "${manifest_file}"
    # Temporarily change the field separator to line breaks so we 
    # don't break up filenames with spaces in them
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    for rom_file in `find "${search_dir}/" -maxdepth 1 -type f | head -1`
    do
        rom_name=`basename "${rom_file}" | rev | cut -f2- -d. | rev`
        # For now, the best we can do is name the game the same thing as
        # the ROM.
        echo "${rom_name}${separator}${rom_name}${separator}" >> "${manifest_file}"
    done
    IFS=$SAVEIFS
    # Insert a blank line for readability
    echo "" >> "${manifest_file}"
else
    # No directory was specified by the user, so look in all the standard locations.
    # First, scrape the base ROMs directory. We assume we're using the default core
    # for these ROMs.
    if [ -d "${src_dir_roms}" ]
    then
        echo "[${default_core}${separator}${no_flags_indicator}]" >> "${manifest_file}"
        # Temporarily change the field separator to line breaks so we 
        # don't break up filenames with spaces in them
        SAVEIFS=$IFS
        IFS=$(echo -en "\n\b")
        for rom_file in `find "${src_dir_roms}/" -maxdepth 1 -type f`
        do
            rom_name=`basename "${rom_file}" | rev | cut -f2- -d. | rev`
            # For now, the best we can do is name the game the same thing as
            # the ROM.
            echo "${rom_name}${separator}${rom_name}${separator}" >> "${manifest_file}"
        done
        IFS=$SAVEIFS
        # Insert a blank line for readability
        echo "" >> "${manifest_file}"
    fi

    # Scrape the platform-specific ROMs directories. We assume the stock cores
    # for these directories.
    for platform in ${stock_core_list}
    do
        echo $platform
        platform_rom_dir="${src_dir_roms}_${platform}"
        if [ -d "${platform_rom_dir}" ]
        then
            echo "[stock_${platform}${separator}${no_flags_indicator}]" >> "${manifest_file}"
            # Temporarily change the field separator to line breaks so we 
            # don't break up filenames with spaces in them
            SAVEIFS=$IFS
            IFS=$(echo -en "\n\b")
            for rom_file in `find "${platform_rom_dir}/" -maxdepth 1 -type f`
            do
                rom_name="`basename "${rom_file}" | rev | cut -f2- -d. | rev`"
                # For now, the best we can do is name the game the same thing as
                # the ROM.
                echo "${rom_name}${separator}${rom_name}${separator}" >> "${manifest_file}"
            done
            IFS=$SAVEIFS
            # Insert a blank line for readability
            echo "" >> "${manifest_file}"
        fi
    done
fi
    
exit 0
