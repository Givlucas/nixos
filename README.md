This repository has been partially written with an LLM. The core implementation and structure was laid out by me personally. I have since used the LLM to make small additions at my direction.
Please see my statement on LLM usage: https://github.com/Givlucas/AI-instructions/blob/main/Statement%20on%20LLM%20use.md

# NixOS Configuration

Personal multi-machine NixOS configuration built around composable modules and configuration inheritance.

## Philosophy

This repository separates **what** a system does from **which hardware** it runs on. Abstract configurations like `gaming-pc` define software, services, and user environments without any hardware assumptions. Concrete hosts like `zephyrus` extend these abstractions with machine-specific details like disk devices, GPU bus IDs, and kernel modules.

This approach means adding a new machine with similar needs only requires defining its hardware differences.

## Hosts

- **base** - Minimal foundation with SSH, basic tools, and an admin user. Other simple hosts extend from here.
- **tv** - Media machine extending base. Adds a tvuser with Firefox, Deluge, Spotify, and Tor Browser.
- **gaming-pc** - Abstract desktop configuration. GNOME desktop, Steam with Proton GE, development tools, virtualization. Defines users lucas and isa via home-manager. Has no hardware configuration—not meant to be deployed directly.
- **zephyrus** - Physical ASUS Zephyrus laptop. Extends gaming-pc with AMD+NVIDIA hybrid GPU setup, NVME storage layout, impermanence, and Thunderbolt support.
- **live** - Bootable installation ISO with Broadcom WiFi drivers and NetworkManager for initial setup.

## Directory Layout

**flake.nix** - Entry point defining all hosts and helper functions for configuration composition.

**modules/** - Reusable configuration pieces:
- **base/** - Core system settings shared everywhere: boot loader, locale, timezone, SSH, basic packages.
- **storage/** - Disk partitioning via disko (50% btrfs with compression, 50% xfs for games) and impermanence for ephemeral root filesystems.
- **hardware/** - Hardware-specific modules. Currently contains NVIDIA hybrid GPU configuration with PRIME offload.
- **desktop/** - GNOME desktop environment with curated extensions for tiling, blur effects, and UI polish.
- **users/** - Home-manager integration defining lucas and isa with their respective packages and dotfiles.

**hosts/** - Machine-specific configurations:
- **base/** - Empty, inherits everything from modules/base.
- **tv/** - TV-specific user and packages.
- **gaming-pc/** - Enables all desktop modules, defines which users exist, sets up virtualization and gaming.
- **zephyrus/** - Hardware definitions: storage device, GPU bus IDs, kernel modules for AMD CPU.

**OLD/** - Previous single-machine configuration kept for reference during migration.

## Stable vs Unstable

Simple hosts (base, tv) use nixpkgs 25.05 stable. Desktop hosts (gaming-pc, zephyrus) use nixpkgs unstable for access to newer packages. The flake provides separate helper functions for each track.

## Installation

To install a host like `zephyrus` from scratch:

1. Build the live ISO (requires Nix with flakes enabled):
   ```bash
   nix build github:Givlucas/nixos#live
   ```

2. Write to USB:
   ```bash
   sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress
   ```

3. Boot from USB on target machine and connect to network.

4. Partition the disk with disko (this will wipe the target drive):
   ```bash
   sudo nix run github:nix-community/disko -- --mode disko --flake github:Givlucas/nixos#zephyrus
   ```

5. Install NixOS:
   ```bash
   sudo nixos-install --flake github:Givlucas/nixos#zephyrus --no-root-passwd
   ```

6. Reboot and set user passwords with `passwd`.

**Note:** Verify `storage.device` in `hosts/zephyrus/default.nix` matches your actual drive before running disko.

## Impermanence

The zephyrus configuration wipes root on every boot, keeping only explicitly persisted paths in `/persist`. This includes SSH keys, logs, Docker/libvirt state, and user home directories. The btrfs `@root` subvolume gets replaced with a fresh snapshot at boot while `@persist` and `@nix` remain untouched.
