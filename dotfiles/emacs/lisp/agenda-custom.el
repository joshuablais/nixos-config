;;; agenda-custom.el --- Description -*- lexical-binding: t; -*-

(use-package org-ql
  :ensure t
  :after org)

;; --- Contact CRM queries ---

(defun jb/stale-clients (&optional days)
  "Clients not contacted in DAYS (default 90)."
  (interactive "P")
  (let ((d (or days 90)))
    (org-ql-search "~/org/contacts.org"
                   `(and (tags "client")
                         (property "LAST_CONTACTED")
                         (property-ts< "LAST_CONTACTED"
                                       ,(format-time-string "%Y-%m-%d"
                                                            (time-subtract (current-time) (days-to-time d))))))))

(defun jb/contacts-in (location)
  "Find contacts in LOCATION."
  (interactive "sLocation: ")
  (org-ql-search "~/org/contacts.org"
                 `(property "LOCATION" ,location)))

(defun jb/contacts-by-tag (tag)
  "Find contacts with TAG."
  (interactive "sTag: ")
  (org-ql-search "~/org/contacts.org"
                 `(tags ,tag)))

(defun jb/upcoming-birthdays (&optional days)
  "Birthdays in the next DAYS days (default 30)."
  (interactive "P")
  (let ((d (or days 30)))
    (org-ql-search "~/org/contacts.org"
                   `(and (property "BIRTHDAY")
                         (ts-active :from today :to ,(format-time-string "%Y-%m-%d"
                                                                         (time-add (current-time) (days-to-time d))))))))

(defun jb/never-contacted ()
  "Contacts with empty LAST_CONTACTED."
  (interactive)
  (org-ql-search "~/org/contacts.org"
    '(property "LAST_CONTACTED" "")))


(defun jb/stale-contacts (days)
  "Show contacts not reached in DAYS days."
  (interactive "nDays since last contact: ")
  (let ((cutoff (format-time-string "%Y-%m-%d"
                                    (time-subtract (current-time) (days-to-time days)))))
    (org-ql-search "~/org/contacts.org"
      `(and (property "LAST_CONTACTED")
            (pred (lambda ()
                    (string< (org-entry-get (point) "LAST_CONTACTED") ,cutoff)))))))

(provide 'agenda-custom)
