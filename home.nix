{ noctalia, ... }: {
  imports = [
    ./home/theme.nix
    ./home/packages.nix
    ./home/svars.nix
    ./home/general.nix
    noctalia.homeModules.default
  ];
}
