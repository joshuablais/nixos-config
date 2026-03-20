;;; init.el --- Typewriter config for X201 TTY -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Joshua Blais
;; Author: Joshua Blais <josh@joshblais.com>
;; Version: 0.0.1
;; Homepage: https://github.com/joshuablais
;;
;; This file is not part of GNU Emacs.
;;; Commentary:
;; Minimal typewriter environment. Org, Evil, Avy, Olivetti. Nothing else.
;;; Code:

;;; Bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;;; Packages
(straight-use-package 'evil)
(straight-use-package 'evil-org)
(straight-use-package 'olivetti)
(straight-use-package 'avy)
(straight-use-package 'org)

;;; Evil — load early, everything else binds after
(setq evil-want-integration t
      evil-want-keybinding nil
      evil-want-C-u-scroll t
      evil-want-C-d-scroll t
      evil-respect-visual-line-mode t
      evil-undo-system 'undo-redo)

(require 'evil)
(evil-mode 1)

;;; Evil-org
(require 'evil-org)
(add-hook 'org-mode-hook #'evil-org-mode)
(with-eval-after-load 'evil-org
  (evil-org-set-key-theme '(navigation textobjects insert additional)))
(require 'evil-org-agenda)
(evil-org-agenda-set-keys)

;;; Avy on s in normal mode
(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "s") #'avy-goto-char-2)
  (define-key evil-visual-state-map (kbd "s") #'avy-goto-char-2))

;;; Silence the machine
(setq inhibit-startup-message t
      initial-scratch-message nil
      ring-bell-function 'ignore
      visible-bell nil)

;;; Clean UI
(when (display-graphic-p)
  (tool-bar-mode -1)
  (scroll-bar-mode -1))
(menu-bar-mode -1)
(blink-cursor-mode -1)

;;; Lines and display
(setq-default fill-column 80
              word-wrap t
              truncate-lines nil)
(global-visual-line-mode 1)

;;; Auto-save
(setq auto-save-default t
      auto-save-timeout 10
      auto-save-interval 100
      make-backup-files t
      backup-directory-alist '(("." . "~/.emacs.d/backups"))
      backup-by-copying t
      version-control t
      kept-new-versions 6
      kept-old-versions 2
      delete-old-versions t)

(add-hook 'focus-out-hook #'save-buffer)

;;; Keybindings
(global-set-key (kbd "C-s") #'save-buffer)

;;; Org-mode
(setq org-directory "~/org"
      org-default-notes-file "~/org/notes.org"
      org-startup-indented t
      org-hide-leading-stars t
      org-hide-emphasis-markers t
      org-pretty-entities t
      org-ellipsis " ▾"
      org-startup-folded 'showall)

(add-hook 'org-mode-hook #'org-indent-mode)

;;; Olivetti
(setq olivetti-body-width 80)
(add-hook 'org-mode-hook #'olivetti-mode)
(add-hook 'text-mode-hook #'olivetti-mode)

;;; Typewriter scrolling
(setq scroll-margin 999
      scroll-conservatively 0
      scroll-up-aggressively 0.5
      scroll-down-aggressively 0.5)

;;; No line numbers in writing buffers
(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'text-mode-hook (lambda () (display-line-numbers-mode -1)))

;;; Minimal modeline
(defun wc/word-count ()
  (number-to-string (count-words (point-min) (point-max))))

(setq-default mode-line-format
              '("%e "
                mode-line-modified
                " %b "
                "| W:" (:eval (wc/word-count))
                " | L:%l "))

;;; Open directly into org notes on launch
(find-file org-default-notes-file)

;;; init.el ends here
