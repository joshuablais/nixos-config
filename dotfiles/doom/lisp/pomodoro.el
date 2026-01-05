;;; pomodoro.el --- Pomodoro timer with org-clock integration -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025
;;
;; Author: Joshua Blais <josh@joshblais.com>
;; Maintainer: Joshua Blais <josh@joshblais.com>
;; Created: February 04, 2025
;; Modified: February 04, 2025
;; Version: 0.1.0
;; Keywords: tools, org, time
;; Homepage: https://github.com/jblais493/pomodoro
;; Package-Requires: ((emacs "29.1"))
;;
;;; Commentary:
;;
;;  Pomodoro timer that integrates with org-clock for native time tracking.
;;  Select tasks from org-agenda or enter ad-hoc tasks.
;;  Uses LOGBOOK entries for accurate time tracking.
;;
;;; Code:

(require 'org)
(require 'org-clock)
(require 'org-agenda)

;;; Customization

(defgroup pomodoro nil
  "Pomodoro timer with org-clock integration."
  :group 'org
  :prefix "pomodoro-")

(defcustom pomodoro-work-minutes 25
  "Work period length in minutes."
  :type 'integer
  :group 'pomodoro)

(defcustom pomodoro-break-minutes 5
  "Break period length in minutes."
  :type 'integer
  :group 'pomodoro)

(defcustom pomodoro-long-break-minutes 15
  "Long break period length in minutes (after 4 pomodoros)."
  :type 'integer
  :group 'pomodoro)

(defcustom pomodoro-adhoc-file "~/org/pomodoro.org"
  "File for ad-hoc tasks that aren't in your agenda."
  :type 'file
  :group 'pomodoro)

(defcustom pomodoro-sound-file "~/Downloads/Bell.mp3"
  "Sound file to play on timer completion."
  :type 'file
  :group 'pomodoro)

;;; State Variables

(defvar pomodoro--timer nil
  "Timer object for the pomodoro countdown.")

(defvar pomodoro--display-timer nil
  "Timer object for updating the display.")

(defvar pomodoro--end-time nil
  "When the current period ends.")

(defvar pomodoro--state nil
  "Current state: nil, `work', or `break'.")

(defvar pomodoro--count 0
  "Number of completed pomodoros in current session.")

(defvar pomodoro--current-marker nil
  "Marker to the org heading being worked on.")

(defvar pomodoro--mode-line ""
  "String to display in mode line.")

;;; Mode Line Setup

(unless (member 'pomodoro--mode-line global-mode-string)
  (setq global-mode-string
        (append global-mode-string '(pomodoro--mode-line))))

;;; Core Functions

(defun pomodoro--play-alert (message)
  "Send notification with MESSAGE and play alert sound."
  (when (fboundp 'notifications-notify)
    (notifications-notify
     :title "Pomodoro"
     :body message
     :urgency 'critical))
  (when (file-exists-p pomodoro-sound-file)
    (cond
     ((executable-find "pw-play")
      (start-process "pomodoro-sound" nil "pw-play" pomodoro-sound-file))
     ((executable-find "mpv")
      (start-process "pomodoro-sound" nil "mpv" "--no-video" "--volume=100" pomodoro-sound-file))
     ((executable-find "ffplay")
      (start-process "pomodoro-sound" nil "ffplay" "-nodisp" "-autoexit" pomodoro-sound-file)))))

(defun pomodoro--update-display ()
  "Update the mode line display."
  (if (and pomodoro--end-time pomodoro--state)
      (let* ((remaining (float-time (time-subtract pomodoro--end-time (current-time))))
             (remaining (max 0 remaining))
             (mins (floor (/ remaining 60)))
             (secs (floor (mod remaining 60)))
             (icon (if (eq pomodoro--state 'work) "🍅" "☕"))
             (task (if (and pomodoro--current-marker
                            (marker-buffer pomodoro--current-marker))
                       (org-with-point-at pomodoro--current-marker
                         (org-get-heading t t t t))
                     "Break")))
        (setq pomodoro--mode-line
              (format " %s %02d:%02d %s "
                      icon mins secs
                      (if (eq pomodoro--state 'work)
                          (truncate-string-to-width task 20 nil nil "…")
                        "Break"))))
    (setq pomodoro--mode-line ""))
  (force-mode-line-update t))

(defun pomodoro--cancel-timers ()
  "Cancel all active timers."
  (when pomodoro--timer
    (cancel-timer pomodoro--timer)
    (setq pomodoro--timer nil))
  (when pomodoro--display-timer
    (cancel-timer pomodoro--display-timer)
    (setq pomodoro--display-timer nil)))

(defun pomodoro--ensure-adhoc-file ()
  "Ensure the ad-hoc task file exists with proper structure."
  (unless (file-exists-p pomodoro-adhoc-file)
    (with-temp-file pomodoro-adhoc-file
      (insert "#+TITLE: Pomodoro Tasks\n#+FILETAGS: :pomodoro:\n\n"))))

(defun pomodoro--create-adhoc-task (task-name)
  "Create an ad-hoc task with TASK-NAME and return marker to it."
  (pomodoro--ensure-adhoc-file)
  (let ((today (format-time-string "* %Y-%m-%d %A")))
    (with-current-buffer (find-file-noselect pomodoro-adhoc-file)
      (goto-char (point-min))
      ;; Find or create today's date heading
      (unless (search-forward today nil t)
        (goto-char (point-max))
        (unless (bolp) (insert "\n"))
        (insert today "\n"))
      ;; Insert the task as a subheading
      (end-of-line)
      (insert (format "\n** TODO %s" task-name))
      (beginning-of-line)
      (save-buffer)
      (point-marker))))

(defun pomodoro--select-task ()
  "Prompt user to select an org-agenda task or enter an ad-hoc task.
Returns a marker to the selected/created heading."
  (let* ((choice (completing-read
                  "Task (select or type new): "
                  (pomodoro--get-agenda-tasks)
                  nil nil nil nil nil))
         (existing (assoc choice (pomodoro--get-agenda-tasks))))
    (if existing
        (cdr existing)
      ;; Create new ad-hoc task
      (pomodoro--create-adhoc-task choice))))

(defun pomodoro--get-agenda-tasks ()
  "Get list of TODO items from org-agenda files.
Returns alist of (display-string . marker)."
  (let (tasks)
    (dolist (file (org-agenda-files))
      (when (file-exists-p file)
        (with-current-buffer (find-file-noselect file)
          (org-map-entries
           (lambda ()
             (let* ((heading (org-get-heading t t t t))
                    (todo (org-get-todo-state))
                    (tags (org-get-tags))
                    (display (format "%s [%s] %s"
                                     (or todo "")
                                     (file-name-nondirectory file)
                                     heading)))
               (when todo  ; Only include items with TODO state
                 (push (cons display (point-marker)) tasks))))
           "/!"  ; Match all TODO states
           'file))))
    (nreverse tasks)))

;;; Work Period

(defun pomodoro-start ()
  "Start a new pomodoro session by selecting a task."
  (interactive)
  ;; Clean up any existing state
  (pomodoro--cancel-timers)
  (when (org-clocking-p)
    (org-clock-out))

  (let ((marker (pomodoro--select-task)))
    (setq pomodoro--current-marker marker)
    (pomodoro--start-work)))

(defun pomodoro--start-work ()
  "Begin the work period with org-clock."
  (setq pomodoro--state 'work)

  ;; Clock in to the task
  (when (and pomodoro--current-marker
             (marker-buffer pomodoro--current-marker))
    (org-with-point-at pomodoro--current-marker
      (org-clock-in)))

  ;; Set up timers
  (setq pomodoro--end-time
        (time-add (current-time)
                  (seconds-to-time (* pomodoro-work-minutes 60))))

  (setq pomodoro--display-timer
        (run-at-time nil 1 #'pomodoro--update-display))

  (setq pomodoro--timer
        (run-at-time (* pomodoro-work-minutes 60) nil
                     #'pomodoro--work-complete))

  (message "🍅 Pomodoro started: %d minutes"
           pomodoro-work-minutes))

(defun pomodoro--work-complete ()
  "Handle completion of work period."
  (pomodoro--cancel-timers)
  (pomodoro--play-alert "Work period complete!")

  ;; Clock out
  (when (org-clocking-p)
    (org-clock-out))

  (cl-incf pomodoro--count)

  ;; Prompt for completion status
  (let ((action (completing-read
                 "Session complete. Action: "
                 '("Start break"
                   "Task done - start new task"
                   "Continue same task"
                   "Stop")
                 nil t)))
    (pcase action
      ("Start break" (pomodoro--start-break))
      ("Task done - start new task"
       (pomodoro--mark-task-done)
       (pomodoro--start-break))
      ("Continue same task" (pomodoro--start-work))
      ("Stop" (pomodoro-stop)))))

(defun pomodoro--mark-task-done ()
  "Mark the current task as DONE."
  (when (and pomodoro--current-marker
             (marker-buffer pomodoro--current-marker))
    (org-with-point-at pomodoro--current-marker
      (org-todo "DONE"))))

;;; Break Period

(defun pomodoro--start-break ()
  "Start a break period."
  (setq pomodoro--state 'break)
  (setq pomodoro--current-marker nil)

  (let ((break-mins (if (zerop (mod pomodoro--count 4))
                        pomodoro-long-break-minutes
                      pomodoro-break-minutes)))

    (setq pomodoro--end-time
          (time-add (current-time)
                    (seconds-to-time (* break-mins 60))))

    (setq pomodoro--display-timer
          (run-at-time nil 1 #'pomodoro--update-display))

    (setq pomodoro--timer
          (run-at-time (* break-mins 60) nil
                       #'pomodoro--break-complete))

    (message "☕ Break started: %d minutes" break-mins)))

(defun pomodoro--break-complete ()
  "Handle completion of break period."
  (pomodoro--cancel-timers)
  (pomodoro--play-alert "Break complete!")
  (setq pomodoro--state nil)
  (pomodoro--update-display)

  (when (y-or-n-p "Start another pomodoro? ")
    (pomodoro-start)))

;;; Task Completion Mid-Pomodoro

(defun pomodoro-task-done ()
  "Mark current task as done and switch to a new task for remaining time.
Use this when you finish a task before the pomodoro ends."
  (interactive)
  (unless (eq pomodoro--state 'work)
    (user-error "No active work period"))

  (let ((remaining (float-time (time-subtract pomodoro--end-time (current-time)))))
    (when (< remaining 60)
      (user-error "Less than a minute remaining—let it finish"))

    ;; Clock out and mark done
    (when (org-clocking-p)
      (org-clock-out))
    (pomodoro--mark-task-done)

    ;; Select new task
    (let ((marker (pomodoro--select-task)))
      (setq pomodoro--current-marker marker)
      ;; Clock into new task (timer continues)
      (when (and pomodoro--current-marker
                 (marker-buffer pomodoro--current-marker))
        (org-with-point-at pomodoro--current-marker
          (org-clock-in)))
      (message "Switched to new task. %.0f minutes remaining."
               (/ remaining 60.0)))))

;;; Control Functions

(defun pomodoro-stop ()
  "Stop the current pomodoro session entirely."
  (interactive)
  (pomodoro--cancel-timers)
  (when (org-clocking-p)
    (org-clock-out))
  (setq pomodoro--state nil
        pomodoro--end-time nil
        pomodoro--current-marker nil
        pomodoro--count 0)
  (pomodoro--update-display)
  (message "Pomodoro stopped."))

(defun pomodoro-toggle ()
  "Start or stop pomodoro based on current state."
  (interactive)
  (if pomodoro--state
      (if (y-or-n-p "Stop current pomodoro? ")
          (pomodoro-stop)
        (message "Continuing..."))
    (pomodoro-start)))

(defun pomodoro-goto ()
  "Jump to the currently clocked task."
  (interactive)
  (if (org-clocking-p)
      (org-clock-goto)
    (user-error "No active clock")))

(defun pomodoro-status ()
  "Display current pomodoro status."
  (interactive)
  (if pomodoro--state
      (let* ((remaining (float-time (time-subtract pomodoro--end-time (current-time))))
             (mins (floor (/ remaining 60)))
             (secs (floor (mod remaining 60))))
        (message "%s: %02d:%02d remaining. Pomodoros today: %d"
                 (if (eq pomodoro--state 'work) "Working" "Break")
                 mins secs pomodoro--count))
    (message "No active pomodoro. Completed today: %d" pomodoro--count)))

;;; Keybindings

(global-set-key (kbd "C-c P") 'pomodoro-toggle)
(global-set-key (kbd "C-c p g") 'pomodoro-goto)
(global-set-key (kbd "C-c p d") 'pomodoro-task-done)
(global-set-key (kbd "C-c p s") 'pomodoro-status)

(provide 'pomodoro)
;;; pomodoro.el ends here
