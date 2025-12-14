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

      # Symlink media directories from .core to home
      home.file."Pictures".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.core/Pictures";
      home.file."Videos".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.core/Videos";
      home.file."Music".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.core/Music";

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

      programs.firefox = {
        enable = true;
        profiles.lucas = {
          settings = {
            # Enable vertical tabs
            "sidebar.verticalTabs" = true;
            "sidebar.revamp" = true;

            # Hide horizontal tab bar
            "browser.tabs.tabmanager.enabled" = true;

            # Additional settings for better vertical tabs experience
            "browser.tabs.firefox-view" = false;
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
            autohide = true;
            intellihide = false;
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
            customize = true;
            sigma = 30;
            brightness = 0.6;
            override-background = true;
            force-light-text = true;
          };

          "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
            blur = true;
            customize = true;
            static-blur = true;
            override-background = true;
          };
        };
      };

      home.stateVersion = "25.05";
    });

    # Persist lucas home in impermanence
    environment.persistence = lib.mkIf (config.impermanence.enable or false) {
      "${userCfg.persistDir}".users.lucas = {
        directories = [
          "Documents"
          "Downloads"
          ".core"
          ".config"
          ".local"
          ".ssh"
          ".gnupg"
        ];
      };
    };
  };
}
