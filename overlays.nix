{ pkgs, ... }:

{
  # Overlay
  nixpkgs.overlays = [
    (self: super: {
      ibus-engines.bamboo = super.ibus-engines.bamboo.overrideAttrs
        (oldAttrs: rec {
          version = "0.8.2-RC18";
          src = super.fetchFromGitHub {
            owner = "BambooEngine";
            repo = oldAttrs.pname;
            rev = "v${version}";
            sha256 = "sha256-5FSGPUJtUdYyeqJenvKaMIJcvon91I//62fnTCXcdig=";
          };
        });
    })
  ];
}
