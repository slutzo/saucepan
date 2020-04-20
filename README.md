# saucepan
Create a UCE file by pulling source files from various locations

## Initial Configuration

### Resource directories

In order for the script to run, four directories need to exist in the resources directory.
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

If you already have directories located elsewhere that meet these descriptions,
you can simply create links to those directories.  For example, if you have an
existing ROMs directory at "/MAME/roms", you can create a link with the
following command:

```
$ ln -s /MAME/roms ./roms
```

### Default box art and bezel

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
