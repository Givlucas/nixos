 #action #home-server 
 #published

# Notes

# Statement of Aciton
get and install mullvad vpn on you personal compute. Mullvad is high speed and doesn't integrate scammy coins.

# Statement of specifications
- must be toggleable via gnome
- must be a nix config flake with options
- must be configured via the wiregaurd options
- must hide keys in a file not manager by nix
- must have use documented
- must not be user specific
- default module options must all be filled

# Statement of inputs
- [[Move personal laptop to global config flake]]

# Statement of design

## Architecture Overview
Create a NixOS module that configures Mullvad VPN via WireGuard with NetworkManager integration for GNOME toggleability.

## Repository Structure
```
modules/
  mullvad-vpn/
    default.nix          # Main module with options
    README.md            # Usage documentation
```

## System Structure (not in git)
```
/etc/nixos-secrets/
  mullvad/
    private-key          # Private key file (on system only)
```

## NixOS Module Design

### Module Options
- `services.mullvad.enable` - Enable/disable the VPN configuration
- `services.mullvad.privateKeyFile` - Path to private key file (default: `/etc/nixos-secrets/mullvad/private-key`)
- `services.mullvad.endpoint` - Mullvad server endpoint
- `services.mullvad.publicKey` - Mullvad server public key
- `services.mullvad.addresses` - IPv4/IPv6 addresses for the interface
- `services.mullvad.dns` - DNS servers to use

### Implementation Details

1. **WireGuard via NetworkManager**
   - Use `networking.networkmanager.ensureProfiles.profiles` to create a VPN profile
   - Configure as WireGuard connection type
   - Reference private key from file path (not in nix store)
   - Set connection to autoconnect=false for manual toggling

2. **Key Management**
   - Private key stored in `/etc/nixos-secrets/mullvad/private-key` (on system, not in git)
   - Set file permissions to 600 (read-write owner only)
   - Module references this path
   - Document key extraction from Mullvad config in README
   - **Add `/etc/nixos-secrets/mullvad/` to impermanence configuration** to persist across reboots

3. **NetworkManager Profile Structure**
   - Connection type: wireguard
   - Interface name: mullvad-wg
   - Autoconnect: false (manual toggle)
   - IPv4/IPv6 configuration from Mullvad settings
   - DNS configuration

4. **GNOME Integration**
   - VPN appears in GNOME Settings > Network > VPN
   - Toggle via system tray network menu
   - Status visible in top bar when connected

## Configuration Flow

1. User downloads WireGuard config from Mullvad account
2. Manually create `/etc/nixos-secrets/mullvad/` directory
3. Extract private key from config to `/etc/nixos-secrets/mullvad/private-key`
4. Set proper permissions (chmod 600)
5. Extract server details (endpoint, public key, addresses, DNS)
6. Configure module options in flake
7. Add secrets directory to impermanence configuration
8. Rebuild system
9. Toggle VPN via GNOME network settings

## File Permissions & Security
- Private key file: mode 0600, owner root
- Secrets directory: mode 0700, owner root
- Secrets directory excluded from git (lives on system only)
- Private key never appears in nix store or system derivations
- Secrets directory must be added to impermanence persistence

