;;; gnus-config.el --- Description -*- lexical-binding: t; -*-

(defun my/read-agenix-secret (path)
  "Read and trim a secret from PATH."
  (with-temp-buffer
    (insert-file-contents path)
    (string-trim (buffer-string))))

(use-package gnus
  :defer t
  :config
  ;; === SERVER CONNECTION ===
  (setq gnus-select-method
        '(nntp "news.eternal-september.org"
               (nntp-address "news.eternal-september.org")
               (nntp-port-number 119)
               (nntp-stream-type starttls)))

  (setq canlock-password  (my/read-agenix-secret "/run/agenix/canlock")
        user-full-name    (my/read-agenix-secret "/run/agenix/gnus-name")
        user-mail-address (my/read-agenix-secret "/run/agenix/gnus-email"))

  ;; === LOCAL STORAGE ===
  (setq gnus-directory              "~/.local/share/gnus/"
        gnus-cache-directory        "~/.local/share/gnus/cache/"
        gnus-article-save-directory "~/.local/share/gnus/saved/"
        message-directory           "~/.local/share/gnus/mail/")

  ;; === THREADING ===
  (setq gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references
        gnus-thread-sort-functions             '(gnus-thread-sort-by-most-recent-date)
        gnus-thread-hide-subtree               nil)

  ;; === VISUAL PRESENTATION ===
  (setq gnus-summary-line-format           "%U%R %20,20f  %B%s\n"
        gnus-sum-thread-tree-root          "  "
        gnus-sum-thread-tree-false-root    "  "
        gnus-sum-thread-tree-single-indent "  "
        gnus-sum-thread-tree-indent        "  "
        gnus-sum-thread-tree-leaf-with-other "    "
        gnus-sum-thread-tree-single-leaf   "    "
        gnus-sum-thread-tree-vertical      "  ")

  ;; === BEHAVIOR ===
  (setq gnus-asynchronous                    t
        gnus-use-cache                       t
        gnus-use-scoring                     t
        message-kill-buffer-on-exit          t
        gnus-treat-strip-trailing-blank-lines t)

  ;; === FACES ===
  (with-eval-after-load 'gnus-sum
    (set-face-attribute 'gnus-summary-normal-unread nil
                        :inherit 'font-lock-keyword-face)
    (set-face-attribute 'gnus-summary-selected nil
                        :inherit '(bold highlight)))

  ;; === UI ENHANCEMENTS ===
  (add-hook 'gnus-group-mode-hook #'gnus-topic-mode)

  ;; === AUTO-SUBSCRIPTION ===
  (defvar my/gnus-subscribed-groups
    '("alt.cyberpunk.tech"
      "alt.cyberpunk"
      "comp.lang.go"
      "comp.os.linux.development.apps"
      "comp.editors"
      "comp.arch"
      "comp.programming"
      "comp.unix.programmer"
      "alt.philosophy.debate"
      "soc.religion.christian"
      "alt.privacy.anon-server"
      "comp.risks"
      "misc.writing")
    "Newsgroups to auto-subscribe on first connection.")

  (defun my/gnus-auto-subscribe-groups ()
    "Subscribe to groups in `my/gnus-subscribed-groups' if not already subscribed."
    (interactive)
    (dolist (group my/gnus-subscribed-groups)
      (let ((full-group (concat "nntp+news.eternal-september.org:" group)))
        (unless (gnus-group-entry full-group)
          (gnus-subscribe-group full-group)
          (message "Subscribed to %s" group)))))

  (add-hook 'gnus-started-hook #'my/gnus-auto-subscribe-groups))

(provide 'gnus-config)
