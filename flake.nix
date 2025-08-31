{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, disko, ... }: rec {

    nixosConfigurations.base = args: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = args.modules ++ [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./modules/configuration.nix
        ./modules/hardware-configuration.nix # required and overwritten by nixos-anywhere
        ./modules/base-disk-config.nix
        disko.nixosModules.disko
      ];
    };

    nixosConfigurations.tv = nixosConfigurations.base {
      modules = [
        ({
          networking.hostName = "tv";
        })
      ];
    };

  };
}
