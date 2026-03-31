;;; clipboard-manager.el --- Description -*- lexical-binding: t; -*-


(defun jb/get-cliphist-entries ()
  "Get the 50 most recent clipboard entries from cliphist, fully decoded."
  (when (executable-find "cliphist")
    (let* ((list-output (shell-command-to-string "cliphist list"))
           (lines (split-string list-output "\n" t))
           ;; Take only first 50 entries (newest first)
           (limited-lines (seq-take lines 50)))
      ;; Decode each entry to get full content
      (delq nil
            (mapcar (lambda (line)
                      (when (string-match "^\\([0-9]+\\)\t" line)
                        (let ((id (match-string 1 line)))
                          (string-trim (shell-command-to-string
                                        (format "cliphist decode %s" id))))))
                    limited-lines)))))

(defun jb/clipboard-manager ()
  "Browse kill ring + system clipboard history, copy selection to clipboard.
The full, untruncated text is always copied - truncation is only for display."
  (interactive)
  (require 'consult)
  (let* ((cliphist-items (jb/get-cliphist-entries))
         (kill-ring-items kill-ring)
         (all-items (delete-dups (append cliphist-items kill-ring-items)))
         (candidates (mapcar (lambda (item)
                               (let ((display (truncate-string-to-width
                                             (replace-regexp-in-string "\n" " " item)
                                             80 nil nil "...")))
                                 (cons display item)))
                             all-items))
         (selected (consult--read
                    candidates
                    :prompt "Clipboard history: "
                    :sort nil
                    :require-match t
                    :category 'kill-ring
                    :lookup #'consult--lookup-cdr
                    :history 'consult--yank-history)))
    (when selected
      (with-temp-buffer
        (insert selected)
        (call-process-region (point-min) (point-max) "wl-copy"))

      (unless (member selected kill-ring)
        (kill-new selected))

      (message "Copied to clipboard: %s"
               (truncate-string-to-width selected 50 nil nil "...")))))

(define-key leader (kbd "y y") #'jb/clipboard-manager)

(provide 'jb-clipboard-manager)
