{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Set to lat lon of your current location
  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 53.5;
    longitude = -113.3;
    temperature = {
      day = 6500;
      night = 2500;
    };
    settings = {
      general = {
        dawn-time = "6:00";
        dusk-time = "18:00";
      };
    };
  };
}
