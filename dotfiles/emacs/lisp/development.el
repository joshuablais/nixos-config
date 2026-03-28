;;; development.el --- Description -*- lexical-binding: t; -*-

;; Code folding
(use-package hideshow
  :ensure nil
  :hook (prog-mode . hs-minor-mode))

;;; Todo in code
(use-package hl-todo
  :ensure t
  :hook (prog-mode . hl-todo-mode))

;; Direnv
(use-package envrc
  :ensure t
  :hook (after-init . envrc-global-mode))

(provide 'development)
;;; development.el ends here
