# saucepan
Assemble a variety of ingredients into a savory UCE file

## What It Do

I managed to manually create UCE files with the Windows Add-On Tool for
about 30 minutes before I started to go completely bugnuts.

But rather than succumb to madness by a thousand clicks, I put together this
helpful Linux script instead.

You simply create subdirectories (or links to other subdirectories) for your
box art, bezels, cores, and ROMs in the resources folder. In those subdirectories,
the box art, bezel, and ROM files for a given game must have the same "base name"
(i.e., the part of the file name before the dot).

So, in other words, to build out a Robby Roto package, you would stage the following files:

* resources/cores/mame2003_plus_libretro.so
* resources/roms/robby.zip

And, if you want a custom box art and a bezel (both are optional), you could also stage these:

* resources/boxart/robby.png
* resources/bezels/robby.png

Then, it's as simple as typing in the following:

```
$ ./saucepan.sh "The Adventures of Robby Roto" robby
```

Et voilà, a wild UCE file appears in the target directory that's ready to be copied onto a USB stick and
carried to your local ALU for some gaming goodness.

By default, the script uses the mame2003_plus_libretro.so core, but if you prefer
to use something different, you can change it by specifying:

```
--core-name <core_name>
```

on the command line. Obviously, that core needs to be in your resources/cores
directory for that to work.

Or, if you'd prefer to use the built-in cores that are provided with the Legends Ultimate,
you can do that too! Assuming that you have a really old firmware that still allows access
to those cores.

Just pass in:

```
--builtin-core genesis|mame2003plus|mame2010|nes|snes|atari2600|colecovision
```

This will configure your UCE to use a built-in core so it doesn't have to bundle one into
the file, which means much smaller file sizes.

## Initial Configuration

### Resource Directories

In order for the script to run, four directories must exist in the resources directory.
They are:

* bezels - Contains bezel image files named after the associated ROMs. A bezel can be any format
  or size. When building the UCE, saucepan will automatically convert it to a 1280x720 PNG.
* boxart - Contains box art image files named after the associated ROMs. A box art can be any
  format or size. When building the UCE, saucepan will automatically convert it to a 222x306 PNG.
* cores - Contains custom cores to be packaged into the UCE file. If you want
  to use the built-in cores included with the Legends Ultimate, there doesn't need
  to be anything in here.
* roms - Contains ROM files.

Before running the script, you will need to create these directories and populate them
with your box art, bezels, cores, and ROMs.

More likely, you already have directories located elsewhere that meet these
descriptions. If so, you can simply create links to those directories.  For
example, if you have an existing ROMs directory at "/MAME/roms", you can create
a link with the following command:

```
$ ln -s /MAME/roms <saucepan_home>/resources/roms
```

NOTE: In order to work with a variety of image and ROM file formats, saucepan has no expectations about
the file extensions of your ROMs, box arts, bezels, and samples.

For example, if you're building a UCE for Robby Roto, the script doesn't care if your box art is named
"robby.jpg" or "robby.png", it will just search for "robby.\*" in your resources directory and work with
what it finds.

However, that means that if you have *both* a "robby.png" and a "robby.jpg" in the same directory, all bets
are off as to which one saucepan will use. It's therefore best to have only one file with the same rom name
in each resource directory.

### Support for MAME Samples

saucepan now supports MAME samples. If you want to make use of this support, you should also
create a samples directory or link called "resources/samples".

Only certain cores support MAME samples.  If you find that your samples aren't working, you
may need to choose a different core.

Note that you will also need zip installed on your system in order for samples support to work.
 
To install zip in Ubuntu, you simply run:

```
$ sudo apt install zip
```

Other distributions may require a different install command. You may also require root or sudo
access to perform an install.

### Default Box Art and Bezel

When no custom box art is found, the script will use the default box art located at
defaults/boxart.png. If you want to set your own default, just copy it over the
existing file.

When no custom bezel is found, the script will use the default bezel located at
defaults/bezel.png. Since not everybody loves bezels, there is no default provided.
Feel free to add your own, or leave it missing if you prefer no bezel.

### Per-Platform Resource Directories

Instead of having a single generic directory for your roms, bezels, and boxart, you can create separate
directories for each different target platform. For example, if you want to put all of your MAME2010 
resources in their own location, you can create any of the following directories:

* resources/bezels_mame2010
* resources/boxart_mame2010
* resources/roms_mame2010
* resources/samples_mame2010

If saucepan detects that you are trying to create a MAME2010 UCE, it will first look for resources in
these directories (if they exist). If it doesn't find what it's looking for in the platform-specific
directories, it will fall back to the generic directory for each type of resource.

An example of how you might use this feature is to create separate roms_mame2003plus and roms_mame2010
directories. Depending on which core you select, saucepan will automatically pull the ROM from the correct
directory.

Note that you can create a platform-specific default boxart and bezel by placing "boxart.png" and
"bezel.png" in their respective platform-specific directories. These will override any custom boxart and bezel
that might exist in the generic resource directories, as well as the overall defaults.

Valid platform names are:

* atari2600
* colecovision
* fbneo
* gba
* genesis
* mame2003plus
* mame2010
* nes
* snes
* supergrafx

