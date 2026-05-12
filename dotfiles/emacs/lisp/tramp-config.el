;;; tramp-config.el --- TRAMP configuration -*- lexical-binding: t; -*-

(setq tramp-use-file-notifications nil)
(setq auto-revert-remote-files nil)
(setq auth-source-save-behavior nil)

(require 'tramp)

;; Core Settings
(setq tramp-default-method "sshx")
(setq tramp-verbose 1)
(setq tramp-connection-timeout 30)

(add-to-list 'tramp-connection-properties
             (list (regexp-quote "192.168.0.53") "term-name" "dumb"))

;; Guix Paths - Added via with-eval-after-load to ensure the list exists
(with-eval-after-load 'tramp
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (add-to-list 'tramp-remote-path "/run/current-system/profile/bin")
  (add-to-list 'tramp-remote-path "/run/current-system/profile/sbin")
  (add-to-list 'tramp-remote-path "/home/joshua/.guix-profile/bin"))

;; Performance Fixes
(setq remote-file-name-inhibit-locks t)
(setq remote-file-name-inhibit-cache 30)
(setq dired-listing-switches "-al --group-directories-first")

;; File locations
(setq tramp-auto-save-directory
      (expand-file-name "tramp-auto-save/" user-emacs-directory))
(setq tramp-persistency-file-name
      (expand-file-name "tramp-persistency" user-emacs-directory))

;; Disable project.el VC for remote files
(with-eval-after-load 'project
  (defun my/tramp-disable-project-vc (orig-fn &rest args)
    (if (and (stringp (car args))
             (file-remote-p (car args)))
        nil
      (apply orig-fn args)))
  (advice-add 'project-try-vc :around #'my/tramp-disable-project-vc))

(provide 'tramp-config)
