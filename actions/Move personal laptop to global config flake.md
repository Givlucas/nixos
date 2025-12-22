#action #action #home-server 
#published 

# notes
- Can configured #gnome #plugins using #dconf.settings
# statement of inputs 
- [[Create basic nix configuration flake]]

# Statement of specifications
- use home manager for user management
- impermanence by default.
- NVIDIA hybrid GPU with prime-offload
- btrfs + zfs 
- desktop env
- Abstract personal config with no hardware sections

# statement of design

# output
## design 
Create several modules that when combined together create a nixos env Suitable for use as a desktop.

Will need to have modules for
- user management using home manager
- a drive configuration suitable for storage of regular work + games. btrfs + xfs? with compression on btrfs. Should be impermanent by default, with exceptions for user locations and game locations
- a NVIDIA hybrid GPU with prime-offload
- a general desktop env flake

Modules should be composable and generic if possible with inputs to determine behavior.

Should use generic base config for basic.