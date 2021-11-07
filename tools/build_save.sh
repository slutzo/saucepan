#!/bin/bash

usage()
{
    echo
    echo "USAGE:"
    echo "`basename $0` <rom_name> [<ini_file>]"
    echo
}

if [ "`whoami`" != "root" ]
then
    echo "This script must be executed as root or with sudo."
    exit 1
fi

if [ "$1" == "" ]
then
    echo "ERROR: You must specify a ROM name on the command line."
    usage
    exit 1
fi

src_ini_file=""
if [ "$2" != "" ]
then
    if [ -f "$2" ]
    then
        echo "Using ini file $2"
        src_ini_file="$2"
    else
        echo "WARNING: ini file $2 does not exist. Ignoring ini file."
    fi
fi

rom_name=$1
echo "Building a save area for ROM: ${rom_name}"

script_dir=`dirname $0`
temp_dir=/tmp
target_dir=.

save_temp_file=${temp_dir}/save_${rom_name}.tmp
temp_fs=${temp_dir}/mnt_${rom_name}
save_file=${target_dir}/${rom_name}.sav.gz
save_size=4M

# Create a new ext4 file system that will become our save area
truncate -s ${save_size} "${save_temp_file}"
mkfs.ext4 -F "${save_temp_file}" >& /dev/null

# Mount the file system as loopback so we can write stuff to it
mkdir -p ${temp_fs}
mount -o loop ${save_temp_file} ${temp_fs}

# Build the basic framework
ini_file=${temp_fs}/upper/retroplayer.ini
mkdir ${temp_fs}/upper
mkdir ${temp_fs}/work
if [ "${src_ini_file}" != "" ]
then
    cp "${src_ini_file}" "${ini_file}"
else
    touch ${ini_file}

    # Global settings
    echo "[Global]" >> ${ini_file}
    echo "ScreenSize=1" >> ${ini_file}
fi
chown 12:man ${ini_file}

# Unmount the file system
umount ${temp_fs}

# Compress it down
gzip -c ${save_temp_file} > ${save_file}

# Clean up
rm ${save_temp_file}
rmdir ${temp_fs}

exit 0
