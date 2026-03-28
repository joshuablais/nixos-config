;;; markdown.el -*- lexical-binding: t; -*-

(use-package markdown-mode
  :ensure t
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode)))

(provide 'markdown)
