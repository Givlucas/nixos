# Disko hybrid storage configuration
# 50% btrfs (with compression) + 50% xfs layout
{ config, lib, ... }:

let
  cfg = config.storage;
in
{
  options.storage = {
    enable = lib.mkEnableOption "hybrid btrfs+xfs storage layout";

    device = lib.mkOption {
      type = lib.types.str;
      description = "Target device (e.g., /dev/nvme0n1)";
      example = "/dev/nvme0n1";
    };

    btrfsSize = lib.mkOption {
      type = lib.types.str;
      default = "465G";
      description = "Size of btrfs partition";
    };

    xfsMountpoint = lib.mkOption {
      type = lib.types.str;
      default = "/games";
      description = "Mountpoint for XFS partition";
    };
  };

  config = lib.mkIf cfg.enable {

    # Create gamers group for shared game storage
    users.groups.gamers = {};

    # Set ownership and permissions on XFS mount
    systemd.tmpfiles.rules = [
      "d ${cfg.xfsMountpoint} 0775 root gamers -"
    ];



    disko.devices.disk.main = {
      device = cfg.device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "500M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          btrfs = {
            size = cfg.btrfsSize;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };

          xfs = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = cfg.xfsMountpoint;
            };
          };
        };
      };
    };

    # Boot loader configuration
    boot.loader.grub.devices = [ cfg.device ];
  };
}
