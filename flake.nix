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
      lazer-pkg = final: prev: {
        Lazer = final.callPackage ./home/localpkgs/Lazer {};
      };
      qt6ct-kde-pkg = final: prev: {
        qt6ct-kde = final.callPackage ./home/localpkgs/qt6ct-kde {};
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ lazer-pkg qt6ct-kde-pkg ];
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
