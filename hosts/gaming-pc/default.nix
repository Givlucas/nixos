# Abstract Gaming PC configuration
# Desktop system with GNOME, Steam, and full user setup
# No hardware-specific settings - meant to be extended
{ config, pkgs, lib, inputs, ... }:

{
  # GNOME desktop
  desktop.gnome.enable = true;

  # Users
  userProfiles.enableHomeManager = true;
  userProfiles.lucas.enable = true;
  userProfiles.isa.enable = true;

  # Git with prompt
  programs.git.enable = true;
  programs.git.prompt.enable = true;

  # Virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.docker.enable = true;

  # Steam with Proton GE
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];

  # RTL-SDR support
  hardware.rtl-sdr.enable = true;

  # Printing
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint pkgs.cnijfilter_4_00 ];
  };

  services.ipp-usb.enable = false;

  # Ollama with CUDA acceleration
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  # Shell aliases
  programs.bash.shellAliases = {
    sudo = "sudo -E";
  };

  # Additional system packages
  environment.systemPackages = with pkgs; [
    ffmpeg
    tree
    hunspell
    hunspellDicts.en_US
    dvdplusrwtools
    wl-clipboard
    cdrkit
    cdrtools
    nvtopPackages.full
    mesa-demos
    hexedit
    helvum
    waypipe
    nil
  ];

  # Common firewall rules
  networking.firewall.allowedTCPPorts = [ 3389 24800 25565 22 5900 ];
  networking.firewall.allowedUDPPorts = [ 25565 22 3389 5900 ];
}
