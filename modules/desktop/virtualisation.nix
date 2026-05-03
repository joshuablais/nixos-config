{ config, pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;
    };
  };

  # Add your user to the libvirt group
  users.users.joshua = {
    extraGroups = [
      "libvirtd"
      "kvm"
    ];
  };

  programs.virt-manager.enable = true;

  networking.bridges = { };
}
