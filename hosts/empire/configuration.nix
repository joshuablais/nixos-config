{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    # inputs.impermanence.nixosModules.default
    ./disk-config.nix
    # ../../services/empire
    ../../modules/cli-tui/neovim.nix
    # ../../sites/luminaforge.nix
  ];

  networking.hostName = "empire";

  # Set device for disko
  disko.devices.disk.main.device = "/dev/sda";

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
  ];

  # Explicitly configure GRUB for BIOS
  boot.loader.grub = {
    enable = true;
  };

  # Enable garden
  # services.garden = {
  #   enable = true;
  #   port = 3000;
  #   domain = "luminaforge.org";
  # };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7upEnqqvZMGYQVkwnQRogLIJZ814TNjfdGqP1zJ4En josh@joshblais.com"
  ];

  system.stateVersion = "26.05";
}
