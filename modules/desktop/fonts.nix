{ config, pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      alegreya
      texlivePackages.cormorantgaramond
      nerd-fonts.geist-mono
      montserrat
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
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
