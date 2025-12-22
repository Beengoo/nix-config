{config, pkgs, ...}: {
	imports = [./theme.nix];
	home.sessionVariable = {
		EDITOR="nvim";
		NH_FLAKE="${config.home.homeDirectory}/nix";
	};
	home = {
		username = "beengoo";
		homeDirectory = "/home/beengoo";
		stateVersion = "26.05";
	};
	xdg = {
		mime.enable = true;
		portal.configPackages = [pkgs.xdg-desktop-portal-hyprland];
	};
	wayland.windowManager.hyprland.xwayland.enable = true;
	home.packages = with pkgs; [
		discord-canary
		btop
		fzf
		ripgrep
		quickshell
		hyprlock
		hypridle
	];
	programs = {
		librewolf.enable = true;
		starship = {
			enable = true;
		};
		obs-studio = {
			enable = true;
			plugins = with pkgs.obs-studio-plugins; [
				obs-pipewire-capture
			];
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
			plugins = [
				pkgs.vimPlugins.nvim-treesitter.withAllGrammars
			];
		};
		nushell = {
			enable = true;
			settings = {
				show_banner = false;
				completions.external.enable = true;
			};
			shellAliases = config.home.shellAliases;
			environmentVariables = config.home.sessionVariables//{CARAPACE_BRIDGES="zsh";};
		};
		home-manager.enable = true;
		fzf = {
			enable = true;
		};
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
