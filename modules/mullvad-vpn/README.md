# Mullvad VPN Module

NixOS module for Mullvad VPN using WireGuard with NetworkManager integration for GNOME toggleability.

## Setup

### 1. Download WireGuard Config from Mullvad

1. Log into your Mullvad account at https://mullvad.net/en/account
2. Go to "WireGuard configuration"
3. Generate or download a WireGuard config file

### 2. Extract Private Key

From the downloaded config file, extract the `PrivateKey` value and save it to `secrets/mullvad-private-key` in this repository:

```bash
# The secrets directory is gitignored - your key stays local
echo "YOUR_PRIVATE_KEY_HERE" > secrets/mullvad-private-key
```

### 3. Configure Module Options

In your host configuration or flake, enable the module and set the server details from your Mullvad config:

```nix
{
  services.mullvad = {
    enable = true;
    # These values come from your Mullvad WireGuard config file
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

Or via GNOME Settings:
1. Open Settings > Network
2. Find "Mullvad VPN" under VPN section
3. Use the toggle switch

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
| `privateKeyFile` | path | `secrets/mullvad-private-key` | Path to WireGuard private key file |
| `endpoint` | str | `103.251.27.127:51820` | Mullvad server endpoint |
| `publicKey` | str | (LA server key) | Mullvad server public key |
| `addresses` | list of str | (default IPs) | Interface IPv4/IPv6 addresses |
| `dns` | list of str | `[ "10.64.0.1" ]` | DNS servers when VPN active |
| `interfaceName` | str | `mullvad-wg` | WireGuard interface name |
| `autoConnect` | bool | `false` | Connect automatically on boot |

## Changing Servers

To switch Mullvad servers:

1. Download a new WireGuard config from Mullvad for the desired server
2. Update the `endpoint` and `publicKey` options (these change per server)
3. Rebuild the system

The `addresses`, `dns`, and private key remain the same for your account.

## Security Notes

- Private key file is stored in `secrets/` which is gitignored
- Key is read at build time and included in the NixOS system derivation
- The nix store is only readable by root
- Never commit `secrets/` directory contents to git
