# Lucas user configuration
{ config, lib, pkgs, ... }:

let
  cfg = config.userProfiles.lucas;
  userCfg = config.userProfiles;
in
{
  imports = [ inputs.impermanence.homeManagerModules.impermanence ];

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

      # Impermanence for home directory
      home.persistence = lib.mkIf userCfg.persistHome {
        "${userCfg.persistDir}/home/lucas" = {
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
          allowOther = true;
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
