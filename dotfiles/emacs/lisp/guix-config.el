;;; guix-config.el -*- lexical-binding: t; -*-

(use-package geiser
  :ensure t)

(use-package geiser-guile
  :ensure t
  :config
  ;; Point at Guix's own Guile — not system Guile
  (setq geiser-guile-binary
        (expand-file-name "~/.config/guix/current/bin/guile"))
  (add-to-list 'geiser-guile-load-path
               (expand-file-name "~/.guix-profile/share/guile/site/3.0"))
  (add-to-list 'geiser-guile-load-path
               (expand-file-name "~/.config/guix/current/share/guile/site/3.0")))

(use-package guix
  :ensure t
  :init
  (setq guix-state-directory "/var/guix"
        guix-user-profiles-directory "~/.guix-profile"
        guix-config-guile-program "~/.guix-profile/bin/guile"))

(provide 'guix-config)
