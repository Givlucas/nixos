{ inputs, ... } :
{
  flake.nixosModules.home-manager-global = ({ config, lib, pkgs, inputs, ... }:
    let
      cfg = config.userProfiles;
    in
    {
      config = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "bak";
          extraSpecialArgs = { inherit inputs; };
        };
      };
    });
}
