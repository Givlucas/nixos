 #action #action #home-server
#Discovery 

# Notes

# Statement of Action
Set up a working home server using nixos
# Statement of Inputs

# Statement of Specifications
- Impermanence by default.
- Should auto set up storage
- Easily testable 
# Statement of Design

## Output: Impermanent enabled nixos server.

#### Design
On this system there are three drives available: 465GB, 1.8TB, and 931GB. The 1.8TB is a commendation of two HDDs in raid 5. The other two are SSDs. 

Install #nixos on the 465 gb. The drive should be partitioned with a 512MB boot drive and the rest for a #LVM physical volume. Under this volume we will create a root_vg, which will store a swap logical volume and a root logical volume. set aside 40GB for swap. In the root logical volume create a btrfs with the following sub-volumes: root, nix, persistent. We will use these to mount or root, nix, and persistent directories. mount root on our root subvolume and nix / persistent on root/. Then mount boot on root as well. 

From here generate config files as normal or pull from git. Next ensure the system is set up to use flakes. This will allow for easier upgrades and better versioning. Assume all un-mentioned steps to follow regular nix set-up 

Now we can set up our impermanence system. The impermanence system functions by linking files from a permanent drive to a ephemeral root which is wiped on each reboot. we can use the "boot.initrd.postresumecommand" to run a script after we mount root. On reboot create a mount point for our base volume. Here create a old_roots directory / ensure its present. Now move our current root to the old_roots directory and timestamp it. Now delete roots older then 30d from the old root directory and unmount.

Next in our configuration file enable impermanence and setup the persistence volume. This volume will store all data we don't want to get wiped. On boot impermanence will create links in our root volume to the impermanence volume. Take care to figure out what files to keep to ensure the working system.

Now we can set up nix as normal. Create a admin account and generate a hashed password file for the account. Create a #ssh key for #github as well. These files need to be persisted but don't need to be configured in nix.

Add a basic git config to you configuration.nix that enables git and changes the main branch name.

init a git directory in our nixos/config directory if not pulled earlier

now install.