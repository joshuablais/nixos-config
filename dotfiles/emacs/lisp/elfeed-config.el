;;; elfeed-config.el --- Description -*- lexical-binding: t; -*-
(use-package elfeed
  :ensure t
  :custom
  (elfeed-db-directory "~/.elfeed")
  (elfeed-search-filter "@1-week-ago +unread")
  :config
  (make-directory "~/.elfeed" t)
  (load (expand-file-name "lisp/custom/elfeed-download" user-emacs-directory))
  (elfeed-download-setup)
  (define-key elfeed-search-mode-map (kbd "d") #'elfeed-download-current-entry)
  (define-key elfeed-search-mode-map (kbd "O") #'elfeed-search-browse-url)
  (define-key elfeed-search-mode-map (kbd "v") #'jb/elfeed-search-play-in-mpv)
  (define-key elfeed-show-mode-map   (kbd "v") #'jb/elfeed-play-in-mpv))

(use-package elfeed-protocol
  :ensure t
  :after elfeed
  :config
  (setq elfeed-feeds nil)
  (setq elfeed-use-curl t)
  (elfeed-set-timeout 36000)


  (let* ((auth (auth-source-search :host "miniflux.labrynth.org"
                                   :require '(:secret)))
         (entry (car auth))
         (pass (if (functionp (plist-get entry :secret))
                   (funcall (plist-get entry :secret))
                 (plist-get entry :secret))))
    (if pass
        (setq elfeed-protocol-feeds
              `(("fever+https://joshua@miniflux.labrynth.org"
                 :api-url "https://miniflux.labrynth.org/fever/"
                 :password ,pass)))
      (message "Error: Could not find credentials in auth-source")))

  (elfeed-protocol-enable)


  (run-at-time "1 minute" (* 60 60) #'elfeed-update))

(use-package elfeed-tube
  :ensure t
  :after elfeed
  :config
  (elfeed-tube-setup)
  (define-key elfeed-show-mode-map   (kbd "F")     #'elfeed-tube-fetch)
  (define-key elfeed-show-mode-map   (kbd "C-x C-s") #'elfeed-tube-save))

(defun jb/elfeed-play-in-mpv ()
  "Play current elfeed show entry in mpv."
  (interactive)
  (let ((url (elfeed-entry-link elfeed-show-entry)))
    (unless url (user-error "No URL for this entry"))
    (start-process "elfeed-mpv" nil "mpv"
                   "--ytdl-format=bestvideo[height<=1080]+bestaudio/best"
                   "--save-position-on-quit"
                   url)))

(defun jb/elfeed-search-play-in-mpv ()
  "Play selected elfeed search entry in mpv."
  (interactive)
  (let* ((entry (elfeed-search-selected :ignore-region))
         (url   (elfeed-entry-link entry)))
    (unless url (user-error "No URL for this entry"))
    (elfeed-untag entry 'unread)
    (elfeed-search-update-entry entry)
    (start-process "elfeed-mpv" nil "mpv"
                   "--ytdl-format=bestvideo[height<=1080]+bestaudio/best"
                   "--save-position-on-quit"
                   url)))

(provide 'elfeed-config)
;;; elfeed-config.el ends here
