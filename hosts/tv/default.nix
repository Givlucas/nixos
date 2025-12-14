# TV host configuration
{ pkgs, ... }:

{
  networking.hostName = "tv";
  networking.networkmanager.enable = true;

  # Disk configuration
  base-disk.device = "/dev/sda";

  # TV user
  users.users.tvuser = {
    isNormalUser = true;
    extraGroups = [ "dialout" "plugdev" ];
    useDefaultShell = true;
    packages = with pkgs; [
      deluge
      tor-browser-bundle-bin
      firefox
      spotify
    ];
  };
}
