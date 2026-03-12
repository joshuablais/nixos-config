{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/cli-tui
    ../../modules/shared
    ../../modules/security
    ../../services/empirica
    ../../modules/secrets-empirica.nix
  ];

  services.homelab.enable = true;

  networking.hostName = "empirica";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.groups.joshua = { };

  users.users.joshua = {
    isNormalUser = true;
    description = "joshua";
    extraGroups = [
      "networkmanager"
      "wheel"
      "uinput"
      "input"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICCWNto66rFbOvb1VDEDuZYdwHQPfKM7+EjpnHvs3eRr joshua@joshuablais.com"
    ];
  };

  users.users.immich = {
    isSystemUser = true;
    group = "immich";
    extraGroups = [ "joshua" ]; # Add to joshua's group
    description = "Immich photo management service";
  };

  security.sudo.extraRules = [
    {
      users = [ "joshua" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";

  services.openssh.enable = true;

  # Disable all systemd sleep/suspend/hibernate targets
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # Configure systemd-logind to ignore power events
  services.logind.settings = {
    Login = {
      HandlePowerKey = "ignore";
      IdleAction = "ignore";
    };
  };

  # Prevent automatic suspension
  powerManagement = {
    enable = false; # Disable NixOS power management entirely
  };

  system.stateVersion = "25.11";
}
