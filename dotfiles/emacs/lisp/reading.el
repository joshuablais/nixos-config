;;; reading.el --- Description -*- lexical-binding: t; -*-

(use-package nov
  :ensure t
  :defer t
  :init
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
  :config
  (setq nov-unzip-program (executable-find "bsdtar")
        nov-unzip-args '("-xC" directory "-f" filename))
  (add-hook 'nov-mode-hook
            (lambda ()
              (face-remap-add-relative 'variable-pitch
                                       :family "ETBembo"
                                       :height 1.4)
              (setq-local line-spacing 0.3)
              (visual-line-mode 1)
              (olivetti-mode 1))))

(use-package calibredb
  :ensure t
  :defer t
  :commands calibredb
  :config
  (setq calibredb-root-dir "~/Library"
        calibredb-db-dir (expand-file-name "metadata.db" calibredb-root-dir)
        calibredb-library-alist '(("~/Library"))
        calibredb-format-all-the-icons t)
  (with-eval-after-load 'evil
    (evil-define-key 'normal calibredb-search-mode-map
      (kbd "RET") #'calibredb-find-file
      (kbd "?")   #'calibredb-dispatch
      (kbd "a")   #'calibredb-add
      (kbd "d")   #'calibredb-remove
      (kbd "j")   #'calibredb-next-entry
      (kbd "k")   #'calibredb-previous-entry
      (kbd "l")   #'calibredb-open-file-with-default-tool
      (kbd "s")   #'calibredb-set-metadata-dispatch
      (kbd "S")   #'calibredb-switch-library
      (kbd "q")   #'calibredb-search-quit)))

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
  (with-eval-after-load 'evil
    (evil-define-key 'normal pdf-view-mode-map
      (kbd "j")   #'pdf-view-next-line-or-next-page
      (kbd "k")   #'pdf-view-previous-line-or-previous-page
      (kbd "J")   #'pdf-view-next-page
      (kbd "K")   #'pdf-view-previous-page
      (kbd "gg")  #'pdf-view-first-page
      (kbd "G")   #'pdf-view-last-page
      (kbd "C-d") #'pdf-view-scroll-up-or-next-page
      (kbd "C-u") #'pdf-view-scroll-down-or-previous-page
      (kbd "+")   #'pdf-view-enlarge
      (kbd "-")   #'pdf-view-shrink
      (kbd "=")   #'pdf-view-fit-page-to-window
      (kbd "a")   #'pdf-view-fit-page-to-window
      (kbd "s")   #'pdf-view-fit-width-to-window
      (kbd "m")   #'pdf-view-set-slice-from-bounding-box
      (kbd "M")   #'pdf-view-reset-slice
      (kbd "i")   #'pdf-view-midnight-minor-mode  ;; toggle midnight
      (kbd "y")   #'pdf-view-kill-ring-save
      (kbd "/")   #'isearch-forward
      (kbd "n")   #'isearch-repeat-forward
      (kbd "N")   #'isearch-repeat-backward
      (kbd "q")   #'quit-window)))

(use-package saveplace-pdf-view
  :ensure t
  :defer t
  :after pdf-tools
  :config
  (save-place-mode 1))

(provide 'reading)
