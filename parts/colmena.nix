{ self, inputs, ... }:
let
  lib = inputs.nixpkgs.lib;

  hosts = builtins.attrNames self.nixosConfigurations;

  deployableHosts = builtins.filter (host: builtins.pathExists ../hosts/${host}/deployment.nix) hosts;

  mkNode =
    host:
    {
      imports = self.nixosConfigurations.${host}._module.args.modules;
    }
    // (import ../hosts/${host}/deployment.nix);

in
{
  flake.colmena = {
    meta = {
      nixpkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      specialArgs = { inherit inputs; };
    };
  }
  // builtins.listToAttrs (
    map (host: {
      name = host;
      value = mkNode host;
    }) deployableHosts
  );
}
