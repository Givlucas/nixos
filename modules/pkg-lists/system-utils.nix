{ inputs, ... } :
{
  flake.nixosModules.system-utils = ({ pkgs, ... } :
    let system = pkgs.stdenv.hostPlatform.system; in
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
