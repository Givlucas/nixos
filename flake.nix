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
        ({ pkgs, ... }: {
          networking.hostName = "tv"; # Define your hostname.
          
          # # Enable the X11 windowing system.
          services.xserver.enable = true;
          services.xserver.displayManager.gdm.enable = true;
          services.xserver.desktopManager.gnome.enable = true;
          services.xserver.desktopManager.gnome.extraGSettingsOverridePackages = [ pkgs.mutter ];
          services.xserver.desktopManager.gnome.extraGSettingsOverrides = "
            [org.gnome.mutter]
            edge-tiling = true
          ";

          users.users.tvuser = {
            isNormalUser = true;
            extraGroups = [ "dialout" "plugdev"]; # Enable ‘sudo’ for the user.
            useDefaultShell = true;
            packages = [
              pkgs.deluge
              pkgs.tor-browser-bundle-bin
              pkgs.firefox
              pkgs.spotify
            ];
          };
          
        })
      ];
    };

  };
}
