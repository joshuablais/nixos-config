;;; persist.el -*- lexical-binding: t; -*-

(use-package easysession
  :ensure t
  :custom
  (easysession-save-interval (* 10 60))
  :config
  (easysession-setup))

(define-key leader (kbd "<TAB> s") #'easysession-save)
(define-key leader (kbd "<TAB> l") #'easysession-switch-to)
(define-key leader (kbd "<TAB> R") #'easysession-rename)
(define-key leader (kbd "<TAB> D") #'easysession-delete)

(provide 'persist)
