{pkgs}: {
  home = {
    username = "beengoo";
    homeDirectory = "/home/beengoo";
    stateVersion = "26.05";
  };
  xdg = {
    mime.enable = true;
    portal.configPackages = [ pkgs.xdg-desktop-portal-hyprland ];
  };
  wayland.windowManager.hyprland.xwayland.enable = true;
}
