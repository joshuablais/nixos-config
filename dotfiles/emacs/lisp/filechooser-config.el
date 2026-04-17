;;; filechooser-config.el --- filechooser -*- lexical-binding: t; -*-

(use-package filechooser
  :ensure t
  :demand t
  :config
  (setq filechooser-filters
        '(("Directories" filechooser-file-directory-p . nil)
          ("Elisp files" "\\.el$" . nil)
          ("Not dot files" "^[^.]" . nil)))
  (setq filechooser-choose-files #'filechooser-with-dired)
  (filechooser-start))

(provide 'filechooser-config)
