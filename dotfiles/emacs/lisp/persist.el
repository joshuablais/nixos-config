;;; persist.el -*- lexical-binding: t; -*-

(use-package easysession
  :ensure t
  :custom
  (easysession-save-interval (* 10 60))
  :config
  (easysession-setup))

;; undo tree across sessions
(use-package undo-tree
  :ensure t
  :demand t
  :config
  (setq undo-tree-auto-save-history t
        undo-tree-history-directory-alist
        `(("." . ,(expand-file-name "undo-tree-history" user-emacs-directory))))
  (global-undo-tree-mode 1))

(provide 'persist)
