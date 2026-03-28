;;; pass-config.el --- Description -*- lexical-binding: t; -*-
;;; Code:
(use-package pass
  :ensure t
  :defer t
  :config
  (advice-add 'pass :around
              (lambda (orig &rest args)
                (let ((switch-to-buffer-obey-display-actions t))
                  (apply orig args)))))

(setq display-buffer-alist
      (append display-buffer-alist
              '(("\\*Password-Store\\*"
                 (display-buffer-in-side-window)
                 (side . left)
                 (window-width . 0.25)
                 (window-parameters . ((no-other-window . nil)))))))

(provide 'pass-config)
;;; pass-config.el ends here
