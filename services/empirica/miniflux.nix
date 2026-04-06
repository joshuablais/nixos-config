{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.homelab;
in
{
  config = mkIf cfg.enable {
    services.miniflux = {
      enable = true;
      config = {
        LISTEN_ADDR = "0.0.0.0:8082";
        POLLING_FREQUENCY = "15";
      };
      adminCredentialsFile = "/run/agenix/miniflux-admin";
    };
  };
}
