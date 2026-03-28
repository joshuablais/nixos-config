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
          (c-mode          . c-ts-mode)))
  (setq treesit-language-source-alist
        '((go         "https://github.com/tree-sitter/tree-sitter-go")
          (gomod      "https://github.com/camdencheek/tree-sitter-go-mod")
          (templ      "https://github.com/vrischmann/tree-sitter-templ")
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
                 ("\\.h\\'"      . c-ts-mode)
                 ("\\.zig\\'"    . zig-ts-mode)))
  (add-to-list 'auto-mode-alist entry))

(use-package templ-ts-mode
  :ensure t
  :mode "\\.templ\\'")

;; YASNIPPET
;; No :defer — yas-global-mode must be live before the first eglot buffer
;; opens or yasnippet-capf serves nothing on first completion attempt.
(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs '("~/.config/emacs/snippets")
        yas-verbosity    0)
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

(use-package yasnippet-capf
  :ensure t
  :after (cape yasnippet))

;; EGLOT
(use-package eglot
  :ensure nil
  :hook ((go-ts-mode     . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (js-ts-mode     . eglot-ensure)
         (templ-ts-mode  . eglot-ensure))
  :custom
  (eglot-autoshutdown       t)
  (eglot-events-buffer-size 0)   ; no event log
  (eglot-sync-connect       nil) ; non-blocking LSP connect
  (eglot-extend-to-xref     t))  ; LSP context follows xref jumps

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

;; EVIL TREE-SITTER TEXT OBJECTS
(use-package evil-textobj-tree-sitter
  :ensure t
  :after evil
  :vc (:url "https://github.com/meain/evil-textobj-tree-sitter"
            :rev :newest
            :files (:defaults "queries" "treesit-queries"))
  :config
  (define-key evil-outer-text-objects-map "f"
              (evil-textobj-tree-sitter-get-textobj "function.outer"))
  (define-key evil-inner-text-objects-map "f"
              (evil-textobj-tree-sitter-get-textobj "function.inner"))
  (define-key evil-outer-text-objects-map "c"
              (evil-textobj-tree-sitter-get-textobj "class.outer"))
  (define-key evil-inner-text-objects-map "c"
              (evil-textobj-tree-sitter-get-textobj "class.inner"))
  (define-key evil-outer-text-objects-map "a"
              (evil-textobj-tree-sitter-get-textobj "parameter.outer"))
  (define-key evil-inner-text-objects-map "a"
              (evil-textobj-tree-sitter-get-textobj "parameter.inner")))

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
