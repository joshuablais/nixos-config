# home-manager config
{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = false;
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
    pinentry.package = pkgs.pinentry-emacs;
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };

  programs.gpg = {
    enable = true;
    settings = {
      use-agent = true;
      pinentry-mode = "loopback";
    };
  };

  programs.ssh = {
    enable = false;
  };
}
