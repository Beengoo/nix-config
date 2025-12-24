{config, ...}: {
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
			open			= true;
			nvidiaSettings	= true;
			package			= config.boot.kernelPackages.nvidiaPackages.stable;
		};
	};
	services.blueman.enable = true;
}
