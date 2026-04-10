
;; Kdeconnect-Cli setup
(defvar kde-connect-id "cd355a901c564b2eabccdd7443fba295")

;; get contacts file
(defvar crm-file "~/org/contacts.org")


(defun jb/crm-send-sms-to-contact ()
  "Search contacts.org for a contact and send an SMS via KDE Connect."
  (interactive)
  (let ((contacts nil))
    ;; 1. Parse the file for Names and Phone numbers
    (with-current-buffer (find-file-noselect crm-file)
      (org-with-wide-buffer
       (goto-char (point-min))
       (while (re-search-forward "^\\*+ " nil t)
         (let ((name (org-get-heading t t t t))
               (phone (org-entry-get (point) "PHONE")))
           (when phone
             (push (cons (format "%-20s | %s" name phone) phone) contacts))))))

    ;; 2. Select contact using completing-read (works with Vertico/Ivy/Helm)
    (let* ((selection (completing-read "Send SMS to: " (reverse contacts)))
           (phone-number (cdr (assoc selection contacts)))
           (message-text (read-string (format "Message to %s: " selection))))

      ;; 3. Execute the command
      (if (and phone-number (not (string-empty-p message-text)))
          (let ((cmd (format "kdeconnect-cli -d %s --send-sms %s --destination %s"
                             kde-connect-id
                             (shell-quote-argument message-text)
                             (shell-quote-argument phone-number))))
            (shell-command cmd)
            (message "SMS Sent to %s" phone-number))
        (error "Operation cancelled or missing data")))))

(provide 'crm-config)
