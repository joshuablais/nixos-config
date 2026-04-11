{ config, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
  };

  # dbus display
  services.mpd-mpris.enable = true;
}
