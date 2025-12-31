# Zephyrus laptop - hardware configuration
# Extends gaming-pc with ASUS Zephyrus specific hardware
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "zephyrus";
  networking.networkmanager.enable = true;

  # Storage - 50% btrfs + 50% xfs
  storage.enable = true;
  storage.device = "/dev/nvme0n1";  # Adjust to actual device
  storage.xfsMountpoint = "/games";

  # Impermanence
  impermanence.enable = true;
  impermanence.persistDir = "/persist";
  userProfiles.persistHome = true;
  userProfiles.persistDir = "/persist";

  # Mullvad VPN
  services.mullvad.enable = true;

  # NVIDIA hybrid GPU (AMD iGPU + NVIDIA dGPU)
  hardware.nvidia-hybrid.enable = true;
  hardware.nvidia-hybrid.nvidiaBusId = "PCI:1:0:0";
  hardware.nvidia-hybrid.amdBusId = "PCI:4:0:0";

  # Docker uses btrfs storage driver on this system
  virtualisation.docker.storageDriver = "btrfs";

  # Thunderbolt
  services.hardware.bolt.enable = true;

  system.stateVersion = "23.05";
}
