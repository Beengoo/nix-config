# Theme for graphical apps
{ lib, pkgs, ... }:
let gtk-theme = "catppuccin-mocha-blue-standard";
in {
  home.packages = with pkgs; [
    (catppuccin-kvantum.override {
      accent = "blue";
      variant = "mocha";
    })
    papirus-folders
  ];

  # Cursor setup
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
    gtk.enable = true;
    x11 = {
      enable = true;
      defaultCursor = true;
    };
  };

  # GTK Setup
  gtk = {
    enable = true;
    theme = {
      name = gtk-theme;
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "blue";
      };
    };

    gtk3 = {
      bookmarks = [

      ];
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };
  dconf.settings = {
    "org/gtk/settings/file-chooser" = { sort-directories-first = true; };

    # GTK4 Setup
    "org/gnome/desktop/interface" = {
      gtk-theme = gtk-theme;
      color-scheme = "prefer-dark";
    };
  };

  xdg.configFile = {
    kvantum = {
      target = "Kvantum/kvantum.kvconfig";
      text =
        lib.generators.toINI { } { General.theme = "catppuccin-mocha-blue"; };
    };

    qt5ct = {
      target = "qt5ct/qt5ct.conf";
      text = lib.generators.toINI { } {
        Appearance = { icon_theme = "Papirus-Dark"; };
      };
    };

    qt6ct = {
      target = "qt6ct/qt6ct.conf";
      text = lib.generators.toINI { } {
        Appearance = { icon_theme = "Papirus-Dark"; };
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
    style = { name = "kvantum"; };
  };

  systemd.user.sessionVariables = { QT_STYLE_OVERRIDE = "kvantum"; };
}
