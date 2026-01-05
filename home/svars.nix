{config, pkgs, ...}: {
  home.sessionVariables = {
    EDITOR = "nvim";
    NH_FLAKE = "${config.home.homeDirectory}/nix";
    JAVA_HOME = "${pkgs.jdk21}";
    LOMBOK_HOME = "${pkgs.lombok}/share/java/lombok.jar";
  };
}
