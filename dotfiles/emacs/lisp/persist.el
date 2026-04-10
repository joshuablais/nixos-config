;;; persist.el -*- lexical-binding: t; -*-

(use-package easysession
  :ensure t
  :custom
  (easysession-save-interval 60)
  :init
  (easysession-setup))

(use-package undo-tree
  :ensure t
  :demand t
  :config
  (setq undo-tree-auto-save-history t
        undo-tree-history-directory-alist
        `(("." . ,(expand-file-name "undo-tree-history" user-emacs-directory))))
  (global-undo-tree-mode 1))

(use-package persistent-scratch
  :ensure t
  :demand t
  :custom
  (persistent-scratch-save-file (expand-file-name "persistent-scratch" user-emacs-directory))
  (persistent-scratch-autosave-interval 60)
  (persistent-scratch-what-to-save '(major-mode point narrowing))
  :config
  (persistent-scratch-setup-default)
  (persistent-scratch-autosave-mode 1))

(provide 'persist)
