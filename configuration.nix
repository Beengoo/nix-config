# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
	imports =
		[
		./hardware-configuration.nix
		];
	boot = {
		kernelPackages = pkgs.linuxPackages_latest;
		tmp.cleanOnBoot = true;
		loader = {
			efi.canTouchEfiVariables = true;
			grub = {
				enable = true;
				device = "nodev";
				efiSupport = true;
				useOSProber = true;
				gfxmodeEfi = "1920x1080";
			};
			timeout = 5;
		};
		plymouth = rec {
			enable = true;
			themePackages = with pkgs; [(adi1090x-plymouth-themes.override {selected_themes = ["rings"];})];
		};

		consoleLogLevel = 0;
		initrd.verbose = false;
		kernelParams = [
			"quiet"
			"splash"
			"boot.shell_on_fail"
			"loglevel=3"
			"rd.systemd.show_status=false"
			"rd.udev.log_level=3"
			"udev.log_priority=3"
		];

	};
	fonts = {
		packages = with pkgs; [ material-icons ]++builtins.filter lib.attrsets.isDerivation(builtins.attrValues pkgs.nerd-fonts);
		fontDir.enable = true;
	};
	services.gnome.gcr-ssh-agent.enable = false;
	services.usbmuxd.enable = true;
	services.zerotierone = {
		enable = false;
		joinNetworks = [];

	};
	networking.hostName = "nixos";
	users.users.beengoo = {
		initialPassword = "1234";
		isNormalUser = true;
		extraGroups = [
			"dialout"
				"plugdev"
				"wheel"
				"networkmanager"
				"video"
				"plugdev"
				"render"
				"lp"
				"scanner"
		];
		shell = pkgs.nushell;
	};
	environment.systemPackages = with pkgs; [
		nh
			git
			neovim
			tmux
			home-manager
			wezterm
	];
	services.pipewire = {
		enable 		= true;
		pulse.enable 	= true;
		alsa.enable 	= true;
		jack.enable 	= true;
	};
	security.rtkit.enable = true;
	hardware = {
		bluetooth.enable = true;
		graphics = {
			enable 		= true;
			enable32Bit 	= true;
		};
		nvidia = {
			modesetting.enable 		= true;
			powerManagement.enable 		= false;
			powerManagement.finegrained 	= false;
			open				= true;
			nvidiaSettings			= true;
			package				= config.boot.kernelPackages.nvidiaPackages.stable;
		};
	};
	services.blueman.enable = true;
	nix.extraOptions = ''
		use-xdg-base-directories = true
		'';
	services.xserver.videoDrivers = ["nvidia"];
	systemd.services.NetworkManager-wait-online.enable = false;
	services.greetd = {
		enable = true;
		restart = true;
		settings = {
			default_session = {
				user = "greeter";
				command = "${pkgs.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:$SHELL --asterisks";
			};
		};
	};
	services.speechd.enable = false;
	nixpkgs.config.allowUnfree = true;
	nix.settings.experimental-features = "nix-command flakes";
	nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
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
	systemd = {

		user.services.polkit-gnome-authentication-agent-1 = {
			description = "polkit-gnome-authentication-agent-1";
			wantedBy = [ "graphical-session.target" ];
			wants = [ "graphical-session.target" ];
			after = [ "graphical-session.target" ];
			serviceConfig = {
				Type = "simple";
				ExecStart =
					"${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
				Restart = "on-failure";
				RestartSec = 1;
				TimeoutStopSec = 10;
			};
		};
	};
	services.gnome.gnome-keyring.enable = true;
	programs = {
		hyprland = {
			enable = true;
			xwayland.enable = true;
			withUWSM = true;
		};
		steam.enable = true;
		nano.enable = false;
		ssh.startAgent = true;
	};
	networking.networkmanager.enable = true;
	system.stateVersion = "26.05"; # DO NOT TOUCH!!!!!!!!!!!!!!!!!!!!

}

