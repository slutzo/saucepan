#!/bin/bash

output_filename=outfile

usage ()
{
    echo
    echo "USAGE:"
    echo "`basename $0` <fs_image> <file_to_extract>"
}

if [ "$1" == "" ]
then
    echo "ERROR: You must specify the name of a file system image."
    usage
    exit 1
else
    fs_image=$1
    if [ ! -f ${fs_image} ]
    then
        echo "ERROR: The specified file system image \"${fs_image}\" does not exist."
        exit 1
    fi
fi

if [ "$2" == "" ]
then
    echo "ERROR: You must specify the name of a file to extract."
    usage
    exit 1
else
    file_to_extract=$2
fi

debugfs -f <(echo cat ${file_to_extract}) ${fs_image} | tail -n +2 > ${output_filename}

echo "Done. The extracted file has been save to ${output_filename}."
exit 0
