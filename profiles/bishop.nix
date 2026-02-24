# ~/nixos-config/profiles/bishop.nix
{ lib, pkgs, ... }:
{
  imports = [
    ../modules/cli-tui
    ../modules/development
    ../modules/desktop
    ../modules/media
    ../modules/security
    ../modules/shared
  ];
  time.timeZone = lib.mkDefault "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";
  boot.loader.systemd-boot.configurationLimit = 20;
  environment.systemPackages = [ pkgs.liquidctl ];
  services.udev.packages = [ pkgs.liquidctl ];

  # hardware.fancontrol.enable = true;
  # hardware.fancontrol.config = ''
  #   INTERVAL=10
  #   DEVPATH=hwmon7=devices/pci0000:00/0000:00:01.2/0000:02:00.0/0000:03:08.0/0000:06:00.1/usb1/1-6/1-6:1.0/0003:1B1C:0C10.0003/hwmon/hwmon7
  #   DEVNAME=hwmon7=corsaircpro
  #   FCTEMPS=hwmon7/pwm5=hwmon1/temp1_input hwmon7/pwm4=hwmon1/temp1_input hwmon7/pwm3=hwmon1/temp1_input
  #   FCFANS=hwmon7/pwm5=hwmon7/fan5_input hwmon7/pwm4=hwmon7/fan4_input hwmon7/pwm3=hwmon7/fan3_input
  #   MINTEMP=hwmon7/pwm5=50 hwmon7/pwm4=50 hwmon7/pwm3=50
  #   MAXTEMP=hwmon7/pwm5=90 hwmon7/pwm4=90 hwmon7/pwm3=90
  #   MINSTART=hwmon7/pwm5=100 hwmon7/pwm4=100 hwmon7/pwm3=100
  #   MINSTOP=hwmon7/pwm5=100 hwmon7/pwm4=100 hwmon7/pwm3=100
  #   MINPWM=hwmon7/pwm5=0 hwmon7/pwm4=0 hwmon7/pwm3=0
  #   MAXPWM=hwmon7/pwm5=230 hwmon7/pwm4=235 hwmon7/pwm3=235
  # '';

  systemd.services.fan-control = {
    description = "Corsair fan quiet profile";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "fan-quiet" ''
        ${pkgs.liquidctl}/bin/liquidctl initialize all
        ${pkgs.liquidctl}/bin/liquidctl --match "Commander Pro" set fan1 speed 25
        ${pkgs.liquidctl}/bin/liquidctl --match "Commander Pro" set fan3 speed 25
        ${pkgs.liquidctl}/bin/liquidctl --match "Commander Pro" set fan4 speed 25
        ${pkgs.liquidctl}/bin/liquidctl --match "Commander Pro" set fan5 speed 25
      '';
    };
  };

  # Optimizations
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
  system.activationScripts.userAvatar = ''
      mkdir -p /var/lib/AccountsService/{icons,users}
      cp ${../assets/joshua.png} /var/lib/AccountsService/icons/joshua
      chmod 644 /var/lib/AccountsService/icons/joshua
      cat > /var/lib/AccountsService/users/joshua << 'EOF'
    [User]
    Icon=/var/lib/AccountsService/icons/joshua
    EOF
  '';
}
