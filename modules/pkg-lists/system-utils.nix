{ inputs, ... } :
{
  flake.nixosModules.system-utils = ({ pkgs, ... } :
    let system = pkgs.stdenv.hostPlatform.system; in
  {
    environment.systemPackages = with pkgs; [
      helix
      tmux
      wget
      gparted
      pciutils
      openssl
      tree
    ] ++ [
      inputs.personal-utils-mono.packages.${system}.gitroot
    ];
  });
}
