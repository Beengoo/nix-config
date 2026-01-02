{
  lib,
  stdenv,
  fetchFromGitHub,
  # Build tools
  pkg-config,
  which,
  python3Packages,
  python3,
  makeWrapper,
  # Feature flags
  withFrontend ? true,
  withQt ? true,
  withGtk2 ? true,
  withGtk3 ? true,
  withX11 ? true,
  withFFmpeg ? true,
  withFluidSynth ? true,
  withProjectM ? false,
  withSDL2 ? true,
  withOSC ? true,
  # Core dependencies
  file,
  liblo,
  alsa-lib,
  fluidsynth,
  libpulseaudio,
  libsndfile,
  # Qt5
  qt5,
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
  # Additional deps
  fftw,
  fftwFloat,
  zlib,
  libGLU,
  libGL,
  # JACK - use PipeWire's JACK by default
  pipewire,
  # Keep jack2 for building only (headers)
  jack2,
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

  patches = [
    ./patches/tray-icon.patch
  ];

  nativeBuildInputs = [
    python3Packages.wrapPython
    pkg-config
    which
    makeWrapper
  ] ++ lib.optional withQt qt5.wrapQtAppsHook;

  pythonPath = with python3Packages; [
    rdflib
    pyliblo3
  ] ++ lib.optionals withFrontend [ pyqt5 pyqt5-sip ];

  buildInputs = [
    file
    alsa-lib
    jack2      # Still needed for headers during build
    libjack2
    libpulseaudio
    libsndfile
    zlib
    fftw
    fftwFloat
    libGL
    libGLU
  ]
  ++ lib.optional withOSC liblo
  ++ lib.optionals withQt [ qt5.qtbase qt5.qtsvg ]
  ++ lib.optional withGtk2 gtk2
  ++ lib.optional withGtk3 gtk3
  ++ lib.optionals withX11 [
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXrandr
    xorg.libXinerama
  ]
  ++ lib.optional withFluidSynth fluidsynth
  ++ lib.optional withFFmpeg ffmpeg
  ++ lib.optional withSDL2 SDL2
  ++ lib.optional (withProjectM && libprojectM != null) libprojectM;

  propagatedBuildInputs = finalAttrs.pythonPath;

  enableParallelBuilding = true;

  makeFlags = [
    "PREFIX=$(out)"
    "LIBDIR=$(out)/lib"
  ];

  installFlags = [ "PREFIX=$(out)" ];

  postPatch = ''
    patchShebangs data/
    patchShebangs source/

    # --with-appname="$0" is evaluated with $0=.carla-wrapped instead of carla
    # Fix that by replacing $0 with the actual program name
    for file in $(grep -rl -- '--with-appname="$0"'); do
      filename="$(basename -- "$file")"
      substituteInPlace "$file" --replace '--with-appname="$0"' "--with-appname=\"$filename\""
    done
  ''
  + lib.optionalString withGtk2 ''
    # Will try to dlopen() libgtk-x11-2.0 at runtime when using the bridge
    substituteInPlace source/bridges-ui/Makefile \
      --replace '$(CXX) $(OBJS_GTK2)' '$(CXX) $(OBJS_GTK2) -lgtk-x11-2.0'
  '';

  # Don't wrap Qt apps in postInstall - we do it in postFixup
  dontWrapQtApps = true;

  postFixup = let
    # Use PipeWire's JACK library FIRST in the path, then fall back to others
    libPath = lib.makeLibraryPath (
      [ pipewire.jack ]  # PipeWire JACK first!
      ++ [ libsndfile alsa-lib libpulseaudio ]
      ++ lib.optionals withX11 [ xorg.libX11 xorg.libXcursor xorg.libXext ]
      ++ lib.optional withFluidSynth fluidsynth
      ++ lib.optional withFFmpeg ffmpeg
      ++ lib.optional withSDL2 SDL2
      ++ lib.optional withOSC liblo
      ++ lib.optional withGtk2 gtk2
      ++ lib.optional withGtk3 gtk3
    );
    pythonPathStr = with python3Packages; lib.makeSearchPath python3.sitePackages ([
      rdflib
      pyliblo3
    ] ++ lib.optionals withFrontend [ pyqt5 pyqt5-sip ]);
  in ''
    # Wrap Python programs in bin/
    wrapPythonPrograms

    # Wrap resources
    wrapPythonProgramsIn "$out/share/carla/resources" "$out $pythonPath"

    # Wrap the main executables in share/carla that are not .py files
    # These need both Qt wrapping and PYTHONPATH
    find "$out/share/carla" -maxdepth 1 -type f -not -name "*.py" -not -name ".*" -print0 | while read -d "" f; do
      chmod +x "$f" || true
      patchShebangs "$f"
      if [ -x "$f" ]; then
        wrapQtApp "$f" \
          --prefix PYTHONPATH : "${pythonPathStr}" \
          --prefix LD_LIBRARY_PATH : "${libPath}"
      fi
    done

    # Wrap resources that need it (non-Python files)
    find "$out/share/carla/resources" -maxdepth 1 -type f -not -name "*.py" -not -name ".*" -print0 | while read -d "" f; do
      chmod +x "$f" || true
      patchShebangs "$f"
      if [ -x "$f" ]; then
        wrapProgram "$f" \
          --prefix PYTHONPATH : "${pythonPathStr}" \
          --prefix LD_LIBRARY_PATH : "${libPath}"
      fi
    done
  '';

  passthru = {
    features = {
      inherit withFrontend withQt withGtk2 withGtk3 withX11 withFFmpeg withFluidSynth withProjectM withSDL2 withOSC;
    };
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
      plus SF2, SF3 and SFZ file support.
    '';
    changelog = "https://github.com/falkTX/Carla/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
    mainProgram = "carla";
  };
})
