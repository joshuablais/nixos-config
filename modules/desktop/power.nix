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
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;           # ADD: boost on battery = thermal spikes = freezes
        PCIE_ASPM_ON_AC = "performance"; # ADD: explicit, since you're using pcie_aspm=off at boot this is belt-and-suspenders
        PCIE_ASPM_ON_BAT = "powersave";
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

services.udev.extraRules = ''
  ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="6594", RUN+="${pkgs.writeShellScript "goodix-no-autosuspend" ''
    echo -1 > /sys$DEVPATH/power/autosuspend_delay_ms
    echo on > /sys$DEVPATH/power/control
  ''}"
'';

boot.kernelParams = [
  "amd_pstate=active"                    # 6850U supports CPPC2 — use it properly
  "nvme_core.default_ps_max_latency_us=0"
  "amdgpu.runpm=0"
  "amdgpu.aspm=0"
  "amdgpu.sg_display=0"
  "amdgpu.gpu_recovery=1"               # ADD: auto-recover GPU hangs instead of freezing
  "pcie_aspm=off"                        # ADD: amdgpu.aspm=0 only covers the GPU node; NVMe/TB/USB PCIe links still negotiate ASPM
  "nmi_watchdog=1"
  "softlockup_panic=1"
  "hardlockup_panic=1"                   # ADD: you had soft but not hard lockup panic
  "iommu=pt"
  "mem_sleep_default=s2idle"             # ADD: Rembrandt requires s2idle (no S3 in BIOS); without this, suspend/resume freezes are common
  "initcall_blacklist=acpi_cpufreq_init" # ADD: prevent acpi_cpufreq loading alongside amd_pstate=active
];

boot.extraModprobeConfig = ''
  options amdgpu dpm=1 dc=1 dcfeaturemask=0x8
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
      for i in 0 1 2; do
        PSR_BLOCK="/sys/kernel/debug/dri/$i/eDP-1/disallow_edp_enter_psr"
        if [ -f "$PSR_BLOCK" ]; then
          echo 1 > "$PSR_BLOCK" && echo "PSR entry blocked on dri/$i/eDP-1" && break
        fi
      done
      '';
    };
  };

  systemd.services.fprintd-resume = {
  description = "Restart fprintd after resume to reinitialize fingerprint reader";
  wantedBy = [ "post-resume.target" ];
  after = [ "post-resume.target" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.systemd}/bin/systemctl restart fprintd.service";
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
        for i in 0 1 2; do
          PSR_BLOCK="/sys/kernel/debug/dri/$i/eDP-1/disallow_edp_enter_psr"
          if [ -f "$PSR_BLOCK" ]; then
            echo 1 > "$PSR_BLOCK" && echo "PSR entry blocked on dri/$i/eDP-1 after resume" && break
          fi
        done
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
