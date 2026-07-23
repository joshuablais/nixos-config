;;; jb-guix.el -*- lexical-binding: t; -*-
(use-package geiser
  :ensure nil)
(use-package geiser-guile
  :ensure nil
  :config
  (setq geiser-guile-case-sensitive-p t))
(use-package guix
  :ensure nil
  :commands (guix guix-installed-user-packages guix-packages-by-name)
  :init
  (require 'guix nil t))
(provide 'jb-guix)
