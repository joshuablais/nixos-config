;;; test-runner.el --- language-agnostic test/benchmark/run dispatch
(defvar my/test-runner-alist
  '((go-mode
     :run            "go run ./..."
     :test-all       "go test ./..."
     :test-file      "go test %f"
     :test-at-point  "go test -v -run ^%t$ ./..."
     :test-single    "go test -v -run ^%t$ ./..."
     :bench-all      "go test -bench=. -benchmem ./..."
     :bench-at-point "go test -bench=^%t$ -benchmem ./...")
    (go-ts-mode
     :run            "go run ./..."
     :test-all       "go test ./..."
     :test-file      "go test %f"
     :test-at-point  "go test -v -run ^%t$ ./..."
     :test-single    "go test -v -run ^%t$ ./..."
     :bench-all      "go test -bench=. -benchmem ./..."
     :bench-at-point "go test -bench=^%t$ -benchmem ./...")
    (python-ts-mode
     :run            "python %f"
     :test-all       "python -m pytest"
     :test-file      "python -m pytest %f"
     :test-at-point  "python -m pytest %f::%t"
     :test-single    "python -m pytest %f::%t -x"
     :bench-all      "python -m pytest --benchmark-only"
     :bench-at-point "python -m pytest --benchmark-only -k %t")
    (rust-mode
     :run            "cargo run"
     :test-all       "cargo test"
     :test-file      "cargo test"
     :test-at-point  "cargo test %t"
     :test-single    "cargo test %t -- --exact"
     :bench-all      "cargo bench"
     :bench-at-point "cargo bench %t")
    (zig-mode
     :run            "zig build run"
     :test-all       "zig build test"
     :test-file      "zig test %f"
     :test-at-point  "zig test %f --test-filter %t"
     :test-single    "zig test %f --test-filter %t"
     :bench-all      "zig build bench"
     :bench-at-point "zig build bench -- %t"))
  "Alist of major-mode -> command plist.
Tokens: %f current file, %t test name at point, %d project root.")

;;; Test-name extraction
(defvar my/test-name-extractors
  '((go-mode        . my/go-test-name-at-point)
    (go-ts-mode     . my/go-test-name-at-point)
    (rust-mode      . my/rust-test-name-at-point)
    (python-ts-mode . my/python-test-name-at-point)
    (zig-mode       . my/zig-test-name-at-point))
  "Alist of major-mode -> function returning test name at point.")

(defun my/go-test-name-at-point ()
  (save-excursion
    (end-of-line)
    (when (re-search-backward
           "^func \\(\\(?:Test\\|Benchmark\\|Example\\)[A-Za-z0-9_]*\\)"
           nil t)
      (match-string-no-properties 1))))

(defun my/rust-test-name-at-point ()
  (save-excursion
    (end-of-line)
    (when (re-search-backward
           "#\\[test\\]\\s-*\n\\s-*fn \\([A-Za-z0-9_]+\\)"
           nil t)
      (match-string-no-properties 1))))

(defun my/python-test-name-at-point ()
  (save-excursion
    (end-of-line)
    (when (re-search-backward
           "^\\s-*def \\(test_[A-Za-z0-9_]+\\)"
           nil t)
      (match-string-no-properties 1))))

(defun my/zig-test-name-at-point ()
  "Return Zig test name at point."
  (save-excursion
    (end-of-line)
    (when (re-search-backward
           "^\\s-*test \"\\([^\"]+\\)\""
           nil t)
      (match-string-no-properties 1))))

;;; Core dispatcher
(defun my/test--get-config (key)
  (let ((entry (or (alist-get major-mode my/test-runner-alist)
                   (cl-loop for (mode . plist) in my/test-runner-alist
                            when (derived-mode-p mode)
                            return plist))))
    (when entry (plist-get entry key))))

(defun my/test--name-at-point ()
  (let ((fn (alist-get major-mode my/test-name-extractors)))
    (when fn (funcall fn))))

(defun my/test--project-root ()
  (if-let ((proj (project-current)))
      (project-root proj)
    default-directory))

(defun my/test--resolve-cmd (cmd)
  (let* ((file  (or (buffer-file-name) ""))
         (root  (my/test--project-root))
         (tname (or (my/test--name-at-point) ""))
         (cmd   (string-replace "%f" file  cmd))
         (cmd   (string-replace "%t" tname cmd))
         (cmd   (string-replace "%d" root  cmd)))
    cmd))

(defun my/test--run (key)
  (let ((cmd (my/test--get-config key)))
    (unless cmd
      (user-error "No %s command configured for %s" key major-mode))
    (let* ((resolved (my/test--resolve-cmd cmd))
           (final    (if current-prefix-arg
                         (read-string "Command: " resolved)
                       resolved))
           (default-directory (my/test--project-root)))
      (compile final))))

;;; Run command — uses eat for a real pty
(defun my/run ()
  "Run project in an eat terminal buffer (full pty, interactive)."
  (interactive)
  (let ((cmd (my/test--get-config :run)))
    (unless cmd
      (user-error "No :run command configured for %s" major-mode))
    (let* ((resolved (my/test--resolve-cmd cmd))
           (final    (if current-prefix-arg
                         (read-string "Run: " resolved)
                       resolved))
           (default-directory (my/test--project-root)))
      (if (fboundp 'vterm-other-window)
          (vterm final)
        ;; fallback if eat isn't loaded yet
        (compile final)))))

;;; Public commands
(defun my/test-all ()       (interactive) (my/test--run :test-all))
(defun my/test-file ()      (interactive) (my/test--run :test-file))
(defun my/test-rerun ()     (interactive) (recompile))
(defun my/bench-all ()      (interactive) (my/test--run :bench-all))
(defun my/test-at-point ()
  (interactive)
  (unless (my/test--name-at-point)
    (user-error "No test found at point"))
  (my/test--run :test-at-point))
(defun my/test-single ()
  (interactive)
  (unless (my/test--name-at-point)
    (user-error "No test found at point"))
  (my/test--run :test-single))
(defun my/bench-at-point ()
  (interactive)
  (unless (my/test--name-at-point)
    (user-error "No benchmark found at point"))
  (my/test--run :bench-at-point))

(provide 'test-runner)
;;; test-runner.el ends here
