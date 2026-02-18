{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    signal-desktop
    telegram-desktop
    element-desktop
    dino
    thunderbird
  ];
}
