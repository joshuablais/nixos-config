;;; evil-config.el --- Description -*- lexical-binding: t; -*-
(use-package undo-fu :demand t)
(use-package undo-fu-session
  :demand t
  :config
  (undo-fu-session-global-mode))
(use-package goto-chg :demand t)
(use-package evil
  :demand t
  :after undo-fu
  :init
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-d-scroll t
        evil-want-fine-undo t
        evil-split-window-below t
        evil-vsplit-window-right t
        evil-undo-system 'undo-fu
        evil-want-Y-yank-to-eol t
        evil-echo-state nil
        evil-move-cursor-back nil)
  :config
  (evil-mode 1)
  (evil-define-key '(normal motion) 'global (kbd "SPC") 'leader)
  (define-key evil-normal-state-map (kbd "C-e") #'move-end-of-line)
  (define-key evil-normal-state-map (kbd "C-a") #'move-beginning-of-line)
  (define-key evil-insert-state-map (kbd "C-e") #'move-end-of-line)
  (define-key evil-insert-state-map (kbd "C-a") #'move-beginning-of-line))

(elpaca-wait) ; block until evil is fully built before evil-collection etc.

(use-package evil-collection
  :demand t
  :after evil
  :config
  (evil-collection-init))
(use-package evil-surround
  :demand t
  :after evil
  :config
  (global-evil-surround-mode 1))
(use-package evil-commentary
  :demand t
  :after evil
  :config
  (evil-commentary-mode 1))

(provide 'evil-config)
;;; evil-config.el ends here
