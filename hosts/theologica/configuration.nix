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

  # Host-specific configuration
  networking.hostName = "theologica";

  # Boot loader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Define your user properly
  users.users.joshua = {
    isNormalUser = true;
    description = "Joshua Blais";
    group = "joshua";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Create the user group
  users.groups.joshua = { };

  # Basic system configuration
  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";

  documentation.enable = true;
  documentation.dev.enable = true;
  documentation.man.enable = true;
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
  ];

  # Enable Supernote sync tool
  # services.supernote-watcher.enable = true;

  # Set the state version
  system.stateVersion = "25.11";
}
