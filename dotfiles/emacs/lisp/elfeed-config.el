;;; elfeed-config.el --- Description -*- lexical-binding: t; -*-
(use-package elfeed
  :ensure t
  :custom
  (elfeed-db-directory "~/.elfeed")
  (elfeed-search-filter "@1-week-ago +unread -news")
  :config
  (make-directory "~/.elfeed" t)
  (load (expand-file-name "lisp/custom/elfeed-download" user-emacs-directory))
  (elfeed-download-setup)
  (with-eval-after-load 'evil
    (define-key elfeed-search-mode-map (kbd "SPC") nil)
    (define-key elfeed-show-mode-map (kbd "SPC") nil)
    (evil-define-key '(normal motion) elfeed-search-mode-map (kbd "SPC") 'leader)
    (evil-define-key '(normal motion) elfeed-show-mode-map (kbd "SPC") 'leader)
    (evil-define-key 'normal elfeed-search-mode-map
      (kbd "d") #'elfeed-download-current-entry
      (kbd "O") #'elfeed-search-browse-url)))

(use-package elfeed-org
  :ensure t
  :after elfeed
  :custom
  (rmh-elfeed-org-files '("~/.config/emacs/elfeed.org"))
  :config
  (elfeed-org)
  (run-at-time nil (* 60 60) #'elfeed-update))

(use-package elfeed-tube
  :ensure t
  :after elfeed
  :config
  (elfeed-tube-setup)
  (with-eval-after-load 'evil
    (define-key elfeed-show-mode-map (kbd "SPC") nil)
    (define-key elfeed-search-mode-map (kbd "SPC") nil)
    (evil-define-key '(normal motion) elfeed-show-mode-map (kbd "SPC") 'leader)
    (evil-define-key '(normal motion) elfeed-search-mode-map (kbd "SPC") 'leader)
    (evil-define-key 'normal elfeed-show-mode-map
      (kbd "F") #'elfeed-tube-fetch
      (kbd "C-x C-s") #'elfeed-tube-save)
    (evil-define-key 'normal elfeed-search-mode-map
      (kbd "F") #'elfeed-tube-fetch
      (kbd "C-x C-s") #'elfeed-tube-save)))

(provide 'elfeed-config)
;;; elfeed-config.el ends here
