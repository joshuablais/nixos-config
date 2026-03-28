;;; org-caldav-config.el -*- lexical-binding: t; -*-

(unless (package-installed-p 'org-caldav)
  (package-refresh-contents)
  (package-install 'org-caldav))

(require 'org-caldav)

(setq org-caldav-url "https://radicale.labrynth.org/joshua"
      org-caldav-calendar-id "a3c565df-28ac-ae51-9fba-0795415c09d3"
      org-caldav-inbox "~/org/caldav-inbox.org"
      org-caldav-files '("~/org/calendar.org")
      org-caldav-sync-direction 'twoway
      org-caldav-delete-org-entries 'ask
      org-caldav-delete-calendar-entries 'ask
      org-icalendar-timezone "America/Edmonton"
      org-icalendar-include-todo nil
      org-export-with-broken-links t)

(with-eval-after-load 'org
  (setq org-export-with-broken-links t))

(advice-add 'org-export-data :around
            (lambda (orig-fun &rest args)
              (let ((org-export-with-broken-links t))
                (apply orig-fun args))))

;; ============================================================================
;; CALDAV SYNC HOOKS
;; ============================================================================

(defun my/org-caldav-sync-calendar ()
  "Sync CalDAV when saving calendar.org."
  (when (and buffer-file-name
             (string-equal (file-name-nondirectory buffer-file-name)
                           "calendar.org"))
    (org-caldav-sync)))

(add-hook 'after-save-hook #'my/org-caldav-sync-calendar)

(defun my/org-caldav-sync-after-capture ()
  "Sync CalDAV after capturing an event."
  (when (and (boundp 'org-capture-mode)
             org-capture-mode
             (member (buffer-file-name)
                     (mapcar #'expand-file-name org-caldav-files)))
    (run-with-timer 1 nil #'org-caldav-sync)))

(add-hook 'org-capture-after-finalize-hook #'my/org-caldav-sync-after-capture)

;; ============================================================================
;; CONTACTS - RADICALE CARDDAV
;; ============================================================================

(defun my/org-contacts-to-radicale ()
  "Export org-contacts to vCard and upload to Radicale."
  (interactive)
  (let* ((url "https://radicale.labrynth.org/joshua/3138d498-1df5-0ddf-1632-9dca442bb144/")
         (username "joshua")
         (auth-info (auth-source-search :host "radicale.labrynth.org"
                                        :port 443
                                        :user username
                                        :require '(:secret)))
         (password (if auth-info
                       (funcall (plist-get (car auth-info) :secret))
                     (error "No credentials found for Radicale"))))
    (with-current-buffer (find-file-noselect "~/org/contacts.org")
      (let ((uploaded 0)
            (failed 0))
        (org-map-entries
         (lambda ()
           (when-let* ((id (org-entry-get nil "ID"))
                       (name (org-entry-get nil "ITEM"))
                       (vcard (my/org-contact-to-vcard-single)))
             (let* ((filename (format "%s.vcf" id))
                    (full-url (concat url filename))
                    (temp-file (make-temp-file "contact-" nil ".vcf")))
               (write-region vcard nil temp-file)
               (let ((result (shell-command-to-string
                              (format "curl -s -w '%%{http_code}' -u %s:%s -X PUT -H 'Content-Type: text/vcard' --data-binary @%s '%s'"
                                      username password temp-file full-url))))
                 (delete-file temp-file)
                 (if (string-match "20[0-4]$" result)
                     (setq uploaded (1+ uploaded))
                   (setq failed (1+ failed))
                   (message "Failed to upload %s: %s" name result))))))
         "LEVEL=1"
         'file)
        (message "Uploaded %d contacts, %d failed" uploaded failed)))))

(defun my/org-contact-to-vcard-single ()
  "Convert current org entry to vCard format."
  (let ((name (org-entry-get nil "ITEM"))
        (phone (org-entry-get nil "PHONE"))
        (email (org-entry-get nil "EMAIL"))
        (birthday (org-entry-get nil "BIRTHDAY"))
        (id (org-entry-get nil "ID")))
    (when name
      (string-join
       (delq nil
             (list
              "BEGIN:VCARD"
              "VERSION:3.0"
              (format "UID:urn:uuid:%s" id)
              (format "FN:%s" name)
              (format "N:%s;;;;" name)
              (when phone (format "TEL;TYPE=CELL:%s" phone))
              (when email (format "EMAIL:%s" email))
              (when birthday
                (format "BDAY:%s"
                        (format-time-string "%Y%m%d"
                                            (org-time-string-to-time birthday))))
              (format "REV:%s" (format-time-string "%Y%m%dT%H%M%SZ"))
              "END:VCARD"))
       "\n"))))

(defun my/auto-export-contacts-to-radicale ()
  "Auto-export contacts to Radicale on save."
  (when (and buffer-file-name
             (string-equal (file-name-nondirectory buffer-file-name)
                           "contacts.org"))
    (my/org-contacts-to-radicale)))

(add-hook 'after-save-hook #'my/auto-export-contacts-to-radicale)

(provide 'org-caldav-config)
