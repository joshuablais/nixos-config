{ config, pkgs, ... }:
{
  imports = [
    ./base.nix
    ./go.nix
    # ./postgres.nix
    ./python.nix
    ./rust.nix
  ];
}
