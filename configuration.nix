# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, inputs, ... }:

let
  prime-run = pkgs.writeShellScriptBin "prime-run" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in {
  imports = [
    ./system/users.nix
    ./hardware-configuration.nix
    ./system/services.nix
    ./system/audio.nix
    ./system/hardware.nix
    ./system/fonts.nix
    ./system/zerotierone.nix
    ./system/boot.nix
    ./system/network.nix
  ];
  environment.systemPackages = with pkgs; [
    nh
    prime-run
    git
    openvpn
    pipewire.jack
    neovim
    neovide
    tmux
    home-manager
    sshfs
    docker
    docker-compose
    fuse3
    kdePackages.kio-fuse
    kdePackages.konsole
    kdePackages.kwallet
    kdePackages.kio
    kdePackages.kio-extras
  ];
  environment.etc."xdg/menus/applications.menu".text = ''
    <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
     "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
    <Menu>
      <Name>Applications</Name>
      <Directory>kde-main.directory</Directory>
      <DefaultAppDirs/>
      <DefaultDirectoryDirs/>
      <DefaultMergeDirs/>
      <Include>
        <All/>
      </Include>
    </Menu>
  '';
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [ stdenv.cc.cc.lib zlib glib libz libx11 ];
    };
    zsh.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
    steam.enable = true;
    nano.enable = false;
    ssh.startAgent = true;
  };

  security.rtkit.enable = true;
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  nix.extraOptions = ''
    use-xdg-base-directories = true
  '';
  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        user = "greeter";
        command =
          "${pkgs.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:$SHELL --asterisks";
      };
    };
  };
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  time.timeZone = "Europe/Kyiv";
  i18n.defaultLocale = "en_US.UTF-8";
  security = {
    polkit.enable = true;
    pam = {
      services = {
        ags = { };
        sddm.enableGnomeKeyring = true;
      };
    };
  };
  system.stateVersion = "26.05";
}

