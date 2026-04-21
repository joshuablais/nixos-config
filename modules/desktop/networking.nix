{ config, pkgs, ... }:
{
  # Enable NetworkManager
  networking.networkmanager.enable = true;

  services.opensnitch = {
    enable = true;
    settings = {
      DefaultAction = "allow";
      DefaultDuration = "always";
      InterceptUnknown = true;
      ProcMonitorMethod = "ebpf";
      LogLevel = 1;
      Firewall = "nftables";
    };
  };

  # Packages
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanagerapplet
    opensnitch-ui
  ];
}
