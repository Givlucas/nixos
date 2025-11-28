{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
        jovian.nixosModules.default
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

          # Autologin to your user
          services.displayManager.autoLogin = {
            enable = true;
            user = "yourusername";
          };

          # Use a simple desktop that can launch Steam
          services.xserver = {
            enable = true;
            displayManager.lightdm.enable = true;
            desktopManager.xfce.enable = true;  # or another lightweight DE
          };

          # Auto-start Steam in Big Picture
          environment.etc."xdg/autostart/steam-bigpicture.desktop".text = ''
            [Desktop Entry]
            Name=Steam Big Picture
            Exec=steam -bigpicture
            Type=Application
            X-GNOME-Autostart-enabled=true
          '';
        
          boot.kernelParams = [ "radeon.si_support=0" "radeon.cik_support=0" "amdgpu.si_support=1" "amdgpu.cik_support=1" ];

          hardware.graphics = {
            enable = true;
            enable32Bit = true;
          };
          
        })
      ];
    };

  };
}
