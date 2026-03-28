;;; evil-config.el --- Description -*- lexical-binding: t; -*-

(use-package undo-fu
  :ensure t)

(use-package undo-fu-session
  :ensure t
  :config
  (undo-fu-session-global-mode))

(use-package goto-chg
  :ensure t)

(use-package evil
  :ensure t
  :after undo-fu
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-d-scroll t)
  (setq evil-want-fine-undo t)
  (setq evil-split-window-below t)
  (setq evil-vsplit-window-right t)
  (setq evil-undo-system 'undo-fu)
  (setq evil-want-Y-yank-to-eol t)
  (setq evil-echo-state nil)
  (setq evil-move-cursor-back nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :ensure t
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary
  :ensure t
  :after evil
  :config
  (evil-commentary-mode 1))

(provide 'evil-config)
;;; evil-config.el ends here
