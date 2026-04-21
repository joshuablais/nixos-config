# ~/nixos-config/modules/home-manager/emacs.nix
{ config, pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    extraPackages =
      epkgs: with epkgs; [
        vterm
        pdf-tools
        treesit-grammars.with-all-grammars
        mu4e
      ];
  };

  home.packages = with pkgs; [
    # --- vterm compile deps ---
    cmake
    gnumake
    libtool

    # For OMEMO in jabber.el
    mbedtls
    pkg-config

    # --- search / navigation ---
    ripgrep
    fd

    # --- vcs ---
    git

    # --- fonts ---
    emacs-all-the-icons-fonts

    # --- spell checking (flyspell) ---
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science

    # --- org-mode / export ---
    # texlive.combined.scheme-full
    graphviz
    sqlite # org-roam, forge

    # --- image handling ---
    imagemagick
    ghostscript
    vips

    # --- window management ---
    wmctrl # emacs frame focus from CLI / scripts

    # --- linters / formatters (flycheck, apheleia, etc.) ---
    shellcheck
    html-tidy
    stylelint
    shfmt

    # --- general tools also used by emacs ---
    curl
    wget
    ledger
  ];

  home.sessionVariables = {
    EDITOR = "emacsclient -nw";
    VISUAL = "emacsclient -nw";
  };

  systemd.user.services.emacs = {
    Unit = {
      Description = "Emacs daemon";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "notify";
      ExecStart = "${config.programs.emacs.finalPackage}/bin/emacs --fg-daemon";
      ExecStop = "${config.programs.emacs.finalPackage}/bin/emacsclient --eval '(kill-emacs)'";
      Restart = "on-failure";
      Environment = [
        "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
      ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
