;;; ../../nixos-config/dotfiles/doom/lisp/download-media.el -*- lexical-binding: t; -*-

(defvar jb/media-download-base-dir "~/Downloads/Elfeed"
  "Base directory for downloaded media.")

(defvar jb/media-youtube-dir (expand-file-name "youtube" jb/media-download-base-dir)
  "Directory for YouTube videos.")

(defvar jb/media-music-dir (expand-file-name "music" jb/media-download-base-dir)
  "Directory for music downloads.")

(defvar jb/media-articles-dir (expand-file-name "articles" jb/media-download-base-dir)
  "Directory for article PDFs.")

(defvar jb/media-download-show-progress t
  "Whether to automatically show download progress buffer.")

(defun jb/media--classify-url (url)
  "Classify URL and return media type symbol.
Returns one of: 'youtube, 'spotify, 'music, 'article"
  (cond
   ((string-match-p "youtube\\.com\\|youtu\\.be" url) 'youtube)
   ((string-match-p "spotify\\.com" url) 'spotify)
   ((string-match-p "soundcloud\\.com\\|bandcamp\\.com" url) 'music)
   (t 'article)))

(defun jb/media--ensure-dirs ()
  "Ensure all download directories exist."
  (dolist (dir (list jb/media-youtube-dir
                     jb/media-music-dir
                     jb/media-articles-dir))
    (unless (file-exists-p dir)
      (make-directory dir t))))

(defun jb/media--setup-progress-buffer (buffer-name)
  "Setup and display progress buffer with BUFFER-NAME.
Returns the buffer object."
  (let ((buf (get-buffer-create buffer-name)))
    (with-current-buffer buf
      (read-only-mode -1)
      (erase-buffer)
      (insert (format "=== Media Download Progress ===\n"))
      (insert (format "Started: %s\n\n"
                      (format-time-string "%Y-%m-%d %H:%M:%S")))
      (special-mode))
    (when jb/media-download-show-progress
      (display-buffer buf
                      '((display-buffer-reuse-window
                         display-buffer-at-bottom)
                        (window-height . 0.3))))
    buf))

(defun jb/media--process-filter (proc string buffer-name)
  "Filter function to handle process output.
PROC is the process, STRING is the output, BUFFER-NAME is the target buffer."
  (when (buffer-live-p (process-buffer proc))
    (with-current-buffer (get-buffer-create buffer-name)
      (let ((moving (= (point) (process-mark proc)))
            (inhibit-read-only t))
        (save-excursion
          (goto-char (process-mark proc))
          ;; Insert the text, filtering out some noise
          (insert (ansi-color-apply string))
          (set-marker (process-mark proc) (point)))
        (when moving
          (goto-char (process-mark proc))
          ;; Auto-scroll the window if it's visible
          (let ((window (get-buffer-window (current-buffer) t)))
            (when window
              (set-window-point window (point)))))))))

(defun jb/media--download-youtube (url)
  "Download YouTube video from URL."
  (let* ((default-directory jb/media-youtube-dir)
         (buffer-name "*yt-dlp*")
         (buf (jb/media--setup-progress-buffer buffer-name))
         (proc (make-process
                :name "yt-dlp"
                :buffer buf
                :command (list "yt-dlp"
                               "-f" "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
                               "--embed-thumbnail"
                               "--add-metadata"
                               "--progress"
                               "--newline"  ; Force newline for each progress update
                               url)
                :filter (lambda (proc string)
                          (jb/media--process-filter proc string buffer-name))
                :sentinel (lambda (process event)
                            (let ((buf (get-buffer buffer-name)))
                              (when (buffer-live-p buf)
                                (with-current-buffer buf
                                  (let ((inhibit-read-only t))
                                    (goto-char (point-max))
                                    (cond
                                     ((string-match-p "finished" event)
                                      (insert (format "\n✓ Download complete at %s\n"
                                                      (format-time-string "%Y-%m-%d %H:%M:%S")))
                                      (message "YouTube download complete: %s" url))
                                     ((string-match-p "exited abnormally" event)
                                      (insert (format "\n✗ Download failed at %s\n"
                                                      (format-time-string "%Y-%m-%d %H:%M:%S")))
                                      (message "YouTube download failed: %s" url)))))))))))
    (message "Downloading YouTube video: %s" url)))

(defun jb/media--download-music (url)
  "Download music from URL using your shell script.
This will prompt for metadata interactively in the terminal."
  (let* ((script-path (expand-file-name "~/bin/download-music.sh"))
         (buffer-name "*music-download*"))
    (unless (file-exists-p script-path)
      (error "Music download script not found at %s" script-path))
    ;; Use make-term to create an interactive terminal
    (let ((term-buffer (make-term "music-download" "/bin/sh" nil script-path)))
      (switch-to-buffer term-buffer)
      (term-char-mode)
      (message "Music download started. Follow the prompts in the terminal."))))

(defun jb/media--download-spotify (url)
  "Download Spotify track/playlist using spotdl."
  (let* ((default-directory jb/media-music-dir)
         (buffer-name "*spotdl*")
         (buf (jb/media--setup-progress-buffer buffer-name))
         (proc (make-process
                :name "spotdl"
                :buffer buf
                :command (list "spotdl" url)
                :filter (lambda (proc string)
                          (jb/media--process-filter proc string buffer-name))
                :sentinel (lambda (process event)
                            (let ((buf (get-buffer buffer-name)))
                              (when (buffer-live-p buf)
                                (with-current-buffer buf
                                  (let ((inhibit-read-only t))
                                    (goto-char (point-max))
                                    (cond
                                     ((string-match-p "finished" event)
                                      (insert (format "\n✓ Download complete at %s\n"
                                                      (format-time-string "%Y-%m-%d %H:%M:%S")))
                                      (message "Spotify download complete: %s" url))
                                     ((string-match-p "exited abnormally" event)
                                      (insert (format "\n✗ Download failed at %s\n"
                                                      (format-time-string "%Y-%m-%d %H:%M:%S")))
                                      (message "Spotify download failed: %s" url)))))))))))
    (message "Downloading from Spotify: %s" url)))

(defun jb/media--download-article (url)
  "Download article as PDF using chromium headless."
  (let* ((filename (format "%s/%s.pdf"
                           jb/media-articles-dir
                           (format-time-string "%Y%m%d-%H%M%S")))
         (buffer-name "*article-download*")
         (buf (jb/media--setup-progress-buffer buffer-name))
         (proc (make-process
                :name "article-download"
                :buffer buf
                :command (list "chromium"
                               "--headless"
                               "--disable-gpu"
                               "--no-sandbox"
                               "--print-to-pdf-no-header"
                               (format "--print-to-pdf=%s" filename)
                               url)
                :filter (lambda (proc string)
                          (jb/media--process-filter proc string buffer-name))
                :sentinel (lambda (process event)
                            (let ((buf (get-buffer buffer-name)))
                              (when (buffer-live-p buf)
                                (with-current-buffer buf
                                  (let ((inhibit-read-only t))
                                    (goto-char (point-max))
                                    (cond
                                     ((string-match-p "finished" event)
                                      (insert (format "\n✓ Article saved as PDF: %s\n" filename))
                                      (insert (format "   Completed at %s\n"
                                                      (format-time-string "%Y-%m-%d %H:%M:%S")))
                                      (message "Article saved as PDF: %s" filename))
                                     ((string-match-p "exited abnormally" event)
                                      (insert (format "\n✗ Download failed at %s\n"
                                                      (format-time-string "%Y-%m-%d %H:%M:%S")))
                                      (message "Article download failed: %s" url)))))))))))
    (message "Downloading article: %s" url)))

(defun jb/download-media ()
  "Download media from a URL - music, video, or article.
Automatically classifies the URL and uses the appropriate tool:
- YouTube: yt-dlp
- Spotify: spotdl
- Other music sites: custom script with metadata prompts
- Articles/webpages: chromium headless PDF

With prefix argument, prompts for media type override."
  (interactive)
  (jb/media--ensure-dirs)
  (let* ((url (or (thing-at-point 'url)
                  (read-string "URL: ")))
         (auto-type (jb/media--classify-url url))
         (type (if current-prefix-arg
                   (intern (completing-read
                            "Media type: "
                            '("youtube" "spotify" "music" "article")
                            nil t
                            (symbol-name auto-type)))
                 auto-type)))
    (pcase type
      ('youtube (jb/media--download-youtube url))
      ('spotify (jb/media--download-spotify url))
      ('music (jb/media--download-music url))
      ('article (jb/media--download-article url))
      (_ (error "Unknown media type: %s" type)))))

(map! :leader
      :desc "Download media locally" "o D" #'jb/download-media)
