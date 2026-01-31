{ config, pkgs, ... }:
{
  # Install security tools system-wide
  environment.systemPackages = with pkgs; [
    gnupg
    age
    # pinentry-all
    (pass-wayland.withExtensions (
      exts: with exts; [
        pass-otp
        pass-import
        pass-audit
      ]
    ))
  ];
}
