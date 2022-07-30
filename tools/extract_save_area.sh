#!/bin/bash

# The save data is the last 4 MB of the UCE file
save_data_size=$(( 1024 * 4096 ))

usage()
{
	echo "USAGE: `basename $0` <UCE_file>"
}

if [ "$1" == "" ]
then
	echo You must specify a UCE file to extract the save data from.
	usage
	exit 1
fi

uce_file=$1
if [ ! -f "${uce_file}" ]
then
    echo ${uce_file} is not a valid file.
    usage
    exit 1
fi

game_name=`basename "${uce_file}" | cut -f1 -d.`
save_data_file=`dirname $0`/${game_name}.savedata
tail -c ${save_data_size} "${uce_file}" > ${save_data_file}
