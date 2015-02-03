Aluin-PiSNES
============

This is an SNES emulator for Raspberry Pi based on [PiSNES](https://code.google.com/p/pisnes) with a few fixes/additions:

* Dpad buttons can now be bound with UP_1, DOWN_2, etc
* Player 2 controls can now be bound to a joystick
* Added Playstation 3 controller support

The snes9x.cfg configuration file is currently set to PS3 controls, but can be modified to work with XBox or other controllers. Be sure to read the comments in the config file for instructions on how to exit, quickload, and quicksave.

Installation
============

Clone this repo into the destination directory (e.g., /opt/retropie/emulators/aluin-pisnes/) and run 'make'. For Retropie, be sure to modify the Super Nintendo section in /etc/emulationstation/es_systems.cfg to point to the snes9x binary created with this code. See below for an example.

```
<system>
    <fullname>Super Nintendo</fullname>
    <name>snes</name>
    <path>~/RetroPie/roms/snes</path>
    <extension>.smc .sfc .fig .swc .SMC .SFC .FIG .SWC</extension>
    <!-- <command>/opt/retropie/supplementary/runcommand/runcommand.sh 4 "/opt/retropie/emulators/RetroArch/installdir/bin/retroarch -L /opt/retropie/emulatorcores/pocketsnes-libretro/libretro.so --config /opt/retropie/configs/all/retroarch.cfg --appendconfig /opt/retropie/configs/snes/retroarch.cfg   %ROM%"</command> -->
    <command>/opt/retropie/emulators/aluin-pisnes/snes9x %ROM%</command>
    <platform>snes</platform>
    <theme>snes</theme>
  </system>
```