## Usage

```
Usage: saucepan.sh [arguments]... <game_name> <rom_name>

  <game_name>
      Specifies the name you want to appear on the ALU Add-On menu.
      Be sure to put the name in quotation marks if it has spaces in it.

  <rom_name>
      Specifies the base name of a ROM file in the resources/roms directory.
      Note that you should not include the file extension.
      If you have a custom box art and/or bezel, they should be located at
          resources/boxart/<rom_name>.png and resources/bezels/<rom_name>.png respectively.

Arguments:
  -b|--builtin-core <platform>
      Use a built-in ALU core. This will make your UCE file substantially smaller.
      <platform> must be genesis, mame2003plus, mame2010, nes, snes, atari2600,
      or colecovision.

  -c|--core <core_name>
      Use the custom core named <core_name> located in your resources/cores directory.

  -i|--ini-file
      Use a pre-created ini file instead of the ALU system defaults.

  -n|--no-resize
      Keep bezel and box art images at their original sizes.

  -o|--organize
      Organize UCE files by genre and/or console

  -r|--restore-save
      Use a backed up save area instead of building a new one from scratch.

  -s|--samples <samples_name>
      By default, we search the samples directories for a file that matches <rom_name>.
      This flag causes the script to search for <samples_name> instead.

  -u|--uncompress
      Uncompress the ROM file. Currently only works on files in .zip format.
```

Note that if you don't specify any core on the command line, the script will attempt to
use resources/cores/mame2003_plus_libretro.so.

### Automatic Image Resizing

Box art images can technically be any size.  However, it is recommended that they be 222x306 in
order to keep file sizes small, since images larger than that will be scaled down by the ALU anyway.

Bezel images *must* be sized at 1280x720 or the ALU will refuse to display them.

Both types of image must be in PNG format.

If you have ImageMagick installed on your system, saucepan will automatically resize your box art
and bezel images to the correct sizes. It will also convert them to PNG format if they are in some
other format.

If ImageMagick is not installed, saucepan will warn you that it can not resize images, and will
use your images at their original sizes.

To determine whether you have ImageMagick installed, run the "convert" command. If it responds with
usage information, you're good to go! If it gives you an error, or suggests that you should install
ImageMagick, you'll need to install it before resizing will work.

To install ImageMagick in Ubuntu, you simply run:

```
$ sudo apt install imagemagick-6.q16
```

Other distributions may require a different command to install the ImageMagick package.  Also note that you will
need to be able to run sudo, or become root by some other means, to install the package.

If you prefer that saucepan not try to resize your images, you can specify "--no-resize" on the command line.
This will also suppress the warning messages about not having ImageMagick installed.

### Automatic UCE Organization

saucepan can automatically organize your UCEs when it writes them out to the target
directory.

If you specify the "--organize" flag, the script will write your MAME UCE into a subdirectory named
after the game's genre, as defined in the catver.ini for that version of MAME.

For example, if you build a Robby Roto UCE using a MAME 2003-Plus core, it will be written to:

<saucepan_home>/target/Maze/Digging/robby.zip

Depending on your ALU's firmware version, the ALU interface may only display a single level of your
file system hierarchy.  So a UCE located in "Maze/Digging" will show up under "Maze".

You can find the catver.ini files for mame2003, mame2003plus, mame2010, and fbneo in saucepan's defaults
directory. Note that these are not verbatim copies of catver.ini; some minor modifications have been
made to work around bugs with certain directory names. Feel free to modify them to suit your preferences.

If you're using a non-MAME core, the UCE will be written to a directory named after the target platform
(e.g., Atari 2600, Genesis, etc.)

### Using Different Emulator Defaults

When the ALU runs a game, the default emulator settings are read from a configuration file called
retroplayer_ro.ini. This file is part of the ALU system software, and can not be directly edited. However,
you can package a file called retroplayer.ini along with your UCE file, and the settings within will override
the ALU defaults.

To use a custom ini, specify "--use-ini" on the command line.  By default, this will read the
retroplayer.ini file from the "defaults" directory and automatically package it up with your UCE.

The default retroplayer.ini delivered with saucepan is configured with the following settings:
* Sets the display mode to "Fit"
* Turns on the horizontal scanline filter
* Disables bilinear filtering for some games where the ALU inexplicably turns it on by default (e.g., several Capcom games)
* Fixes the repeated popping sound that occurs in several early Namco games

If you want a particular ROM to have a different retroplayer.ini, create a directory under resources called
"inis", and save your custom ini file to it as "<rom_name>.ini". When you specify "--use-ini", saucepan will
first look for this file and, if it doesn't exist, will use the default instead.

For those who are interested, retroplayer_ro.ini is included in the "tools" directory.  This file shows
the ALU's default settings, and makes for a useful reference if you want to experiment with different
settings on your own. Note that the included file was extracted from a very early firmware version, so it
may not reflect the ALU's defaults in more recent revisions.

### Rebuilding a UCE with the Same Save Area

If you want to rebuild a UCE but you want to keep its current settings and high scores, you can backup
your UCE's save area and tell saucepan to use it when building the new UCE.

