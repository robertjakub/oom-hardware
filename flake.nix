{
  description = "Flake for oom's hardware support on NixOS";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-raspberrypi.url = "github:robertjakub/nixos-raspberrypi/develop";
    nixos-raspberrypi.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixos-raspberrypi,
      ...
    }@inputs:
    let
      rpiSystems = [
        "aarch64-linux"
        "armv7l-linux"
        "armv6l-linux"
      ];
      allSystems = nixpkgs.lib.systems.flakeExposed;
      forSystems = systems: f: nixpkgs.lib.genAttrs systems (system: f system);
      # te
      mkRpiPkgs =
        nixpkgs: system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.pkgs ];
        };
      mkLegacyPackagesFor = nixpkgs: forSystems rpiSystems (mkRpiPkgs nixpkgs);
    in
    {
      devShells = forSystems allSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              alejandra
              nixfmt
              nixpkgs-fmt
            ];
          };
        }
      );

      nixosConfigurations =
        let
          mkuCNixOSSD =
            modules:
            nixos-raspberrypi.lib.nixosSystem {
              system = "aarch64-linux";
              specialArgs = inputs // {
                uC-config = self;
              };
              trustCaches = false;
              modules = [
                "${nixpkgs}/nixos/modules/profiles/base.nix"
                "${nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
                "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"

                (
                  {
                    config,
                    lib,
                    pkgs,
                    modulesPath,
                    ...
                  }:
                  {
                    disabledModules = [ (modulesPath + "/rename.nix") ];
                    image.baseName =
                      let
                        cfg = config.boot.loader.raspberryPi;
                      in
                      lib.mkOverride 40 "nixos-uc-cm${cfg.variant}";
                    boot.loader.raspberryPi.bootloader = "kernel";
                    boot.consoleLogLevel = 7;
                    users.users.root.initialPassword = ""; # FIXME
                    sdImage = {
                      firmwareSize = 1024;
                      firmwarePartitionID = "0x2175794e";
                      compressImage = false; # FIXME
                      populateFirmwareCommands = ''
                        ${config.boot.loader.raspberryPi.firmwarePopulateCmd} -c ${config.system.build.toplevel} -f ./firmware
                      '';
                      populateRootCommands = ''
                        # create with a mount point for FIRMWARE
                        mkdir -p ./files/boot/firmware
                        ${config.boot.loader.raspberryPi.bootPopulateCmd} -c ${config.system.build.toplevel} -b ./files/boot
                      '';
                    };
                    console = {
                      earlySetup = true;
                      font = "ter-v32n";
                      packages = with pkgs; [ terminus_font ];
                    };
                    environment.systemPackages = with pkgs; [
                      wirelesstools
                      iw
                      gitMinimal
                    ];
                    systemd.services.NetworkManager.wantedBy = lib.mkOverride 50 [ ];
                    systemd.services.sshd.wantedBy = lib.mkOverride 50 [ ];
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
                    system.nixos.tags =
                      let
                        cfg = config.boot.loader.raspberryPi;
                      in
                      [ "uc-cm${cfg.variant}" ];
                    system.stateVersion = "25.11";
                    system.defaultChannel = "https://nixos.org/channels/nixos-unstable";
                    systemd.services."serial-getty@ttyS0".enable = false;
                    imports = [
                      (lib.mkAliasOptionModule [ "environment" "checkConfigurationOptions" ] [ "_module" "check" ])
                    ];
                    nix.settings.experimental-features = [
                      "nix-command"
                      "flakes"
                    ];
                  }
                )
              ]
              ++ modules;
            };
        in
        {
          uc-cm4-sdimage = mkuCNixOSSD [
            (
              {
                config,
                pkgs,
                lib,
                nixos-raspberrypi,
                ...
              }:
              {
                imports =
                  (with nixos-raspberrypi.nixosModules; [
                    raspberry-pi-4.base
                    raspberry-pi-4.bluetooth
                  ])
                  ++ (with self.nixosModules; [
                    uc.kernel
                    uc.configtxt
                    uc.base-cm4
                  ]);
              }
            )
          ];
          uc-cm5-sdimage = mkuCNixOSSD [
            (
              {
                config,
                pkgs,
                lib,
                nixos-raspberrypi,
                ...
              }:
              {
                imports =
                  (with nixos-raspberrypi.nixosModules; [
                    raspberry-pi-5.base
                  ])
                  ++ (with self.nixosModules; [
                    uc.kernel
                    uc.configtxt
                    uc.base-cm5
                  ]);
              }
            )
          ];
        };

      nixosModules = {
        nixpkgs =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          import ./modules/nixpkgs.nix {
            inherit
              config
              lib
              pkgs
              self
              ;
          };
        uc = {
          kernel = import modules/uc/kernel.nix;
          configtxt = import modules/uc/configtxt.nix;
          base-cm4 = import modules/uc/base-cm4.nix;
          base-cm5 = import modules/uc/base-cm5.nix;
          aio = import modules/uc/aio;
          sleep =
            {
              lib,
              pkgs,
              config,
              ...
            }:
            import modules/uc/uc-sleep.nix { inherit lib pkgs config; };
          module-4g =
            {
              lib,
              pkgs,
              config,
              ...
            }:
            import modules/uc/module-4g.nix { inherit lib pkgs config; };
        };
        deskpi4 = { lib, pkgs, ... }: import modules/deskpi4 { inherit lib pkgs self; };
      };

      uCimages =
        let
          nixos = self.nixosConfigurations;
          mkImage = nixosConfig: nixosConfig.config.system.build.sdImage;
        in
        {
          cm4 = mkImage nixos.uc-cm4-sdimage;
          cm5 = mkImage nixos.uc-cm5-sdimage;
        };

      overlays = {
        pkgs = import ./overlays/pkgs.nix;
      };

      legacyPackages = mkLegacyPackagesFor nixpkgs;

      packages = forSystems rpiSystems (
        system:
        let
          pkgs = self.legacyPackages.${system};
        in
        {
          deskpi4-tools = pkgs.deskpi4-tools;
          uc-sleep = pkgs.uc-sleep;
        }
      );

    };
}
