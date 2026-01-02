{ pkgs, zen-browser, config, ... }: {

  home.packages = with pkgs; [
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    discord-canary
    btop
    prismlauncher
    carla
    osu-lazer
    kdePackages.gwenview
    vlc
    kdePackages.dolphin
    kdePackages.ark
    gpu-screen-recorder
    cliphist
    wl-clipboard
    zip
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
    nushell = {
      enable = true;
      settings = {
        show_banner = false;
        completions.external.enable = true;
      };
      shellAliases = config.home.shellAliases;
      environmentVariables = config.home.sessionVariables // {
        CARAPACE_BRIDGES = "zsh";
      };
    };
    home-manager.enable = true;
    fzf = { enable = true; };
    carapace = {
      enable = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
    };
  };
}
