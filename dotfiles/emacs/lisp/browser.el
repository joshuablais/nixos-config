;;; browser.el --- Description -*- lexical-binding: t; -*-

;; set specific browser to open links
;; set browser to firefox
;; (setq browse-url-browser-function 'browse-url-firefox)
(setq browse-url-browser-function 'browse-url-generic)
(setq browse-url-generic-program "chromium")  ; replace with actual executable name

(provide 'browser)
