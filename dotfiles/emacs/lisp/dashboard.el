;;; dashboard.el --- Startup dashboard -*- lexical-binding: t; -*-

(defconst jb-dashboard-buffer "*dashboard*")

(defun jb-dashboard--load-time ()
  (float-time (time-subtract after-init-time before-init-time)))

(defun jb-dashboard-render ()
  (let ((buf (get-buffer-create jb-dashboard-buffer)))
    (with-current-buffer buf
      (let* ((inhibit-read-only t)
             (win (get-buffer-window buf t))
             (width (if win (window-body-width win) (frame-width)))
             (height (if win (window-body-height win) (frame-height)))
             (center (lambda (s)
                       (concat (make-string (max 0 (/ (- width (length s)) 2)) ?\s)
                               s)))
             (lines (list (funcall center "Studium Emacs")
                          ""
                          (funcall center (format "Emacs %s" emacs-version))
                          (funcall center (if (daemonp) "daemon" "standalone"))
                          ""
                          (funcall center (format-time-string "%A, %d %B %Y"))
                          ""
                          (funcall center (format "Loaded in %.2fs" (jb-dashboard--load-time)))))
             (top-pad (max 0 (/ (- height (length lines)) 2))))
        (erase-buffer)
        (insert (make-string top-pad ?\n))
        (dolist (line lines)
          (insert line "\n")))
      (special-mode)
      (local-set-key (kbd "g") #'jb-dashboard-render)
      (goto-char (point-min)))))

(setq initial-buffer-choice
      (lambda ()
        (let ((buf (get-buffer-create jb-dashboard-buffer)))
          (run-with-idle-timer 0 nil #'jb-dashboard-render)
          buf)))

(provide 'dashboard)
;;; dashboard.el ends here
