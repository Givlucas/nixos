{ config, lib ,... }:
{

  options.base-disk = {
    device = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    boot.loader.grub.devices = [ config.disko.devices.disk.main.device ];
    disko.devices.disk.main = {
      device = config.base-disk.device;
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
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
