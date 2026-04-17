# modules/emacs-filechooser.nix
{ pkgs, lib, ... }:
pkgs.stdenv.mkDerivation {
  pname = "emacs-filechooser-portal";
  version = "git";
  src = pkgs.fetchgit {
    url = "https://codeberg.org/rahguzar/filechooser";
    rev = "866304ab4244865108e12499f6e3be63e4981f92";
    hash = "sha256-P+L9OA9gU/cq/E39bBSzetWrxNwGQUwRyzXZob/qtjQ=";
  };
  nativeBuildInputs = [ pkgs.emacs ]; # brings emacsclient into PATH during build for substituteInPlace
  installPhase = ''
    mkdir -p $out/share/dbus-1/services/
    substitute org.gnu.Emacs.FileChooser.service \
      $out/share/dbus-1/services/org.gnu.Emacs.FileChooser.service \
      --replace "/usr/bin/emacsclient" "${pkgs.emacs}/bin/emacsclient"
    mkdir -p $out/share/xdg-desktop-portal/portals/
    cp emacs.portal $out/share/xdg-desktop-portal/portals/
  '';
}
