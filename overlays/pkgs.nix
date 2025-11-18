self: super: {
  # final: prev:
  deskpi4-tools = super.callPackage ../pkgs/deskpi4-tools.nix { };
  raspberrypi-eeprom = super.callPackage ../pkgs/raspberrypi-eeprom.nix { };
}
