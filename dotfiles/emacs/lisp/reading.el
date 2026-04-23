;;; reading.el --- Description -*- lexical-binding: t; -*-

(use-package nov
  :ensure t
  :defer t
  :init
  (setq large-file-warning-threshold (* 50 1024 1024))
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
  :config
  ;; Double-check if bsdtar exists, otherwise fallback to standard unzip
  (let ((bsdtar (executable-find "bsdtar")))
    (if bsdtar
        (setq nov-unzip-program bsdtar
              nov-unzip-args '("-xC" directory "-f" filename))
      (setq nov-unzip-program (executable-find "unzip"))))

  (defun my-nov-setup ()
    (face-remap-add-relative 'variable-pitch
                             :family "ETBembo"
                             :height 1.4)
    (buffer-face-mode 1)
    (setq-local line-spacing 0.3)
    (setq-local olivetti-body-width 85)
    (visual-line-mode 1)
    (olivetti-mode 1))

  (add-hook 'nov-mode-hook #'my-nov-setup))

(use-package calibredb
  :ensure t
  :defer t
  :commands calibredb
  :config
  (setq calibredb-root-dir "~/Library"
        calibredb-db-dir (expand-file-name "metadata.db" calibredb-root-dir)
        calibredb-library-alist '(("~/Library"))
        calibredb-format-all-the-icons t)
  (with-eval-after-load 'calibredb
    (define-key calibredb-search-mode-map (kbd "RET") #'calibredb-find-file)
    (define-key calibredb-search-mode-map (kbd "?")   #'calibredb-dispatch)
    (define-key calibredb-search-mode-map (kbd "a")   #'calibredb-add)
    (define-key calibredb-search-mode-map (kbd "d")   #'calibredb-remove)
    (define-key calibredb-search-mode-map (kbd "j")   #'calibredb-next-entry)
    (define-key calibredb-search-mode-map (kbd "k")   #'calibredb-previous-entry)
    (define-key calibredb-search-mode-map (kbd "l")   #'calibredb-open-file-with-default-tool)
    (define-key calibredb-search-mode-map (kbd "s")   #'calibredb-set-metadata-dispatch)
    (define-key calibredb-search-mode-map (kbd "S")   #'calibredb-switch-library)
    (define-key calibredb-search-mode-map (kbd "q")   #'calibredb-search-quit)))

(use-package pdf-tools
  :ensure t
  :defer t
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-tools-install :no-query)
  (setq pdf-view-display-size 'fit-page
        pdf-view-continuous t
        pdf-view-midnight-colors '("#d4c9a8" . "#1c1c1c")
        pdf-annot-activate-created-annotations t)
  (add-hook 'pdf-view-mode-hook
            (lambda ()
              (pdf-view-midnight-minor-mode 1)
              (setq-local mode-line-format nil)))
  (with-eval-after-load 'pdf-tools
    (define-key pdf-view-mode-map (kbd "j") #'pdf-view-next-line-or-next-page)
    (define-key pdf-view-mode-map (kbd "k") #'pdf-view-previous-line-or-previous-page)
    (define-key pdf-view-mode-map (kbd "J") #'pdf-view-next-page)
    (define-key pdf-view-mode-map (kbd "K") #'pdf-view-previous-page)
    (define-key pdf-view-mode-map (kbd "g") #'pdf-view-first-page)
    (define-key pdf-view-mode-map (kbd "G") #'pdf-view-last-page)
    (define-key pdf-view-mode-map (kbd "C-d") #'pdf-view-scroll-up-or-next-page)
    (define-key pdf-view-mode-map (kbd "C-u") #'pdf-view-scroll-down-or-previous-page)
    (define-key pdf-view-mode-map (kbd "+") #'pdf-view-enlarge)
    (define-key pdf-view-mode-map (kbd "-") #'pdf-view-shrink)
    (define-key pdf-view-mode-map (kbd "=") #'pdf-view-fit-page-to-window)
    (define-key pdf-view-mode-map (kbd "s") #'pdf-view-fit-width-to-window)
    (define-key pdf-view-mode-map (kbd "m") #'pdf-view-set-slice-from-bounding-box)
    (define-key pdf-view-mode-map (kbd "M") #'pdf-view-reset-slice)
    (define-key pdf-view-mode-map (kbd "i") #'pdf-view-midnight-minor-mode)
    (define-key pdf-view-mode-map (kbd "y") #'pdf-view-kill-ring-save)
    (define-key pdf-view-mode-map (kbd "/") #'isearch-forward)
    (define-key pdf-view-mode-map (kbd "n") #'isearch-repeat-forward)
    (define-key pdf-view-mode-map (kbd "N") #'isearch-repeat-backward)
    (define-key pdf-view-mode-map (kbd "q") #'quit-window)))


  (use-package saveplace-pdf-view
    :ensure t
    :defer t
    :after pdf-tools
    :config
    (save-place-mode 1))

(provide 'reading)
