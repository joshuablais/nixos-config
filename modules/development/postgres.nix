{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureDatabases = [
      "dev"
      "joshua"
    ];
    ensureUsers = [
      {
        name = "joshua";
        ensureDBOwnership = true;
        ensureClauses.superuser = true;
      }
    ];
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
    '';

    # Dev-optimized settings
    settings = {
      log_statement = "all"; # See every query
      fsync = false; # Dangerous in prod
      synchronous_commit = false;
    };

    extensions =
      ps: with ps; [
        pgvector # Embeddings
        pg_uuidv7
      ];
  };
}
