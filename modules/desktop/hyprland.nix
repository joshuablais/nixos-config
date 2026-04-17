# ~/nixos-config/modules/desktop/hyprland.nix
{
  config,
  pkgs,
  lib,
  ...
}:
let
  emacsPortal = import ./emacs-filechooser.nix { inherit pkgs lib; };
in
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      emacsPortal
    ];
    config = {
      common = {
        "org.freedesktop.impl.portal.FileChooser" = [ "emacs" ];
      };
      hyprland = {
        default = [
          "emacs"
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "emacs" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screencast" = [ "hyprland" ];
      };
    };
  };

  # Ensure DBus knows about the new service
  services.dbus.packages = [ emacsPortal ];

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1"; # Also helps Electron apps
  };

  # Install Hyprland ecosystem packages
  environment.systemPackages = with pkgs; [
    cliphist
    grim
    hypridle
    hyprpicker
    hyprutils
    hyprwayland-scanner
    kitty
    slurp
    noctalia-shell
    # hyprlock
    # hyprsunset
    # swaynotificationcenter
    # swww
    wlsunset
    # waybar
    wl-clipboard
    wl-kbptr
    wofi
    wtype
    xclip
  ];

  services.fprintd.enable = true;

  security.pam.services.hyprlock = {
    fprintAuth = true;
  };
}
