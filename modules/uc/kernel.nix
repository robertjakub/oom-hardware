{ ... }:
let
  patches = [
    ./patches/0001-configs.patch
    ./patches/0002-panel.patch
    ./patches/0003-power.patch
    ./patches/0004-backlight.patch
    ./patches/0005-overlays.patch
    ./patches/0006-bcm2835-staging.patch
    ./patches/0007-simple-switch.patch
  ];
in
{
  boot.initrd.kernelModules = [
    "ocp8178_bl"
    "panel_cwu50"
    "vc4"
  ];

  boot.kernelPatches =
    (builtins.map
      (patch: { name = patch + ""; patch = patch; })
      patches
    )
    ++ [{
      name = "uc-config";
      patch = null;
      structuredExtraConfig = { };
    }];
}
