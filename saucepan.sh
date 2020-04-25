#!/bin/bash

# saucepan.sh - assemble a variety of ingredients into a savory UCE file

usage()
{
    echo
    echo "Usage: `basename $0` [arguments]... <game_name> <rom_name>"
    echo
    echo "  <game_name>"
    echo "      Specifies the name you want to appear on the ALU Add-On menu."
    echo "      Be sure to put the name in quotation marks if it has spaces in it."
    echo
    echo "  <rom_name>"
    echo "      Specifies the base name of a ROM file in the resources/roms directory."
    echo "      Note that you should not include the file extension."
    echo "      If you have a custom box art and/or bezel, they should be located at"
    echo "          resources/boxart/<rom_name>.png and resources/bezels/<rom_name>.png respectively."
    echo
    echo "Arguments:"
    echo "  -c|--core <core_name>"
    echo "      Use the custom core named <core_name> located in your resources/cores directory."
    echo
    echo "  -s|--stock-core <stock_core>"
    echo "      Use a built-in ALU core. This will make your UCE file substantially smaller."
    echo "      <stock_core> must be genesis, mame2003plus, mame2010, nes, snes, atari2600,"
    echo "      or colecovision."
    echo
    echo "  -n|--no-resize"
    echo "      Keep bezel and box art images at their original sizes."
    echo
    echo "  -o|--organize"
    echo "      Organize UCE files by genre and/or console"
    echo
    echo "  -u|--uncompress"
    echo "      Uncompress the ROM file. Currently only works on files in .zip format."
    echo
}

cleanup()
{
    # If we've left temporary files lying around, ice them
    if [ ! -z "${game_temp_file}" ] && [ -f "${game_temp_file}" ]
    then
        rm "${game_temp_file}"
    fi
    if [ ! -z "${save_temp_file}" ] && [ -f "${save_temp_file}" ]
    then
        rm "${save_temp_file}"
    fi
    if [ ! -z "${staging_dir}" ] && [ -d "${staging_dir}" ]
    then
        rm -r "${staging_dir}"
    fi
}
trap cleanup EXIT

# Built-in cores located in /emulator on the ALU file system
stock_core_genesis=genesis_plus_gx_libretro.so
stock_core_mame2003plus=mame2003_plus_libretro.so
stock_core_mame2010=mame2010_libretro.so
stock_core_nes=quicknes_libretro.so
stock_core_snes=snes_mtfaust-arm64-cortex-a53.so
stock_core_atari2600=stella_libretro.so
stock_core_colecovision=libcv.so

# The core to use if none are specified on the command line
default_core_name=mame2003_plus_libretro.so

# Where the script lives
script_dir=`dirname $0`

# Where all the temporary junk lives
working_dir=/tmp

# Where the UCE file gets put
target_dir="${script_dir}/target"

# Location of the various files that will be pulled in to create a UCE
src_dir_bezels="${script_dir}/resources/bezels"
src_dir_boxart="${script_dir}/resources/boxart"
src_dir_cores="${script_dir}/resources/cores"
src_dir_roms="${script_dir}/resources/roms"

# Default box art and bezel files
default_boxart="${script_dir}/defaults/boxart.png"
default_bezel="${script_dir}/defaults/bezel.png"

# Recommended dimensions for images
bezel_size=1280x720
boxart_size=222x306

# Defaults if no command-line arguments
core_name=""
target_platform=""
use_stock_core=false
resize_images=true
alt_defaults=false
organize_targest=false
uncompress_rom=false

# Parse out command-line options
positional_args=""
while (( "$#" ))
do
    case "$1" in
        -h)
            usage
            exit 0
            ;;
        -c|--core)
            if [ "$core_name" != "" ]
            then
                echo "ERROR: Multiple cores specified on the command line"
                exit 1
            else
                core_name="$2"
            fi
            shift 2
            ;;
        -s|--stock-core)
            if [ "$core_name" != "" ]
            then
                echo "ERROR: Multiple cores specified on the command line"
                exit 1
            else
                target_platform="$2"
                case "${target_platform}" in
                    genesis)
                        core_name="${stock_core_genesis}"
                        ;;
                    mame2003plus)
                        core_name="${stock_core_mame2003plus}"
                        ;;
                    mame2010)
                        core_name="${stock_core_mame2010}"
                        ;;
                    nes)
                        core_name="${stock_core_nes}"
                        ;;
                    snes)
                        core_name="${stock_core_snes}"
                        ;;
                    atari2600)
                        core_name="${stock_core_atari2600}"
                        ;;
                    colecovision)
                        core_name="${stock_core_colecovision}"
                        ;;
                    *)
                        echo "ERROR: There is no stock core associated with the name \"$2\""
                        exit 1
                        ;;
                esac
                use_stock_core=true
                shift 2
            fi
            ;;
        -n|--no-resize)
            echo "Images will not be resized"
            resize_images=false
            shift
            ;;
        -o|--organize)
            organize_targets=true
            shift
            ;;
        -u|--uncompress)
            uncompress_rom=true
            shift
            ;;
        -a|--alt-defaults)
            alt_defaults=true
            shift
            ;;
        -*|--*) # unrecognized arguments
            echo "ERROR: Unrecognized argument $1"
            usage
            exit 1
            ;;
        *) # preserve positional arguments
            positional_args="${positional_args} \"$1\""
            shift
            ;;
    esac
