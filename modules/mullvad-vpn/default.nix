# Mullvad VPN module - WireGuard via NetworkManager for GNOME integration
{ config, lib, pkgs, ... }:

let
  cfg = config.services.mullvad;

  # Read private key from file at build time
  privateKey = lib.strings.trim (builtins.readFile cfg.privateKeyFile);

  # Helper to extract IPv4 and IPv6 addresses
  ipv4Addrs = lib.filter (a: lib.hasInfix "." a) cfg.addresses;
  ipv6Addrs = lib.filter (a: lib.hasInfix ":" a) cfg.addresses;
  ipv4Dns = lib.filter (d: lib.hasInfix "." d) cfg.dns;
  ipv6Dns = lib.filter (d: lib.hasInfix ":" d) cfg.dns;
in
{
  options.services.mullvad = {
    enable = lib.mkEnableOption "Mullvad VPN via WireGuard";

    privateKeyFile = lib.mkOption {
      type = lib.types.path;
      default = ../.. + "/secrets/mullvad-private-key";
      description = "Path to the WireGuard private key file (gitignored)";
    };

    endpoint = lib.mkOption {
      type = lib.types.str;
      default = "103.251.27.127:51820";
      description = "Mullvad server endpoint (IP:port)";
    };

    publicKey = lib.mkOption {
      type = lib.types.str;
      default = "KPjr8jrGP3dVI+GbMq2LNc9eREW6EhGHndoSWHqakxE=";
      description = "Mullvad server public key";
    };

    addresses = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "10.72.213.220/32" "fc00:bbbb:bbbb:bb01::9:d5db/128" ];
      description = "IPv4 and IPv6 addresses for the WireGuard interface";
    };

    dns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "10.64.0.1" ];
      description = "DNS servers to use when VPN is active";
    };

    interfaceName = lib.mkOption {
      type = lib.types.str;
      default = "mullvad-wg";
      description = "Name of the WireGuard interface";
    };

    autoConnect = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Automatically connect to VPN on boot";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure NetworkManager is enabled
    networking.networkmanager.enable = true;

    # Create the WireGuard VPN profile for NetworkManager
    networking.networkmanager.ensureProfiles.profiles.mullvad-vpn = {
      connection = {
        id = "Mullvad VPN";
        type = "wireguard";
        interface-name = cfg.interfaceName;
        autoconnect = lib.boolToString cfg.autoConnect;
      };
      wireguard = {
        private-key = privateKey;
      };
      "wireguard-peer.${cfg.publicKey}" = {
        endpoint = cfg.endpoint;
        allowed-ips = "0.0.0.0/0;::/0;";
        persistent-keepalive = "25";
      };
      ipv4 = {
        method = "manual";
        address1 = lib.head ipv4Addrs;
        dns = lib.concatStringsSep ";" ipv4Dns + ";";
        never-default = "false";
      };
      ipv6 = lib.mkIf (ipv6Addrs != []) {
        method = "manual";
        address1 = lib.head ipv6Addrs;
        dns = lib.optionalString (ipv6Dns != []) (lib.concatStringsSep ";" ipv6Dns + ";");
      };
    };

    # Firewall: Allow WireGuard UDP port
    networking.firewall.allowedUDPPorts = [ 51820 ];
  };
}
