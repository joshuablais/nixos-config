;;; tabs.el --- Description -*- lexical-binding: t; -*-

(use-package centaur-tabs
  :ensure t
  :demand t
  :init
  (setq centaur-tabs-set-icons t
        centaur-tabs-gray-out-icons 'buffer
        centaur-tabs-set-bar 'left
        centaur-tabs-set-modified-marker t
        centaur-tabs-close-button "✕"
        centaur-tabs-modified-marker "•"
        centaur-tabs-icon-type 'nerd-icons
        centaur-tabs-cycle-scope 'tabs
        centaur-tabs-style "bar"
        centaur-tabs-height 32)
  :config
  ;; Filter out temp/ephemeral buffers from tabs
  (defun my/tabs-buffer-list ()
    (seq-filter
     (lambda (b)
       (when (buffer-live-p b)
         (let ((name (buffer-name b)))
           (not (or (string-prefix-p " " name)
                    (string-prefix-p "*" name)
                    (string= name ""))))))
     (buffer-list)))

  (setq centaur-tabs-buffer-list-function #'my/tabs-buffer-list)

  ;; Disable tabs in transient/popup-like buffers
  (dolist (hook '(dashboard-mode-hook
                  calendar-mode-hook
                  helpful-mode-hook
                  help-mode-hook))
    (add-hook hook #'centaur-tabs-local-mode))

  (centaur-tabs-mode 1)
  (centaur-tabs-group-by-projectile-project))

;; Keybindings — match Doom's defaults
(with-eval-after-load 'centaur-tabs
  (evil-define-key 'normal centaur-tabs-mode-map
    (kbd "<C-tab>")           #'centaur-tabs-forward
    (kbd "<C-iso-lefttab>")   #'centaur-tabs-backward))

(provide 'tabs)
;;; tabs.el ends here
