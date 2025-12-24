{
  description = "My nix config";
  inputs = {
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, noctalia, zen-browser, ... }@inputs:
    let
      system = "x86_64-linux";
      overlay = final: prev: {
        Lazer = final.callPackage ./home/localpkgs/Lazer {};
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ overlay ];
      };
    in {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          modules = [ ./configuration.nix ];
          specialArgs = { inherit system inputs pkgs; };
        };
      };
      homeConfigurations = {
        beengoo = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit noctalia;
            inherit zen-browser;
          };
          modules = [ ./home.nix ];
        };
      };
    };
}
