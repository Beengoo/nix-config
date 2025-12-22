{config, ...}: {
  home.sessionVariables = {
    EDITOR = "nvim";
    NH_FLAKE = "${config.home.homeDirectory}/nix";
  };
}
