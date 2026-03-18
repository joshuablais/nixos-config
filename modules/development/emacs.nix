# this is a minimal emacs installation for lightweight machines
{
  config,
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    (emacs.override { withNativeCompilation = true; })
    emacs-all-the-icons-fonts
    # doom dependencies
    git
    ripgrep
    fd
    # vterm
    cmake
    gnumake
    libtool
  ];

  # Emacs as a system-level daemon via NixOS service
  services.emacs = {
    enable = true;
    package = pkgs.emacs.override { withNativeCompilation = true; };
    install = true;
  };

  environment.variables = {
    EDITOR = "emacsclient -nw";
    VISUAL = "emacsclient -nw";
  };
}
