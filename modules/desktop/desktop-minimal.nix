{ config, pkgs, ... }:
{
  imports = [
    ./display-manager.nix
    ./fonts.nix
    # ./gaming.nix
    ./hyprland.nix
    ./kmonad.nix
    ./networking.nix
    ./power.nix
    ./storage.nix
    ./theming.nix
  ];
}
