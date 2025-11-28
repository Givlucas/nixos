{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, disko, self, ... }:
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
          ({pkgs, ...}: {
            networking.wireless = {
              enable = true;
              networks = {
                "ORBI60" = {
                  psk = "calmfire650";
                };
              };
            };
          })
        ];
      };

    
      base = mkConfig [] baseConfigs;

      steam-machine = extendConfig base [
        ./modules/broadcom.nix
        ({ pkgs, lib, ... }: {
          networking.hostName = "steam-machine"; # Define your hostname.

          base-disk.device = "/dev/sda";
          
          users.users.gamer = {
            isNormalUser = true;
            extraGroups = [ "dialout" "plugdev"]; # Enable ‘sudo’ for the user.
            useDefaultShell = true;
            packages = [
              pkgs.deluge
              pkgs.tor-browser
              pkgs.firefox
              pkgs.spotify
            ];
          };

          # Generic steam deck-specific configs that are reasonable for other people to refer to / use
          # Enable Steam
          programs.steam.enable = true;
          programs.steam.gamescopeSession.enable = false;
          programs.gamescope.enable = true;

          # Autologin to your user
          services.displayManager.autoLogin = {
            enable = true;
            user = "gamer";
          };

          services.xserver = {
            enable = true;
            displayManager.lightdm.enable = true;
  
            displayManager.session = [
              {
                manage = "desktop";
                name = "steam-big-picture";
                start = ''
                  # Performance environment variables
                  export MESA_GL_VERSION_OVERRIDE=4.5
                  export RADV_PERFTEST=gpl,rt
                  export mesa_glthread=true
                  export AMD_VULKAN_ICD=RADV
                  export DXVK_ASYNC=1
          
                  # Disable compositing overhead
                  export STEAM_DISABLE_COMPOSITING=1
          
                  ${pkgs.steam}/bin/steam -bigpicture &
                  waitPID=$!
                '';
              }
            ];
  
            displayManager.defaultSession = "steam-big-picture";
          };
        
        })
      ];
    };

  };
}
