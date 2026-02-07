#action #action #home-server 
#discovery


# Notes


- Installations built using the above command do not have a /etc/nixos/config file or flake.
- It is possible to make configurations compose-able by creating a nixosConfiguration object who evaluates a function which takes a argument set containing a list of modules. This function will then call lib.nixos.System (???) and add the modules passed into the module set.
- alienware requires broadcom had to temporarly make a custom nixos install config to use. Will clean up in later action. Testing disko options with TV flake - it worked
- completely re-work this. your extension is not standard behavior and it's technical debt.

# Questions
- [x] What does updating look like? Do you just need to do a nixos-rebuild switch --flake ??
- yep
- [ ] How to install without nixos-anywhere?
- [x] do you need to have disk-config as "disk-config"
	- nope
- [v] Why not basic modules that you can import between flakes for functionalities instead of modifying through inputs. One library flake and another for configurations based on the library flakes modules? Maybe a mix
	- A: You can mix it, its best not to chain flakes too much as it will require you to update every flakes lock file.
# Statement of action
Create a basic nixos install flake that can be used with unattended installs

# Statement of specifications 
- [x] Minimal input required when installed (unattended / remote install easy)
- [x] Able to easily update from new configuration on already installed machines
- [x] able to choose the name of the disk to use as a module input for basic disk

# Statement of Outputs

#### Output: A mono flake for multiple nixos configurations to be deployed using nixos-anywhere
Create a nix "mono flake" comprised of several nixos configurations that layer on top of each other. To accomplish this create two helper functions. One that takes two sets of configs and combines them passing them the nixosSystem function to create a config. And another function which takes a nixosConfiguration and a module set, extracts the modules from the configuration and passes them and the other module set to the first function. 

This allows you to create generic config classes like a “abstract-base” or “gaming” etc then more specific host specific configs that extend from them. 

Only create a module if it will be used in several places in the same way with only minor changes.

Deployment of the configurations should be done using nixos-anywhere as a primary method using a command similar to the following 

``` bash
nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --flake 'github:givlucas/base-nixos-configuration#test' --target-host root@192.168.12.140

nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./modules/hardware-configuration.nix --flake 'github:givlucas/nixos#tv' --target-host root@192.168.12.140

```

Create a basic config which serves as the config for all other configs you will be using. Base config should come with a admin user with no default password. This should be set on install

Use disko for automatic disk configuration. Create a disko module which takes a required option to specify the target device. Each config that inherits from base will need to specify this in their configuration.

Deployment commands should be added to a nix shell as scripts for easy running.

Organize the repo as follows

- root
	- flake.nix
	- flake.lock
	- modules/
		- base-config.nix
		- hardware-configuration.nix
		- disk-config.nix
		- configs\\\<Name of config>
			- config specific modules
		- hosts\\\<Name of host>
			- Host specific modules