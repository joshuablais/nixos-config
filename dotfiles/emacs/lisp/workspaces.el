;;; workspaces.el --- Description -*- lexical-binding: t; -*-
;;; Faces
(defface +workspace-tab-face
  '((t :inherit shadow))
  "Face for inactive workspace tabs.")

(defface +workspace-tab-selected-face
  '((t :inherit (bold default)))
  "Face for the active workspace tab.")

;;; Backend: bufferlo for real isolation
(use-package bufferlo
  :ensure t
  :demand t
  :config
  (bufferlo-mode 1)
  (bufferlo-anywhere-mode 1))

;;; Helpers
(defun +workspace--current-name ()
  (alist-get 'name (tab-bar--current-tab)))

(defun +workspace--names ()
  (mapcar (lambda (tab) (alist-get 'name tab)) (tab-bar-tabs)))

;;; Display
(defun +workspace--format-tab (index name is-current)
  (let* ((label (format "[%d] %s" (1+ index) name))
         (text  (if is-current
                    (format "(%s) " label)
                  (format " %s  " label)))
         (face  (if is-current
                    '+workspace-tab-selected-face
                  '+workspace-tab-face)))
    (propertize text 'face face)))

(defun +workspace/display ()
  "Show workspace bar in the echo area."
  (interactive)
  (let* ((tabs    (tab-bar-tabs))
         (current (tab-bar--current-tab)))
    (message "%s"
             (mapconcat
              (lambda (tab)
                (+workspace--format-tab
                 (seq-position tabs tab)
                 (alist-get 'name tab)
                 (eq tab current)))
              tabs ""))))

(dolist (fn '(tab-bar-new-tab
              tab-bar-close-tab
              tab-bar-switch-to-tab
              tab-bar-select-tab
              tab-bar-rename-tab))
  (advice-add fn :after (lambda (&rest _) (+workspace/display))))

;;; Core operations
(defun +workspace/new (&optional name)
  "Create a new blank workspace named NAME."
  (interactive (list (read-string "Workspace name: "
                                  (format "" (1+ (length (tab-bar-tabs)))))))
  (let ((name (or name (format "" (1+ (length (tab-bar-tabs)))))))
    (if (member name (+workspace--names))
        (message "+workspace: '%s' already exists" name)
      (let ((tab-bar-new-tab-choice (lambda () (get-buffer-create "*scratch*"))))
        (tab-bar-new-tab)
        (tab-bar-rename-tab name)
        (delete-other-windows)))))

(defun +workspace/switch-to ()
  "Switch to workspace via completing-read."
  (interactive)
  (let ((name (completing-read "Switch to workspace: "
                               (+workspace--names)
                               nil t)))
    (tab-bar-switch-to-tab name)))

(defun +workspace/delete ()
  "Close current workspace. bufferlo handles buffer cleanup."
  (interactive)
  (if (<= (length (tab-bar-tabs)) 1)
      (message "+workspace: can't delete the last workspace")
    ;; Kill buffers that belong only to this tab
    (let ((local-bufs (bufferlo-buffer-list)))
      (tab-bar-close-tab)
      (dolist (buf local-bufs)
        (when (and (buffer-live-p buf)
                   (not (get-buffer-window buf t))
                   ;; Don't kill if it's now local to the new current tab
                   (not (bufferlo-local-buffer-p buf)))
          (kill-buffer buf))))))

(defun +workspace/rename (name)
  "Rename the current workspace."
  (interactive (list (read-string "Rename workspace to: "
                                  (+workspace--current-name))))
  (tab-bar-rename-tab name))

;;; Project integration
(defun +workspace/switch-to-project ()
  "Open project in a dedicated workspace; switch if it already exists."
  (interactive)
  (let* ((dir  (project-prompt-project-dir))
         (name (file-name-nondirectory (directory-file-name dir))))
    (if (member name (+workspace--names))
        (tab-bar-switch-to-tab name)
      (let ((tab-bar-new-tab-choice (lambda () (get-buffer-create "*scratch*"))))
        (tab-bar-new-tab)
        (tab-bar-rename-tab name)
        (delete-other-windows)
        (let ((default-directory dir))
          (project-find-file))))))

;;; Consult integration
(with-eval-after-load 'consult
  (defvar +workspace-consult-source-buffer
    `(:name     "Workspace"
                :narrow   ?w
                :category buffer
                :face     consult-buffer
                :history  buffer-name-history
                :state    ,#'consult--buffer-state
                :default  t
                :items    ,(lambda ()
                             (consult--buffer-query
                              :predicate #'bufferlo-local-buffer-p
                              :sort      'visibility
                              :as        #'buffer-name))))

  (defvar +workspace-consult-source-other-buffer
    `(:name     "Other Workspaces"
                :narrow   ?o
                :hidden   t
                :category buffer
                :face     consult-buffer
                :history  buffer-name-history
                :state    ,#'consult--buffer-state
                :items    ,(lambda ()
                             (consult--buffer-query
                              :predicate (lambda (b)
                                           (and (not (bufferlo-local-buffer-p b))
                                                (not (string-prefix-p " " (buffer-name b)))))
                              :sort      'visibility
                              :as        #'buffer-name))))

  (setq consult-buffer-sources
        '(+workspace-consult-source-buffer
          +workspace-consult-source-other-buffer)))

;;; Bootstrap
(setq tab-bar-show nil)

;;; Keybindings
(with-eval-after-load 'evil
  (evil-define-key 'normal 'global
    (kbd "<leader>TAB TAB") #'+workspace/display
    (kbd "<leader>TAB n")   #'+workspace/new
    (kbd "<leader>TAB d")   #'+workspace/delete
    (kbd "<leader>TAB r")   #'+workspace/rename
    (kbd "<leader>TAB .")   #'+workspace/switch-to
    (kbd "<leader>TAB [")   #'tab-bar-switch-to-prev-tab
    (kbd "<leader>TAB ]")   #'tab-bar-switch-to-next-tab
    (kbd "<leader>p p")     #'+workspace/switch-to-project))

(when (featurep 'consult)
  (setq consult-buffer-sources
        '(+workspace-consult-source-buffer
          +workspace-consult-source-other-buffer)))

(provide 'workspaces)
;;; workspaces.el ends here
