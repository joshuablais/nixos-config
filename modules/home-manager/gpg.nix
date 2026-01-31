# home-manager config
{ config, pkgs, ... }:
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
    defaultCacheTtlSsh = 86400;
    maxCacheTtlSsh = 86400;
    pinentry.package = pkgs.pinentry-emacs;
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };

  programs.gpg = {
    enable = false;
  };

  home.file.".gnupg/gpg.conf".text = ''
    use-agent
    pinentry-mode loopback
  '';
}
