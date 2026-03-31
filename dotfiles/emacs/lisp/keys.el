;;; keys.el --- Description -*- lexical-binding: t; -*-
;; SPACE Leader key
(define-prefix-command 'leader)

;; Window bindings
(define-key leader (kbd "w v") #'split-window-right)
(define-key leader (kbd "w s") #'split-window-below)
(define-key leader (kbd "w d") #'delete-window)

;; Buffer
(define-key leader (kbd "b k") (lambda () (interactive) (kill-buffer (current-buffer))))
(define-key leader (kbd "b l") (lambda () (interactive) (switch-to-buffer nil)))
(define-key leader (kbd "b b") #'switch-to-buffer)
(define-key leader (kbd "b n") #'next-buffer)
(define-key leader (kbd "b i") #'ibuffer)

;; files and buffers
(define-key leader (kbd ".") #'find-file)
(define-key leader (kbd ",") #'consult-buffer)
(define-key leader (kbd "/") #'consult-ripgrep)
(define-key leader (kbd "f r") #'consult-recent-file)
(define-key leader (kbd "SPC") #'project-find-file)
(define-key leader (kbd "p R") #'project-query-replace-regexp)
(define-key leader (kbd "s o") #'universal-launcher--web-search)

;; paste into minibuffer
(define-key minibuffer-local-map (kbd "C-S-v") #'yank)
;; kill word backwards in minibuffer
(dolist (map (list minibuffer-local-map
                   minibuffer-local-ns-map
                   minibuffer-local-completion-map
                   minibuffer-local-must-match-map
                   minibuffer-local-isearch-map))
  (define-key map (kbd "C-w") #'backward-kill-word))

;; Movement keys
(global-set-key (kbd "C-<left>")  #'windmove-left)
(global-set-key (kbd "C-<right>") #'windmove-right)
(global-set-key (kbd "C-<down>")  #'windmove-down)
(global-set-key (kbd "C-<up>")    #'windmove-up)

;; Resizing windows
(global-set-key (kbd "S-<right>") (lambda () (interactive)
                                    (if (window-in-direction 'left)
                                        (shrink-window-horizontally 5)
                                      (enlarge-window-horizontally 5))))
(global-set-key (kbd "S-<left>")  (lambda () (interactive)
                                    (if (window-in-direction 'right)
                                        (shrink-window-horizontally 5)
                                      (enlarge-window-horizontally 5))))
(global-set-key (kbd "S-<up>")    (lambda () (interactive)
                                    (if (window-in-direction 'below)
                                        (shrink-window 2)
                                      (enlarge-window 2))))
(global-set-key (kbd "S-<down>")  (lambda () (interactive)
                                    (if (window-in-direction 'above)
                                        (shrink-window 2)
                                      (enlarge-window 2))))


;; zoom in/out like we do everywhere else.
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

;; Bookmarks
(define-key leader (kbd "b m") #'bookmark-set)
(define-key leader (kbd "b P") #'bookmark-save)
(define-key leader (kbd "b D") #'bookmark-delete)
(define-key leader (kbd "RET") #'bookmark-jump)
(define-key leader (kbd "o b") #'browse-url-of-file)
(define-key leader (kbd "x") #'org-capture)

;; Save
(global-set-key (kbd "C-s") #'save-buffer)
(global-set-key (kbd "C-v") #'clipboard-yank)

;; Save all buffers
(defun my/save-all-buffers ()
  "Save all modified buffers without prompting."
  (interactive)
  (save-some-buffers t))

(define-key leader (kbd "b S") #'my/save-all-buffers)

;; Tabs keybinds
(global-set-key (kbd "C-<tab>")   #'tab-next)
(global-set-key (kbd "C-S-<tab>") #'tab-previous)

;; evaluate region
(global-set-key (kbd "C-x C-r") #'eval-region)

;; programs
(define-key leader (kbd "o T") #'vterm-here)
(define-key leader (kbd "o d") #'dirvish)
(define-key leader (kbd "e r") #'my/erc-connect)
(define-key leader (kbd "e w") #'eww)
(define-key leader (kbd "e e") #'elfeed)
(define-key leader (kbd "e u") #'elfeed-update)
(define-key leader (kbd "e v") #'elfeed-tube-mpv)
(define-key leader (kbd "e g") #'gptel)
(define-key leader (kbd "e s") #'gptel-send)

;; File path yanking
(defun my/yank-buffer-path (&optional root)
  "Copy current buffer's file path, or dired file at point, to kill ring."
  (interactive)
  (let ((filename (or (and (derived-mode-p 'dired-mode)
                           (dired-get-file-for-visit))
                      (buffer-file-name))))
    (if filename
        (let ((path (if root
                        (file-relative-name filename root)
                      (abbreviate-file-name filename))))
          (kill-new path)
          (message "Copied: %s" path))
      (message "Buffer is not visiting a file"))))

;; yank when in file
(define-key leader (kbd "f y") #'my/yank-buffer-path)

;; Reload function
(defun my/reload-config ()
  (interactive)
  (load-file user-init-file)
  (message "Config reloaded."))

(global-set-key (kbd "C-c r") #'my/reload-config)

;; config hotkey
(define-key leader (kbd "f p")
            (lambda () (interactive)
              (let ((default-directory "~/nixos-config/dotfiles/emacs/"))
                (call-interactively #'find-file))))

;; snippets hotkey
(define-key leader (kbd "f s")
            (lambda () (interactive)
              (let ((default-directory "~/nixos-config/dotfiles/emacs/snippets/"))
                (call-interactively #'find-file))))

(provide 'keys)
;;; keys.el ends here
