;;; jabber-config.el --- Description -*- lexical-binding: t; -*-

(use-package jabber
  :ensure (:host nil
                 :repo "https://git.thanosapollo.org/emacs-jabber/"
                 :branch "master"
                 :main "lisp/jabber.el"
                 :files ("lisp/*.el" "lisp/*.elc"))
  :custom
  (jabber-account-list '(("joshua@xmpp.social")))
  :config
  (jabber-modeline-mode 1)
  :bind-keymap (("C-x C-j" . jabber-global-keymap))
  :hook (kill-emacs . jabber-disconnect))

(provide 'jabber-config)
