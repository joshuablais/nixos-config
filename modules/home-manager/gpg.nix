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

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

  home.activation.sshConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sf /run/agenix/sshConfig $HOME/.ssh/config
  '';
}
