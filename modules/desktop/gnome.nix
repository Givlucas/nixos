# GNOME Desktop Environment module
{ config, lib, pkgs, ... }:

let
  cfg = config.desktop.gnome;
in
{
  options.desktop.gnome = {
    enable = lib.mkEnableOption "GNOME desktop environment";

    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs.gnomeExtensions; [
        compiz-alike-magic-lamp-effect
        compiz-windows-effect
        tiling-shell
        dash-to-dock
        blur-my-shell
        hide-top-bar
        rounded-window-corners-reborn
        just-perfection
        light-style
      ];
      description = "GNOME Shell extensions to install";
    };

    edgeTiling = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable edge tiling (snap windows to edges)";
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
    services.xserver.desktopManager.gnome.extraGSettingsOverrides =
      lib.mkIf cfg.edgeTiling ''
        [org.gnome.mutter]
        edge-tiling = true
      '';

    # GNOME packages
    environment.systemPackages = [ pkgs.gnome-tweaks ] ++ cfg.extensions;

    # Disable PulseAudio (use PipeWire via GNOME)
    hardware.pulseaudio.enable = false;
  };
}
