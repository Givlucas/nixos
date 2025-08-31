{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, disko, ... }: {

    # Please replace my-nixos with your hostname
    nixosConfigurations.base = args: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = args.modules ++ [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./modules/configuration.nix
        ./modules/hardware-configuration.nix
        ./modules/disk-config.nix
        disko.nixosModules.disko
      ];
    };
  };
}
