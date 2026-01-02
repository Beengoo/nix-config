{
  lib,
  stdenv,
  fetchFromGitHub,
  # Build tools
  pkg-config,
  which,
  python3Packages,
  python3,
  wrapQtAppsHook,
  makeWrapper,
  # Feature flags
  withFrontend ? true,
  withQt ? true,
  withGtk2 ? true,
  withGtk3 ? true,
  withX11 ? true,
  withFFmpeg ? true,
  withFluidSynth ? true,
  withProjectM ? false, # ProjectM can be heavy, optional
  withSDL2 ? true,
  withOSC ? true,
  withHylia ? false, # Ableton Link support (requires hylia)
  # Core dependencies
  file,
  liblo,
  alsa-lib,
  fluidsynth,
  jack2,
  libpulseaudio,
  libsndfile,
  # Qt dependencies
  qtbase,
  qtsvg,
  # Gtk dependencies
  gtk2,
  gtk3,
  # X11 dependencies
  xorg,
  # FFmpeg
  ffmpeg,
  # SDL2
  SDL2,
  # ProjectM (optional)
  libprojectM ? null,
  # Additional deps for full functionality
  fftw,
  fftwFloat,
  zlib,
  libGLU,
  libGL,
  # For NSM support
  libjack2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "carla";
  version = "2.5.10";

  src = fetchFromGitHub {
    owner = "falkTX";
    repo = "carla";
    rev = "v${finalAttrs.version}";
    hash = "sha256-21QaFCIjGjRTcJtf2nwC5RcVJF8JgcFPIbS8apvf9tw=";
  };

  nativeBuildInputs = [
    python3Packages.wrapPython
    pkg-config
    which
    makeWrapper
  ] ++ lib.optional withQt wrapQtAppsHook;

  pythonPath = with python3Packages; [
    rdflib
    pyliblo3
  ] ++ lib.optional withFrontend pyqt5;

  buildInputs = [
    # Core dependencies (always needed)
    file
    alsa-lib
    jack2
    libjack2
    libpulseaudio
    libsndfile
    zlib
    fftw
    fftwFloat
    libGL
    libGLU
  ]
  # OSC support
  ++ lib.optional withOSC liblo
  # Qt support
  ++ lib.optionals withQt [ qtbase qtsvg ]
  # Gtk support
  ++ lib.optional withGtk2 gtk2
  ++ lib.optional withGtk3 gtk3
  # X11 support
  ++ lib.optionals withX11 [
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXrandr
    xorg.libXinerama
  ]
  # FluidSynth for SF2/SF3 support
  ++ lib.optional withFluidSynth fluidsynth
  # FFmpeg for extra audio formats
  ++ lib.optional withFFmpeg ffmpeg
  # SDL2 audio driver
  ++ lib.optional withSDL2 SDL2
  # ProjectM visualization
  ++ lib.optional (withProjectM && libprojectM != null) libprojectM;

  propagatedBuildInputs = finalAttrs.pythonPath;

  enableParallelBuilding = true;

  makeFlags = [
    "PREFIX=$(out)"
    "LIBDIR=$(out)/lib"
  ];

  installFlags = [ "PREFIX=$(out)" ];

  # Ensure pkg-config finds all libraries
  preBuild = ''
    export PKG_CONFIG_PATH="${lib.makeSearchPath "lib/pkgconfig" finalAttrs.buildInputs}:$PKG_CONFIG_PATH"
  '';

  postPatch = ''
    # Fix the --with-appname issue for NixOS wrapped programs
    # This ensures NSM (Non Session Manager) compatibility
    patchShebangs data/
    patchShebangs source/

    # Replace $0 with hardcoded executable name for wrapper compatibility
    # This is needed because NixOS wraps executables, causing $0 to point to the wrapper
    substituteInPlace source/frontend/carla_host.py \
      --replace-quiet '--with-appname="$0"' '--with-appname="carla"' || true

    substituteInPlace source/frontend/carla_control.py \
      --replace-quiet '--with-appname="$0"' '--with-appname="carla-control"' || true

    # Fix hardcoded paths
    substituteInPlace source/backend/CarlaStandalone.cpp \
      --replace-quiet '/usr/lib' '${placeholder "out"}/lib' || true
  '';

  postInstall = ''
    # Wrap Python scripts with correct environment
    wrapPythonProgramsIn "$out/share/carla" "$out $pythonPath"

    # Make executable scripts wrapper-friendly
    find "$out/share/carla/resources" -maxdepth 1 -type f -not -name "*.py" -print0 | while read -d "" f; do
      patchShebangs "$f"
    done

    # Create lib/carla directory for plugins
    mkdir -p "$out/lib/carla"

    # Ensure desktop files are correct
    for desktop in $out/share/applications/*.desktop; do
      if [ -f "$desktop" ]; then
        substituteInPlace "$desktop" \
          --replace-quiet '/usr' "$out" || true
      fi
    done
  '';

  # Wrap Qt applications properly
  dontWrapQtApps = !withQt;

  preFixup = let
    libPath = lib.makeLibraryPath (
      [ jack2 libjack2 libsndfile alsa-lib libpulseaudio ]
      ++ lib.optionals withX11 [ xorg.libX11 xorg.libXcursor xorg.libXext ]
      ++ lib.optional withFluidSynth fluidsynth
      ++ lib.optional withFFmpeg ffmpeg
      ++ lib.optional withSDL2 SDL2
      ++ lib.optional withOSC liblo
    );
  in ''
    for program in $out/bin/*; do
      if [ -f "$program" ] && [ -x "$program" ]; then
        ${if withQt then ''
          wrapQtApp "$program" \
            --prefix PYTHONPATH : "$PYTHONPATH" \
            --prefix LD_LIBRARY_PATH : "${libPath}"
        '' else ''
          wrapProgram "$program" \
            --prefix PYTHONPATH : "$PYTHONPATH" \
            --prefix LD_LIBRARY_PATH : "${libPath}"
        ''}
      fi
    done

    # Also wrap carla-single and bridge executables
    for bridge in $out/lib/carla/carla-bridge-* $out/lib/carla/carla-discovery-*; do
      if [ -f "$bridge" ] && [ -x "$bridge" ]; then
        wrapProgram "$bridge" \
          --prefix LD_LIBRARY_PATH : "${libPath}" || true
      fi
    done
  '';

  passthru = {
    # Allow users to check what features are enabled
    features = {
      inherit withFrontend withQt withGtk2 withGtk3 withX11 withFFmpeg withFluidSynth withProjectM withSDL2 withOSC withHylia;
    };
    # Allow overriding features easily
    override = newAttrs: finalAttrs.finalPackage.override (newAttrs);
  };

  meta = {
    homepage = "https://kx.studio/carla";
    description = "A fully-featured audio plugin host with support for many audio drivers and plugin formats";
    longDescription = ''
      Carla is a fully-featured modular audio plugin host, with support for
      many audio drivers and plugin formats. It has some nice features like
      transport control, automation of parameters via MIDI CC and remote
      control over OSC.

      Carla currently supports LADSPA, DSSI, LV2, VST2, VST3 and AU plugin formats,
      plus SF2, SF3 and SFZ file support. It uses JACK as the default and preferred
      audio driver but also supports native drivers like ALSA, PulseAudio, SDL2 and more.

      Carla is also available as an LV2 and VST2 plugin itself, allowing it to be
      loaded inside other DAWs.

      This package is built with the following features:
      - Frontend (GUI): ${if withFrontend then "YES" else "NO"}
      - Qt5 UI support: ${if withQt then "YES" else "NO"}
      - GTK2 UI support: ${if withGtk2 then "YES" else "NO"}
      - GTK3 UI support: ${if withGtk3 then "YES" else "NO"}
      - X11 support: ${if withX11 then "YES" else "NO"}
      - FFmpeg support: ${if withFFmpeg then "YES" else "NO"}
      - FluidSynth (SF2/SF3): ${if withFluidSynth then "YES" else "NO"}
      - SDL2 audio driver: ${if withSDL2 then "YES" else "NO"}
      - OSC remote control: ${if withOSC then "YES" else "NO"}
      - Ableton Link (Hylia): ${if withHylia then "YES" else "NO"}
    '';
    changelog = "https://github.com/falkTX/Carla/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
    mainProgram = "carla";
  };
})
