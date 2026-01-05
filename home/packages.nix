{ pkgs, zen-browser, ... }: {

  home.packages = with pkgs; [
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    discord-canary
    btop
    lsp-plugins
    prismlauncher
    qpwgraph
    networkmanagerapplet
    jdt-language-server
    carla
    jetbrains.idea-community-bin
    jdk21
    python3
    maven
    gradle
    ant
    osu-lazer
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
    evolution-data-server
    fzf
    nixd
    nixfmt-classic
    ripgrep
    hyprlock
    hypridle
  ];
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
