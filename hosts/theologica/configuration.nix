{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./hardware-overrides.nix
    ../../profiles/workstation.nix
    ../../modules/secrets/joshua.nix
  ];

  networking.hostName = "theologica";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.joshua = {
    isNormalUser = true;
    description = "Joshua Blais";
    group = "joshua";
    extraGroups = [
      "networkmanager"
      "wheel"
      "ydotool"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHOhKWVw7qSIftvEZzjPkbxbRizHe3LVmmQ/xaT78F8 joshua@logos-202604"
    ];
  };

  users.groups.joshua = { };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "joshua" ];
    };
  };

  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";

  documentation.enable = true;
  documentation.dev.enable = true;
  documentation.man.enable = true;
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
  ];

  system.stateVersion = "26.05";
}
