let
  # main machine key
  joshua = "age1k0sc4ugaxzpav2rs8cmugwthaa3tpuzygvax8u84m6sm9ldh737qspv058";

  # server machine key
  empirica = "age1gt2m3dtrkx3lwnddwv62fesadyd5pkmadtwtdfwvcs4lhcyqt33qfq386s";

  users = [ joshua ];
  servers = [ empirica ];
  allSystems = users ++ servers;
in

# Create secrets here:
{
  "canlock.age".publicKeys = users;
  "gnus-name.age".publicKeys = users;
  "gnus-email.age".publicKeys = users;
  "restic-password.age".publicKeys = users;
  "storagebox.age".publicKeys = users;
  "ssh-config.age".publicKeys = users;
  "miniflux-admin.age".publicKeys = servers;
  "cloudflare-api-token.age".publicKeys = servers;
}
