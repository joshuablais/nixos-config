;;; init.el -*- lexical-binding: t; -*-

;; Initial setup for user and auth sources
(setq user-full-name "Joshua Blais"
      user-mail-address "josh@joshblais.com")
(setq auth-sources '("~/.authinfo.gpg" "~/.authinfo")
      auth-source-cache-expiry nil)

;; Setup MELPA
(require 'package)
(setq package-user-dir "~/.config/emacs/var/elpa/")
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; point packages to etc/var for cleaner directory structure (gitignored)
(use-package no-littering
  :init
  (setq no-littering-etc-directory "~/.config/emacs/etc/"
        no-littering-var-directory "~/.config/emacs/var/")
  :config
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
  (setq backup-directory-alist
        `((".*" . ,(no-littering-expand-var-file-name "backup/")))))

;; Keep Custom out of init.el
(setq custom-file (no-littering-expand-etc-file-name "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

;; GC MANAGEMENT - restore after startup
(use-package gcmh
  :defer 1
  :config
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold (* 16 1024 1024))
  (gcmh-mode 1))

;; Sane defaults
(setq-default
 delete-by-moving-to-trash t
 window-combination-resize t
 x-stretch-cursor t)

(setq
 undo-limit 80000000
 scroll-margin 2
 scroll-conservatively 101
 mouse-wheel-scroll-amount '(2 ((shift) . 5))
 mouse-wheel-progressive-speed nil
 confirm-kill-emacs 'yes-or-no-p
 make-backup-files nil
 create-lockfiles nil
 initial-scratch-message nil
 use-short-answers t
 truncate-string-ellipsis "…")

;; Global modes
(electric-pair-mode 1)
(save-place-mode 1)
(setq save-place-limit 400)
(savehist-mode 1)
(recentf-mode 1)
(global-hl-line-mode 1)
(show-paren-mode 1)
(column-number-mode 1)
(delete-selection-mode 1)
(global-auto-revert-mode 1)
(setq show-paren-delay 0
      auto-revert-verbose nil)

;; testing for package timings
;; (setq use-package-compute-statistics t)

;; autosaving
(setq auto-save-default t)
;; Trigger an auto-save after 300 keystrokes
(setq auto-save-interval 300)
;; Trigger an auto-save 30 seconds of idle time.
(setq auto-save-timeout 30)

;; UI
(set-fringe-mode 10)

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes/" user-emacs-directory))
(use-package doom-themes
  :config
  (load-theme 'compline t))

;; Highlight line
(custom-set-faces
 '(hl-line ((t (:background "#22262b" :foreground unspecified :extend t)))))

;; Which-key
(use-package which-key
  :defer 1
  :config
  (setq which-key-idle-delay 0.2)
  (which-key-mode 1))

;; Recentf - saves recent file locations
(use-package recentf
  :ensure nil
  :defer 1
  :config
  (setq recentf-max-menu-items 25
        recentf-max-saved-items 100)
  (add-to-list 'recentf-exclude "\\.git/")
  (add-to-list 'recentf-exclude "/tmp/")
  (add-to-list 'recentf-exclude "/nix/store/")
  (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-var-directory))
  (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-etc-directory))
  (add-hook 'kill-emacs-hook #'recentf-cleanup -90))

;; Save history and auto open on re-launch
(use-package savehist
  :ensure nil
  :defer 1
  :config
  (setq history-length 1000
        history-delete-duplicates t
        savehist-save-minibuffer-history t)
  (dolist (var '(extended-command-history
                 search-ring
                 regexp-search-ring
                 consult--buffer-history
                 recentf-list))
    (add-to-list 'savehist-additional-variables var)))

;; Load Path  + Modules
(add-to-list 'load-path (expand-file-name "lisp/" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "lisp/custom/" user-emacs-directory))

(require 'evil-config)
(require 'keys)
(require 'magit-config)
(require 'mail)
(require 'move-text-config)
(require 'flash-config)
(require 'pass-config)
(require 'org-caldav-config)
(require 'markdown)
(require 'development)
(require 'ledger-config)
(require 'grammars)
(require 'modeline)
(require 'editing)
(require 'tabs)
(require 'llms)
(require 'completion)
(require 'test-runner)
(require 'persist)
(require 'dired-config)
(require 'vterm-config)
(require 'elfeed-config)
(require 'reading)
(require 'emms-config)
(require 'erc-config)
(require 'browser)
(require 'writing)
(require 'spelling)
(require 'workspaces)
(require 'everywhere)
(require 'elpher-config)
(require 'gnus-config)
(require 'tools)

;; heavy org deferral
(with-eval-after-load 'org
  (require 'org-config))

;; Custom
(require 'jitsi-meeting)
(require 'universal-launcher)
(require 'jb-0x0)
(require 'jb-clipboard-manager)
(require 'pomodoro)
(require 'posse-twitter)
(require 'post-to-blog)
(require 'done-refile)
(require 'create-daily)
(require 'nm)
