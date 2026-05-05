;;; guix-config.el -*- lexical-binding: t; -*-

(use-package geiser
  :ensure t)

(use-package geiser-guile
  :ensure t
  :config
  ;; Instead of a raw guile binary, use 'guix repl'
  ;; which already has all the paths correctly baked in.
  (setq geiser-guile-binary "guix")
  (setq geiser-guile-extra-arguments '("repl"))

  ;; This ensures Geiser doesn't get confused by the 'guix' command name
  (setq geiser-guile-case-sensitive-p t))

(use-package guix
  :ensure t
  :init
  ;; We still need to tell the emacs-guix package where the SOURCE is
  ;; so it can find the .scm files for 'guix-edit', etc.
  (let* ((guix-root (expand-file-name "~/.config/guix/current"))
         (share-dir (concat guix-root "/share/guile/site/3.0"))
         (lib-dir   (concat guix-root "/lib/guile/3.0/site-ccache")))

    (setq guix-state-directory "/var/guix"
          guix-user-profiles-directory "~/.guix-profile"
          ;; Point this to the actual 'guix' executable
          guix-config-guile-program (concat guix-root "/bin/guix")

          ;; Map all the directory variables it might look for
          guix-scheme-directory share-dir
          guix-config-guix-scheme-directory share-dir
          guix-config-scheme-compiled-directory lib-dir
          guix-config-guix-scheme-compiled-directory lib-dir))
  :config
  ;; Ensure the pulled guix is in Emacs' path
  (add-to-list 'exec-path (expand-file-name "~/.config/guix/current/bin")))

(provide 'guix-config)
