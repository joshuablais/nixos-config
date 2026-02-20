(defun jb/post-to-0x0 (file)
  "Upload FILE to 0x0.st via curl. Copies URL to wl-clipboard and kill-ring."
  (interactive
   (list (read-file-name "Upload file: "
                         (expand-file-name "~/Pictures/")
                         nil t)))
  (unless (file-exists-p file)
    (user-error "File does not exist: %s" file))
  (let* ((file (expand-file-name file))
         (buf (generate-new-buffer " *0x0-upload*")))
    (message "⏳ Uploading %s..." (file-name-nondirectory file))
    (make-process
     :name "0x0-upload"
     :buffer buf
     :stderr buf
     :command (list "curl" "-sS" "--max-time" "60"
                    "-F" (format "file=@%s" file)
                    "https://0x0.st")
     :sentinel (lambda (proc event)
                 (let ((proc-buf (process-buffer proc)))
                   (when (string-match-p "finished" event)
                     (let* ((raw (with-current-buffer proc-buf
                                   (string-trim (buffer-string))))
                            (url (when (string-match "https://0x0\\.st/[a-zA-Z0-9.]+" raw)
                                   (match-string 0 raw))))
                       (when (buffer-live-p proc-buf)
                         (kill-buffer proc-buf))
                       (if (not url)
                           (message "0x0 upload failed: %s" raw)
                         (kill-new url)
                         (ignore-errors
                           (with-temp-buffer
                             (insert url)
                             (call-process-region (point-min) (point-max) "wl-copy")))
                         (message "✓ %s — copied to clipboard" url)))))))))
