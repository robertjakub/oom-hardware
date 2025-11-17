{ self, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      oom-hardware = import self.inputs.nixpkgs {
        inherit (prev) system;
        config = { inherit (prev.config) allowUnfree allowUnfreePredicate; };
        overlays = [ self.overlays.pkgs ];
      };
    })
  ];
}
