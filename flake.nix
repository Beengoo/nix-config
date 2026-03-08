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
    nixcord.url = "github:FlameFlag/nixcord";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, zen-browser, youtube-music, noctalia, hytale-launcher, nixcord, ... }@inputs:
    let
      system = "x86_64-linux";
      lazer-pkg = final: prev: {
        Lazer = final.callPackage ./home/localpkgs/Lazer {};
      };
      carla-patched-pkg = final: prev: {
        carla-patched = final.callPackage ./home/localpkgs/carla-patched {};
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
      packages.${system} = {
      carla-patched = pkgs.carla-patched; # Temporary for force rebuild
      };
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          modules = [ ./configuration.nix ];
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
            inherit nixcord;
          };
          modules = [ ./home.nix ];
        };
      };
    };
}
