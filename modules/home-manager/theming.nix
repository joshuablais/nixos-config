{ pkgs, ... }:
let
  cursor = {
    name = "Nordzy-cursors-white";
    package = pkgs.nordzy-cursor-theme;
    size = 24;
  };
in
{
  home.pointerCursor = cursor // {
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Zafiro-icons-Dark";
      package = pkgs.zafiro-icons;
    };

    gtk2.extraConfig = ''gtk-key-theme-name = "Emacs"'';
    gtk3.extraConfig.gtk-key-theme-name = "Emacs";
  };

  dconf.settings."org/gnome/desktop/interface" = {
    gtk-key-theme = "Emacs";
    cursor-theme = cursor.name;
    cursor-size = cursor.size;
  };

  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";

    # HM-side overlays are illegal under useGlobalPkgs (HM ec80131).
    # Remove once stylix guards on osConfig.home-manager.useGlobalPkgs.
    overlays.enable = false;

    targets = {
      firefox = {
        enable = true;
        profileNames = [ "default" ];
      };
      wofi.enable = true;
      kitty.enable = false;
      waybar.enable = false;
      emacs.enable = false;
    };

    # Nowhere
    base16Scheme = {
      base00 = "1a1d21";
      base01 = "22262b";
      base02 = "282c34";
      base03 = "3d424a";
      base04 = "c0bdb8";
      base05 = "e0dcd4";
      base06 = "e8e4dc";
      base07 = "f5f2eb";
      base08 = "c8beb8";
      base09 = "c8c0b0";
      base0A = "ccc4b0";
      base0B = "b4beb4";
      base0C = "b0bcc8";
      base0D = "b4bec8";
      base0E = "c4beb8";
      base0F = "c0b8bc";
    };
  };
}
