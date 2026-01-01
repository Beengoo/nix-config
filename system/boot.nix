{pkgs, ...}: {
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
			"resume_offset=51200"
		];
		resumeDevice = "/dev/disk/by-uuid/1973ccd4-dc8a-44fc-8491-e723eac6629e";

	};

	# Hibrnation
	powerManagement.enable = true;
	swapDevices = [
		{
			device = "/var/lib/swapfile";
			size = 16 * 1024;
		}
	];
}
