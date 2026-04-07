# USB Apple SuperDrive setup

{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.udev.extraRules = ''
    # Apple USB SuperDrive initialization
    ACTION=="add", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="1500", RUN+="${pkgs.sg3_utils}/bin/sg_raw /dev/$kernel EA 00 00 00 00 00 01"
  '';

  environment.systemPackages = with pkgs; [
    sg3_utils
  ];
}
