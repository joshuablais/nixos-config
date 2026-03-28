;;; mu4e.el -*- lexical-binding: t; -*-

(use-package mu4e
  :ensure nil
  :defer t
  :commands (mu4e mu4e-compose-new)
  :init
  (setq mu4e-mu-binary (executable-find "mu"))
  :config

  (setq mu4e-maildir "~/Mail"
        mu4e-get-mail-command "mbsync -a"
        mu4e-update-interval 300
        mu4e-change-filenames-when-moving t
        mu4e-attachment-dir "~/Downloads"
        mu4e-compose-format-flowed t
        mu4e-view-show-images t
        mu4e-view-show-addresses t)

  (setq message-send-mail-function 'message-send-mail-with-sendmail
        send-mail-function 'message-send-mail-with-sendmail
        sendmail-program (executable-find "msmtp")
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-sendmail-f-is-evil t
        mail-specify-envelope-from t
        mail-envelope-from 'header)

  (setq user-mail-address "josh@joshblais.com"
        user-full-name "Joshua Blais")
  (setq mu4e-sent-messages-behavior 'sent)

  (setq mu4e-contexts
        (list
         (make-mu4e-context
          :name "joshuaPersonal"
          :match-func (lambda (msg)
                        (when msg
                          (string-prefix-p "/joshuaPersonal"
                                           (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address  . "josh@joshblais.com")
                  (user-full-name     . "Joshua Blais")
                  (mu4e-sent-folder   . "/joshuaPersonal/Sent")
                  (mu4e-drafts-folder . "/joshuaPersonal/Drafts")
                  (mu4e-trash-folder  . "/joshuaPersonal/Trash")
                  (mu4e-refile-folder . "/joshuaPersonal/Archive")))

         (make-mu4e-context
          :name "RevereJosh"
          :match-func (lambda (msg)
                        (when msg
                          (string-prefix-p "/RevereJosh"
                                           (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address  . "josh@reverehome.ca")
                  (user-full-name     . "Joshua Blais")
                  (mu4e-sent-folder   . "/RevereJosh/Sent")
                  (mu4e-drafts-folder . "/RevereJosh/Drafts")
                  (mu4e-trash-folder  . "/RevereJosh/Trash")
                  (mu4e-refile-folder . "/RevereJosh/Archive")))))

  (setq mu4e-context-policy 'pick-first
        mu4e-compose-context-policy 'ask)

  (setq mu4e-bookmarks
        '(("flag:unread AND NOT flag:trashed" "Unread messages"   ?u)
          ("date:today..now"                  "Today's messages"  ?t)
          ("maildir:/joshuaPersonal/Inbox"    "Personal Inbox"    ?p)
          ("flag:flagged"                     "Flagged messages"  ?f)
          ("size:5M.."                        "Big messages"      ?b)))

  (setq mu4e-headers-thread-enable t
        mu4e-headers-show-threads t
        mu4e-headers-include-related t)

  (defun mu4e-compose-mailto (url)
    "Compose from mailto: URL."
    (require 'url-parse)
    (let* ((parsed  (url-generic-parse-url url))
           (to      (url-filename parsed))
           (query   (url-target parsed))
           (headers (when query (url-parse-query-string query))))
      (mu4e-compose-new)
      (message-goto-to)
      (insert to)
      (when-let ((subject (cadr (assoc "subject" headers))))
        (message-goto-subject)
        (insert (url-unhex-string subject)))
      (when-let ((body (cadr (assoc "body" headers))))
        (message-goto-body)
        (insert (url-unhex-string body)))))

  (setq mu4e-compose-complete-addresses nil)

  (setq mu4e-split-view 'horizontal
        mu4e-headers-visible-lines 20)

  ;; Kill message buffer after sending
  (setq message-kill-buffer-on-exit t)

  (defun mu4e-debug-msmtp ()
    "Debug current mail sending settings."
    (interactive)
    (message "sendmail-program: %s" sendmail-program)
    (message "user-mail-address: %s" user-mail-address)
    (message "message-sendmail-extra-arguments: %s"
             message-sendmail-extra-arguments)))

(define-key leader (kbd "o m") #'mu4e)
(define-key leader (kbd "y m") #'mu4e-org-mode)

(provide 'mail)
