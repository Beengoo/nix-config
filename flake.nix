{
	description = "My nix config";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};
	outputs = {nixpkgs, home-manager, ...} @inputs: let system = "x86_64-linux"; pkgs = import nixpkgs { inherit system; config.allowUnfree = true; }; in{
		nixosConfigurations = {
			nixos = nixpkgs.lib.nixosSystem {
				modules = [./configuration.nix];
				specialArgs = {
					inherit system inputs;
				};
			};
		};
		homeConfigurations = {
			beengoo = home-manager.lib.HomeManagerConfiguration {inherit pkgs; modules = [./home.nix];};
		};
	};
}
