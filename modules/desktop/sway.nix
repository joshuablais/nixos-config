{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common.default = "*";
      sway.default = lib.mkForce [
        "wlr"
        "gtk"
      ];
    };
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    cliphist
    grim
    slurp
    kanshi
    swayidle
    wl-clipboard
    wl-color-picker
    wl-kbptr
    wlsunset
    wtype
    xclip
    kitty
    noctalia-shell
    wofi
  ];

  services.fprintd.enable = true;
  security.pam.services.swaylock.fprintAuth = true;
}
