;;; editing.el --- Description -*- lexical-binding: t; -*-

;; code folding
(use-package kirigami
  :ensure t
  :after evil
  :config
  (define-key evil-normal-state-map "zo" #'kirigami-open-fold)
  (define-key evil-normal-state-map "zO" #'kirigami-open-fold-rec)
  (define-key evil-normal-state-map "zc" #'kirigami-close-fold)
  (define-key evil-normal-state-map "za" #'kirigami-toggle-fold)
  (define-key evil-normal-state-map "zr" #'kirigami-open-folds)
  (define-key evil-normal-state-map "zm" #'kirigami-close-folds))

;; global formatting
(use-package apheleia
  :ensure t
  :config
  ;; Add nixfmt support
  (setf (alist-get 'nixfmt apheleia-formatters) '("nixfmt"))
  (setf (alist-get 'nix-mode apheleia-mode-alist) 'nixfmt)
  (setf (alist-get 'nix-ts-mode apheleia-mode-alist) 'nixfmt)
  (apheleia-global-mode 1))

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default fill-column 80)
(add-hook 'before-save-hook #'delete-trailing-whitespace)
(setq display-line-numbers-type 'relative)
(global-visual-line-mode t)
(setq delete-by-moving-to-trash t)
(setq auto-save-default t)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'hs-minor-mode)

(with-eval-after-load 'electric
  (setq electric-pair-preserve-balance t)
  (setq electric-pair-inhibit-predicate #'electric-pair-conservative-inhibit)
  (setq electric-pair-pairs
        '((?\" . ?\")
          (?\` . ?\`)
          (?\( . ?\))
          (?\[ . ?\])
          (?\{ . ?\}))))
(electric-pair-mode 1)

;; fix <> closing automatically in org-mode
(with-eval-after-load 'org
  (add-hook 'org-mode-hook
            (lambda ()
              (setq-local electric-pair-inhibit-predicate
                          (lambda (c)
                            (if (char-equal c ?<)
                                t
                              (electric-pair-conservative-inhibit c)))))))

(with-eval-after-load 'paren
  (setq show-paren-delay 0)
  (setq show-paren-style 'parenthesis)
  (setq show-paren-when-point-inside-paren t)
  (setq show-paren-when-point-in-periphery t))
(show-paren-mode 1)

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

;; Elisp
(use-package aggressive-indent
  :ensure t
  :hook (emacs-lisp-mode . aggressive-indent-mode))

(use-package highlight-defined
  :ensure t
  :hook (emacs-lisp-mode . highlight-defined-mode))

(use-package elisp-refs
  :ensure t)

(use-package combobulate
  :vc (:url "https://github.com/mickeynp/combobulate" :rev :newest)
  :hook ((go-ts-mode . combobulate-mode))
  :defer t
  :custom
  (combobulate-key-prefix "C-c o"))

(provide 'editing)
;;; editing.el ends here
