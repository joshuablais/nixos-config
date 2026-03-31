;;; task-runner.el --- Description -*- lexical-binding: t; -*-

;;; ── Configuration table ──────────────────────────────────────
(defvar my/test-runner-alist
  '((go-mode
     :test-all       "go test ./..."
     :test-file      "go test %f"
     :test-at-point  "go test -v -run ^%t$ ./..."
     :test-single    "go test -v -run ^%t$ ./..."
     :bench-all      "go test -bench=. -benchmem ./..."
     :bench-at-point "go test -bench=^%t$ -benchmem ./...")

    (go-ts-mode
     :test-all       "go test ./..."
     :test-file      "go test %f"
     :test-at-point  "go test -v -run ^%t$ ./..."
     :test-single    "go test -v -run ^%t$ ./..."
     :bench-all      "go test -bench=. -benchmem ./..."
     :bench-at-point "go test -bench=^%t$ -benchmem ./...")

    (python-ts-mode
     :test-all       "python -m pytest"
     :test-file      "python -m pytest %f"
     :test-at-point  "python -m pytest %f::%t"
     :test-single    "python -m pytest %f::%t -x"
     :bench-all      "python -m pytest --benchmark-only"
     :bench-at-point "python -m pytest --benchmark-only -k %t")

    (rust-mode
     :test-all       "cargo test"
     :test-file      "cargo test"
     :test-at-point  "cargo test %t"
     :test-single    "cargo test %t -- --exact"
     :bench-all      "cargo bench"
     :bench-at-point "cargo bench %t"))
  "Alist of major-mode -> test command plist.
Tokens: %f current file, %t test name at point, %d project root.")

;;; ── Test-name extraction ─────────────────────────────────────
(defvar my/test-name-extractors
  '((go-mode        . my/go-test-name-at-point)
    (go-ts-mode     . my/go-test-name-at-point)
    (rust-mode      . my/rust-test-name-at-point)
    (python-ts-mode . my/python-test-name-at-point))
  "Alist of major-mode -> function returning test name at point.")

(defun my/go-test-name-at-point ()
  "Return Go test/benchmark name enclosing point."
  (save-excursion
    ;; end-of-line so backward search catches the func line point is already on
    (end-of-line)
    (when (re-search-backward
           "^func \\(\\(?:Test\\|Benchmark\\|Example\\)[A-Za-z0-9_]*\\)"
           nil t)
      (match-string-no-properties 1))))

(defun my/rust-test-name-at-point ()
  "Return Rust test function name enclosing point."
  (save-excursion
    (end-of-line)
    (when (re-search-backward
           "#\\[test\\]\\s-*\n\\s-*fn \\([A-Za-z0-9_]+\\)"
           nil t)
      (match-string-no-properties 1))))

(defun my/python-test-name-at-point ()
  "Return pytest-compatible test name enclosing point."
  (save-excursion
    (end-of-line)
    (when (re-search-backward
           "^\\s-*def \\(test_[A-Za-z0-9_]+\\)"
           nil t)
      (match-string-no-properties 1))))

;;; ── Core dispatcher ──────────────────────────────────────────
(defun my/test--get-config (key)
  "Return command string for KEY in current major-mode's config."
  (let ((entry (or (alist-get major-mode my/test-runner-alist)
                   (cl-loop for (mode . plist) in my/test-runner-alist
                            when (derived-mode-p mode)
                            return plist))))
    (when entry (plist-get entry key))))

(defun my/test--name-at-point ()
  "Return test name at point using mode-specific extractor."
  (let ((fn (alist-get major-mode my/test-name-extractors)))
    (when fn (funcall fn))))

(defun my/test--project-root ()
  "Return project root or default-directory."
  (if-let ((proj (project-current)))
      (project-root proj)
    default-directory))

(defun my/test--resolve-cmd (cmd)
  "Expand %f, %t, %d tokens in CMD."
  ;; thread-first inserts as first arg — string-replace is (FROM TO IN)
  ;; so we need IN last: use sequential lets instead
  (let* ((file  (or (buffer-file-name) ""))
         (root  (my/test--project-root))
         (tname (or (my/test--name-at-point) ""))
         (cmd   (string-replace "%f" file  cmd))
         (cmd   (string-replace "%t" tname cmd))
         (cmd   (string-replace "%d" root  cmd)))
    cmd))

(defun my/test--run (key)
  "Dispatch test command KEY. C-u prefix opens editable prompt."
  (let ((cmd (my/test--get-config key)))
    (unless cmd
      (user-error "No %s command configured for %s" key major-mode))
    (let* ((resolved (my/test--resolve-cmd cmd))
           (final    (if current-prefix-arg
                         (read-string "Command: " resolved)
                       resolved))
           (default-directory (my/test--project-root)))
      (compile final))))

;;; ── Public commands ──────────────────────────────────────────
(defun my/test-all ()       (interactive) (my/test--run :test-all))
(defun my/test-file ()      (interactive) (my/test--run :test-file))
(defun my/test-rerun ()     (interactive) (recompile))
(defun my/bench-all ()      (interactive) (my/test--run :bench-all))

(defun my/test-at-point ()
  (interactive)
  (unless (my/test--name-at-point)
    (user-error "No test found at point (searched backward for Test*/Benchmark*)"))
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

;; keybinds
(defun my/test--install-bindings ()
  (define-key leader (kbd "m t a") #'my/test-all)
  (define-key leader (kbd "m t f") #'my/test-file)
  (define-key leader (kbd "m t t") #'my/test-at-point)
  (define-key leader (kbd "m t s") #'my/test-single)
  (define-key leader (kbd "m t r") #'my/test-rerun)
  (define-key leader (kbd "m t b") #'my/bench-all)
  (define-key leader (kbd "m t p") #'my/bench-at-point))

(my/test--install-bindings)

(provide 'test-runner)

(provide 'test-runner)
