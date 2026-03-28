;;; erc-config.el -*- lexical-binding: t; -*-
;;; Code:
(use-package erc
  :ensure nil
  :custom
  (erc-server "irc.joshblais.com")
  (erc-port 6697)
  (erc-nick "joshuablais")
  (erc-autojoin-channels-alist
   '(("libera" "#technicalrenaissance" "#emacs" "#go-nuts" "#systemcrafters" "#nixos" "#librephone")))
  (erc-track-shorten-start 8)
  (erc-kill-buffer-on-part t)
  (erc-auto-query 'bury)
  (erc-fill-column 100)
  (erc-save-queries-on-quit t)
  (erc-interpret-mirc-color t)
  :config
  (add-hook 'erc-text-matched-hook #'my/erc-notify-on-mention)
  (with-eval-after-load 'evil
    (evil-define-key '(normal motion) erc-mode-map
      (kbd "SPC") 'leader)))

(defun my/erc-connect ()
  "Connect to irc.joshblais.com via TLS using auth-source for password."
  (interactive)
  (let ((password (auth-source-pick-first-password
                   :host "irc.joshblais.com"
                   :user "joshua")))
    (if password
        (erc-tls :server "irc.joshblais.com"
                 :port 6697
                 :nick "joshuablais"
                 :password (format "joshua/liberachat:%s" password))
      (message "ERC: password not found in auth-source"))))

(defun my/erc-notify-on-mention (match-type nick message)
  "Send desktop notification on current-nick match."
  (when (and (eq match-type 'current-nick)
             (not (string-match "^\\** *Users on " message)))
    (start-process
     "erc-notify" nil
     "notify-send"
     "-i" "emacs"
     "-u" "normal"
     (format "ERC: %s" (buffer-name))
     (format "%s: %s" nick message))))


(provide 'erc-config)
;;; erc-config.el ends here
