{inputs, ...}:
{
  flake.homeModules.git = ({lib, config, ...}:
    let
      cfg = config.git;
    in
    {
    options.git = {
      user.name = lib.mkOption {
        type = lib.types.str;
      };

      user.email = lib.mkOption {
        type = lib.types.str;
      };

      identityFile = lib.mkOption {
        type = lib.types.str;
      };
        
    };

    config = {
      programs.git = {
        enable = true;
        settings.user.name = cfg.user.name;
        settings.user.email = cfg.user.email;
      };

      programs.ssh = {
        enable = true;
        settings = {
          "github.com" = {
            HostName = "github.com";
            User = "git";
            IdentityFile = cfg.identityFile;
          };
        };
      };

    };
  });
}
