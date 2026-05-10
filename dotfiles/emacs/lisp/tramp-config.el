;;; tramp-config.el --- Description -*- lexical-binding: t; -*-

(setq tramp-remote-path
      '("/run/current-system/profile/bin"
        "/run/current-system/profile/sbin"
        "/home/joshua/.guix-profile/bin"
        tramp-default-remote-path
        tramp-own-remote-path))

(setq tramp-connection-local-default-profile-alist
      '((".*" . ((tramp-remote-path . ("/run/current-system/profile/bin"
                                       "/run/current-system/profile/sbin"
                                       "/home/joshua/.guix-profile/bin"
                                       tramp-default-remote-path))))))

(provide 'tramp-config)
