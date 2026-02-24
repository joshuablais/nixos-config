{ config, pkgs, ... }:

{
  # Enable Hyprland at system level
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common.default = "*";
      hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1"; # Also helps Electron apps
  };

  # Install Hyprland ecosystem packages
  environment.systemPackages = with pkgs; [
    cliphist
    grim
    hypridle
    hyprlock
    hyprpicker
    hyprsunset
    hyprutils
    hyprwayland-scanner
    kitty
    slurp
    swaynotificationcenter
    swww
    waybar
    wl-clipboard
    wl-kbptr
    wlsunset
    wofi
    wtype
    xclip
  ];

  services.fprintd.enable = true;

  security.pam.services.hyprlock = {
    fprintAuth = true;
  };
}
