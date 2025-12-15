self: super: {
  # final: prev:
  deskpi4-tools = super.callPackage ../pkgs/deskpi4-tools.nix { };
  uc-sleep = super.callPackage ../pkgs/uc-sleep.nix { };
}
