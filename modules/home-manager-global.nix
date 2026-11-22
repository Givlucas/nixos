{ inputs, ... } :
{
  flake.nixosModules.home-manager-global = ({ config, lib, pkgs, ... }:
    let
      cfg = config.userProfiles;
    in
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      
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
