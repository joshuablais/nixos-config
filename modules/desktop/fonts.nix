{ config, pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      alegreya
      nerd-fonts.geist-mono
      montserrat
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      google-fonts
    ];

    # Font configuration
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Alegreya" ];
        sansSerif = [ "Montserrat" ];
        monospace = [ "GeistMono Nerd Font" ];
      };
    };
  };
}
