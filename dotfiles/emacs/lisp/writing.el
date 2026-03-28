;;; writing.el -*- lexical-binding: t; -*-

(use-package olivetti
  :ensure t
  :defer t
  :custom
  (olivetti-body-width 100))

(use-package focus
  :ensure t
  :defer t)

(defvar my/zen--saved-cursor-type nil
  "Cursor type before zen mode was activated.")

(defvar my/zen--saved-face-remapping nil
  "Face remapping cookie before zen mode was activated.")

(defun my/zen-mode ()
  "Toggle a distraction-free writing environment."
  (interactive)
  (require 'olivetti)
  (require 'focus)
  (if (bound-and-true-p olivetti-mode)
      (progn
        (olivetti-mode -1)
        (focus-mode -1)
        (display-line-numbers-mode 1)
        (hl-line-mode 1)
        (text-scale-set 0)
        (when my/zen--saved-cursor-type
          (setq cursor-type my/zen--saved-cursor-type)
          (setq my/zen--saved-cursor-type nil))
        (when my/zen--saved-face-remapping
          (face-remap-remove-relative my/zen--saved-face-remapping)
          (setq my/zen--saved-face-remapping nil)))
    (progn
      (setq my/zen--saved-cursor-type cursor-type)
      (setq my/zen--saved-face-remapping
            (face-remap-add-relative 'default
                                     :family "Alegreya"
                                     :height 1.2))
      (olivetti-mode 1)
      (focus-mode 1)
      (display-line-numbers-mode -1)
      (hl-line-mode -1)
      (text-scale-set 1)
      (setq cursor-type 'bar))))

(define-key leader (kbd "t z") #'my/zen-mode)

;; Dictionary - built-in, just bind it properly
(use-package dictionary
  :ensure nil
  :bind
  (:map evil-normal-state-map
        ("SPC s t" . dictionary-search))
  :custom
  (dictionary-server "dict.org"))

;; Synonyms via powerthesaurus (online, no system deps)
(use-package powerthesaurus
  :ensure t
  :bind
  (:map evil-normal-state-map
        ("SPC s T" . powerthesaurus-lookup-synonyms-dwim)))

(provide 'writing)
