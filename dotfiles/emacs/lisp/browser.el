;;; browser.el --- Description -*- lexical-binding: t; -*-

;; set specific browser to open links
;; set browser to firefox
;; (setq browse-url-browser-function 'browse-url-firefox)
;; (setq browse-url-browser-function 'browse-url-generic)
;; (setq browse-url-generic-program "chromium")

;; set searx instance
(setq eww-search-prefix "https://searx.labrynth.org/search?q=")
(setq eww-download-directory (expand-file-name "~/Downloads/"))

(defun my-browse-url-mpv (url &rest _args)
  "Open URL in mpv."
  (start-process "mpv" nil "mpv" url))

(defun my-browse-url-pdf (url &rest _args)
  "Fetch remote PDF and open in pdf-tools within Emacs."
  (let ((tmp (make-temp-file "emacs-pdf-" nil ".pdf")))
    (url-copy-file url tmp t)
    (find-file-other-window tmp)
    (pdf-view-mode)))

(setq browse-url-handlers
      '(("\\(youtube\\.com\\|youtu\\.be\\|vimeo\\.com\\|twitch\\.tv\\)" . my-browse-url-mpv)
        ("\\.pdf$" . my-browse-url-pdf)
        ("^gemini://" . elpher-browse-url-elpher)
        ("^gopher://" . elpher-browse-url-elpher)
        ("." . eww-browse-url)))

;; Keep your fallback setting
(setq browse-url-secondary-browser-function 'browse-url-generic
      browse-url-generic-program "chromium")

(with-eval-after-load 'eww
  (define-key eww-mode-map (kbd "=") #'text-scale-increase)
  (define-key eww-mode-map (kbd "-") #'text-scale-decrease)
  (define-key eww-mode-map (kbd "0") #'text-scale-adjust))

(setq shr-width 100)          ;; hard column limit, tune to your frame width
(setq shr-max-width 120)      ;; absolute ceiling
(setq shr-indentation 4)      ;; left margin breathing room

(setq shr-use-fonts nil) ;; fix font zoom
(setq shr-max-image-size '(800 . 600))  ;; cap image dimensions
(setq shr-image-animate t)             ;; kill animated gifs entirely

(defun my/eww-download-image-at-point ()
  "Download image at point to `eww-download-directory'."
  (interactive)
  (let ((url (or (get-text-property (point) 'image-url)
                 (get-text-property (point) 'shr-url))))
    (if (not url)
        (message "No image at point")
      (let* ((filename (file-name-nondirectory (url-filename (url-generic-parse-url url))))
             (dest (expand-file-name filename eww-download-directory)))
        (url-copy-file url dest t)
        (message "Saved: %s" dest)))))

;; Keybinds
(with-eval-after-load 'eww
  (define-key eww-mode-map (kbd "b") #'eww-back-url)
  (define-key eww-mode-map (kbd "a") #'eww-add-bookmark)
  (define-key eww-mode-map (kbd "D") #'my/eww-download-image-at-point))

(provide 'browser)
