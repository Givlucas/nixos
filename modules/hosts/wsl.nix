{inputs, self, ...}: {
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.default
      self.nixosModules.system-utils
      self.nixosModules.nix-commands
      {
        system.stateVersion = "26.05";
        wsl.enable = true;
        wsl.defaultUser = "nixos";
      }
      ({config, lib, pkgs, ...} : {

        imports = [ self.nixosModules.home-manager-global ];
       
        home-manager.users.nixos = ({ config, pkgs, ... }: {
          home.username = "nixos";
          home.homeDirectory = "/home/nixos";
          home.stateVersion = "26.05"; # Did you read the comment?

          programs.git = {
            enable = true;
            settings.user.name = "Lucas";
            settings.user.email = "lucas.givens@tutamail.com";
          };

          programs.ssh = {
            enable = true;
            settings = {
              "github.com" = {
                HostName = "github.com";
                User = "git";
                IdentityFile = "~/.ssh/github";
              };
            };
          };
          
        });

        environment.systemPackages = with pkgs; [
          helix
          tmux
        ];


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
