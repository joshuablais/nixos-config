;;; grammars.el --- treesit, eglot, snippets, lsp -*- lexical-binding: t; -*-
;; TREESIT
(use-package treesit
  :ensure nil
  :init
  ;; Must be in :init — remap must exist before any buffer opens.
  ;; :config is too late; treesit may already be loaded.
  (setq major-mode-remap-alist
        '((go-mode         . go-ts-mode)
          (python-mode     . python-ts-mode)
          (javascript-mode . js-ts-mode)
          (css-mode        . css-ts-mode)
          (html-mode       . html-ts-mode)
          (nix-mode        . nix-ts-mode)
          (c-mode          . c-ts-mode)))
  (setq treesit-language-source-alist
        '((go         "https://github.com/tree-sitter/tree-sitter-go")
          (gomod      "https://github.com/camdencheek/tree-sitter-go-mod")
          (templ      "https://github.com/vrischmann/tree-sitter-templ")
          (nix "https://github.com/nix-community/tree-sitter-nix")
          (python     "https://github.com/tree-sitter/tree-sitter-python")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
          (css        "https://github.com/tree-sitter/tree-sitter-css")
          (c          "https://github.com/tree-sitter/tree-sitter-c")
          (zig        "https://github.com/tree-sitter-grammars/tree-sitter-zig")
          (html       "https://github.com/tree-sitter/tree-sitter-html"))))

(dolist (entry '(("\\.go\\'"     . go-ts-mode)
                 ("go\\.mod\\'"  . go-mod-ts-mode)
                 ("go\\.sum\\'"  . go-mod-ts-mode)
                 ("\\.c\\'"      . c-ts-mode)
                 ("\\.h\\'"      . c-ts-mode)))
  (add-to-list 'auto-mode-alist entry))

(use-package zig-mode
  :ensure t
  :mode "\\.zig\\'")

(use-package templ-ts-mode
  :mode "\\.templ\\'")

(use-package nix-ts-mode
  :mode "\\.nix\\'")

;; YASNIPPET
;; No :defer — yas-global-mode must be live before the first eglot buffer
;; opens or yasnippet-capf serves nothing on first completion attempt.
(use-package yasnippet
  :ensure t
  :demand t
  :config
  (setq yas-snippet-dirs '("~/.config/emacs/snippets")
        yas-verbosity    0)
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :demand t
  :after yasnippet)

(use-package yasnippet-capf
  :ensure t
  :demand t
  :custom
  (yasnippet-capf-lookup-by 'key))

(elpaca-wait)

(add-hook 'org-mode-hook
          (lambda ()
            (setq-local completion-at-point-functions
                        (list #'yasnippet-capf
                              #'cape-dabbrev
                              #'cape-file
                              #'pcomplete-completions-at-point
                              #'ispell-completion-at-point))))

;; See go-mode snippets
(add-hook 'go-ts-mode-hook #'(lambda () (yas-activate-extra-mode 'go-mode)))

;; EGLOT
(use-package eglot
  :ensure nil
  :hook ((go-ts-mode     . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (js-ts-mode     . eglot-ensure)
         (css-ts-mode    . eglot-ensure)
         (html-ts-mode   . eglot-ensure)
         (c-ts-mode      . eglot-ensure)
         (nix-ts-mode    . eglot-ensure)
         (templ-ts-mode  . eglot-ensure)
         (zig-mode       . eglot-ensure))
  :custom
  (eglot-autoshutdown       t)
  (eglot-events-buffer-size 0)
  (eglot-sync-connect       nil)
  (eglot-extend-to-xref     t)
  :config
  (add-to-list 'eglot-server-programs
               '(templ-ts-mode . ("templ" "lsp"))))

(add-hook 'before-save-hook
          (lambda ()
            (when (bound-and-true-p eglot--managed-mode)
              (eglot-format-buffer))))

;; ELDOC BOX
(use-package eldoc-box
  :ensure t
  :hook (eglot-managed-mode . eldoc-box-hover-at-point-mode)
  :custom
  (eldoc-echo-area-use-multiline-p nil) ; suppress echo area, box only
  (eldoc-box-max-pixel-width        400)
  (eldoc-box-max-pixel-height       300)
  (eldoc-box-only-multi-line        t)
  (eldoc-box-cleanup-interval       0.5)
  (eldoc-box-fringe-use-same-bg     t))

;; CAPF WIRING
;; eglot nukes completion-at-point-functions when it starts.
;; This hook fires after eglot takes over and rebuilds the list.
;;
;; cape-capf-super merges eglot + yasnippet into one unified candidate
;; list so they compete on equal footing in the popup.
;; cape-file and cape-dabbrev stay separate — they're fallbacks with
;; different trigger semantics and shouldn't pollute LSP results.
(defun my/eglot-capf ()
  "Rebuild capf stack after eglot activates."
  (setq-local completion-at-point-functions
              (list (cape-capf-super #'eglot-completion-at-point
                                     #'yasnippet-capf)
                    #'cape-file
                    #'cape-dabbrev)))

(add-hook 'eglot-managed-mode-hook #'my/eglot-capf)

;; (with-eval-after-load 'meow
;;   (meow-thing-register 'function
;;                        '(treesit "function.inner")
;;                        '(treesit "function.outer"))
;;   (meow-thing-register 'class
;;                        '(treesit "class.inner")
;;                        '(treesit "class.outer"))
;;   (meow-thing-register 'parameter
;;                        '(treesit "parameter.inner")
;;                        '(treesit "parameter.outer"))
;;   (setq meow-char-thing-table
;;         (append meow-char-thing-table
;;                 '((?f . function)
;;                   (?c . class)
;;                   (?a . parameter)))))

;; KIND-ICON
(use-package kind-icon
  :ensure t
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(provide 'grammars)
;;; grammars.el ends here
