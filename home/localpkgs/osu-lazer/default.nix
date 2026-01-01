{
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
}:

let
  pname = "osu-lazer-bin";
  version = "2026.102.0";

  src = fetchurl {
    url = "https://github.com/ppy/osu/releases/download/${version}-lazer/osu.AppImage";
    # First build will fail - copy the correct hash from the error message
    # Or run: nix-prefetch-url https://github.com/ppy/osu/releases/download/2026.102.0-lazer/osu.AppImage
    # Then: nix hash to-sri --type sha256 <resulting-hash>
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  # Extract the AppImage to get assets (icons, desktop file)
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in
appimageTools.wrapType2 {
  inherit pname version src;

  # Extra packages needed in the FHS environment
  extraPkgs = pkgs: with pkgs; [
    # Graphics
    libGL
    libGLU
    
    # Audio
    alsa-lib
    pipewire
    pulseaudio
    
    # Input
    libevdev
    
    # Misc
    icu
    openssl
    zlib
    
    # For hardware acceleration
    libva
    vaapiVdpau
    libvdpau-va-gl
  ];

  # Install desktop entry and icons
  extraInstallCommands = ''
    source "${makeWrapper}/nix-support/setup-hook"
    
    # Rename binary to friendlier name
    mv $out/bin/${pname}-${version} $out/bin/osu-lazer
    
    # Create additional symlink as "osu!"
    ln -s $out/bin/osu-lazer "$out/bin/osu!"
    
    # Install desktop file
    install -Dm644 ${appimageContents}/osu!.desktop $out/share/applications/osu-lazer.desktop
    
    # Fix the desktop file
    substituteInPlace $out/share/applications/osu-lazer.desktop \
      --replace-fail 'Exec=osu!' 'Exec=osu-lazer' \
      --replace-fail 'Icon=osu!' 'Icon=osu-lazer'
    
    # Install icons
    for size in 16 32 48 64 128 256 512 1024; do
      if [ -f "${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/osu!.png" ]; then
        install -Dm644 \
          "${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/osu!.png" \
          "$out/share/icons/hicolor/''${size}x''${size}/apps/osu-lazer.png"
      fi
    done
    
    # Fallback: copy main icon if available
    if [ -f "${appimageContents}/osu!.png" ]; then
      install -Dm644 "${appimageContents}/osu!.png" "$out/share/icons/hicolor/256x256/apps/osu-lazer.png"
    fi
  '';

  meta = with lib; {
    description = "Rhythm is just a *click* away (official AppImage for score submission and multiplayer)";
    homepage = "https://osu.ppy.sh";
    changelog = "https://osu.ppy.sh/home/changelog/lazer/${version}";
    license = with licenses; [
      mit
      cc-by-nc-40
      unfreeRedistributable
    ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "osu-lazer";
  };
}
