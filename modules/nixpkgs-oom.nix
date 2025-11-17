{ self, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      oom-hardware = import self.inputs.nixpkgs {
        system = prev.stdenv.hostPlatform.system;
        config = { inherit (prev.config) allowUnfree allowUnfreePredicate; };
        overlays = [ self.overlays.pkgs ];
      };
    })
  ];
}
