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
--stock-core genesis|mame2003plus|mame2010|nes|snes|atari2600
```

This will configure your UCE to use a built-in core so it doesn't have bundle one into
the file, which means much smaller file sizes.

## Initial Configuration

### Resource Directories

In order for the script to run, four directories must exist in the resources directory.
They are:

* bezels - Contains 1280x720 bezels in PNG format with the same
  names as the associated ROMs.
* boxart - Contains box art in PNG format with the same names
  as the associated ROMs. The art can be any size, but 222x306 is recommended
  in order to keep UCE file size small.
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

### Default Box Art and Bezel

When no custom box art is found, the script will use the default box art located at
defaults/boxart.png. If you want to set your own default, just copy it over the
existing file.

When no custom bezel is found, the script will use the default bezel located at
defaults/bezel.png. Since not everybody loves bezels, there is no default provided.
Feel free to add your own, or leave it missing if you prefer no bezel.

## Usage

```
saucepan.sh [--core <core_name>|--stock-core <stock_core>] <game_name> <rom_name>

  --core <core_name>
      Use the custom core named <core_name> located in your resources/cores directory.

  --stock-core <stock_core>
      Use a built-in ALU core. This will make your UCE file substantially smaller.
      <stock_core> must be genesis, mame2003plus, mame2010, nes, snes, or atari2600.

  <game_name>
      Specifies the name you want to appear on the ALU Add-On menu.
      Be sure to put the name in quotation marks if it has spaces in it.

  <rom_name>
      Specifies the base name of a ROM file in the resources/roms directory.
      Note that you should not include the file extension.
      If you have a custom box art and/or bezel, they should be located at
          resources/boxart/<rom_name>.png and resources/bezels/<rom_name>.png respectively.
```

Note that if you don't specify any core on the command line, the script will attempt to
use resources/cores/mame2003_plus_libretro.so.

## Credit Where Due

This thing was made by [slutzo](https://github.com/slutzo).