done

# Put the positional arguments back in place so we can parse them
eval set -- "${positional_args}"

# Use the default core if none was specified
if [ "${core_name}" == "" ]
then
    core_name="${default_core_name}"
fi

# If using a custom core, figure out the target platform based on the core name.
# If using a stock core, we already know the target platform.
if [ "${use_stock_core}" == "false" ]
then
    case "${core_name}" in
        genesis_plus_gx_libretro.so)
            target_platform="genesis"
            ;;
        mame2003_plus_libretro.so|mame2003_plus_libretro_custom_save.so)
            target_platform="mame2003plus"
            ;;
        mame2010_libretro.so)
            target_platform="mame2010"
            ;;
        mednafen_gba_libretro.so|mgba_libretro.so)
            target_platform="gba"
            ;;
        mednafen_supergrafx_libretro.so)
            target_platform="supergrafx"
            ;;
        nestopia_libretro.so)
            target_platform="nes"
            ;;
        snes9x2010_libretro.so)
            target_platform="snes"
            ;;
    esac
fi

# If using a custom core, make sure the file really exists before we proceed
if [ "${use_stock_core}" == "false" ]
then
    if [ ! -f "${src_dir_cores}/${core_name}" ]
    then
        echo "ERROR: Could not find custom core ${core_name} in ${src_dir_cores}"
        exit 1
    fi
fi

if [ "$1" == "" ]
then
    echo "ERROR: You need to specify a game name on the command line."
    exit 1
else
    game_name="$1"
fi

if [ "$2" == "" ]
then
    echo "ERROR: You need to specify a ROM name on the command line."
    exit 1
else
    rom_name="$2"
fi

command -v convert > /dev/null
if [ $? -ne 0 ] && [ "${resize_images}" == true ]
then
    echo "WARNING: Images can not be resized, so their original sizes will be maintained."
    echo "         Auto-resizing requires the \"convert\" command to be in your path."
    echo "         You may need to modify your PATH variable or install ImageMagick."
    resize_images=false
fi

echo "Building \"${game_name}\" from sources named \"${rom_name}\"..."

# Verify a ROM really exists before we get in too deep.
# We assume there's only one file with the base rom_name in the roms directory.
# If there's more, there's a chance we'll grab the wrong one.
src_rom=`find "${src_dir_roms}/" -maxdepth 1 -type f -name "${rom_name}.*" | head -1`
if [ "${src_rom}" != "" ]
then
    echo "Found ROM file: ${src_rom}"
else
    echo "Could not locate ROM file for \"${rom_name}\". Exiting."
    exit 1
fi

# Replace any characters in the game name that are likely to confuse the file system
sanitized_game_name=`echo "$1" | sed 's|[ :]|_|g'`

staging_dir=${working_dir}/AddOn_${sanitized_game_name}
mkdir -p "${staging_dir}/boxart"
mkdir -p "${staging_dir}/emu"
mkdir -p "${staging_dir}/roms"
mkdir -p "${staging_dir}/save"

# Pull in box art from the source dir. If none exists, use the default.
# We assume there's only one file with the base rom_name in the boxart directory.
# If there's more, there's a chance we'll grab the wrong one.
src_boxart=`find "${src_dir_boxart}/" -maxdepth 1 -type f -name "${rom_name}.*" | head -1`
dest_boxart=${staging_dir}/boxart/boxart.png
if [ "${src_boxart}" != "" ]
then
    echo "Found custom box art: ${src_boxart}"
else
    echo "Custom box art not found. Using default box art"
	src_boxart=${default_boxart}
fi
if [ "${resize_images}" == "true" ]
then
	convert -resize ${boxart_size} "${src_boxart}" "${dest_boxart}"
else
    cp -p "${src_boxart}" "${dest_boxart}"
fi

# Pull in bezel from the source dir. If none exists, use the default.
# If no default exists, assume no bezel.
# We assume there's only one file with the base rom_name in the bezel directory.
# If there's more, there's a chance we'll grab the wrong one.
src_bezel=`find "${src_dir_bezels}/" -maxdepth 1 -type f -name "${rom_name}.*" | head -1`
dest_bezel=${staging_dir}/boxart/addon.z.png
if [ "${src_bezel}" != "" ]
then
    echo "Found custom bezel: ${src_bezel}"
elif [ -f "${default_bezel}" ]
then
    echo "Custom bezel not found. Using default bezel."
    src_bezel=${default_bezel}
else
    echo "Not using a bezel"
fi
if [ "${src_bezel}" != "" ]
then
    if [ "${resize_images}" == "true" ]
    then
	    convert -resize ${bezel_size} "${src_bezel}" "${dest_bezel}"
    else
        cp -p "${src_bezel}" "${dest_bezel}"
    fi
fi

