;;; emms-config.el --- Description -*- lexical-binding: t; -*-
;;; Code:
(use-package emms
  :defer t
  :commands (emms
             emms-browser
             emms-playlist-mode-go
             emms-pause
             emms-stop
             emms-next
             emms-previous
             emms-shuffle)
  :init
  (setq emms-source-file-default-directory "~/Music"
        emms-playlist-buffer-name "*Music*"
        emms-info-asynchronously t
        emms-browser-default-browse-type 'artist)

  :config
  (emms-all)
  (emms-default-players)
  (emms-mode-line-mode 1)
  (emms-playing-time-mode 1)

  (setq emms-browser-covers #'emms-browser-cache-thumbnail-async
        emms-browser-thumbnail-small-size 64
        emms-browser-thumbnail-medium-size 128
        emms-source-file-directory-tree-function
        'emms-source-file-directory-tree-find)

  ;; MPD
  (require 'emms-player-mpd)
  (setq emms-player-mpd-server-name "localhost"
        emms-player-mpd-server-port "6600"
        emms-player-mpd-music-directory (expand-file-name "~/Music"))

  (setq emms-player-list '(emms-player-mpd
                           emms-player-mplayer
                           emms-player-vlc
                           emms-player-mpg321
                           emms-player-ogg123))

  (add-to-list 'emms-info-functions 'emms-info-mpd)
  (add-to-list 'emms-info-functions 'emms-info-ogginfo)
  (add-to-list 'emms-info-functions 'emms-info-tinytag)

  (run-with-timer 0.1 nil #'emms-player-mpd-connect)

  ;; Faces
  (set-face-attribute 'emms-browser-artist-face nil
                      :foreground "#e0dcd4" :height 1.1)
  (set-face-attribute 'emms-browser-album-face nil
                      :foreground "#b4bec8" :height 1.0)
  (set-face-attribute 'emms-browser-track-face nil
                      :foreground "#b4beb4" :height 1.0)
  (set-face-attribute 'emms-playlist-track-face nil
                      :foreground "#c0bdb8" :height 1.0)
  (set-face-attribute 'emms-playlist-selected-face nil
                      :foreground "#ccc4b0" :weight 'bold)

  ;; Browser keybindings
  (define-key emms-browser-mode-map (kbd "RET") #'emms-browser-add-tracks-and-play)
  (define-key emms-browser-mode-map (kbd "SPC") #'emms-pause)

  (add-hook 'emms-player-started-hook #'emms-notify-song-change-with-artwork))

;; HELPER FUNCTIONS
(defun my/update-emms-from-mpd ()
  "Update EMMS cache from MPD and refresh browser."
  (interactive)
  (require 'emms)
  (message "Updating EMMS cache from MPD...")
  (emms-player-mpd-connect)
  (emms-cache-set-from-mpd-all)
  (message "EMMS cache updated. Refreshing browser...")
  (when (get-buffer "*EMMS Browser*")
    (with-current-buffer "*EMMS Browser*"
      (emms-browser-refresh))))

(defun emms-center-buffer-in-frame ()
  "Add margins to center the EMMS buffer in the frame."
  (let* ((window-width (window-width))
         (desired-width 80)
         (margin (max 0 (/ (- window-width desired-width) 2))))
    (setq-local left-margin-width margin)
    (setq-local right-margin-width margin)
    (setq-local line-spacing 0.2)
    (set-window-buffer (selected-window) (current-buffer))))

(defun emms-cover-art-path ()
  "Return cover art path for the current track."
  (when (bound-and-true-p emms-playlist-buffer)
    (let* ((track (emms-playlist-current-selected-track))
           (path (emms-track-get track 'name))
           (dir (file-name-directory path))
           (standard-files '("cover.jpg" "cover.png" "folder.jpg" "folder.png"
                             "album.jpg" "album.png" "front.jpg" "front.png"))
           (standard-cover (cl-find-if
                            (lambda (file)
                              (file-exists-p (expand-file-name file dir)))
                            standard-files)))
      (if standard-cover
          (expand-file-name standard-cover dir)
        (let ((cover-files (directory-files dir nil ".*\\(jpg\\|png\\|jpeg\\)$")))
          (when cover-files
            (expand-file-name (car cover-files) dir)))))))

(defun emms-notify-song-change-with-artwork ()
  "Send song change notification with album artwork via notify-send."
  (when (bound-and-true-p emms-playlist-buffer)
    (let* ((track (emms-playlist-current-selected-track))
           (artist (or (emms-track-get track 'info-artist) "Unknown Artist"))
           (title  (or (emms-track-get track 'info-title)  "Unknown Title"))
           (album  (or (emms-track-get track 'info-album)  "Unknown Album"))
           (cover  (emms-cover-art-path)))
      (apply #'start-process
             "emms-notify" nil "notify-send"
             "-a" "EMMS"
             "-c" "music"
             (append
              (when cover (list "-i" cover))
              (list (format "Now Playing: %s" title)
                    (format "Artist: %s\nAlbum: %s" artist album)))))))

;; HOOKS
(with-eval-after-load 'emms-browser
  (add-hook 'emms-browser-mode-hook
            (lambda ()
              (face-remap-add-relative 'default '(:background "#1a1d21"))
              (emms-center-buffer-in-frame))))

(with-eval-after-load 'emms-playlist-mode
  (add-hook 'emms-playlist-mode-hook
            (lambda ()
              (face-remap-add-relative 'default '(:background "#1a1d21"))
              (emms-center-buffer-in-frame))))

(with-eval-after-load 'emms
  (add-hook 'window-size-change-functions
            (lambda (_)
              (when (memq major-mode '(emms-browser-mode emms-playlist-mode))
                (emms-center-buffer-in-frame)))))

;; Keybinds
(with-eval-after-load 'emms
  (define-key leader (kbd "m u") #'my/update-emms-from-mpd)
  (define-key leader (kbd "m d") #'emms-play-directory-tree)
  (define-key leader (kbd "m p") #'emms-playlist-mode-go)
  (define-key leader (kbd "m h") #'emms-shuffle)
  (define-key leader (kbd "m x") #'emms-pause)
  (define-key leader (kbd "m s") #'emms-stop)
  (define-key leader (kbd "m b") #'emms-previous)
  (define-key leader (kbd "m n") #'emms-next)
  (define-key leader (kbd "m o") #'emms-browser))

(provide 'emms-config)
;;; emms-config.el ends here
