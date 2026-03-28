;;; elpher-config.el --- Description -*- lexical-binding: t; -*-

(use-package elpher
  :ensure (:url "https://thelambdalab.xyz/git/elpher.git" :depth nil)
  :defer t
  :config
  (defun my/org-return-and-maybe-elpher ()
    "Handle org-return and open gemini/gopher links in elpher when appropriate."
    (interactive)
    (let ((context (org-element-context)))
      (if (and (eq (org-element-type context) 'link)
               (member (org-element-property :type context) '("gemini" "gopher")))
          (let ((url (org-element-property :raw-link context)))
            (elpher-go url))
        (org-return))))
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "RET") #'my/org-return-and-maybe-elpher)
    (org-link-set-parameters "gemini"
                             :follow (lambda (path)
                                       (elpher-go (concat "gemini://" path))))
    (org-link-set-parameters "gopher"
                             :follow (lambda (path)
                                       (elpher-go (concat "gopher://" path))))))

(provide 'elpher-config)