# Set up our emulator core
if [ "${use_stock_core}" == "true" ]
then
    echo "Building with stock core: ${core_name}"
    # No need to copy anything. The core is already on the ALU.
    core_path=/emulator/${core_name}
else
    echo "Building with custom core: ${core_name}"
    cp -p "${src_dir_cores}/${core_name}" "${staging_dir}/emu"
    core_path=./emu/${core_name}
fi

# Pull in ROM from the source dir, uncompressing it if requested
if [ "${uncompress_rom}" == "true" ]
then
    rom_ext=`basename "${src_rom}" | cut -f2 -d.`
    if [ "${rom_ext}" != "zip" ]
    then
        echo "WARNING: Can't compress a ROM that isn't a zip file. Leaving it as-is."
        cp -p "${src_rom}" "${staging_dir}/roms"
    else
        unzip -o "${src_rom}" -d "${staging_dir}/roms"
    fi
else
    cp -p "${src_rom}" "${staging_dir}/roms"
fi

# Create a relative link for the title image
pushd "${staging_dir}" > /dev/null
ln -sf boxart/boxart.png title.png
popd > /dev/null

# Copy in our XML descriptor and the executable, replacing their
# contents as appropriate
cat "${script_dir}/defaults/cartridge.xml" | sed "s|GAME_NAME|${game_name}|g" > "${staging_dir}/cartridge.xml"
if [ "${src_bezel}" != "" ]
then
    exec_src=${script_dir}/defaults/exec_bezel.sh
else
    exec_src=${script_dir}/defaults/exec.sh
fi
# We have to look up the file in the staging dir, because the extension may have
# changed if it was uncompressed.
rom_file_path=`find "${staging_dir}/roms/" -maxdepth 1 -type f -name "${rom_name}.*" | head -1`
rom_file_name=`basename "${rom_file_path}"`
cat ${exec_src} | sed "s|CORE_PATH|${core_path}|g" | sed "s|ROM_NAME|${rom_file_name}|g" > ${staging_dir}/exec.sh
chmod 755 "${staging_dir}/exec.sh"

# The staging area is built, so let's cook it up into a UCE
game_temp_file=${working_dir}/${sanitized_game_name}_game.tmp
save_temp_file=${working_dir}/${sanitized_game_name}_save.tmp
mksquashfs "${staging_dir}" "${game_temp_file}" -comp gzip -b 256K -root-owned -noappend > /dev/null

# Next up is a 16-byte MD5 checksum of the squashfs file we just made,
# followed by 32 reserved bytes of empty space
md5sum "${game_temp_file}" \
    | cut -f1 -d' ' \
    | xxd -r -p \
    | dd of="${game_temp_file}" ibs=16 count=1 obs=16 oflag=append conv=notrunc status=none
dd if=/dev/zero of="${game_temp_file}" ibs=16 count=2 obs=16 oflag=append conv=notrunc status=none

# Time to set up the file that's going to be our 4M save area
if [ "${alt_defaults}" == "false" ]
then
    # Create a new ext4 file system and populate it with a couple
    # of required directories
    truncate -s 4M "${save_temp_file}"
    mkfs.ext4 "${save_temp_file}" >& /dev/null
    debugfs -R 'mkdir upper' -w "${save_temp_file}" >& /dev/null
    debugfs -R 'mkdir work' -w "${save_temp_file}" >& /dev/null
else
    # Use a pre-built save area that contains alternate default settings
    gunzip -c ${script_dir}/defaults/alt.sav.gz > "${save_temp_file}"
fi

# Now get an MD5 checksum of our save area file, and tack that on to the game file
md5sum "${save_temp_file}" \
    | cut -f1 -d' ' \
    | xxd -r -p \
    | dd of="${game_temp_file}" ibs=16 count=1 obs=16 oflag=append conv=notrunc status=none

if [ "${organize_targets}" == "true" ]
then
    # Determine which subdirectory to put the file into, depending on platform
    case "${target_platform}"
    in
        mame2003plus|mame2010)
            game_category=`grep ^${rom_name}= ${script_dir}/defaults/${target_platform}/catver.ini \
                | head -1 \
                | cut -f2 -d= \
                | sed 's| \/|\/|g' \
                | sed 's|\/ |\/|g'`
            ;;
        genesis)
            game_category="Genesis"
            ;;
        nes)
            game_category="NES"
            ;;
        snes)
            game_category="Super NES"
            ;;
        atari2600)
            game_category="Atari 2600"
            ;;
        colecovision)
            game_category="ColecoVision"
            ;;
        gba)
            game_category="GameBoy Advance"
            ;;
        supergrafx)
            game_category="SuperGrafx"
            ;;
    esac
    target_dir=${target_dir}/${game_category}
    mkdir -p "${target_dir}"
fi

# Finally, we tack our save file onto the end of the game file, and we're done
uce_file=${target_dir}/AddOn_${sanitized_game_name}.UCE
cat "${game_temp_file}" "${save_temp_file}" > "${uce_file}"

echo "Creation complete! UCE file written to: ${uce_file}"

exit 0
