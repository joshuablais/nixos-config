{ lib, ... }:
{
  imports = [
    ../modules/security
    # NO audio modules
  ];

  time.timeZone = "UTC";

  networking.networkmanager.enable = lib.mkForce false;
  networking.useNetworkd = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Disable ALL documentation
  documentation.enable = lib.mkForce false;
  documentation.nixos.enable = lib.mkForce false;
  documentation.man.enable = lib.mkForce false;
  documentation.info.enable = lib.mkForce false;
  documentation.doc.enable = lib.mkForce false;

  boot.loader.systemd-boot.configurationLimit = 5;

  # Server hardening
  security.sudo.wheelNeedsPassword = true;
  services.fail2ban.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };
}
