{ pkgs, zen-browser, hytale-launcher, ... }: {

  home.packages = with pkgs; [
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    discord-canary
    btop
    lsp-plugins
    prismlauncher
    telegram-desktop
    qpwgraph
    ostree
    librecad
    gnome-network-displays
    networkmanagerapplet
    jdt-language-server
    android-tools
    scrcpy
    gthumb
    libreoffice-qt-fresh
    carla
    jetbrains.idea-community-bin
    hytale-launcher.packages.${pkgs.system}.default
    jdk21
    python3
    maven
    gradle
    ant
    osu-lazer
    hopondesk
    claude-code
    kdePackages.gwenview
    vlc
    kdePackages.dolphin
    kdePackages.ark
    gpu-screen-recorder
    cliphist
    wl-clipboard
    zip
    vesktop
    unzip
    brightnessctl
    youtube-music
    ddcutil
    matugen
    cava
    wlsunset
    dbeaver-bin
    evolution-data-server
    fzf
    nixd
    nixfmt-classic
    ripgrep
    hyprlock
    hypridle
    kdePackages.kdeconnect-kde
  ];
  # Why everybody forget about prime offload?
  # Oh wait.. I know..
  xdg.desktopEntries.hytale-launcher = {
    name = "Hytale";
    genericName = "Hytale Launcher";
    comment = "Launch Hytale";
    exec = "env __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia hytale-launcher %U";
    icon = "hytale-launcher";
    terminal = false;
    categories = [ "Game" ];
    startupNotify = true;
  };

  services.flameshot = {
    # Also installs/enables flameshot
    enable = true;
    settings = {
      General = {
        useGrimAdapter = true;
        # Stops warnings for using Grim
        disabledGrimWarning = true;
      };
    };
  };
  programs = {
    zsh = { enable = true; };
    noctalia-shell = {
      enable = true;
      systemd.enable = true;
    };
    starship = { enable = true; };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [ obs-pipewire-audio-capture ];
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    neovim = {
      enable = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      plugins = [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];
    };
    home-manager.enable = true;
    fzf = { enable = true; };
    carapace = {
      enable = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };
  };
}
