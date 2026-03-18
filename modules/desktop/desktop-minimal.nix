{ config, pkgs, ... }:
{
  imports = [
    ./fonts.nix
    ./hyprland.nix
    ./kmonad.nix
    ./networking.nix
    ./power.nix
    ./storage.nix
    ./theming.nix
  ];
}
