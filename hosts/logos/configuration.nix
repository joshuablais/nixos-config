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
    ../../profiles/bishop.nix
    ../../modules/media/davinci.nix
    ../../modules/llms/default.nix
    ../../modules/secrets/joshua.nix
  ];

  # Host-specific configuration
  networking.hostName = "logos";

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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHOhKWVw7qSIftvEZzjPkbxbRizHe3LVmmQ/xaT78F8 joshua@logos-202604"
    ];
  };

  # Create the user group
  users.groups.joshua = { };

  # Basic system configuration
  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable Supernote sync tool
  # services.supernote-watcher.enable = true;

  # Set the state version
  system.stateVersion = "25.11";
}
