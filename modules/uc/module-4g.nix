{ pkgs, lib, config, ... }:
let
  cfg = config.hardware.uc-module-4g;

  uconsole-4g = pkgs.writeShellScriptBin "uconsole-4g" ''
    function tip {
      echo "use mmcli -L to see 4G modem or not"
    }

    function enable4g {
      echo "Power on 4G module on uConsole cm4"
      ${cfg.rpi-utils}/bin/pinctrl set 24 op dh
      ${cfg.rpi-utils}/bin/pinctrl set 15 op dh
      ${pkgs.coreutils}/bin/sleep 5
      ${cfg.rpi-utils}/bin/pinctrl set 15 dl
      echo "waiting..."
      ${pkgs.coreutils}/bin/sleep 13
      echo "done"
    }

    function disable4g {
      echo "Power off 4G module"
      ${cfg.rpi-utils}/bin/pinctrl set 24 op dl
      ${cfg.rpi-utils}/bin/pinctrl set 24 dh
      ${pkgs.coreutils}/bin/sleep 3
      ${cfg.rpi-utils}/bin/pinctrl set 24 dl
      ${pkgs.coreutils}/bin/sleep 20
      echo "Done"
    }

    if [ "$#" -ne 1 ] ; then
      echo "$0: enable/disable"
      exit 3
    fi

    if [ $1 == "enable" ]; then
      enable4g;
      tip;
    fi

    if [ $1 == "disable" ]; then
      disable4g
      tip;
    fi
  '';
in
{
  options.hardware.uc-module-4g = {
    enable = lib.mkOption { type = lib.types.bool; default = true; };
    rpi-utils = lib.mkPackageOption pkgs.rpi "raspberrypi-utils" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ uconsole-4g ];
  };
}
