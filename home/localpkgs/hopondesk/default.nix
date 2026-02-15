{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, dpkg
, makeWrapper
, wrapGAppsHook
, alsa-lib
, at-spi2-atk
, at-spi2-core
, cairo
, cups
, dbus
, expat
, gdk-pixbuf
, glib
, gtk3
, libappindicator-gtk3
, libdrm
, libnotify
, libpulseaudio
, libsecret
, libuuid
, libxkbcommon
, mesa
, nspr
, nss
, pango
, systemd
, xorg
}:

stdenv.mkDerivation rec {
  pname = "hoptodesk";
  version = "1.45.6"; # Update this with the latest version from https://www.hoptodesk.com/changelog
  
  src = fetchurl {
    url = "https://www.hoptodesk.com/hoptodesk.deb";
    # To get the correct hash, run: nix-prefetch-url https://www.hoptodesk.com/hoptodesk.deb
    # Or use: nix-shell -p nix-prefetch --run "nix-prefetch-url https://www.hoptodesk.com/hoptodesk.deb"
    sha256 = "0000000000000000000000000000000000000000000000000000"; # PLACEHOLDER - UPDATE THIS
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libappindicator-gtk3
    libdrm
    libnotify
    libpulseaudio
    libsecret
    libuuid
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    xorg.libxshmfence
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin
    mkdir -p $out/lib
    mkdir -p $out/share
    
    # Copy the application files
    cp -r usr/bin/* $out/bin/ || true
    cp -r usr/lib/* $out/lib/ || true
    cp -r usr/share/* $out/share/ || true
    
    # Create wrapper to ensure proper library paths
    if [ -f $out/bin/hoptodesk ]; then
      wrapProgram $out/bin/hoptodesk \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"
    fi
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Free remote desktop software with end-to-end encryption";
    longDescription = ''
      HopToDesk is a free remote desktop tool allowing users to share their 
      screen and allow remote control access to their computers and devices.
      
      Features:
      - Screen sharing and remote control
      - File transfer and live chat
      - End-to-end encryption for all communications
      - Cross-platform support (Windows, Mac, Linux, Android, iOS)
      - Free for both personal and commercial use
      - Open source (AGPLv3)
    '';
    homepage = "https://www.hoptodesk.com/";
    changelog = "https://www.hoptodesk.com/changelog";
    license = licenses.agpl3Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    mainProgram = "hoptodesk";
  };
}
