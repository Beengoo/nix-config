{pkgs, ...}: {
	networking.hostName = "nixos";
	networking.networkmanager.enable = true;
	networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
}
