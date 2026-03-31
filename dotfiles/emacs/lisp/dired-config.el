;;; dired-config.el --- Dired/dirvish config -*- lexical-binding: t; -*-
(use-package dired
  :ensure nil
  :hook
  (dired-mode . dired-omit-mode)
  (dired-mode . auto-revert-mode)
  :custom
  (dired-listing-switches "-lAh --group-directories-first --no-group")
  (dired-dwim-target t)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'top)
  (dired-create-destination-dirs 'ask)
  (delete-by-moving-to-trash t)
  (dired-auto-revert-buffer t)
  ;; dired-x
  (dired-omit-verbose nil)
  (dired-omit-files (concat "\\(?:^\\|/\\)\\.")))

(use-package dirvish
  :ensure t
  :init
  (dirvish-override-dired-mode)
  :custom
  (dirvish-attributes '(nerd-icons subtree-state file-size))
  (dirvish-use-mode-line nil)
  (dirvish-use-header-line t)
  (dirvish-header-line-format '(:left (path) :right (free-space)))
  (dirvish-subtree-always-show-state t)
  (dirvish-hide-details '(dirvish))
  (dirvish-reuse-session 'open)
  (dirvish-preview-dispatchers '(image gif video audio epub archive pdf))
  :config
  (use-package diredfl
    :ensure t
    :hook (dired-mode . diredfl-mode))
  (with-eval-after-load 'evil
    (define-key dired-mode-map (kbd "SPC") nil)
    (evil-define-key '(normal motion) dired-mode-map (kbd "SPC") 'leader)
    (evil-define-key 'normal dirvish-mode-map
      (kbd "<left>")  #'dired-up-directory
      (kbd "<right>") #'dired-find-file
      (kbd "<down>")  #'dired-next-line
      (kbd "<up>")    #'dired-previous-line
      (kbd "TAB")     #'dirvish-subtree-toggle
      (kbd "S-TAB")   #'dirvish-subtree-toggle)
    (evil-define-key 'normal dired-mode-map
      (kbd "m")   #'dired-mark
      (kbd "u")   #'dired-unmark
      (kbd "d")   #'dired-flag-file-deletion
      (kbd "D")   #'dired-do-delete
      (kbd "R")   #'dired-do-rename
      (kbd "y y")   #'dired-do-copy
      (kbd "q")   #'dirvish-quit
      (kbd ".")   #'dired-omit-mode
      (kbd "g r") #'revert-buffer)))

(custom-set-faces
 '(dirvish-hl-line-inactive ((t (:background "#171a1e"))))
 '(dirvish-hl-line ((t (:background "#2a2d32")))))

(provide 'dired-config)
;;; dired-config.el ends here
