{ config, lib, ... }:
{
  age.identityPaths = [
    "/etc/age/keys.txt"
  ];

  age.secrets = {
    miniflux-admin = {
      file = ../secrets/miniflux-admin.age;
      owner = "root";
      group = "root";
      mode = "0400"; # Root readable only
    };
    cloudflare-api-token = {
      file = ../secrets/cloudflare-api-token.age;
      owner = "caddy";
      group = "caddy";
      mode = "0400";
    };
    searx-key = {
      file = ../secrets/searx-key.age;
      owner = "searx";
      group = "searx";
      mode = "0400";
    };
  };
}
