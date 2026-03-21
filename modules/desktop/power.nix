{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.power-profiles-daemon.enable = false;

  services = {
    upower = {
      enable = true;
      percentageLow = 15;
      percentageCritical = 5;
      percentageAction = 3;
      criticalPowerAction = "Hibernate";
    };

    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 20;
        CPU_MAX_PERF_ON_BAT = 80;

        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "off";

        USB_AUTOSUSPEND = 0;
        USB_EXCLUDE_BTUSB = 1;

        DISK_DEVICES = "nvme0n1";
        DISK_APM_LEVEL_ON_AC = "254";
        DISK_APM_LEVEL_ON_BAT = "254";

        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "on";
      };
    };

    thermald.enable = false;
    fwupd.enable = true;
  };

  boot.kernelParams = [
    "amd_pstate=guided"
    "nvme_core.default_ps_max_latency_us=0"
    "amdgpu.runpm=0"
    "amdgpu.aspm=0"
    "nmi_watchdog=1"
    "softlockup_panic=1"
    "iommu=pt"
  ];

  boot.extraModprobeConfig = ''
    options amdgpu dpm=1 dc=1 dcfeaturemask=0x8
  '';

  boot.kernel.sysctl = {
    "kernel.hung_task_timeout_secs" = 60;
  };

  # Disable PSR at boot — prevents DMCUB firmware crash on Rembrandt
  systemd.services.disable-amdgpu-psr = {
    description = "Disable AMD PSR to prevent DMCUB firmware crash";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "disable-psr" ''
        sleep 2
        if [ -f /sys/kernel/debug/dri/1/eDP-1/psr_state ]; then
          echo 0 > /sys/kernel/debug/dri/1/eDP-1/psr_state
          echo "PSR disabled on eDP-1"
        fi
      '';
    };
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  hardware.cpu.amd.updateMicrocode = true;

  environment.systemPackages = with pkgs; [
    powertop
    acpi
    lm_sensors
  ];
}
