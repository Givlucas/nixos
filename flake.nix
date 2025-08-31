{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, disko, ... }:
  let
    baseConfigs = [
      ./modules/configuration.nix
      ./modules/hardware-configuration.nix # required and overwritten by nixos-anywhere
      ./modules/base-disk-config.nix
      disko.nixosModules.disko
    ];

    mkConfig = baseModules: extraModules: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = baseModules ++ extraModules;
    };
    
    # Function that extends an existing configuration
    extendConfig = baseConfig: extraModules: mkConfig 
      baseConfig._module.args.modules 
      extraModules;
  in
  {
    nixosConfigurations = rec {
      base = mkConfig [] baseConfigs;

      tv = extendConfig base [
        ({ ... }: {
          networking.hostName = "working"; # Define your hostname.
          services = {
            desktopManager.plasma5.bigscreen.enable = true;
            displayManager.sddm.enable = true;
            displayManager.sddm.wayland.enable = true;
          };
        })
      ];
    };

  };
}
