# Isa user configuration
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.userProfiles.isa;
  userCfg = config.userProfiles;
in
{
  options.userProfiles.isa = {
    enable = lib.mkEnableOption "isa user account";
  };

  config = lib.mkIf cfg.enable {
    # System user
    users.users.isa = {
      isNormalUser = true;
      extraGroups = [ "dialout" "plugdev" ];
      useDefaultShell = true;
    };

    # Home-manager configuration
    home-manager.users.isa = lib.mkIf userCfg.enableHomeManager ({ config, pkgs, ... }: {
      home.username = "isa";
      home.homeDirectory = "/home/isa";

      home.packages = with pkgs; [
        # Development
        vscode
        (python3.withPackages (python-pkgs: with python-pkgs; [
          pip
          jupyter
          notebook
          ipykernel
          numpy
        ]))

        # Design & Productivity
        xournalpp
        libreoffice

        # Communication & Web
        firefox
        discord
        spotify

        # Gaming
        prismlauncher
        gamescope
      ];

      # Impermanence for home directory
      home.persistence = lib.mkIf userCfg.persistHome {
        "${userCfg.persistDir}/home/isa" = {
          directories = [
            "Documents"
            "Downloads"
            "Pictures"
            "Music"
            "Videos"
            ".config"
            ".local"
          ];
          allowOther = true;
        };
      };

      home.stateVersion = "25.05";
    });

    # Persist isa home in impermanence
    environment.persistence = lib.mkIf (config.impermanence.enable or false) {
      "${userCfg.persistDir}".users.isa = {
        directories = [
          "Documents"
          "Downloads"
          "Pictures"
          "Music"
          "Videos"
          ".config"
          ".local"
        ];
      };
    };
  };
}
