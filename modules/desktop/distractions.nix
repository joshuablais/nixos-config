{
  config,
  lib,
  pkgs,
  ...
}:

# Apps I find distracting
{
  environment.systemPackages = with pkgs; [
    telegram-desktop
    dino
  ];
}
