{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # File managers
    xfce.thunar
    xfce.tumbler

    # Graphics and image optimizations
    gimp3-with-plugins
    libwebp
    libavif
    mozjpeg
    oxipng
    nodePackages.svgo

    # KDE connect
    kdePackages.kdeconnect-kde

    # Productivity
    libreoffice

    # System utilities
    brightnessctl
    libnotify
    xdg-utils
    gammastep
    usbutils

    # VPN
    mullvad-vpn

    # Others
    qbittorrent
    flatpak

    # Added for Radicale
    apacheHttpd
  ];

  # Android tooling
  programs.adb.enable = true;
  users.users.joshua.extraGroups = [ "adbusers" ];

  services.resolved.enable = true;
  services.mullvad-vpn.enable = true;
  programs.kdeconnect.enable = true;

  systemd.user.services.kdeconnect = {
    description = "KDE Connect daemon";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnectd";
      Restart = "on-failure";
      RestartSec = 3;
    };
    environment = {
      # Ensure proper DBus session
      DISPLAY = ":0";
    };
  };

  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
  };

  # Enable flatpak
  services.flatpak.enable = true;

  # Syncthing for laptop to phone synchronization
  services.syncthing = {
    enable = true;
    user = "joshua";
    dataDir = "/home/joshua/.syncthing";
    configDir = "/home/joshua/.config/syncthing";

    # Force declarative management - this is key
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      # Define all your devices here
      devices = {
        "theologica" = {
          id = "4U5G6WT-F5GWI74-DXAVHOP-SKXKPXU-WGZU6MQ-6KDJ2VW-OL5VN2G-RBSDRA5";
        };
        "logos" = {
          id = "SMCSIA3-OGJLLPI-N7EXXLI-KHYLJPU-OJHRJYB-ALUEGQH-F44QSXF-R4UFMQK";
        };
        "phone" = {
          id = "TTUKVRU-FEJGUXM-SERMOTN-TJNRQKV-7QP2N5J-V3ESDBE-5WTKB4K-2LCGDA3";
        };
      };

      # Define your folder structure
      folders = {
        "library" = {
          path = "/home/joshua/Library";
          devices = [
            "theologica"
            "logos"
          ];
          ignorePerms = false;
        };
        "music" = {
          path = "/home/joshua/MusicOrganized";
          devices = [
            "theologica"
            "logos"
          ];
          ignorePerms = false;
        };
        "projects" = {
          path = "/home/joshua/Projects";
          devices = [
            "theologica"
            "logos"
          ];
          ignorePerms = false;
        };
        "accounting" = {
          path = "/home/joshua/Accounting";
          devices = [
            "theologica"
            "logos"
          ];
          ignorePerms = false;
        };
        "catholic" = {
          path = "/home/joshua/Catholic";
          devices = [
            "theologica"
            "logos"
          ];
          ignorePerms = false;
        };
        "media-dev" = {
          path = "/home/joshua/Development/Media";
          devices = [
            "theologica"
            "logos"
          ];
          ignorePerms = false;
        };
        "revere" = {
          path = "/home/joshua/Revere";
          devices = [
            "theologica"
            "logos"
          ];
          ignorePerms = false;
        };
        "elfeed" = {
          path = "/home/joshua/Downloads/Elfeed";
          devices = [
            "theologica"
            "logos"
          ];
          ignorePerms = false;
        };
        "phone-backup" = {
          path = "/home/joshua/Pictures/Phone Backup";
          devices = [
            "theologica"
            "logos"
          ];
          ignorePerms = false;
        };
      };
    };
  };

  # Ensure directories exist
  systemd.tmpfiles.rules = [
    "d /home/joshua/Library 0755 joshua users -"
    "d /home/joshua/MusicOrganized 0755 joshua users -"
    "d /home/joshua/Projects 0755 joshua users -"
    "d /home/joshua/Accounting 0755 joshua users -"
    "d /home/joshua/Catholic 0755 joshua users -"
    "d /home/joshua/Development/Media 0755 joshua users -"
    "d /home/joshua/Revere 0755 joshua users -"
    "d /home/joshua/Downloads/Elfeed 0755 joshua users -"
    "d /home/joshua/Pictures/Phone\\ Backup 0755 joshua users -"
  ];

  # Radicale testing for server calendar/VCard sync
  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ "0.0.0.0:5232" ]; # Localhost only for testing
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = "/var/lib/radicale/users";
        htpasswd_encryption = "bcrypt";
      };
      storage = {
        filesystem_folder = "/var/lib/radicale/collections";
      };
      logging = {
        level = "info"; # Helpful for debugging during testing
      };
    };
  };

  networking.firewall = {
    interfaces."tailscale0" = {
      allowedTCPPorts = [ 5232 ];
    };
  };
}
