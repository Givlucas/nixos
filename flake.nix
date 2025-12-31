{
  description = "Multi-machine NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    impermanence.url = "github:nix-community/impermanence";

    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, disko, home-manager, impermanence, nur, ... }@inputs:
  let
    system = "x86_64-linux";

    # Base configurations for stable hosts (tv, base)
    baseConfigs = [
      ./modules/base
      ./modules/hardware-configuration.nix
      ./modules/base-disk-config.nix
      disko.nixosModules.disko
    ];

    # Base configurations for unstable desktop hosts (gaming-pc, zephyrus)
    desktopConfigs = [
      ./modules/base
      ./modules/storage
      ./modules/hardware/nvidia-hybrid.nix
      ./modules/desktop
      ./modules/users
      ./modules/mullvad-vpn
      disko.nixosModules.disko
      home-manager.nixosModules.home-manager
      impermanence.nixosModules.impermanence
    ];

    # Create config with stable nixpkgs
    mkConfig = baseModules: extraModules: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = baseModules ++ extraModules;
    };

    # Create config with unstable nixpkgs
    mkUnstableConfig = baseModules: extraModules: nixpkgs-unstable.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = baseModules ++ extraModules;
    };

    # Function that extends an existing configuration (stable)
    extendConfig = baseConfig: extraModules: mkConfig
      baseConfig._module.args.modules
      extraModules;

    # Function that extends an existing configuration (unstable)
    extendUnstableConfig = baseConfig: extraModules: mkUnstableConfig
      baseConfig._module.args.modules
      extraModules;
  in
  {
    # Live installer ISO
    packages.${system}.live = self.nixosConfigurations.live.config.system.build.isoImage;

    nixosConfigurations = rec {
      # Live installer
      live = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
          ({ pkgs, config, ... }: {
            boot.initrd.kernelModules = [ "wl" ];
            boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.permittedInsecurePackages = [
              "broadcom-sta-6.30.223.271-57-6.12.44"
            ];
            networking.networkmanager.enable = true;
          })
        ];
      };

      # Base configuration
      base = mkConfig [] baseConfigs;

      # TV configuration (extends base)
      tv = extendConfig base [
        ./hosts/tv
      ];

      # Abstract gaming PC (unstable, no hardware specifics)
      gaming-pc = mkUnstableConfig [] (desktopConfigs ++ [
        ./hosts/gaming-pc
      ]);

      # Zephyrus laptop (extends gaming-pc with hardware specifics)
      zephyrus = extendUnstableConfig gaming-pc [
        ./hosts/zephyrus
      ];
    };
  };
}
