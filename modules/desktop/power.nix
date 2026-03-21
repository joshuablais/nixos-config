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

  # Top-level, not nested under services
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="6594", RUN+="${pkgs.writeShellScript "goodix-no-autosuspend" ''
      echo 0 > /sys$DEVPATH/power/autosuspend_delay_ms
    ''}"
  '';

  boot.kernelParams = [
    "amd_pstate=guided"
    "nvme_core.default_ps_max_latency_us=0"
    "amdgpu.runpm=0"
    "amdgpu.aspm=0"
    "amdgpu.sg_display=0"
    "nmi_watchdog=1"
    "softlockup_panic=1"
    "iommu=pt"
  ];

  boot.extraModprobeConfig = ''
    options amdgpu dpm=1 dc=1 dcfeaturemask=0x0
  '';

  boot.kernel.sysctl = {
    "kernel.hung_task_timeout_secs" = 60;
  };

  systemd.services.disable-amdgpu-psr = {
    description = "Disable AMD PSR to prevent DMCUB firmware crash";
    wantedBy = [
      "multi-user.target"
      "sleep.target"
    ];
    after = [
      "systemd-udev-settle.service"
      "sys-kernel-debug.mount"
    ];
    before = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
      ExecStart = pkgs.writeShellScript "disable-psr" ''
        sleep 2
        PSR_BLOCK=/sys/kernel/debug/dri/1/eDP-1/disallow_edp_enter_psr
        if [ -f "$PSR_BLOCK" ]; then
          echo 1 > "$PSR_BLOCK" && echo "PSR entry blocked on eDP-1" || echo "Failed to block PSR entry"
        else
          echo "disallow_edp_enter_psr not found, skipping"
        fi
      '';
    };
  };

  systemd.services.amdgpu-resume-fix = {
    description = "Re-block AMD PSR after resume";
    wantedBy = [ "post-resume.target" ];
    after = [
      "post-resume.target"
      "sys-kernel-debug.mount"
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = pkgs.writeShellScript "amdgpu-resume-fix" ''
        sleep 3
        PSR_BLOCK=/sys/kernel/debug/dri/1/eDP-1/disallow_edp_enter_psr
        if [ -f "$PSR_BLOCK" ]; then
          echo 1 > "$PSR_BLOCK" && echo "PSR entry blocked on eDP-1 after resume" || echo "Failed to block PSR after resume"
        else
          echo "disallow_edp_enter_psr not found after resume, skipping"
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
