# Base system configuration module
# Common settings shared across all hosts

{ pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Timezone
  services.automatic-timezoned.enable = true;

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Default admin user for all systems
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" "plugdev" ];
    useDefaultShell = true;
    initialPassword = "";
  };

  # Base system packages
  environment.systemPackages = with pkgs; [
    helix
    tmux
    wget
    gparted
    pciutils
    git
    ntfs3g
    fastfetch
    openssl
  ];

  # SSH
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ 22 ];

  system.stateVersion = lib.mkDefault "23.05";
}
