{
  description = "Carla - A fully-featured audio plugin host for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # Allow unfree packages if needed for some audio codecs
          config.allowUnfree = true;
        };
      in
      {
        packages = {
          # Default package with all features
          default = self.packages.${system}.carla-full;

          # Full-featured Carla with all optional dependencies
          carla-full = pkgs.callPackage ./package.nix {
            withFrontend = true;
            withQt = true;
            withGtk2 = true;
            withGtk3 = true;
            withX11 = true;
            withFFmpeg = true;
            withFluidSynth = true;
            withProjectM = false; # Set to true if you want ProjectM
            withSDL2 = true;
            withOSC = true;
          };

          # Minimal Carla (headless, for server use)
          carla-headless = pkgs.callPackage ./package.nix {
            withFrontend = false;
            withQt = false;
            withGtk2 = false;
            withGtk3 = false;
            withX11 = false;
            withFFmpeg = true;
            withFluidSynth = true;
            withProjectM = false;
            withSDL2 = false;
            withOSC = true;
          };

          # Carla without FFmpeg (for license concerns)
          carla-no-ffmpeg = pkgs.callPackage ./package.nix {
            withFrontend = true;
            withQt = true;
            withGtk2 = true;
            withGtk3 = true;
            withX11 = true;
            withFFmpeg = false;
            withFluidSynth = true;
            withProjectM = false;
            withSDL2 = true;
            withOSC = true;
          };
        };

        # Development shell for working on Carla
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Build tools
            gnumake
            gcc
            pkg-config
            which
            python3

            # Python packages
            python3Packages.pyqt5
            python3Packages.rdflib
            python3Packages.pyliblo3

            # Core dependencies
            file
            liblo
            alsa-lib
            fluidsynth
            jack2
            libpulseaudio
            libsndfile

            # Qt
            qt5.qtbase
            qt5.qtsvg

            # Gtk
            gtk2
            gtk3

            # X11
            xorg.libX11
            xorg.libXcursor
            xorg.libXext
            xorg.libXrandr
            xorg.libXinerama

            # FFmpeg
            ffmpeg

            # SDL2
            SDL2

            # Additional
            fftw
            zlib
            libGLU
            libGL
          ];

          shellHook = ''
            echo "Carla development environment"
            echo "Run 'make features' to see what features will be built"
            echo "Run 'make' to build Carla"
            echo "Run 'make install PREFIX=$out' to install"
          '';
        };

        # NixOS module for system-wide installation
        nixosModules.default = { config, lib, ... }:
          let
            cfg = config.programs.carla;
          in
          {
            options.programs.carla = {
              enable = lib.mkEnableOption "Carla audio plugin host";

              package = lib.mkOption {
                type = lib.types.package;
                default = self.packages.${system}.carla-full;
                description = "The Carla package to use";
              };

              jackSupport = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Enable JACK audio support";
              };
            };

            config = lib.mkIf cfg.enable {
              environment.systemPackages = [ cfg.package ];

              # Enable JACK if requested
              services.jack = lib.mkIf cfg.jackSupport {
                jackd.enable = lib.mkDefault true;
              };
            };
          };
      });
}
