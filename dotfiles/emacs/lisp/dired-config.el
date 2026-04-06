;;; dired-config.el --- Dired/dirvish config -*- lexical-binding: t; -*-
;;; Code:
(use-package dired
  :ensure nil
  :custom
  (dired-listing-switches "-lAh --group-directories-first --no-group")
  (dired-dwim-target t)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'top)
  (dired-create-destination-dirs 'ask)
  (delete-by-moving-to-trash t))

;; inotify-based auto-revert calling dirvish's own revert function
(defvar-local my/dired-file-watch nil
  "File watch descriptor for current dired buffer.")

(defun my/dired-setup-file-watch ()
  "Watch a directory with inotify and revert on change."
  (let ((dir default-directory)
        (buf (current-buffer)))
    (when (and (featurep 'filenotify)
               (file-directory-p dir)
               (not my/dired-file-watch))
      (setq my/dired-file-watch
            (file-notify-add-watch
             dir
             '(change)
             (lambda (_event)
               (when (buffer-live-p buf)
                 (with-current-buffer buf
                   (if (fboundp 'dirvish-revert)
                       (dirvish-revert nil t)
                     (dired-revert nil t)))))))
      (add-hook 'kill-buffer-hook #'my/dired-remove-file-watch nil t))))

(defun my/dired-remove-file-watch ()
  "Clean up inotify watch when buffer is killed."
  (when my/dired-file-watch
    (file-notify-rm-watch my/dired-file-watch)
    (setq my/dired-file-watch nil)))

(defun my/dired-watch-subtree ()
  "Add inotify watch for a just-expanded subtree directory."
  (let ((dir (dired-get-filename nil t)))
    (when (and dir (file-directory-p dir))
      (let ((buf (current-buffer)))
        (file-notify-add-watch
         dir
         '(change)
         (lambda (_event)
           (when (buffer-live-p buf)
             (with-current-buffer buf
               (if (fboundp 'dirvish-revert)
                   (dirvish-revert nil t)
                 (dired-revert nil t))))))))))

(add-hook 'dired-mode-hook #'my/dired-setup-file-watch)
(advice-add 'dirvish-subtree-toggle :after #'my/dired-watch-subtree)

;; Omit dot/hidden files by default
(use-package dired-x
  :ensure nil
  :hook (dired-mode . dired-omit-mode)
  :custom
  (dired-omit-verbose nil)
  (dired-omit-files (concat "\\(?:^\\|/\\)\\.")))

(use-package dirvish
  :ensure t
  :init
  (require 'dired)
  (define-key dired-mode-map (kbd "y") nil)
  (dirvish-override-dired-mode)
  :custom
  (dirvish-attributes '(nerd-icons subtree-state file-size))
  (dirvish-use-mode-line nil)
  (dirvish-use-header-line t)
  (dirvish-header-line-format '(:left (path) :right (free-space)))
  (dirvish-subtree-always-show-state t)
  (dirvish-hide-details '(dirvish))
  (dirvish-reuse-session 'open)
  (dirvish-preview-dispatchers
   '(image gif video audio epub archive pdf))
  :config
  (use-package diredfl
    :ensure t
    :hook (dired-mode . diredfl-mode))
  ;; disable yank extension before it registers y p
  (setq dirvish-yank-keys nil)
  (define-key dirvish-mode-map (kbd "h")       #'dired-up-directory)
  (define-key dirvish-mode-map (kbd "l")       #'dired-find-file)
  (define-key dirvish-mode-map (kbd "j")       #'dired-next-line)
  (define-key dirvish-mode-map (kbd "k")       #'dired-previous-line)
  (define-key dirvish-mode-map (kbd "<left>")  #'dired-up-directory)
  (define-key dirvish-mode-map (kbd "<right>") #'dired-find-file)
  (define-key dirvish-mode-map (kbd "<down>")  #'dired-next-line)
  (define-key dirvish-mode-map (kbd "<up>")    #'dired-previous-line)
  (define-key dirvish-mode-map (kbd "TAB")     #'dirvish-subtree-toggle)
  (define-key dirvish-mode-map (kbd "S-TAB")   #'dirvish-subtree-toggle)
  (define-key dired-mode-map (kbd "m")         #'dired-mark)
  (define-key dired-mode-map (kbd "i")         #'wdired-change-to-wdired-mode)
  (define-key dired-mode-map (kbd "u")         #'dired-unmark)
  (define-key dired-mode-map (kbd "D")         #'dired-flag-file-deletion)
  (define-key dired-mode-map (kbd "R")         #'dired-do-rename)
  (define-key dired-mode-map (kbd "C")         #'dired-do-copy)
  (define-key dired-mode-map (kbd "q")         #'dirvish-quit)
  (define-key dired-mode-map (kbd ".")         #'dired-omit-mode)
  (define-key dired-mode-map (kbd "G")         #'revert-buffer))

;; (with-eval-after-load 'dirvish
;;   (set-face-attribute 'dirvish-hl-line nil
;;                       :inherit 'hl-line
;;                       :background 'unspecified)
;;   (set-face-attribute 'dirvish-hl-line-inactive nil
;;                       :inherit 'hl-line
;;                       :background 'unspecified))

(provide 'dired-config)
;;; dired-config.el ends here
