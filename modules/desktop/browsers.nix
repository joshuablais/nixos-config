{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    librewolf
    (ungoogled-chromium.override {
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--enable-features=WaylandWindowDecorations"
        "--enable-wayland-ime=true"
        "--gtk-version=4"
      ];
    })
    tor-browser
  ];
}
