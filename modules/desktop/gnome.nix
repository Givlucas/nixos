# GNOME Desktop Environment module
{ config, lib, pkgs, ... }:

let
  cfg = config.desktop.gnome;
in
{
  options.desktop.gnome = {
    enable = lib.mkEnableOption "GNOME desktop environment";

    edgeTiling = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable edge tiling (snap windows to edges)";
    };

    automaticTimezone = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable automatic timezone detection";
    };
  };

  config = lib.mkIf cfg.enable {
    # X11 and GNOME
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Edge tiling via mutter GSettings
    services.xserver.desktopManager.gnome.extraGSettingsOverridePackages =
      lib.mkIf cfg.edgeTiling [ pkgs.mutter ];
    services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
      ${lib.optionalString cfg.edgeTiling ''
        [org.gnome.mutter]
        edge-tiling = true
      ''}
      ${lib.optionalString cfg.automaticTimezone ''
        [org.gnome.desktop.datetime]
        automatic-timezone = true
      ''}
    '';

    # GNOME packages (gnome-tweaks moved to per-user packages)
    environment.systemPackages = [ ];

    # Disable PulseAudio (use PipeWire via GNOME)
    hardware.pulseaudio.enable = false;

    # Enable automatic timezone detection
    services.automatic-timezoned.enable = true;
  };
}
