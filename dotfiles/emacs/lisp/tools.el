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
  :ensure t)

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

(defun jb/checks ()
  "Execute my bash script."
  (interactive)
  (shell-command "~/.config/scripts/Misc/checks"))

;; Password store helper script
(defun my/read-secret (entry)
  "Return the first line of pass ENTRY, or nil if unavailable."
  (require 'password-store)
  (ignore-errors
    (password-store-get entry)))

(defgroup jb/just nil
  "Custom integration for `just` runner."
  :group 'tools)

(defvar jb/just-last-root nil
  "Last project root used by `jb/just`.")

(defvar jb/just-last-recipe nil
  "Last recipe executed by `jb/just`.")

(defun jb/just--find-root (&optional arg)
  "Determine the project root directory.
If ARG is non-nil, force prompting for a project root via `project-prompt-project-dir`."
  (cond
   (arg (project-root (project-current t)))
   ((project-current) (project-root (project-current)))
   (jb/just-last-root jb/just-last-root)
   (t (project-root (project-current t)))))

(defun jb/just--executable (root)
  "Locate the `just` binary, preferring project-local direnv environments."
  (let ((local-just (expand-file-name ".direnv/profile/bin/just" root)))
    (if (file-executable-p local-just)
        local-just
      (or (executable-find "just")
          (error "Could not find `just` executable")))))

(defun jb/just--get-recipes (root)
  "Extract available recipes using `just --summary`."
  (let ((default-directory root)
        (just (jb/just--executable root)))
    (when (fboundp 'envrc--update-env)
      (ignore-errors (envrc--update-env root)))
    (with-temp-buffer
      (if (zerop (call-process just nil t nil "--summary"))
          (split-string (buffer-string) "[ \t\n]+" t)
        (error "Failed to retrieve recipes from %s" root)))))

;;;###autoload
(defun jb/just (root recipe &optional arg)
  "Run a just RECIPE from project ROOT using compilation mode.

With a single prefix argument (\\[universal-argument]), prompt to choose a
different project ROOT.
With a double prefix argument (\\[universal-argument] \\[universal-argument]),
re-run the last executed recipe directly."
  (interactive
   (let* ((force-root (equal current-prefix-arg '(4)))
          (rerun (equal current-prefix-arg '(16)))
          (root (if rerun
                    (or jb/just-last-root (jb/just--find-root))
                  (jb/just--find-root force-root)))
          (recipes (unless rerun (jb/just--get-recipes root)))
          (recipe (if rerun
                      (or jb/just-last-recipe
                          (completing-read "just: " recipes nil t))
                    (completing-read (format "just (%s): "
                                             (file-name-nondirectory
                                              (directory-file-name root)))
                                     recipes nil t))))
     (list root recipe current-prefix-arg)))

  (setq jb/just-last-root root
        jb/just-last-recipe recipe)

  (let* ((default-directory root)
         (just (jb/just--executable root))
         (profile-bin (expand-file-name ".direnv/profile/bin" root))
         (compilation-environment
          (append (list (concat "PATH=" profile-bin ":" (getenv "PATH")))
                  compilation-environment)))
    (compile (format "%s %s" just recipe))))

;;;###autoload
(defun jb/just-rerun ()
  "Re-run the last `jb/just` recipe in its respective project root."
  (interactive)
  (if (and jb/just-last-root jb/just-last-recipe)
      (jb/just jb/just-last-root jb/just-last-recipe)
    (call-interactively #'jb/just)))

(provide 'tools)
