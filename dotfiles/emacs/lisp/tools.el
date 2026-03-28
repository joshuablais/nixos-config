;;; tools.el --- Description -*- lexical-binding: t; -*-

(use-package helpful
  :ensure t
  :bind
  ([remap describe-command]  . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-key]      . helpful-key)
  ([remap describe-symbol]   . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  :custom
  (helpful-max-buffers 7))

(use-package git-modes
  :ensure t
  :mode (("/\\.gitignore\\'" . gitignore-mode)
         ("/\\.gitconfig\\'" . gitconfig-mode)
         ("/\\.gitattributes\\'" . gitattributes-mode)))

(use-package server
  :ensure nil
  :hook (after-init . server-start))

;; show colors of kex codes
(use-package rainbow-mode
  :hook ((prog-mode . rainbow-mode)
         (emacs-lisp-mode . rainbow-mode)
         (org-mode . rainbow-mode)))

;; link hint search and jump
(use-package link-hint
  :ensure t
  :bind
  (:map evil-normal-state-map
        ("SPC s l" . link-hint-open-link)))

;; scratch buffer
(use-package persistent-scratch
  :ensure t
  :custom
  (persistent-scratch-save-file (expand-file-name "persistent-scratch" user-emacs-directory))
  (persistent-scratch-autosave-interval 60)
  (persistent-scratch-what-to-save '(major-mode point narrowing))
  :config
  (persistent-scratch-setup-default)
  (persistent-scratch-autosave-mode 1))

(defun my/scratch-popup ()
  "Open scratch buffer as a bottom popup at 30% height."
  (interactive)
  (select-window
   (display-buffer
    (get-buffer-create "*scratch*")
    '((display-buffer-reuse-window
       display-buffer-in-side-window)
      (side . bottom)
      (slot . 0)
      (window-height . 0.3)
      (window-parameters . ((no-delete-other-windows . t)))))))

(define-key leader (kbd "X") #'my/scratch-popup)
(which-key-add-key-based-replacements "SPC X" "scratch popup")

;; Messages buffer
(defun my/messages-popup ()
  "Open *Messages* buffer as a bottom popup and focus it."
  (interactive)
  (select-window
   (display-buffer
    (get-buffer-create "*Messages*")
    '((display-buffer-reuse-window
       display-buffer-in-side-window)
      (side . bottom)
      (slot . 1)
      (window-height . 0.3)
      (window-parameters . ((no-delete-other-windows . t))))))
  (local-set-key (kbd "q") #'quit-window)
  (goto-char (point-max)))

(global-set-key (kbd "C-h C-m") #'my/messages-popup)
(which-key-add-key-based-replacements "C-h C-m" "messages popup")

(provide 'tools)
