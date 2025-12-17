{ pkgs, lib, config, ... }:
let
  cfg = config.services.uc-sleep;
  envFile = pkgs.writeTextFile {
    name = "uc-sleep.env";
    text = (lib.concatStringsSep "\n" cfg.settings);
  };
in
{
  options.services.uc-sleep = {
    enable = lib.mkOption { type = lib.types.bool; default = true; };
    package = lib.mkPackageOption pkgs.oom-hardware "uc-sleep" { };
    settings = lib.mkOption { type = with lib.types; listOf str; default = [ ]; };
  };

  config = lib.mkIf cfg.enable {
    systemd.packages = [ cfg.package ];

    systemd.services."sleep-remap-powerkey" = {
      description = "Sleep Remap PowerKey";
      after = [ "basic.target" ];
      wantedBy = [ "basic.target" ];
      enviroment = envFile;
      serviceConfig = {
        Restart = "always";
        ExecStartPre = "${pkgs.kmod}/bin/modprobe uinput";
        ExecStart = "${cfg.package}/bin/sleep_remap_powerkey";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.services."sleep-power-control" = {
      description = "Sleep Power Control Based on Display and Sleep State";
      after = [ "basic.target" ];
      wantedBy = [ "basic.target" ];
      enviroment = envFile;
      serviceConfig = {
        Restart = "always";
        ExecStart = "${cfg.package}/bin/sleep_power_control";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

  };
}
