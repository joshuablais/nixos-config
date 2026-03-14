{ self, inputs, ... }:
let
  lib = inputs.nixpkgs.lib;

  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
    overlays = [ inputs.nur.overlays.default ];
  };

  base = [
    inputs.agenix.nixosModules.default
  ];

  desktop = base ++ [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.joshua = import ../modules/home-manager;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.backupFileExtension = "backup";
    }
  ];

  mkHost =
    hostname: modules:
    lib.nixosSystem {
      inherit pkgs;
      specialArgs = { inherit inputs; };
      modules = [ ../hosts/${hostname}/configuration.nix ] ++ modules;
    };
in
{
  flake.nixosConfigurations = {
    theologica = mkHost "theologica" desktop;
    logos = mkHost "logos" desktop;
    king = mkHost "king" desktop;
    axios = mkHost "axios" desktop;
    empirica = mkHost "empirica" base;
    empire = mkHost "empire" base;
  };
}
