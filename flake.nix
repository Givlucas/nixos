{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    jovian.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, disko, self, jovian, ... }:
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
    # Builds a live image based on the custom configruation in this flake
    packages.x86_64-linux.live = self.nixosConfigurations.live.config.system.build.isoImage;

    nixosConfigurations = rec {
      live = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
          ./modules/broadcom.nix
          ({...}: {
            networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
          })
        ];
      };

    
      base = mkConfig [] baseConfigs;

      steam-machine = extendConfig base [
        ./modules/broadcom.nix
        jovian.nixosModules.default
        ({ pkgs, ... }: {
          networking.hostName = "steam-machine"; # Define your hostname.

          base-disk.device = "/dev/sda";

          jovian.steam.enable = true;
					jovian.steam.autoStart = true;

					programs.steam.enable = true;
          
          users.users.gamer = {
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