To do this, first create a subdirectory called "saves" in the "resources" directory. Then you can backup a UCE's
save with the backup_save_area.sh script in the "tools" directory, like so:

```
$ tools/backup_save_area.sh <path_to_UCE_file>
```

This will extract the save area from the UCE, compress it, and store it in resources/saves under the name
"<rom_name>.sav.gz".

To use this save area when building a UCE, simply specify "--restore-save" on the saucepan command line.
saucepan will look for your custom save area in "resources/saves".  If it can't find one, it will instead
use "defaults/default.sav.gz".  default.sav.gz is a basic save area that includes the default retroplayer.ini.

## Batch Processing

saucepan supports building several UCE files at once through the use of a manifest file and the
cook_batch script.

To specify a list of games to build, create a file called "batch.manifest" in <saucepan_home>.
The file batch.manifest.sample describes the correct format for the manifest, and is shown here:

```
# Manifest file for saucepan batch cooker

# Blank lines are ignored, as are comment lines like this one,
# which begin with a "#".

# Each section begins with a line surrounded by brackets which indicates
# the core to use for the games in that section, as well as the flags
# that will be used by default when building that section's UCE's.
#
# The core line is followed by a list of games, each containing the name
# of the game, the base filename of the ROM file, and the flags to use
# for that game if you want to override the core defaults.
# 
# All fields are separated by the "pipe" symbol (|).
#
# FORMAT:
# [<core_name>|<core_default_parameters>]
# Game Name 1|ROM File Base Name 1|Override Flags 1
# Game Name 2|ROM File Base Name 2|Override Flags 2
# ...

# The games in this section will use the custom core
# "mame2003_plus_libretro.so", which should be in your
# resources/cores directory.
# 
# We specify that all games in this section will be built with
# the "-o" flag to automatically organize UCEs, unless a game
# specifies flags of its own. For example, the game Victory
# below, will use "-n" instead of "-o" to build its UCE.
[mame2003_plus_libretro.so|-o]
The Adventures of Robby Roto|robby|
Victory|victory|-n

# These games will use the built-in MAME2003-Plus core that
# is built in to the ALU. As a result, the UCE size will be
# substantially smaller.
#
# We can specify that no flags should be used for a game
# by using "--" for its flags. So the game Star Fire below will
# not use the default "-o" flag.
[builtin_mame2003plus|-o]
Looping|looping|
Star Fire|starfire|--

# You can have as many sections that use the same core as you like.
# Here we repeat the built-in MAME2003-Plus core, but for this section,
# we won't pass any flags to saucepan by default.
[builtin_mame2003plus|--]
Fire One|fireone|

# These games will use the built-in Sega Genesis core that
# is built in to the ALU.
#
# We use "-u" in our default flags here because our game files
# are zipped, but the built-in Genesis core can't read zip files.
[builtin_genesis|-o -u]
The Lion King|Lion King, The (World)|
```

Once you've created your manifest file, you simply run:
```
$ ./cook_batch.sh [-m|--manifest <manifest_file>]
```
and the script will go through your manifest and build a UCE for each game.

By default, cook_batch will use <saucepan_home>/batch.manifest as its manifest, but if you pass in 
"-m|--manifest <manifest_file>", you can specify any file you choose.

You can also specify "-p|--prefix" to use the prefix feature. Any line in your manifest file that
begins with a #: is considered a prefix. With the prefix flag turned on, that prefix is prepended to
the name of any game that comes afterwards. For instance, a manifest that reads:
```
#:1979 - 
Fire One|fireone|
Star Fire|starfire|
```
will produce two UCEs, one with the game name "1979 - Star Fire" and one with a game name
"1979 - Fire One".  (Note that there is a space after the dash in the prefix above.) To clear the prefix,
simply insert a line that is "#:" by itself.

### Automatic Manifest Building

Building a manifest file by hand is a drag, so there's also a script to help you create one automatically.

```
Usage: build_batch_manifest.sh [arguments]...

Arguments:
  -a|--append
      Add to the end of the manifest file rather than overwriting it.

  -d|--directory <directory>
      Instead of looking through all default game directories, search the
      specified directory only.
```

If you just run build_batch_manifest by itself, the script will go through all of the standard ROM directories
(<saucepan_home>/resources/roms*) and add every file that it finds to batch.manifest.  The script will do its
best to determine which core it should use depending on the directory, but you'll probably want to check it before
running cook_batch, especially if you want to add flags for each core or game.

By default, each run of build_batch_manifest will overwrite <saucepan_home>/batch.manifest. If you would prefer to have
it add its findings to the end of the existing file, pass in the "--append" flag.

This is particularly useful in conjunction with the "--directory" parameter, which tells
build_batch_manifest to look for ROMs in only the specified directory. For example, if you wanted to create a
manifest containing only MAME2010 and Genesis games, you could do the following:
```
$ ./build_batch_manifest.sh --directory resources/roms_mame2010
$ ./build_batch_manifest.sh --append --directory resources/roms_genesis
```
## Credit Where Due

This thing was made by [slutzo](https://github.com/slutzo).
