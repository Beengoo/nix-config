{
  description = "My nix config";
  inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    youtube-music = {
      url = "github:h-banii/youtube-music-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hytale-launcher.url = "github:TNAZEP/HytaleLauncherFlake";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, zen-browser, youtube-music, noctalia, hytale-launcher, ... }@inputs:
    let
      system = "x86_64-linux";
      carla-patched-pkg = final: prev: {
        carla-patched = final.callPackage ./home/localpkgs/carla-patched {};
      };
      lazer-pkg = final: prev: {
        Lazer = final.callPackage ./home/localpkgs/Lazer {};
      };
      qt6ct-kde-pkg = final: prev: {
        qt6ct-kde = final.callPackage ./home/localpkgs/qt6ct-kde {};
      };
      osu-lazer-pkg = final: prev: {
        osu-lazer = final.callPackage ./home/localpkgs/osu-lazer {};
      };

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ 
          lazer-pkg
          carla-patched-pkg
          qt6ct-kde-pkg
          osu-lazer-pkg
        ];
      };
    in {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          modules = [ ./configuration.nix ];  # Remove dolphin-overlay from here
          specialArgs = { inherit system inputs; };
        };
      };
      homeConfigurations = {
        beengoo = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit noctalia;
            inherit zen-browser;
            inherit youtube-music;
            inherit hytale-launcher;
          };
          modules = [ ./home.nix ];
        };
      };
    };
}
