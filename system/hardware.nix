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

	fileSystems."/home/beengoo/arch" = 
		{
			device = "/dev/disk/by-uuid/8354ea92-7e8a-4996-b9f7-f234f91da872";
			fsType = "ext4";
			options = [ "rw" ];
		};
}
