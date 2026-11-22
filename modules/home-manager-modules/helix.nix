{ inputs, ... } :
{
  flake.homeModules.helix = {
      programs.helix = {
        enable = true;
        settings = {
          theme = "base16_default";
          editor = {
            rulers = [ 80 120 ];
            bufferline = "multiple";
            soft-wrap.enable = true;
            true-color = true;
          };
        };
      };
    };
}

