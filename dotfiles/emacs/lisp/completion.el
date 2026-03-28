;;; completion.el --- completion stack -*- lexical-binding: t; -*-
;;; Code:

(use-package vertico
  :ensure t
  :init
  (vertico-mode 1)
  :custom
  (vertico-cycle t))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode 1))

(elpaca-wait)

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package consult
  :ensure t
  :defer t
  :init
  (setq xref-show-xrefs-function    #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :bind
  (("C-x b"   . consult-buffer)
   ("C-x C-f" . consult-find)
   ("M-g g"   . consult-goto-line)
   ("M-s r"   . consult-ripgrep)
   ("M-s l"   . consult-line)
   ("M-s f"   . consult-fd)
   ("M-y"     . consult-yank-pop))
  :config
  (consult-customize
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   :preview-key '(:debounce 0.4 any)))

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)))

(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package nerd-icons-completion
  :ensure t
  :demand t
  :config
  (nerd-icons-completion-mode)
  (nerd-icons-completion-marginalia-setup))

(use-package corfu
  :ensure t
  :custom
  (corfu-auto        t)
  (corfu-auto-delay  0.2)
  (corfu-auto-prefix 2)
  (corfu-cycle       t)
  (corfu-quit-no-match t)
  :init
  (global-corfu-mode))

;; remove ispell word completion
(setq text-mode-ispell-word-completion nil)

;; Global fallback capfs for non-eglot buffers.
;; eglot-managed buffers get their own stack rebuilt in grammars.el.
(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block))

(provide 'completion)
