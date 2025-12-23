# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
	imports =
		[
		./hardware-configuration.nix
		./system/services.nix
		];

	fonts = {
		packages = with pkgs; [ material-icons ]++builtins.filter lib.attrsets.isDerivation(builtins.attrValues pkgs.nerd-fonts);
		fontDir.enable = true;
	};

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
		plymouth = {
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
	nix.extraOptions = ''
		use-xdg-base-directories = true
		'';
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


	system.stateVersion = "26.05";
}

