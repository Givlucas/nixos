{inputs, self, ...}: {
  flake.nixosConfigurations.hp-probook = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.nixosModules.system-utils
      self.nixosModules.nix-commands
      ({config, lib, pkgs, ...} : {
        imports = [
          self.nixosModules.home-manager-global
        ];

        # TODO: Should probably make a USER module? Bundle home manager with basic user creation? this also formalizes your password storage scheme
        # This will be useful to those ends: https://ryantm.github.io/nixpkgs/functions/library/attrsets/#function-library-lib.attrsets.getAttrs
        # ../accounts.nix

        # 1)
        users.users.lucas = {
          isNormalUser = true;
          extraGroups = [ "wheel" "dialout" "plugdev" "docker" "libvirtd" ];
          useDefaultShell = true;
          hashedPasswordFile = "/persist/secrets/lucas-password";
        };

        # 2)
        home-manager.users.lucas = ({ config, pkgs, ... }: {
          imports = [
            self.homeModules.helix
            self.homeModules.git
          ];
          home.homeDirectory = "/home/lucas";
          home.stateVersion = "26.05"; # Did you read the comment?

          git.user.name = "Lucas";
          git.user.email = "lucas.givens@tutamail.com";
          git.identityFile = "~/.ssh/github";
          
        });

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It's perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "26.05"; # Did you read the comment?
      })
    ];
  };
}
