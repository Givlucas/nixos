{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    # Please replace my-nixos with your hostname
    nixosConfigurations.zephyrus = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";


          home-manager.users.lucas = {config, pkgs, lib, ...} :
           {

          
            home.file.".config/nixpkgs/config.nix".text = ''
              {
                allowUnfree = true;
              }
            '';
            home.username = "lucas";
            home.packages = [
              pkgs.claude-code
              pkgs.android-studio
              pkgs.inkscape
              pkgs.obsidian
              pkgs.splat
              pkgs.calibre
              pkgs.gimp
              pkgs.raleway
              pkgs.google-chrome
              pkgs.deluge
              pkgs.tor-browser
              pkgs.freecad
              pkgs.firefox
              pkgs.oh-my-zsh
              pkgs.discord
              pkgs.libreoffice
              pkgs.prismlauncher
              pkgs.adw-gtk3
              pkgs.betaflight-configurator
              pkgs.arduino
              pkgs.kicad
              pkgs.dvdauthor
              pkgs.spotify
              pkgs.android-tools
              pkgs.sdrpp
              pkgs.gamescope
              pkgs.xournalpp
              pkgs.kotlin-language-server
              pkgs.anki-bin
              pkgs.nixos-anywhere
            ];

            programs.helix = {
              enable = true;
              settings = {
                theme = "base16_default";
                editor = {
                  rulers = [80 120];
                  bufferline = "multiple";
                  soft-wrap.enable = true;
                };
              };
            };

            
            home.stateVersion = "25.05";
          };

        }
      ];
    };
  };
}
