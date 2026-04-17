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

(defun jb/post-to-catbox (file)
  "Upload FILE to catbox.moe via curl. Copies URL to wl-clipboard and kill-ring."
  (interactive
   (list (read-file-name "Upload file: "
                         (expand-file-name "~/Pictures/")
                         nil t)))
  (unless (file-exists-p file)
    (user-error "File does not exist: %s" file))
  (let* ((file (expand-file-name file))
         (buf (generate-new-buffer " *catbox-upload*")))
    (message "  Uploading %s..." (file-name-nondirectory file))
    (make-process
     :name "catbox-upload"
     :buffer buf
     :stderr buf
     :command (list "curl" "-sS" "--max-time" "60"
                    "-F" "reqtype=fileupload"
                    "-F" (format "fileToUpload=@%s" file)
                    "https://catbox.moe/user/api.php")
     :sentinel (lambda (proc event)
                 (let ((proc-buf (process-buffer proc)))
                   (when (string-match-p "finished" event)
                     (let* ((raw (with-current-buffer proc-buf
                                   (string-trim (buffer-string))))
                            (url (when (string-match "https://files\\.catbox\\.moe/[a-zA-Z0-9.]+" raw)
                                   (match-string 0 raw))))
                       (when (buffer-live-p proc-buf)
                         (kill-buffer proc-buf))
                       (if (not url)
                           (message "catbox upload failed: %s" raw)
                         (kill-new url)
                         (ignore-errors
                           (with-temp-buffer
                             (insert url)
                             (call-process-region (point-min) (point-max) "wl-copy")))
                         (message "  %s   copied to clipboard" url)))))))))

(defun jb/upload-to-snips (file)
  "Upload FILE to snips.sh via SSH and yank the returned URL."
  (interactive (list (read-file-name "Upload to snips.sh: ")))
  (let* ((file (expand-file-name file))
         (buf  (generate-new-buffer " *snips-upload*")))
    (unless (file-readable-p file)
      (error "File not readable: %s" file))
    (message "Uploading %s to snips.sh..." (file-name-nondirectory file))
    (make-process
     :name     "snips-upload"
     :buffer   buf
     :command  (list "sh" "-c"
                     (format "ssh snips.sh < %s"
                             (shell-quote-argument file)))
     :sentinel (lambda (proc event)
                 (when (string-prefix-p "finished" event)
                   (with-current-buffer (process-buffer proc)
                     (let* ((raw  (buffer-string))
                            (clean (replace-regexp-in-string
                                    "\x1b\\[[0-9;]*[mKHF]" "" raw))
                            (url  (when (string-match
                                         "https://snips\\.sh/f/[A-Za-z0-9_-]+"
                                         clean)
                                    (match-string 0 clean))))
                       (if url
                           (progn
                             (kill-new url)
                             (message "snips.sh → %s (killed)" url))
                         (message "snips.sh upload failed: couldn't parse URL"))))
                   (kill-buffer (process-buffer proc)))
                 (when (string-prefix-p "exited" event)
                   (message "snips.sh upload failed")
                   (kill-buffer (process-buffer proc)))))))

(defun jb/post-to-uguu (file)
  "Upload FILE to uguu.se via curl. Copies URL to wl-clipboard and kill-ring."
  (interactive
   (list (read-file-name "Upload file: "
                         (expand-file-name "~/Pictures/")
                         nil t)))
  (unless (file-exists-p file)
    (user-error "File does not exist: %s" file))
  (let* ((file (expand-file-name file))
         (buf (generate-new-buffer " *uguu-upload*")))
    (message "Uploading %s..." (file-name-nondirectory file))
    (make-process
     :name "uguu-upload"
     :buffer buf
     :stderr buf
     :command (list "curl" "-sS" "--max-time" "60"
                    "-F" (format "files[]=@%s" file)
                    "https://uguu.se/upload?output=text")
     :sentinel (lambda (proc event)
                 (let ((proc-buf (process-buffer proc)))
                   (when (string-match-p "finished" event)
                     (let* ((raw (with-current-buffer proc-buf
                                   (string-trim (buffer-string))))
                            (url (when (string-match "https://[^\n\r]+" raw)
                                   (match-string 0 raw))))
                       (when (buffer-live-p proc-buf)
                         (kill-buffer proc-buf))
                       (if (not url)
                           (message "uguu upload failed: %s" raw)
                         (kill-new url)
                         (ignore-errors
                           (with-temp-buffer
                             (insert url)
                             (call-process-region (point-min) (point-max) "wl-copy")))
                         (message "uguu.se → %s — copied to clipboard" url)))))))))

(provide 'jb-0x0)
