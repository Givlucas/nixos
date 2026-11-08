{ inputs, config, ... } :
let system = config.nixpkgs.hostPlatform.system; in
{
  
  flake.nixosModules.system-utils = ({ pkgs, ... } :
  {
    environment.systemPackages = with pkgs; [
      tmux
      wget
      gparted
      pciutils
      openssl
    ] ++ [
      inputs.personal-utils-mono.packages.${system}.pswd
    ];
  });
}
