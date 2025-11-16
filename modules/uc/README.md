# uCImages

## uCimages: building

> [!TIP]
> Images use new generational bootloader for uC-CM4/5 by default.
> To keep that in your configuration, set `boot.loader.raspberryPi.bootloader = "kernel"`.

SD image can be built with:

```
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
