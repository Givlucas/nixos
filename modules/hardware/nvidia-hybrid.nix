# NVIDIA Hybrid GPU module - PRIME offload configuration
{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.nvidia-hybrid;

  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  options.hardware.nvidia-hybrid = {
    enable = lib.mkEnableOption "NVIDIA hybrid GPU with PRIME offload";

    nvidiaBusId = lib.mkOption {
      type = lib.types.str;
      default = "PCI:1:0:0";
      description = "PCI bus ID for NVIDIA GPU";
      example = "PCI:1:0:0";
    };

    amdBusId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "PCI:4:0:0";
      description = "PCI bus ID for AMD iGPU (set to null if using Intel)";
      example = "PCI:4:0:0";
    };

    intelBusId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "PCI bus ID for Intel iGPU (set to null if using AMD)";
      example = "PCI:0:2:0";
    };
  };

  config = lib.mkIf cfg.enable {
    # Graphics configuration
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Allow unfree NVIDIA packages
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "nvidia-x11"
        "nvidia-settings"
      ];

    # NVIDIA driver
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      powerManagement.enable = true;
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      open = false;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        nvidiaBusId = cfg.nvidiaBusId;
      } // lib.optionalAttrs (cfg.amdBusId != null) {
        amdgpuBusId = cfg.amdBusId;
      } // lib.optionalAttrs (cfg.intelBusId != null) {
        intelBusId = cfg.intelBusId;
      };
    };

    # Add nvidia-offload script to PATH
    environment.systemPackages = [ nvidia-offload ];
  };
}
