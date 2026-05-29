{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    signal-desktop
    thunderbird
    cinny-desktop
  ];
}
