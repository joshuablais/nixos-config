;;; browser.el --- Description -*- lexical-binding: t; -*-

;; set specific browser to open links
;; set browser to firefox
;; (setq browse-url-browser-function 'browse-url-firefox)
;; (setq browse-url-browser-function 'browse-url-generic)
;; (setq browse-url-generic-program "chromium")

(defun my-browse-url-mpv (url &rest _args)
  "Open URL in mpv."
  (start-process "mpv" nil "mpv" url))

(setq browse-url-handlers
      '(("\\(youtube\\.com\\|youtu\\.be\\)" . my-browse-url-mpv)
        ("." . eww-browse-url)))

;; Keep your fallback setting
(setq browse-url-secondary-browser-function 'browse-url-generic
      browse-url-generic-program "chromium")

(provide 'browser)
