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
                  # Set resolution first
                  ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-A-1 --mode 1920x1080 --rate 60
                  sleep 2

                  # Force Steam scaling
                  export STEAM_FORCE_DESKTOPUI_SCALING=1
                  export GDK_SCALE=1
                  export QT_AUTO_SCREEN_SCALE_FACTOR=0

                  ${pkgs.steam}/bin/steam -bigpicture -fullscreen -steamos &
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
