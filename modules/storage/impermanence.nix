# Impermanence module - ephemeral root filesystem
{ config, lib, inputs, ... }:

let
  cfg = config.impermanence;
in
{
  options.impermanence = {
    enable = lib.mkEnableOption "impermanent root filesystem";

    persistDir = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "Directory where persistent state is stored";
    };
  };

  config = lib.mkIf cfg.enable {
    # Wipe root on boot using a btrfs snapshot
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      mkdir -p /mnt
      mount -o subvol=/ /dev/disk/by-partlabel/btrfs /mnt

      if [[ -e /mnt/@root ]]; then
        mkdir -p /mnt/@snapshots
        timestamp=$(date --date="@$(stat -c %Y /mnt/@root)" "+%Y-%m-%d_%H:%M:%S")
        mv /mnt/@root "/mnt/@snapshots/$timestamp"
      fi

      btrfs subvolume create /mnt/@root
      umount /mnt
    '';

    # Persist essential system state
    environment.persistence.${cfg.persistDir} = {
      hideMounts = true;
      directories = [
        "/etc/nixos"
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        { directory = "/var/lib/docker"; mode = "0710"; }
        { directory = "/var/lib/libvirt"; mode = "0755"; }
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };

    fileSystems."/persist".neededForBoot = true;

    # Ensure persist directory exists and has correct permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.persistDir} 0755 root root -"
      "d ${cfg.persistDir}/home 0755 root root -"
    ];

    # Users need their home directories persisted
    # This is handled per-user in the users module via home-manager impermanence
  };
}
