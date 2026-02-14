{ config, lib, ... }:
let
  cfg = config.hardware.uconsole.aio;
  # Helper to create config options with default values
  opt = enable: value: {
    enable = lib.mkDefault enable;
    value = lib.mkDefault value;
  };
in
{
  options.hardware.uconsole.aio = {
    gps.device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/ttyAMA0";
      description = "AIO GPS device: ttyAMA0 for CM5, ttyS0 for CM4";
    };
  };

  config = lib.mkIf cfg.gps.enable {
    hardware.raspberry-pi.config = {
      cm4.options.enable_uart = opt true 1;
      cm5.base-dt-params.uart0 = opt true null;
    };

    systemd.services."serial-getty@ttyS0".enable = lib.mkForce false;
    systemd.services."serial-getty@ttyAMA0".enable = lib.mkForce false;

    services.gpsd = {
      enable = true;
      devices = [
        cfg.gps.device
        "/dev/pps0"
      ];
    };
  };
}
