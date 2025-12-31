# Mullvad VPN Module

NixOS module for Mullvad VPN using WireGuard with NetworkManager integration for GNOME toggleability.

## Setup

### 1. Download WireGuard Config from Mullvad

1. Log into your Mullvad account at https://mullvad.net/en/account
2. Go to "WireGuard configuration"
3. Generate or download a WireGuard config file

### 2. Create Private Key File

Extract the `PrivateKey` value from your config and create the key file on your system:

```bash
sudo mkdir -p /etc/nixos-secrets/mullvad
sudo chmod 700 /etc/nixos-secrets/mullvad
echo "YOUR_PRIVATE_KEY_HERE" | sudo tee /etc/nixos-secrets/mullvad/private-key
sudo chmod 600 /etc/nixos-secrets/mullvad/private-key
```

If using impermanence, the `/etc/nixos-secrets/mullvad` directory is automatically persisted.

### 3. Enable the Module

In your host configuration:

```nix
{
  services.mullvad.enable = true;
}
```

The module uses sensible defaults. Override server settings if needed:

```nix
{
  services.mullvad = {
    enable = true;
    endpoint = "103.251.27.127:51820";
    publicKey = "KPjr8jrGP3dVI+GbMq2LNc9eREW6EhGHndoSWHqakxE=";
    addresses = [ "10.72.213.220/32" "fc00:bbbb:bbbb:bb01::9:d5db/128" ];
    dns = [ "10.64.0.1" ];
  };
}
```

### 4. Rebuild System

```bash
sudo nixos-rebuild switch --flake .#your-host
```

## Usage

### Toggle via GNOME

1. Click the system tray network icon
2. Click "VPN" section
3. Toggle "Mullvad VPN" on/off

Or via GNOME Settings: Settings > Network > VPN > Mullvad VPN

### Toggle via Command Line

```bash
# Connect
nmcli connection up "Mullvad VPN"

# Disconnect
nmcli connection down "Mullvad VPN"

# Check status
nmcli connection show --active | grep -i mullvad
```

## Module Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Mullvad VPN configuration |
| `privateKeyFile` | str | `/etc/nixos-secrets/mullvad/private-key` | Path to WireGuard private key |
| `endpoint` | str | `103.251.27.127:51820` | Mullvad server endpoint |
| `publicKey` | str | (LA server key) | Mullvad server public key |
| `addresses` | list | (default IPs) | Interface IPv4/IPv6 addresses |
| `dns` | list | `[ "10.64.0.1" ]` | DNS servers when VPN active |
| `interfaceName` | str | `mullvad-wg` | WireGuard interface name |
| `autoConnect` | bool | `false` | Connect automatically on boot |

## Changing Servers

To switch Mullvad servers:

1. Download a new WireGuard config from Mullvad for the desired server
2. Update the `endpoint` and `publicKey` options (these change per server)
3. Rebuild the system

The `addresses`, `dns`, and private key remain the same for your account.

## Security Notes

- Private key stored at `/etc/nixos-secrets/mullvad/private-key` (not in nix store)
- Secrets directory has 700 permissions (root only)
- Private key file has 600 permissions (root read/write only)
- A systemd service injects the key into NetworkManager at boot
- With impermanence enabled, secrets directory is automatically persisted
