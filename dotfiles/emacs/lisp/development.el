;;; development.el --- Description -*- lexical-binding: t; -*-

;; Code folding
(use-package hideshow
  :ensure nil
  :hook (prog-mode . hs-minor-mode))

;;; Todo in code
(use-package hl-todo
  :ensure t
  :hook (prog-mode . hl-todo-mode))

(use-package agenix
  :demand t
  :config
  (setq agenix-age-program "/run/current-system/sw/bin/age"
        agenix-key-files '("~/.config/age/keys.txt"))
  (defun agenix--identity-protected-p (_identity-path)
    nil))

(use-package envrc
  :demand t
  :config
  (envrc-global-mode))

(provide 'development)
;;; development.el ends here
