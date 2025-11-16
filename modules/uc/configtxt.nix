{ lib, ... }:
let
  inherit (lib) mkDefault;
  opt = enable: value: { enable = mkDefault enable; value = mkDefault value; };
in
{
  hardware.raspberry-pi.extra-config = ''
    [all]
    gpio=10=ip,np
    gpio=11=op,dh
  '';

  hardware.raspberry-pi.config = {
    cm4 = {
      options = {
        otg_mode = { enable = false; };
        over_voltage = opt true "6";
        arm_freq = opt true "2000";
        gpu_freq = opt true "750";
        gpu_mem = opt true "256";
        force_turbo = opt true "1";
      };
      base-dt-params = {
        spi = opt true "on";
      };
      dt-overlays = {
        clockworkpi-uconsole = {
          enable = mkDefault true;
          params = { };
        };
        clockworkpi-uconsole-sound-switch = {
          enable = mkDefault true;
          params = { };
        };
        clockworkpi-uconsole-disable-genet = {
          enable = mkDefault true;
          params = { };
        };
        clockworkpi-uconsole-disable-pcie = {
          enable = mkDefault true;
          params = { };
        };
        dwc2 = {
          enable = true;
          params = {
            dr_mode = opt true "host";
          };
        };
        vc4-kms-v3d-pi4 = {
          enable = mkDefault true;
          params = {
            cma-384 = opt true "on";
            nohdmi1 = opt true "off";
          };
        };
      };
    };
    cm5 = {
      base-dt-params = {
        pciex1 = opt true "off";
      };
      dt-overlays = {
        clockworkpi-uconsole-cm5 = {
          enable = mkDefault true;
          params = {
            no_rp1eth = opt false true;
            no_sound_switch = opt false true;
            energy_full_design_uwh = opt false "24790000";
            charge_full_design_uah = opt false "6700000";
          };
        };
        vc4-kms-v3d-pi5 = {
          enable = mkDefault true;
          params = {
            cma-384 = opt true "on";
            nohdmi1 = opt true "off";
          };
        };
      };
    };
    all = {
      options = {
        ignore_lcd = opt true true;
        enable_uart = opt true true;
        uart_2ndstage = opt true true;
        disable_audio_dither = opt true 1;
        pwm_sample_bits = opt true 20;
        dtdebug = opt true true;
      };
      # Base DTB parameters
      base-dt-params = {
        ant2 = opt true "on";
        audio = opt true "on";
      };
      dt-overlays = {
        vc4-kms-v3d = { enable = false; };
        audremap = {
          enable = mkDefault true;
          params = {
            pin_12_13 = opt true "on";
          };
        };
      };
    };
  };
}
