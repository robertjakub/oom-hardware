# uConsole module

ClockworkPi uConsole support for NixOS.

## Usage

see [example flake](example/flake.nix)

## uCimages: building

> [!TIP]
> Images use new generational bootloader for uC-CM4/5 by default.
> To keep that in your configuration, set `boot.loader.raspberryPi.bootloader = "kernel"`.

SD image can be built with:

```
cd <flake-main-dir>
[...]
nix build .#uCimages.cm4
nix build .#uCimages.cm5
```

## uCimages: WiFi connectivity
```
# systemctl start NetworkManager.service
# systemctl start sshd.service
# nmtui
[...]
```

## overlays \[WIP\]
```
clockworkpi-uconsole-cm5
  	no_rp1eth # true: disable cm5 ethernet
    no_sound_switch = # true: disable simple sound switch
    energy_full_design_uwh # default "24790000", battery capacity
    charge_full_design_uah # default "6700000", battery capacity
```

```
clockworkpi-uconsole
  	nogenet # true: disable cm4 ethernet (FIXME)
   	nopcie0 # true: disable pcie (FIXME)
    no_sound_switch = # true: disable simple sound switch
    energy_full_design_uwh # default "24790000", battery capacity
    charge_full_design_uah # default "6700000", battery capacity
```

## ToDo

- 4G module script
- kernel overlays cleanup
- documentation
- tests...
