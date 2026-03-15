{ config, pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages =
      epkgs: with epkgs; [
        doom
        vterm
        pdf-tools
        org-roam
        treesit-grammars.with-all-grammars
        mu4e
      ];
  };
  systemd.user.services.emacs = {
    Unit = {
      Description = "Emacs daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Requires = [ "graphical-session.target" ];
    };
    Service = {
      Type = "notify";
      ExecStart = "${config.programs.emacs.finalPackage}/bin/emacs --fg-daemon";
      ExecStop = "${config.programs.emacs.finalPackage}/bin/emacsclient --eval '(kill-emacs)'";
      Restart = "on-failure";
      PassEnvironment = [
        "WAYLAND_DISPLAY"
        "XDG_RUNTIME_DIR"
        "DISPLAY"
      ];
      Environment = [
        "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
        "GDK_BACKEND=wayland"

      ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  home.sessionPath = [ "${config.home.homeDirectory}/.emacs.d/bin" ];
  home.sessionVariables = {
    DOOMDIR = "${config.home.homeDirectory}/.config/doom";
    DOOMLOCALDIR = "${config.home.homeDirectory}/.local/share/doom";
  };
}
