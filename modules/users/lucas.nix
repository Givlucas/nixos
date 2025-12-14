# Lucas user configuration
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.userProfiles.lucas;
  userCfg = config.userProfiles;
in
{

  options.userProfiles.lucas = {
    enable = lib.mkEnableOption "lucas user account";
  };

  config = lib.mkIf cfg.enable {
    # System user
    users.users.lucas = {
      isNormalUser = true;
      extraGroups = [ "wheel" "dialout" "plugdev" "docker" "libvirtd" ];
      useDefaultShell = true;
    };

    # Home-manager configuration
    home-manager.users.lucas = lib.mkIf userCfg.enableHomeManager ({ config, pkgs, ... }: {
      imports = [ inputs.impermanence.homeManagerModules.impermanence ];

      home.username = "lucas";
      home.homeDirectory = "/home/lucas";

      home.file.".config/nixpkgs/config.nix".text = ''
        {
          allowUnfree = true;
        }
      '';

      home.packages = with pkgs; [
        # Development
        claude-code
        android-studio
        android-tools
        arduino
        kicad
        kotlin-language-server
        nil
        nixos-anywhere

        # Design & Media
        inkscape
        gimp
        freecad
        ffmpeg
        dvdauthor

        # Productivity
        obsidian
        calibre
        libreoffice
        xournalpp
        anki-bin

        # Communication & Web
        google-chrome
        firefox
        discord
        tor-browser
        deluge

        # Gaming
        prismlauncher
        gamescope
        spotify

        # Radio & Hardware
        sdrpp
        betaflight-configurator
        splat

        # Shell & Theming
        oh-my-zsh
        adw-gtk3
        raleway

        # GNOME utilities
        gnome-tweaks

        # GNOME Extensions
        gnomeExtensions.compiz-alike-magic-lamp-effect
        gnomeExtensions.compiz-windows-effect
        gnomeExtensions.tiling-shell
        gnomeExtensions.dash-to-dock
        gnomeExtensions.blur-my-shell
        gnomeExtensions.hide-top-bar
        gnomeExtensions.rounded-window-corners-reborn
        gnomeExtensions.just-perfection
        gnomeExtensions.light-style
      ];

      programs.helix = {
        enable = true;
        settings = {
          theme = "base16_default";
          editor = {
            rulers = [ 80 120 ];
            bufferline = "multiple";
            soft-wrap.enable = true;
          };
        };
      };

      # GNOME dconf settings
      dconf = {
        enable = true;

        settings = {
          # Enable GNOME Shell extensions
          "org/gnome/shell" = {
            disable-user-extensions = false;

            enabled-extensions = with pkgs.gnomeExtensions; [
              compiz-alike-magic-lamp-effect.extensionUuid
              compiz-windows-effect.extensionUuid
              tiling-shell.extensionUuid
              dash-to-dock.extensionUuid
              blur-my-shell.extensionUuid
              hide-top-bar.extensionUuid
              rounded-window-corners-reborn.extensionUuid
              just-perfection.extensionUuid
              light-style.extensionUuid
            ];
          };

          # Dash to Dock configuration
          "org/gnome/shell/extensions/dash-to-dock" = {
            dock-position = "BOTTOM";
            dock-fixed = false;
            intellihide = true;
            dash-max-icon-size = 48;
            show-trash = false;
            show-mounts = false;
            transparency-mode = "DYNAMIC";
            background-opacity = 0.8;
            click-action = "MINIMIZE";
          };

          # Blur My Shell configuration
          "org/gnome/shell/extensions/blur-my-shell" = {
            brightness = 0.6;
            sigma = 30;
          };

          "org/gnome/shell/extensions/blur-my-shell/panel" = {
            blur = true;
            sigma = 30;
          };

          "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
            blur = true;
            static-blur = true;
          };
        };
      };

      # Impermanence for home directory
      # NOTE: Disabled home-manager level persistence to avoid conflict with system-level
      # persistence (environment.persistence below). System-level persistence already
      # handles all these directories.
      # home.persistence = lib.mkIf userCfg.persistHome {
      #   "${userCfg.persistDir}/home/lucas" = {
      #     directories = [
      #       "Documents"
      #       "Downloads"
      #       "Pictures"
      #       "Music"
      #       "Videos"
      #       "Projects"
      #       ".config"
      #       ".local"
      #       ".ssh"
      #       ".gnupg"
      #     ];
      #     allowOther = true;
      #   };
      # };

      home.stateVersion = "25.05";
    });

    # Persist lucas home in impermanence
    environment.persistence = lib.mkIf (config.impermanence.enable or false) {
      "${userCfg.persistDir}".users.lucas = {
        directories = [
          "Documents"
          "Downloads"
          "Pictures"
          "Music"
          "Videos"
          "Projects"
          ".config"
          ".local"
          ".ssh"
          ".gnupg"
        ];
      };
    };
  };
}
