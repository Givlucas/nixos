# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib,... }:

let
    nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" "dynamic-derivations" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "zephyrus"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  services.hardware.bolt.enable = true;

  programs.git.enable = true;
  programs.git.prompt.enable = true;


  # Enable virtulization  
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
    
  # Set your time zone.
  services.automatic-timezoned.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  
  # # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.gnome.extraGSettingsOverridePackages = [ pkgs.mutter ];
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = "
    [org.gnome.mutter]
    edge-tiling = true
  ";
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # Configureing nvidia
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
    ];

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    powerManagement.enable = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    prime = {
      offload.enable = true;
      amdgpuBusId = "PCI:4:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    open = false;
  }; 

  #Enable steam
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];

  programs.bash.shellAliases = {
    sudo = "sudo -E";
  };
  # Enable docker
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  hardware.pulseaudio.enable = false;

  hardware.rtl-sdr.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # useraccounts

  users.users.lucas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" "plugdev"]; # Enable ‘sudo’ for the user.
    useDefaultShell = true;
  };
  
  users.users.isa = {
    isNormalUser = true;
    extraGroups = [ "dialout" "plugdev"];
    useDefaultShell = true;
    packages = [
      pkgs.vscode
      pkgs.xournalpp
      pkgs.prismlauncher
      pkgs.gamescope
      pkgs.firefox
      pkgs.libreoffice
      pkgs.spotify
      pkgs.discord
      (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
        # select Python packages here
        pip
        jupyter
        notebook
        ipykernel
        numpy
      ]))      
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # Building of 0.8 Gradience
  # System Packages
  environment.systemPackages = with pkgs; [
    helix # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    ffmpeg
    tree
    hunspell
    hunspellDicts.en_US
    pciutils
    dvdplusrwtools
    tmux
    wl-clipboard
    cdrkit
    nil
    wget
    waypipe
    gparted
    pciutils
    cdrtools
    nvtopPackages.full
    nvidia-offload
    mesa-demos
    ntfs3g
    hexedit
    fastfetch
    openssl
    helvum
    # barrier
    gnome-tweaks
    gnomeExtensions.compiz-alike-magic-lamp-effect
    gnomeExtensions.compiz-windows-effect
    gnomeExtensions.tiling-shell
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.hide-top-bar
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.just-perfection
    gnomeExtensions.light-style
  ];

  # environment.shells = with pkgs; [ zsh ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 3389 24800 25565 22 3389 5900];
  networking.firewall.allowedUDPPorts = [ 25565 22 3389 5900];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

