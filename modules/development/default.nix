{ config, pkgs, ... }:
{
  imports = [
    ./base.nix
    ./doom.nix
    ./go.nix
    ./postgres.nix
    ./python.nix
    ./rust.nix
  ];
}
