{
  description = "Nhu Bao Truong NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #bootspec-secureboot = {
    #  url = "github:DeterminateSystems/bootspec-secureboot/main";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    nur.url = "github:nix-community/NUR";
  };
  outputs = { self, nixpkgs, ... }@attrs: {
      nixosConfigurations = {
        Kappa-Linux = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./configuration.nix
          ];
        };
      };
    };
}
