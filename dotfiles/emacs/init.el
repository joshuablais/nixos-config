;;; init.el -*- lexical-binding: t; -*-

;; Username setup
(setq user-full-name "Joshua Blais"
      user-mail-address "josh@joshblais.com")
(setq auth-sources '("~/.authinfo.gpg" "~/.authinfo")
      auth-source-cache-expiry nil)

;; Elpaca bootstrap
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
        (elpaca-use-package-mode))
(elpaca-wait)

(setq use-package-always-defer t
      use-package-always-ensure t
      ;; Testing for package timing
      ;; use-package-compute-statistics t
      use-package-expand-minimally t)

;; no-littering must run before anything writes files
(setq custom-file (expand-file-name "etc/custom.el" user-emacs-directory))

(use-package no-littering
  :demand t
  :init
  (setq no-littering-etc-directory (expand-file-name "etc/" user-emacs-directory)
        no-littering-var-directory  "~/.local/share/emacs/")
  :config
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))
  (elpaca-wait) ; block until no-littering is fully built and configured
(when (file-exists-p custom-file)
  (load custom-file))

;; GC
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
 truncate-string-ellipsis " ")

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

(setq auto-save-default t
      auto-save-interval 300
      auto-save-timeout 30)

;; UI
(set-fringe-mode 10)
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes/" user-emacs-directory))
(use-package doom-themes
  :demand t
  :config
  (load-theme 'compline t))

(with-eval-after-load 'hl-line
  (set-face-attribute 'hl-line nil
                      :background "#22262b"
                      :foreground 'unspecified
                      :extend t))

(use-package which-key
  :config
  (setq which-key-idle-delay 0.2)
  (which-key-mode 1))

(use-package recentf
  :ensure nil
  :config
  (setq recentf-max-menu-items 25
        recentf-max-saved-items 100)
  (dolist (path '("\\.git/" "/tmp/" "/nix/store/"))
    (add-to-list 'recentf-exclude path))
  (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-var-directory))
  (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-etc-directory))
  (add-hook 'kill-emacs-hook #'recentf-cleanup -90))

(use-package savehist
  :ensure nil
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

(elpaca-wait)

;; Modules
(add-to-list 'load-path (expand-file-name "lisp/" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "lisp/custom/" user-emacs-directory))

;;(require 'meow-setup)
;;(require 'meow-keys)
(require 'evil-config)
(require 'keys)
(require 'dashboard)
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
;;(require 'elpher-config)
(require 'gnus-config)
(require 'tools)

(with-eval-after-load 'org
  (require 'org-config))

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
