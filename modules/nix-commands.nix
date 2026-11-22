{ inputs, ... } :
{
  flake.nixosModules.nix-commands = ({ pkgs, ... } :
  {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  });
}
