# TODO: Finish this

{inputs, ... }:
{
  flake.nixosModules.accounts = ({lib, config, ...}:
    let
      cfg = config.accounts;
    {
      imports = [
        self.nixosModules.home-manager-global
      ];
      
      options.accounts = {
        accounts = lib.mkOption {
          type = lib.types.attrs;
        };  
      };
      config = {};
      
    });
}
