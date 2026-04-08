;;; org-roam-config.el --- Description -*- lexical-binding: t; -*-

(defun my/org-roam-filetags-prompt ()
  "Prompt for filetags from existing org-roam tags."
  (let* ((tags (seq-uniq (flatten-list
                          (org-roam-db-query
                           [:select [tag] :from tags]))))
         (selected (completing-read-multiple "Tags: " tags)))
    (format ":%s:" (string-join selected ":"))))

(use-package org-roam
  :ensure t
  :hook (org-mode . org-roam-db-autosync-mode)
  :commands (org-roam-node-find
             org-roam-node-insert
             org-roam-dailies-goto-today
             org-roam-buffer-toggle
             org-roam-db-sync
             org-roam-capture)
  :init
  (setq org-roam-directory "~/org/roam"
        org-roam-database-connector 'sqlite-builtin
        org-roam-completion-everywhere t
        org-roam-db-location (expand-file-name "org-roam.db" "~/org/roam")
        org-roam-v2-ack t)
  :config
  (setq org-roam-db-update-on-save nil)

  (unless (file-exists-p org-roam-directory)
    (make-directory org-roam-directory t))

  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "${slug}.org"
                              ":PROPERTIES:\n:ID: %(org-id-new)\n:END:\n#+title: ${title}\n#+filetags: %(my/org-roam-filetags-prompt)\n\n")
           :unnarrowed t
           :immediate-finish nil)))

  (setq org-roam-dailies-directory "daily/"
        org-roam-dailies-capture-templates
        '(("d" "default" entry "* %<%H:%M>: %?"
           :target (file+head "%<%Y-%m-%d>.org"
                              ":PROPERTIES:\n:ID:       %(org-id-new)\n:END:\n#+title: %<%Y-%m-%d %A>\n#+filetags: :daily:\n\n")))))


(use-package org-roam-ui
  :ensure t
  :defer t
  :commands (org-roam-ui-mode org-roam-ui-open)
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

(provide 'org-roam-config)
