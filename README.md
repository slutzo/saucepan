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

Or, if you'd prefer to use the stock cores that are provided with the Legends Ultimate,
you can do that too!

Just pass in:

```
--stock-core genesis|mame2003plus|mame2010|nes|snes|atari2600|colecovision
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
  to use the stock cores included with the Legends Ultimate, there doesn't need
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
the file extensions of your ROMs, box arts, and bezels.

For example, if you're building a UCE for Robby Roto, the script doesn't care if your box art is named
"robby.jpg" or "robby.png", it will just search for "robby.\*" in your resources directory and work with
what it finds.

However, that means that if you have *both* a "robby.png" and a "robby.jpg" in the same directory, all bets
are off as to which one saucepan will use. It's therefore best to have only one file with the same rom name
in each resource directory.

### Default Box Art and Bezel

When no custom box art is found, the script will use the default box art located at
defaults/boxart.png. If you want to set your own default, just copy it over the
existing file.

When no custom bezel is found, the script will use the default bezel located at
defaults/bezel.png. Since not everybody loves bezels, there is no default provided.
Feel free to add your own, or leave it missing if you prefer no bezel.

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
  -c|--core <core_name>
      Use the custom core named <core_name> located in your resources/cores directory.

  -s|--stock-core <stock_core>
      Use a built-in ALU core. This will make your UCE file substantially smaller.
      <stock_core> must be genesis, mame2003plus, mame2010, nes, snes, atari2600,
      or colecovision.

  -n|--no-resize
      Keep bezel and box art images at their original sizes.

  -o|--organize
      Organize UCE files by genre and/or console
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

Of course, the ALU only reads the first subdirectory name when scanning a USB stick for Add-Ons,
so the game will show up under "Maze". Perhaps AtGames will someday enhance the firmware to
allow multi-level navigation, but for now, it's better than nothing.

If you're using a non-MAME core, the UCE will be written to a directory named after the target platform
(e.g., Atari 2600, Genesis, etc.)

## Credit Where Due

This thing was made by [slutzo](https://github.com/slutzo).
