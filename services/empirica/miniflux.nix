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
      createDatabaseLocally = true;
      config = {
        LISTEN_ADDR = "127.0.0.1:8082";
        POLLING_FREQUENCY = "15";
        DATABASE_URL = "user=miniflux host=/run/postgresql dbname=miniflux";
      };
      adminCredentialsFile = "/run/agenix/miniflux-admin";
    };

    # Static identity: resolvable from /etc/passwd, no NSS daemon in the path.
    users.users.miniflux = {
      isSystemUser = true;
      group = "miniflux";
    };
    users.groups.miniflux = { };

    systemd.services.miniflux = {
      serviceConfig = {
        DynamicUser = mkForce false;
        User = mkForce "miniflux";
        Group = mkForce "miniflux";
      };
      startLimitIntervalSec = 300;
      startLimitBurst = 5;
    };
  };
}
