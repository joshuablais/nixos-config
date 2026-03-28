;;; spelling.el --- spell checking -*- lexical-binding: t; -*-
;;; Code:

(use-package ispell
  :ensure nil
  :config
  (let* ((aspell-bin  (executable-find "aspell"))
         (aspell-root (when aspell-bin
                        (file-name-directory
                         (directory-file-name
                          (file-name-directory aspell-bin)))))
         (dict-dir    (when aspell-root
                        (expand-file-name "lib/aspell" aspell-root))))
    (setq ispell-program-name  "aspell"
          ispell-dictionary    "en_US"
          ispell-extra-args    (when dict-dir
                                 (list "--lang=en_US"
                                       (concat "--dict-dir=" dict-dir)))
          ispell-alternate-dictionary
          (expand-file-name "+STORE/dictionary/words_spell-fu-ispell-words-default.txt" "~")
          ispell-local-dictionary-alist
          '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)))))

(use-package flyspell
  :ensure nil
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode))
  :custom
  (flyspell-issue-message-flag nil) ; suppress per-word messages, reduces noise
  :config
  ;; prog-mode: check comments only, not strings or doc faces
  (setq flyspell-prog-text-faces
        (cl-remove-if (lambda (f) (memq f '(font-lock-string-face
                                            font-lock-doc-face)))
                      flyspell-prog-text-faces)))

;; suppress ispell from polluting corfu in text buffers
(setq text-mode-ispell-word-completion nil)

(use-package flyspell-correct
  :ensure t
  :after flyspell
  :bind (:map flyspell-mode-map
              ("C-;" . flyspell-correct-wrapper)))

(provide 'spelling)
;;; spelling.el ends here
