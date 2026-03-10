{
  description = "Example flake for uConsole";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-raspberrypi.url = "github:robertjakub/nixos-raspberrypi/develop"; # stick with my branch
    nixos-raspberrypi.inputs.nixpkgs.follows = "nixpkgs";
    oom-hardware.url = "github:robertjakub/oom-hardware/devel";
    oom-hardware.inputs.nixpkgs.follows = "nixpkgs";
    oom-hardware.inputs.nixos-raspberrypi.follows = "nixos-raspberrypi";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {

      nixosConfigurations.default = inputs.nixos-raspberrypi.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = inputs;
        trustCaches = false;
        modules = [
          # inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base
          # inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.bluetooth
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
          inputs.oom-hardware.nixosModules.uc.kernel
          inputs.oom-hardware.nixosModules.uc.configtxt
          # inputs.oom-hardware.nixosModules.uc.base-cm4
          inputs.oom-hardware.nixosModules.uc.base-cm5
          (
            {
              config,
              lib,
              pkgs,
              ...
            }:
            {
              boot.loader.raspberry-pi.bootloader = "kernel"; # default for new installation
              boot.consoleLogLevel = 7;
              users.users.root.initialPassword = ""; # FIXME
              console = {
                earlySetup = true;
                font = "ter-v32n";
                packages = with pkgs; [ terminus_font ];
              };
              fileSystems = {
                "/boot/firmware" = {
                  device = "/dev/disk/by-label/FIRMWARE";
                  fsType = "vfat";
                  options = [ "noatime" ];
                };
                "/" = {
                  device = "/dev/disk/by-label/NIXOS_SD";
                  fsType = "ext4";
                  options = [ "noatime" ];
                };
              };
              environment.systemPackages = with pkgs; [
                wirelesstools
                iw
                gitMinimal
              ];
              networking.networkmanager.enable = true;
              programs.mosh.enable = true;
              services.openssh = {
                enable = true;
                settings = {
                  KexAlgorithms = [
                    "sntrup761x25519-sha512"
                    "mlkem768x25519-sha256"
                    "curve25519-sha256@libssh.org"
                  ];
                  KbdInteractiveAuthentication = false;
                  PasswordAuthentication = true;
                  PermitRootLogin = "yes"; # FIXME
                  UseDns = false;
                };
              };
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              systemd.services."serial-getty@ttyS0".enable = false; # there is no serial console? am I right?
              system.stateVersion = config.system.nixos.release;
              system.defaultChannel = "https://nixos.org/channels/nixos-unstable";
            }
          )
        ];
      };
    };
}
