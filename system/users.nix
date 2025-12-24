{pkgs, ...}: {
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
}
