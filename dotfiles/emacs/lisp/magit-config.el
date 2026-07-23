;;; magit.el --- Description -*- lexical-binding: t; -*-

(use-package transient :ensure t :demand t)
(elpaca-wait)

(use-package magit-section :ensure t :demand t)
(elpaca-wait)

(use-package magit
  :ensure t
  :defer t
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1
        magit-bury-buffer-function #'magit-restore-window-configuration))

(use-package forge
  :ensure t
  :after magit
  :demand t
  :init
  (setq forge-add-default-bindings t)
  :config
  (dolist (entry '(("codeberg.org" "codeberg.org/api/v1" "codeberg.org" forge-forgejo-repository)
                   ("forge.labrynth.org" "forge.labrynth.org/api/v1" "forge.labrynth.org" forge-forgejo-repository)))
    (add-to-list 'forge-alist entry)))
(elpaca-wait)

(add-hook 'git-commit-mode-hook #'meow-insert)

(with-eval-after-load 'magit
  (define-key magit-mode-map (kbd "SPC") nil)
  (define-key magit-status-mode-map (kbd "p") #'magit-push))

(provide 'magit-config)
