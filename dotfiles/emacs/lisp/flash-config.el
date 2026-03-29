;;; flash-config.el --- Description -*- lexical-binding: t; -*-

(use-package flash
  :ensure t
  :custom
  (flash-multi-window t)
  (flash-backdrop t)
  (flash-autojump t)
  (flash-rainbow nil)
  ;; (flash-rainbow-shade 1)
  (flash-char-jump-labels t)
  (flash-char-multi-line t)
  :init
  (with-eval-after-load 'evil
    (require 'flash-evil)
    (evil-define-key '(normal visual operator motion) 'global
      (kbd "f") #'flash-evil-jump))
  :config
  (require 'flash-isearch)
  (flash-isearch-mode 1))

;; (use-package avy
;;   :ensure t
;;   :config
;;   (setq avy-background t)
;;   (define-key evil-normal-state-map (kbd "f") #'avy-goto-char-2))

(provide 'flash-config)
