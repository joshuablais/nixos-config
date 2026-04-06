;;; early-init.el --- Description -*- lexical-binding: t; -*-
(setq package-enable-at-startup nil)

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 1.0)

;; Opacity
(add-to-list 'default-frame-alist '(alpha-background . 90))

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1024 1024)
                  gc-cons-percentage 0.1)))

;;; File handler optimization — skip regex matching on every load
(defvar my--old-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist my--old-file-name-handler-alist)))

;;; UI — set frame parameters directly
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(horizontal-scroll-bars) default-frame-alist)
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)

;;; Performance
(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize t
      auto-mode-case-fold nil
      read-process-output-max (* 2 1024 1024)
      load-prefer-newer t)

;;; Bidirectional text
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

;;; PGTK latency fix (if on Wayland)
;; (when (boundp 'pgtk-wait-for-event-timeout)
;;   (setq pgtk-wait-for-event-timeout 0.001))

;; UTF-8
(set-charset-priority 'unicode)
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;;; Fonts
(set-face-attribute 'default nil
                    :family "GeistMono Nerd Font"
                    :height 110)
(set-face-attribute 'variable-pitch nil
                    :family "Alegreya"
                    :height 120)
(set-face-attribute 'fixed-pitch nil
                    :family "GeistMono Nerd Font"
                    :height 110)

;;; Native comp
(setq native-comp-async-report-warnings-errors 'silent)

(provide 'early-init)
