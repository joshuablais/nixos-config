;;; vterm-config.el --- vterm configuration -*- lexical-binding: t; -*-

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

(with-eval-after-load 'vterm
  ;; Meow integration
  (add-hook 'vterm-mode-hook #'meow-insert-mode)

  (define-key vterm-mode-map (kbd "<escape>")
              (lambda () (interactive)
                (meow-normal-mode)
                (vterm-copy-mode 1)))

  (define-key vterm-copy-mode-map (kbd "i")
              (lambda () (interactive)
                (vterm-copy-mode -1)
                (meow-insert-mode)))

  (define-key vterm-copy-mode-map (kbd "y") #'meow-clipboard-save)
  (define-key vterm-copy-mode-map (kbd "l") #'meow-line)
  (define-key vterm-copy-mode-map (kbd "L")
              (lambda () (interactive) (meow-line 1) (meow-reverse)))
  (define-key vterm-copy-mode-map (kbd "m") #'meow-mark-word)
  (define-key vterm-copy-mode-map (kbd "f") #'flash-jump)
  (define-key vterm-copy-mode-map (kbd "/") #'consult-line)
  (define-key vterm-copy-mode-map (kbd "n") #'meow-next)
  (define-key vterm-copy-mode-map (kbd "e") #'meow-prev)
  (define-key vterm-copy-mode-map (kbd "h") #'meow-left)
  (define-key vterm-copy-mode-map (kbd "w") #'meow-next-word)
  (define-key vterm-copy-mode-map (kbd "b") #'meow-back-word)
  (define-key vterm-copy-mode-map (kbd ";") #'meow-reverse)
  (define-key vterm-copy-mode-map (kbd "v") #'meow-search)
  (define-key vterm-copy-mode-map (kbd "V") #'meow-visit)
  (define-key vterm-copy-mode-map (kbd "g") #'meow-cancel-selection)
  (define-key vterm-copy-mode-map (kbd "<escape>")
              (lambda () (interactive)
                (vterm-copy-mode -1)
                (meow-insert-mode)))

  ;; Auto-spawn vterm in any new frame that isn't main or explicitly handled
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

(defun jb/vterm ()
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

(provide 'vterm-config)
;;; vterm-config.el ends here
