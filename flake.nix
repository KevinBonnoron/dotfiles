{
  description = "Dotfiles: Home Manager environment and shared NixOS module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    omp.url = "github:can1357/oh-my-pi";
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    {
      # home-manager switch --flake ~/dotfiles
      homeConfigurations.kevin = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home ];
      };

      # System settings shared by every machine, imported from /etc/nixos/flake.nix.
      nixosModules.default = ./nixos/common.nix;
    };
}
