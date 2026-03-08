{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./locale.nix
    ./networking.nix
    ./nix-settings.nix
    ./ssh.nix
  ];
}
