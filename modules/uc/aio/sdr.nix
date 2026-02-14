{ config, lib, ... }:
let
  cfg = config.hardware.uconsole.aio;
in
{
  config = lib.mkIf cfg.sdr.enable {
    boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];
  };
}
