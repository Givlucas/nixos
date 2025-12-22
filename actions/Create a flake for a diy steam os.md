#action #action #home-server 
#implementation 

# Notes
- jovian doesn't seem to boot with just a gamescope session alone. 
	- It doesn't like our GPU may need to switch away from jovian. Oh well.
- Gamescope is a compositor. Using xserver was a compositor and then launching steam is fine. No need to double layer compositors.
- wrong size window. Install xterm, then launch it from steam. Check what settings are being used
# Statement of action 
Create flake using the nixos repository using the base flake for a diy steam os on the alienware kobe gave you

# Statement of specifications
- Easy to use UI, netflix etc
- Uses steam big picture mode at default boot
- Bluetooth enabled and usable
- GPU works

# Statement of inputs
- [[Create basic nix configuration flake]]

# Statement of design

#### Output: nixosConfiguration to mimic steam os
Create a new nixos configuration attribute to create a diy steam os configuration derived from the base distro for your alien ware pc

will need to create a broadcom module to use with the alienware. It should set the Broadcom driver. 
- [ ] Enables Bluetooth as well.

In the host specific config add a way to 
- [ ] set AMD gpu to use always
- [ ] Using xserver compositor using steam in big picture mode full screen as the only window. Don’t use Jovian of game scope as they are crazy buggy with the old hardware on the alien

These are separate and not modular because they are host specific.

#### Output: nixos live install custom
Create a new nixos configuration. This configuration should be buildable into a live image. It should come with all the drivers needed to book on all your systems. This tool will be used to boot from so nixos-anywhere can install to a system.
