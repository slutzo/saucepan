#!/bin/bash

temp_dir="/tmp"

# The save data is the last 4 MB of the UCE file
save_data_size=$(( 1024 * 4096 ))

usage()
{
	echo "USAGE: `basename $0` <UCE_file>"
}

if [ "$1" == "" ]
then
	echo ERROR: You must specify a UCE file to extract the save data from.
	usage
	exit 1
fi

uce_file=$1
if [ ! -f "${uce_file}" ]
then
    echo "${uce_file}" is not a valid file.
    usage
    exit 1
fi

rom_file=`unsquashfs -l "${uce_file}" roms | tail -1 | xargs basename`
rom_name="${rom_file%.*}"
if [ "${rom_name}" == "" ]
then
    echo ERROR: Could not extract ROM name from the UCE file.
    exit 1
fi

script_dir="`dirname $0`"
saves_dir="${script_dir}/../resources/saves"
if [ ! -d "${saves_dir}" ]
then
    echo "WARNING: Destination directory ${saves_dir} does not exist."
    echo "         Save file will be written to local directory."
    saves_dir="."
fi

save_temp_file="${temp_dir}/${rom_name}.sav"
save_dest_file="${saves_dir}/${rom_name}.sav.gz"
tail -c ${save_data_size} "${uce_file}" > "${save_temp_file}"
gzip -c "${save_temp_file}" > "${save_dest_file}"
