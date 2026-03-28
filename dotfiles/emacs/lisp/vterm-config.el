;;; vterm.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 joshuablais
;;
;; Author: joshuablais <josh@joshblais.com>
;; Maintainer: joshuablais <josh@joshblais.com>
;; Created: March 23, 2026
;; Modified: March 23, 2026
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex text tools unix vc wp
;; Homepage: https://github.com/joshuablais/vterm
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:
;;; vterm-config.el -*- lexical-binding: t; -*-

(use-package vterm
  :ensure t
  :defer t
  :init
  (setq vterm-timer-delay 0.05
        vterm-kill-buffer-on-exit t
        vterm-max-scrollback 5000)
  :config
  (setq vterm-buffer-name-string "vterm %s"
        vterm-environment '("TERM=xterm-256color"))

  (defun +vterm--respect-current-dir (fn &rest args)
    "Open vterm in the directory of the current buffer."
    (let ((default-directory (or (and (buffer-file-name)
                                      (file-name-directory (buffer-file-name)))
                                 (and (eq major-mode 'dired-mode)
                                      (dired-current-directory))
                                 default-directory)))
      (apply fn args)))
  (advice-add 'vterm :around #'+vterm--respect-current-dir)

  (add-hook 'vterm-mode-hook
            (lambda ()
              (setq-local confirm-kill-processes nil)
              (setq-local hscroll-margin 0)
              (setq-local mode-line-format nil)
              (set (make-local-variable 'buffer-face-mode-face)
                   '(:family "GeistMono Nerd Font"))
              (buffer-face-mode t)))

  (define-key vterm-mode-map (kbd "C-<left>")  #'windmove-left)
  (define-key vterm-mode-map (kbd "C-<right>") #'windmove-right)
  (define-key vterm-mode-map (kbd "C-<up>")    #'windmove-up)
  (define-key vterm-mode-map (kbd "C-<down>")  #'windmove-down))

(defun my/vterm ()
  "Open vterm buffer as a bottom popup at 30% height."
  (interactive)
  (require 'vterm)
  (let ((buf (get-buffer-create "*vterm*")))
    (with-current-buffer buf
      (unless (derived-mode-p 'vterm-mode)
        (vterm-mode)))
    (select-window
     (display-buffer
      buf
      '((display-buffer-reuse-window
         display-buffer-in-side-window)
        (side . bottom)
        (slot . 0)
        (window-height . 0.3)
        (window-parameters . ((no-delete-other-windows . t))))))))

(define-key leader (kbd "o t") #'my/vterm)

;; Tag initial frame as main so hooks can skip it
(defun my/tag-initial-frame ()
  "Tag the first frame as main."
  (set-frame-parameter nil 'main-frame t))
(add-hook 'emacs-startup-hook #'my/tag-initial-frame)

;; Explicitly spawn a new frame with vterm
(defun my/new-frame-with-vterm ()
  "Create a new frame and immediately open vterm in it."
  (interactive)
  (require 'vterm)
  (let ((new-frame (make-frame '((explicit-vterm . t)))))
    (select-frame new-frame)
    (delete-other-windows)
    (let ((vterm-buffer (vterm (format "*vterm-%s*" (frame-parameter new-frame 'name)))))
      (switch-to-buffer vterm-buffer)
      (delete-other-windows))))

;; Auto-spawn vterm in any new frame that isn't main or explicitly handled
(with-eval-after-load 'vterm
  (defun my/vterm-in-new-frame (frame)
    "Open vterm only in additional frames, not the main frame or explicit frames."
    (unless (or (frame-parameter frame 'main-frame)
                (frame-parameter frame 'explicit-vterm))
      (with-selected-frame frame
        (delete-other-windows)
        (let ((vterm-buffer (vterm (format "*vterm-%s*" (frame-parameter frame 'name)))))
          (switch-to-buffer vterm-buffer)
          (delete-other-windows)))))
  (add-hook 'after-make-frame-functions #'my/vterm-in-new-frame))

(defun my/open-vterm-at-point ()
  "Open vterm in the directory of the currently selected window's buffer."
  (interactive)
  (let* ((buf (window-buffer (selected-window)))
         (dir (with-current-buffer buf
                (cond
                 ((buffer-file-name buf)
                  (file-name-directory (buffer-file-name buf)))
                 ((eq major-mode 'dired-mode)
                  (dired-current-directory))
                 (t default-directory)))))
    (let ((default-directory dir))
      (vterm))))

;; Running commands async
(defun jb/run-command ()
  "Unified interface: shell history + async/output options."
  (interactive)
  (let* ((cmd (consult--read
               shell-command-history
               :prompt "Run: "
               :sort nil
               :require-match nil
               :category 'shell-command
               :history 'shell-command-history))
         (method (completing-read "Method: "
                                  '("shell-command" "async-shell-command" "eshell-command"))))
    (pcase method
      ("shell-command" (shell-command cmd))
      ("async-shell-command" (async-shell-command cmd))
      ("eshell-command" (eshell-command cmd)))))

(define-key leader (kbd "!") #'jb/run-command)

(provide 'vterm-config)
;;; vterm.el ends here
