{pkgs, ...}: {
	networking.hostName = "nixos";
	networking.networkmanager.enable = true;
	networking.wireless.enable = false;
	networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
	networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
	networking.firewall.allowedTCPPorts = [5900];
	networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
}
