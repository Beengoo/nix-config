{pkgs, ...}: {
	networking.hostName = "nixos";
	networking.networkmanager.enable = true;
	networking.wireless.enable = false;
	networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
}
