{
  lib,
  self,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  device = "/dev/deskPi";
  opt = enable: value: {
    enable = mkDefault enable;
    value = mkDefault value;
  };
in
{
  imports = [ self.nixosModules.nixpkgs ];

  services.udev.extraRules = ''
    ACTION=="add", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SUBSYSTEM=="tty", SYMLINK+="${builtins.baseNameOf device}"
    ACTION=="add|change", ATTRS{idVendor}=="174c", ATTRS{idProduct}=="55aa", SUBSYSTEM=="scsi_disk", ATTR{provisioning_mode}="unmap"
  '';

  systemd.packages = [ pkgs.oom-hardware.deskpi4-tools ];

  systemd.services."deskpi-safe-shut" = {
    description = "DeskPi Safe-Shutdown Service";
    after = [ "shutdown.target" ];
    before = [ "final.target" ];
    wantedBy = [ "shutdown.target" ];
    conflicts = [ "reboot.target" ];
    unitConfig = {
      ConditionPathExists = device;
      DefaultDependencies = "no";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.oom-hardware.deskpi4-tools}/bin/safeCutOffPower";
      RemainAfterExit = "yes";
      TimeoutSec = "infinity";
      StandardOutput = "tty";
    };
  };

  systemd.services."deskpi" = {
    description = "DeskPi PWM Control Fan Service";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      ConditionPathExists = device;
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.oom-hardware.deskpi4-tools}/bin/pwmFanControl";
      RemainAfterExit = "no";
    };
  };

  hardware.raspberry-pi.config = {
    pi4 = {
      base-dt-params = {
        act_led_trigger = opt true "none";
        pwr_led_trigger = opt true "none";
      };
      options.otg_mode = opt true "1";
      dt-overlays.dwc2 = {
        enable = mkDefault true;
        params.dr_mode = opt true "host";
      };
    };
    all = {
      options.dtdebug = opt false true;
    };
  };
}
