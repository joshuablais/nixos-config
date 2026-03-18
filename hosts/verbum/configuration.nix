{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/tiny.nix
    ../../modules/home-manager
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Setup keyfile
  boot.initrd.secrets = {
    "/boot/crypto_keyfile.bin" = null;
  };

  boot.loader.grub.enableCryptodisk = true;

  boot.initrd.luks.devices."luks-65f8f8c1-feb2-4ba1-bfc4-1e8214361602".keyFile =
    "/boot/crypto_keyfile.bin";

  # Host-specific configuration
  networking.hostName = "verbum";

  networking.networkmanager.enable = true;

  users.groups.joshua = { };

  nix.settings.trusted-users = [
    "root"
    "joshua"
  ];

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

  environment.sessionVariables = {
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
  };

  # Set the state version
  system.stateVersion = "25.11";
}
