{ config, lib, ... }:
let
  # GPS: 27
  # LORA: 16
  # SDR: 7
  # Internal USB: 23
  # dh = enabled, dl = disabled
  cfg = config.hardware.uconsole.aio;
  gps = if cfg.gps.enable then "dh" else "dl";
  lora = if cfg.lora.enable then "dh" else "dl";
  sdr = if cfg.sdr.enable then "dh" else "dl";
  usb = if cfg.usb.enable then "dh" else "dl";

  # Helper to create config options with default values
  opt = enable: value: {
    enable = lib.mkDefault enable;
    value = lib.mkDefault value;
  };
in
{
  options.hardware.uconsole.aio = {
    gps.enable = lib.mkEnableOption "Enable HG/AIO GPS module";
    lora.enable = lib.mkEnableOption "Enable HG/AIO LORA module";
    sdr.enable = lib.mkEnableOption "Enable HG/AIO SDR module";
    usb.enable = lib.mkEnableOption "Enable HG/AIO internal USB";
  };
  config = {
    hardware.raspberry-pi.extra-config = lib.concatStringsSep "\n" [
      "[all]"
      "  gpio=27=op,${gps}"
      "  gpio=16=op,${lora}"
      "  gpio=7=op,${sdr}"
      "  gpio=23=op,${usb}"
    ];
    # enable RTC as default
    hardware.raspberry-pi.config = {
      cm4 = {
        base-dt-params.i2c_arm = opt true "on";
        dt-overlays.i2c-rtc = {
          enable = lib.mkDefault true;
          params.pcf85063a = opt true null;
        };
      };
      cm5 = {
        # disable the CM5 internal RTC
        base-dt-params.rtc = opt true "off";
        # i2c_csi_dsi0, remap the i2c0 to GPIO38/39 on CM5
        dt-overlays.i2c-rtc = {
          enable = lib.mkDefault true;
          params = {
            pcf85063a = opt true null;
            i2c_csi_dsi0 = opt true null;
          };
        };
      };
    };
  };
  imports = [
    ./sdr.nix
    ./gps.nix
  ];
}
