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

(setq tramp-use-file-notifications nil)

;; Keep TRAMP's connection process alive — don't let it die between ops
(setq tramp-connection-timeout 30)
(customize-set-variable 'tramp-connection-min-time-diff 0)

;; Cache remote file attributes aggressively — 30s is fine for interactive use
(setq remote-file-name-inhibit-cache 30)

;; Do NOT auto-revert remote files — this is the primary fd leak
(setq auto-revert-remote-files nil)

;; Keep auto-saves local, never remote
(setq tramp-auto-save-directory (expand-file-name "tramp-auto-save/" user-emacs-directory))

;; Suppress TRAMP from verbose logging (each log write can touch fds)
(setq tramp-verbose 1)

;; Persist connection info across sessions
(setq tramp-persistency-file-name
      (expand-file-name "tramp-persistency" user-emacs-directory))

;; Don't let remote-file-name inhibit locking (another fd source)
(setq remote-file-name-inhibit-locks t)

(provide 'tramp-config)
