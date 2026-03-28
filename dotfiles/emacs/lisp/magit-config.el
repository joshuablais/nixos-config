;;; magit.el --- Description -*- lexical-binding: t; -*-
;;; Code:
(use-package magit
  :ensure t
  :defer t
  :bind (:map leader
              ("g g" . magit-status))
  :config
  ;; Full screen magit
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
  ;; Restore previous window layout on quit
  (setq magit-bury-buffer-function #'magit-restore-window-configuration))

;; open magit commit in insert state
(add-hook 'git-commit-mode-hook #'evil-insert-state)

;; Set SPC properly in magit
(with-eval-after-load 'magit
  (define-key magit-status-mode-map (kbd "SPC") nil)
  (define-key magit-log-mode-map (kbd "SPC") nil)
  (define-key magit-diff-mode-map (kbd "SPC") nil))

(provide 'magit-config)
;;; magit.el ends here
