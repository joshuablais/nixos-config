;;; everywhere.el -*- lexical-binding: t; -*-

(defun thanos/wtype-text (text)
  "Process TEXT for wtype, handling newlines properly."
  (let* ((has-final-newline (string-match-p "\n$" text))
         (lines (split-string text "\n"))
         (last-idx (1- (length lines))))
    (string-join
     (cl-loop for line in lines
              for i from 0
              collect (cond
                       ;; Last line without final newline
                       ((and (= i last-idx) (not has-final-newline))
                        (format "wtype \"%s\""
                                (replace-regexp-in-string "\"" "\\\\\"" line)))
                       ;; Any other line
                       (t
                        (format "wtype \"%s\" && wtype -k Return"
                                (replace-regexp-in-string "\"" "\\\\\"" line)))))
     " && ")))

(define-minor-mode thanos/type-mode
  "Minor mode for inserting text via wtype."
  :keymap `((,(kbd "C-c C-c") . ,(lambda () (interactive)
                                   (call-process-shell-command
                                    (thanos/wtype-text (buffer-string))
                                    nil 0)
                                   (delete-frame)))
            (,(kbd "C-c C-k") . ,(lambda () (interactive)
                                   (kill-buffer (current-buffer))))))

(defun thanos/type ()
  "Launch a temporary frame with a clean buffer for typing."
  (interactive)
  (let ((frame (make-frame '((name . "emacs-float")
                             (fullscreen . 0)
                             (undecorated . t)
                             (width . 70)
                             (height . 20))))
        (buf (get-buffer-create "emacs-float")))
    (select-frame frame)
    (switch-to-buffer buf)
    (with-current-buffer buf
      (erase-buffer)
      (org-mode)
      (flyspell-mode)
      (thanos/type-mode)
      (setq-local header-line-format
                  (format " %s to insert text or %s to cancel."
                          (propertize "C-c C-c" 'face 'help-key-binding)
			              (propertize "C-c C-k" 'face 'help-key-binding)))
      ;; Make the frame more temporary-like
      (set-frame-parameter frame 'delete-before-kill-buffer t)
      (set-window-dedicated-p (selected-window) t))))

(provide 'everywhere)
