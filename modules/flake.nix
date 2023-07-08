{
  description =
    "A NixOS FHS+LSB compatibility layer for containers and VMs. Not recommended on hosts.";

  outputs = { self }: {

    nixosModules = { fhs = import ./fhs.nix; };
  };
}
