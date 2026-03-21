{pkgs, ...}: {
	users.users.beengoo = {
		initialPassword = "1234";
		isNormalUser = true;
		extraGroups = [
			"virt-manager"
			"virt-viewer"
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
		shell = pkgs.zsh;
	};
}
