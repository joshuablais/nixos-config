;;; magit.el --- Description -*- lexical-binding: t; -*-

(use-package transient
  :ensure (:host github :repo "magit/transient")
  :demand t)
(elpaca-wait)

(use-package magit-section :demand t)
(elpaca-wait)

(use-package magit
  :demand t
  :bind (:map leader
              ("g g" . magit-status))
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1
        magit-bury-buffer-function #'magit-restore-window-configuration))

(add-hook 'git-commit-mode-hook #'evil-insert-state)

(with-eval-after-load 'magit
  (define-key magit-status-mode-map (kbd "SPC") nil)
  (define-key magit-log-mode-map (kbd "SPC") nil)
  (define-key magit-diff-mode-map (kbd "SPC") nil))

(provide 'magit-config)
