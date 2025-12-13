# Storage module - imports submodules
{ ... }:

{
  imports = [
    ./disko-hybrid.nix
    ./impermanence.nix
  ];
}
