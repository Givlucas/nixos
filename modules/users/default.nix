# Users module - home-manager integration
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.userProfiles;
in
{
  imports = [
    ./lucas.nix
    ./isa.nix
  ];

  options.userProfiles = {
    enableHomeManager = lib.mkEnableOption "home-manager integration";

    persistHome = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable home directory persistence (for impermanence setups)";
    };

    persistDir = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "Persistence directory for impermanence";
    };
  };

  config = lib.mkIf cfg.enableHomeManager {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs; };
    };
  };
}
