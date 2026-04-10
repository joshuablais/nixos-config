;;; flash-config.el --- Description -*- lexical-binding: t; -*-

(use-package flash
  :ensure t
  :custom
  (flash-multi-window t)
  (flash-backdrop t)
  (flash-autojump t)
  (flash-rainbow nil)
  (flash-search-folds t)
  (flash-char-jump-labels t)
  (flash-char-multi-line t)
  :config
  (require 'flash-isearch)
  (flash-isearch-mode 1))

;; (use-package avy
;;   :ensure t
;;   :config
;;   (setq avy-background t)

(provide 'flash-config)
