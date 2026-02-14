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
  config = lib.mkIf cfg.lora.enable {
    hardware.raspberry-pi.config = {
      cm4 = {
        base-dt-params.spi = opt true "on";
        dt-overlays.spi1-1cs = {
          enable = lib.mkDefault true;
          params = { };
        };
      };
      cm5.dt-overlays.spi1-1cs = {
        enable = lib.mkDefault true;
        params = { };
      };
    };
  };
}
