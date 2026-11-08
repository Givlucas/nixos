{inputs, self', ...}: {
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.default
      {
        system.stateVersion = "26.05";
        wsl.enable = true;
        wsl.defaultUser = "nixos";
      }
      ({config, lib, pkgs, ...} : {

        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        programs.git.enable = true;

        environment.systemPackages = with pkgs; [
          helix
          tmux
        ];

        programs.ssh.startAgent = true;

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
