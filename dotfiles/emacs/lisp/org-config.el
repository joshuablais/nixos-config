;;; org-mode-config.el --- Description -*- lexical-binding: t; -*-
;;; Code:
(setq org-directory "~/org")
(setq org-clock-out-when-done nil)
(setq org-log-done 'time)

(with-eval-after-load 'org
  (setq org-modules                     '(org-habit)
        org-edit-src-content-indentation 0
        org-hide-leading-stars           t)

  ;; Heading navigation
  (define-key org-mode-map (kbd "<M-left>")  #'org-do-promote)
  (define-key org-mode-map (kbd "<M-right>") #'org-do-demote)

  ;; Misc
  (define-key org-mode-map (kbd "C-c C-i") #'my/org-insert-image)
  (define-key org-mode-map (kbd "C-c e")   #'org-set-effort)
  (define-key org-mode-map (kbd "C-c i")   #'org-clock-in)
  (define-key org-mode-map (kbd "C-c o")   #'org-clock-out)

  ;; Calendar date navigation
  (with-eval-after-load 'org
    (advice-add 'org-read-date :before
                (lambda (&rest _)
                  (when (keymapp org-read-date-minibuffer-local-map)
                    (define-key org-read-date-minibuffer-local-map (kbd "<left>")
                                (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-day 1))))
                    (define-key org-read-date-minibuffer-local-map (kbd "<right>")
                                (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-day 1))))
                    (define-key org-read-date-minibuffer-local-map (kbd "<up>")
                                (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-week 1))))
                    (define-key org-read-date-minibuffer-local-map (kbd "<down>")
                                (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-week 1))))))))

  ;; Insertion
  (defun +org--insert-item (direction)
    (let ((context (org-element-lineage
                    (org-element-context)
                    '(table table-row headline inlinetask item plain-list)
                    t)))
      (pcase (org-element-type context)
        ((or `item `plain-list)
         (let ((orig-point (point)))
           (if (eq direction 'above)
               (org-beginning-of-item)
             (end-of-line))
           (let* ((ctx-item? (eq 'item (org-element-type context)))
                  (ctx-cb (org-element-property :contents-begin context))
                  (beginning-of-list? (and (not ctx-item?)
                                           (= ctx-cb orig-point)))
                  (item-context (if beginning-of-list?
                                    (org-element-context)
                                  context))
                  (ictx-cb (org-element-property :contents-begin item-context))
                  (empty? (and (eq direction 'below)
                               (or (not ictx-cb)
                                   (= ictx-cb (1+ (point))))))
                  (pre-insert-point (point)))
             (when empty? (insert "x"))
             (org-insert-item (org-element-property :checkbox context))
             (when empty?
               (delete-region pre-insert-point (1+ pre-insert-point))))))
        ((or `table `table-row)
         (pcase direction
           ('below (save-excursion (org-table-insert-row t))
                   (org-table-next-row))
           ('above (save-excursion (org-shiftmetadown))
                   (org-table-previous-row))))
        (_
         (let ((level (or (org-current-level) 1)))
           (pcase direction
             (`below
              (let (org-insert-heading-respect-content)
                (goto-char (line-end-position))
                (org-end-of-subtree)
                (insert "\n" (make-string level ?*) " ")))
             (`above
              (org-back-to-heading)
              (insert (make-string level ?*) " ")
              (save-excursion (insert "\n"))))
           (run-hooks 'org-insert-heading-hook)
           (when-let* ((todo-keyword (org-element-property :todo-keyword context))
                       (todo-type    (org-element-property :todo-type context)))
             (org-todo
              (cond ((eq todo-type 'done)
                     (car (+org-get-todo-keywords-for todo-keyword)))
                    (todo-keyword)
                    ('todo)))))))
      (when (org-invisible-p)
        (org-show-hidden-entry))
      (when (and (bound-and-true-p evil-local-mode)
                 (not (evil-emacs-state-p)))
        (evil-insert 1))))

  (defun +org/insert-item-below (count)
    "Insert new heading, table cell or item below current."
    (interactive "p")
    (dotimes (_ count) (+org--insert-item 'below)))

  (defun +org/insert-item-above (count)
    "Insert new heading, table cell or item above current."
    (interactive "p")
    (dotimes (_ count) (+org--insert-item 'above)))

  (with-eval-after-load 'evil
    (evil-define-key '(normal insert) org-mode-map
      (kbd "M-RET")        #'+org/insert-item-below
      (kbd "C-<return>")   #'+org/insert-item-below
      (kbd "C-S-<return>") #'+org/insert-item-above)))

(defun my/org-clock-in-if-starting ()
  "Clock in when task state changes to STRT."
  (when (and (string= org-state "STRT")
             (not (org-clock-is-active)))
    (org-clock-in)))

(defun my/org-clock-out-if-not-starting ()
  "Clock out when leaving STRT state."
  (when (and (org-clock-is-active)
             (not (string= org-state "STRT")))
    (org-clock-out)))

(add-hook 'org-after-todo-state-change-hook #'my/org-clock-in-if-starting)
(add-hook 'org-after-todo-state-change-hook #'my/org-clock-out-if-not-starting)

(use-package org-auto-tangle
  :ensure t
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))

(use-package org-appear
  :ensure t
  :defer t
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autolinks t
        org-appear-autosubmarkers t))

;; agenda
(setq org-agenda-time-grid
      '((daily today require-timed)
        (500 600 700 800 900 1000 1100 1200
             1300 1400 1500 1600 1700 1800 1900 2000 2100)
        "      " "                "))

(setq org-agenda-current-time-string
      "    NOW                                         ")

(setq org-habit-show-habits-only-for-today t)
(setq org-habit-graph-column 50)
(setq org-agenda-remove-tags t)
(setq org-agenda-block-separator ? )

(setq org-agenda-custom-commands
      '(("d" "Dashboard"
         ((tags "PRIORITY=\"A\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "\n  HIGHEST PRIORITY\n")
                 (org-agenda-prefix-format "  %?-12t %s")))
          (agenda ""
                  ((org-agenda-start-day "+0d")
                   (org-agenda-span 1)
                   (org-agenda-remove-tags t)
                   (org-agenda-todo-keyword-format "")
                   (org-agenda-scheduled-leaders '("" ""))
                   (org-agenda-overriding-header "\n  TODAY\n")
                   (org-agenda-prefix-format "  %?-12t %s")))
          (tags-todo "-STYLE=\"habit\""
                     ((org-agenda-overriding-header "\n  ALL TASKS\n")
                      (org-agenda-sorting-strategy '(priority-down))
                      (org-agenda-remove-tags t)
                      (org-agenda-prefix-format "  %?-12t %s")))))))

(defun my/org-agenda-dashboard ()
  "Open the custom org-agenda dashboard."
  (interactive)
  (org-agenda nil "d")
  (delete-other-windows))

;; Capture templates
(defun org-capture-bookmark-tags ()
  "Prompt for tags with completion against existing bookmark tags."
  (save-window-excursion
    (let ((tags-list '()))
      (with-current-buffer (find-file-noselect "~/org/bookmarks.org")
        (save-excursion
          (goto-char (point-min))
          (while (re-search-forward "^:TAGS:\\s-*\\(.+\\)$" nil t)
            (let ((tag-string (match-string 1)))
              (dolist (tag (split-string tag-string "[,;]" t "[[:space:]]"))
                (push (string-trim tag) tags-list))))))
      (setq tags-list (sort (delete-dups tags-list) 'string<))
      (let ((selected-tags (completing-read-multiple "Tags (comma-separated): " tags-list)))
        (mapconcat 'identity selected-tags ", ")))))

(defun org-capture-ref-link (file)
  "Create a link to a contact in FILE."
  (let* ((headlines (org-map-entries
                     (lambda ()
                       (cons (org-get-heading t t t t)
                             (org-id-get-create)))
                     t
                     (list file)))
         (contact (completing-read "Contact: " (mapcar #'car headlines)))
         (id (cdr (assoc contact headlines))))
    (format "[[id:%s][%s]]" id contact)))

(with-eval-after-load 'org
  (setq org-todo-keywords
        '((sequence "TODO(t)" "STRT(s)" "WAIT(w)" "HOLD(h)" "|" "DONE(d)" "KILL(k)"))))

(with-eval-after-load 'org
  (setq org-capture-templates
        '(("t" "Todo" entry
           (file+headline "~/org/inbox.org" "Inbox")
           "* TODO %^{Task}\n:PROPERTIES:\n:CREATED: %U\n:CAPTURED: %a\n:END:\n%?")

          ("e" "Event" entry
           (file+headline "~/org/calendar.org" "Events")
           "* %^{Event}\n%^{SCHEDULED}T\n:PROPERTIES:\n:CREATED: %U\n:CAPTURED: %a\n:CONTACT: %(org-capture-ref-link \"~/org/roam/contacts.org\")\n:END:\n%?")

          ("d" "Deadline" entry
           (file+headline "~/org/calendar.org" "Deadlines")
           "* TODO %^{Task}\nDEADLINE: %^{Deadline}T\n:PROPERTIES:\n:CREATED: %U\n:CAPTURED: %a\n:END:\n%?")

          ("b" "Bookmark" entry
           (file+headline "~/org/bookmarks.org" "Inbox")
           "** [[%^{URL}][%^{Title}]]\n:PROPERTIES:\n:CREATED: %U\n:TAGS: %(org-capture-bookmark-tags)\n:END:\n\n"
           :empty-lines 0)

          ("c" "Contact" entry
           (file "~/org/roam/contacts.org")
           "* %^{Name} %^g
:PROPERTIES:
:ID: %(org-id-new)
:CREATED: %U
:CAPTURED: %a
:EMAIL: %^{Email}
:PHONE: %^{Phone}
:BIRTHDAY: %^{Birthday (use <YYYY-MM-DD +1y> format)}t
:LOCATION: %^{Address}
:LAST_CONTACTED: %U
:END:
%?"
           :empty-lines 1)

          ("n" "Note" entry
           (file+headline "~/org/notes.org" "Inbox")
           "* [%<%Y-%m-%d %a>] %^{Title}\n:PROPERTIES:\n:CREATED: %U\n:CAPTURED: %a\n:END:\n%?"
           :prepend t))))

(setq display-buffer-alist
      `(("\\*Capture\\*\\|CAPTURE-.*"
         (display-buffer-reuse-window display-buffer-at-bottom)
         (window-height . 0.3))
        ("\\*Calendar\\*"
         (display-buffer-reuse-window display-buffer-at-bottom)
         (window-height . 0.3))
        ("\\*Org Agenda\\*"
         (display-buffer-reuse-window display-buffer-at-bottom)
         (window-height . 0.4))))

;; Contacts
(defvar my/contacts-file "~/org/roam/contacts.org")

(defun my/contacts-get-emails ()
  "Extract all emails from contacts.org."
  (let (contacts)
    (with-current-buffer (find-file-noselect my/contacts-file)
      (org-with-wide-buffer
       (goto-char (point-min))
       (while (re-search-forward "^\\*+ \\(.+\\)$" nil t)
         (let ((name (match-string 1))
               (email (org-entry-get (point) "EMAIL")))
           (when email
             (dolist (addr (split-string email "," t " "))
               (push (cons name (string-trim addr)) contacts)))))))
    (nreverse contacts)))

(defun my/contacts-complete ()
  "Complete email addresses from contacts.org."
  (let* ((end (point))
         (start (save-excursion
                  (skip-chars-backward "^:,; \t\n")
                  (point)))
         (contacts (my/contacts-get-emails))
         (collection (mapcar
                      (lambda (contact)
                        (format "%s <%s>" (car contact) (cdr contact)))
                      contacts)))
    (list start end collection :exclusive 'no)))

(add-hook 'message-mode-hook
          (lambda ()
            (setq-local completion-at-point-functions
                        (cons #'my/contacts-complete
                              completion-at-point-functions))))

(with-eval-after-load 'mu4e
  (setq mu4e-compose-complete-addresses nil)

  (defun my/update-last-contacted ()
    (when (and (derived-mode-p 'mu4e-compose-mode)
               mu4e-compose-parent-message)
      (when-let* ((from (mu4e-message-field mu4e-compose-parent-message :from))
                  (email (if (stringp from) from (cdar from))))
        (when (stringp email)
          (with-current-buffer (find-file-noselect my/contacts-file)
            (save-excursion
              (goto-char (point-min))
              (when (search-forward email nil t)
                (org-back-to-heading)
                (org-set-property "LAST_CONTACTED"
                                  (format-time-string "[%Y-%m-%d %a %H:%M]"))
                (save-buffer))))))))

  (add-hook 'mu4e-compose-mode-hook #'my/update-last-contacted))

;; roam
(use-package org-roam
  :ensure t
  :defer t
  :commands (org-roam-node-find
             org-roam-node-insert
             org-roam-dailies-goto-today
             org-roam-buffer-toggle
             org-roam-db-sync
             org-roam-capture)
  :init
  (setq org-roam-directory "~/org/roam"
        org-roam-database-connector 'sqlite-builtin
        org-roam-db-location (expand-file-name "org-roam.db" "~/org/roam")
        org-roam-v2-ack t)
  :config
  (setq org-roam-db-update-on-save nil)

  (unless (file-exists-p org-roam-directory)
    (make-directory org-roam-directory t))

  (add-hook 'org-roam-find-file-hook
            (lambda ()
              (unless org-roam-db-autosync-mode
                (org-roam-db-autosync-mode 1))))

  (setq org-roam-completion-everywhere t)

  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "${slug}.org"
                              ":PROPERTIES:\n:ID:       %(org-id-new)\n:END:\n#+title: ${title}\n#+filetags: \n\n")
           :unnarrowed t)

          ("c" "concept" plain "%?"
           :target (file+head "concepts/${slug}.org"
                              ":PROPERTIES:\n:ID:       %(org-id-new)\n:END:\n#+title: ${title}\n#+filetags: :concept:\n\n")
           :unnarrowed t)

          ("C" "Contact" plain
           "* Contact Info
:PROPERTIES:
:EMAIL: %^{Email}
:PHONE: %^{Phone}
:BIRTHDAY: %^{Birthday (YYYY-MM-DD +1y)}t
:LOCATION: %^{Location}
:LAST_CONTACTED: %U
:END:

** Communications

** Notes
%?"
           :target (file+head "contacts/${slug}.org"
                              "#+title: ${title}\n#+filetags: %^{Tags}\n#+created: %U\n")
           :unnarrowed t)

          ("b" "book" plain "%?"
           :target (file+head "books/${slug}.org"
                              ":PROPERTIES:\n:ID:       %(org-id-new)\n:END:\n#+title: ${title}\n#+author: \n#+filetags: :book:\n\n* Summary\n\n* Key Ideas\n\n* Quotes\n\n* Related\n\n")
           :unnarrowed t)

          ("p" "person" plain "%?"
           :target (file+head "people/${slug}.org"
                              ":PROPERTIES:\n:ID:       %(org-id-new)\n:END:\n#+title: ${title}\n#+filetags: :person:\n\n* Background\n\n* Key Ideas\n\n* Works\n\n")
           :unnarrowed t)

          ("t" "tech" plain "%?"
           :target (file+head "tech/${slug}.org"
                              ":PROPERTIES:\n:ID:       %(org-id-new)\n:END:\n#+title: ${title}\n#+filetags: :tech:\n\n")
           :unnarrowed t)

          ("T" "theology" plain "%?"
           :target (file+head "faith/theology/${slug}.org"
                              ":PROPERTIES:\n:ID:       %(org-id-new)\n:END:\n#+title: ${title}\n#+filetags: :theology:faith:\n\n* Doctrine\n\n* Scripture\n\n* Tradition\n\n* Application\n\n")
           :unnarrowed t)

          ("w" "writing" plain "%?"
           :target (file+head "writing/${slug}.org"
                              ":PROPERTIES:\n:ID:       %(org-id-new)\n:END:\n#+title: ${title}\n#+filetags: :writing:draft:\n\n")
           :unnarrowed t)

          ("P" "project" plain "%?"
           :target (file+head "projects/${slug}.org"
                              ":PROPERTIES:\n:ID:       %(org-id-new)\n:END:\n#+title: ${title}\n#+filetags: :project:private:\n\n* Overview\n\n* Goals\n\n* Status\n\n* Notes\n\n")
           :unnarrowed t)))

  (setq org-roam-dailies-directory "daily/"
        org-roam-dailies-capture-templates
        '(("d" "default" entry "* %<%H:%M>: %?"
           :target (file+head "%<%Y-%m-%d>.org"
                              ":PROPERTIES:\n:ID:       %(org-id-new)\n:END:\n#+title: %<%Y-%m-%d %A>\n#+filetags: :daily:\n\n")))))

(use-package org-roam-ui
  :ensure t
  :defer t
  :commands (org-roam-ui-mode org-roam-ui-open)
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

;; Images
(defun my/org-insert-image ()
  "Select and insert an image into org file."
  (interactive)
  (let ((selected-file (read-file-name "Select image: " "~/Pictures/" nil t)))
    (when selected-file
      (insert (format "[[file:%s]]\n" selected-file))
      (org-display-inline-images))))

(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-star '(" " " " " " " " "◉")
        org-modern-todo t
        org-modern-progress t
        org-modern-priority t
        org-modern-tag t
        org-modern-block-fringe t
        org-modern-todo-faces
        '(("TODO" . (:background "#b8c4b8" :foreground "#1a1d21"))
          ("STRT" . (:background "#b4bcc4" :foreground "#1a1d21"))
          ("WAIT" . (:background "#d4ccb4" :foreground "#1a1d21"))
          ("HOLD" . (:background "#d4ccb4" :foreground "#1a1d21"))
          ("DONE" . (:background "#3d424a" :foreground "#8b919a"))
          ("KILL" . (:background "#3d424a" :foreground "#8b919a" :strike-through t)))))

(with-eval-after-load 'org
  (setq org-startup-folded 'showeverything
        org-cycle-emulate-tab t
        org-indent-mode t)
  (add-hook 'org-mode-hook #'org-indent-mode))

(with-eval-after-load 'org
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("go" . "src go"))
  (add-to-list 'org-structure-template-alist '("sh" . "src sh")))

(add-hook 'org-mode-hook #'display-line-numbers-mode)

;; DWIM at point
(with-eval-after-load 'org

  (defun +org--toggle-inline-images-in-subtree (&optional beg end)
    (let ((overlays (overlays-in (or beg (point-min)) (or end (point-max)))))
      (if (cl-find-if (lambda (o) (overlay-get o 'org-image-overlay)) overlays)
          (org-remove-inline-images)
        (org-display-inline-images nil t beg end))))

  (defun +org-get-todo-keywords-for (&optional keyword)
    (when keyword
      (cl-loop for (type . keywords) in org-todo-keywords
               if (string= type "sequence")
               return (let ((kws (mapcar (lambda (k) (car (split-string k "(")))
                                         keywords)))
                        (cdr (member keyword kws))))))

  (defun +org/dwim-at-point (&optional arg)
    "Do-what-I-mean at point."
    (interactive "P")
    (if (button-at (point))
        (call-interactively #'push-button)
      (let* ((context (org-element-context))
             (type (org-element-type context)))
        (while (and context (memq type '(verbatim code bold italic underline strike-through subscript superscript)))
          (setq context (org-element-property :parent context)
                type (org-element-type context)))
        (pcase type
          ((or `citation `citation-reference)
           (org-cite-follow context arg))

          (`headline
           (cond ((memq (bound-and-true-p org-goto-map) (current-active-maps))
                  (org-goto-ret))
                 ((and (fboundp 'toc-org-insert-toc) (member "TOC" (org-get-tags)))
                  (toc-org-insert-toc)
                  (message "Updating table of contents"))
                 ((string= "ARCHIVE" (car-safe (org-get-tags)))
                  (org-force-cycle-archived))
                 ((or (org-element-property :todo-type context)
                      (org-element-property :scheduled context))
                  (org-todo
                   (if (eq (org-element-property :todo-type context) 'done)
                       (or (car (+org-get-todo-keywords-for (org-element-property :todo-keyword context)))
                           'todo)
                     'done))))
           (org-update-checkbox-count)
           (org-update-parent-todo-statistics)
           (let* ((beg (if (org-before-first-heading-p)
                           (line-beginning-position)
                         (save-excursion (org-back-to-heading) (point))))
                  (end (if (org-before-first-heading-p)
                           (line-end-position)
                         (save-excursion (org-end-of-subtree) (point))))
                  (overlays (ignore-errors (overlays-in beg end)))
                  (latex-overlays
                   (cl-find-if (lambda (o) (eq (overlay-get o 'org-overlay-type) 'org-latex-overlay)) overlays))
                  (image-overlays
                   (cl-find-if (lambda (o) (overlay-get o 'org-image-overlay)) overlays)))
             (+org--toggle-inline-images-in-subtree beg end)
             (if (or image-overlays latex-overlays)
                 (org-clear-latex-preview beg end)
               (org--latex-preview-region beg end))))

          (`clock (org-clock-update-time-maybe))

          (`footnote-reference
           (org-footnote-goto-definition (org-element-property :label context)))

          (`footnote-definition
           (org-footnote-goto-previous-reference (org-element-property :label context)))

          ((or `planning `timestamp)
           (org-follow-timestamp-link))

          ((or `table `table-row)
           (if (org-at-TBLFM-p)
               (org-table-calc-current-TBLFM)
             (ignore-errors
               (save-excursion
                 (goto-char (org-element-property :contents-begin context))
                 (org-call-with-arg 'org-table-recalculate (or arg t))))))

          (`table-cell
           (org-table-blank-field)
           (org-table-recalculate arg)
           (when (and (string-empty-p (string-trim (org-table-get-field)))
                      (bound-and-true-p evil-local-mode))
             (evil-change-state 'insert)))

          (`babel-call
           (org-babel-lob-execute-maybe))

          (`statistics-cookie
           (save-excursion (org-update-statistics-cookies arg)))

          ((or `src-block `inline-src-block)
           (org-babel-execute-src-block arg))

          ((or `latex-fragment `latex-environment)
           (org-latex-preview arg))

          (`link
           (let* ((lineage (org-element-lineage context '(link) t))
                  (path (org-element-property :path lineage)))
             (if (or (equal (org-element-property :type lineage) "img")
                     (and path (image-type-from-file-name path)))
                 (+org--toggle-inline-images-in-subtree
                  (org-element-property :begin lineage)
                  (org-element-property :end lineage))
               (org-open-at-point arg))))

          ((guard (org-element-property :checkbox (org-element-lineage context '(item) t)))
           (org-toggle-checkbox))

          (`paragraph
           (+org--toggle-inline-images-in-subtree))

          (_
           (if (or (org-in-regexp org-ts-regexp-both nil t)
                   (org-in-regexp org-tsr-regexp-both nil t)
                   (org-in-regexp org-link-any-re nil t))
               (call-interactively #'org-open-at-point)
             (+org--toggle-inline-images-in-subtree
              (org-element-property :begin context)
              (org-element-property :end context))))))))

  (with-eval-after-load 'evil
    (evil-define-key 'normal org-mode-map (kbd "RET") #'+org/dwim-at-point)))

(use-package ob-go :demand t)
(elpaca-wait)

(with-eval-after-load 'org
  (setq org-src-fontify-natively t)
  (add-to-list 'org-src-lang-modes '("go" . go-ts))
  (require 'ob-shell)
  (require 'ob-python)
  (require 'ob-C)
  (require 'ob-go)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell      . t)
     (emacs-lisp . t)
     (python     . t)
     (C          . t)
     (go         . t))))

(provide 'org-config)
;;; org-mode-config.el ends here
