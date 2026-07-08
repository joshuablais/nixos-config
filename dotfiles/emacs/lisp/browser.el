;;; browser.el --- Description -*- lexical-binding: t; -*-

;; set specific browser to open links
;; set browser to firefox
;; (setq browse-url-browser-function 'browse-url-firefox)
;; (setq browse-url-browser-function 'browse-url-generic)
(setq browse-url-generic-program "chromium")

;; set searx instance
(setq eww-search-prefix "https://searx.labrynth.org/search?q=")
(setq eww-download-directory (expand-file-name "~/Downloads/"))
(setq eww-auto-rename-buffer 'title)

;; push sites to lighter versions
(setq eww-url-transformers
      '(eww-remove-tracking
        (lambda (url)
          (cond
           ((string-match-p "twitter\\.com" url)
            (replace-regexp-in-string "twitter\\.com" "nitter.net" url))
           ((string-match-p "reddit\\.com" url)
            (replace-regexp-in-string "reddit\\.com" "libreddit.it" url))
           (t url)))))

;; Syntax hilighting
(use-package shr-tag-pre-highlight
  :ensure t
  :after shr
  :config
  (add-to-list 'shr-external-rendering-functions
               '(pre . shr-tag-pre-highlight)))

(use-package language-detection
  :ensure t)

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
        ("\\.mp4$" . my-browse-url-mpv)
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
  (define-key eww-mode-map (kbd "B") #'eww-back-url)
  (define-key eww-mode-map (kbd "F") #'eww-forward-url)
  (define-key eww-mode-map (kbd "a") #'eww-add-bookmark)
  (define-key eww-mode-map (kbd "U") #'shr-copy-url)
  (define-key eww-mode-map (kbd "D") #'my/eww-download-image-at-point))


;; Browser tab switching brought into emacs
(defvar jb/browser-debug-port 9222
  "CDP remote debugging port. Same for Firefox and Chromium.")

(defun jb/browser-tabs ()
  "Get all tabs from a CDP-compatible browser."
  (let* ((raw (shell-command-to-string
               (format "curl -s http://localhost:%d/json" jb/browser-debug-port)))
         (tabs (json-parse-string raw :array-type 'list :object-type 'alist)))
    (seq-filter (lambda (tab)
                  (string= (alist-get 'type tab) "page"))
                tabs)))

(defun jb/switch-browser-tab ()
  "Switch to a browser tab via CDP, then raise the browser window."
  (interactive)
  (let* ((tabs (jb/browser-tabs))
         (candidates (mapcar (lambda (tab)
                               (cons (format "%s  %s"
                                             (alist-get 'title tab)
                                             (alist-get 'url tab))
                                     (alist-get 'id tab)))
                             tabs))
         (choice (completing-read "Tab: " (mapcar #'car candidates) nil t))
         (id (cdr (assoc choice candidates))))
    (shell-command
     (format "curl -s -X POST http://localhost:%d/json/activate/%s"
             jb/browser-debug-port id))
    (shell-command "swaymsg '[app_id=\"chromium\" ] focus' || swaymsg '[app_id=\"firefox\"] focus'")))

(provide 'browser)
