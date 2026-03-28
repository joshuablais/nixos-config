;;; ledger-config.el --- Ledger-mode configuration -*- lexical-binding: t; -*-

;;; Core ledger-mode
(use-package ledger-mode
  :defer t
  :mode ("\\.\\(ledger\\|ldg\\)\\'" . ledger-mode)
  :init
  ;; Defers hook setup until mode loads
  (setq ledger-mode-should-check-version nil
        ledger-report-links-in-register nil
        ledger-binary-path "ledger")
  :config
  (setq ledger-clear-whole-transactions t     ; mark entire transaction, not just posting
        ledger-post-auto-align t              ; auto-align amounts on save
        ledger-default-date-format "%Y/%m/%d" ; ISO-adjacent standard
        ledger-reconcile-default-commodity "$"
        ledger-highlight-xact-under-point t
        ledger-copy-transaction-insert-blank-line-after-beg t)

  ;; Report definitions
  (setq ledger-reports
        '(("bal"            "%(binary) -f %(ledger-file) bal")
          ("bal this month" "%(binary) -f %(ledger-file) bal -p %(month) -S amount")
          ("bal last month" "%(binary) -f %(ledger-file) bal -p \"last month\" -S amount")
          ("reg"            "%(binary) -f %(ledger-file) reg")
          ("payee"          "%(binary) -f %(ledger-file) reg @%(payee)")
          ("account"        "%(binary) -f %(ledger-file) reg %(account)")
          ("net worth"      "%(binary) -f %(ledger-file) bal Assets Liabilities")
          ("cash flow"      "%(binary) -f %(ledger-file) reg Income Expenses -p %(month)"))))

;;; Flycheck integration
(use-package flycheck-ledger
  :after (flycheck ledger-mode)
  :demand t
  :config
  (add-to-list 'flycheck-checkers 'ledger))

;;; Evil bindings for ledger
(use-package evil-ledger
  :after ledger-mode
  :hook (ledger-mode . evil-ledger-mode)
  :config
  (setq evil-ledger-sort-key "S"))

;;; Completion: hook into corfu/company for account and payee completion
(with-eval-after-load 'ledger-mode
  ;; ledger-mode has built-in pcomplete; wire it to cape if you use corfu
  (when (fboundp 'cape-capf-buster)
    (add-hook 'ledger-mode-hook
              (lambda ()
                (setq-local completion-at-point-functions
                            (list (cape-capf-buster #'ledger-complete-at-point))))))

  ;; If using company instead
  (when (fboundp 'company-mode)
    (add-hook 'ledger-mode-hook
              (lambda ()
                (setq-local company-backends '(company-capf))))))

;;; Reconcile buffer settings (Doom configures these)
(with-eval-after-load 'ledger-reconcile
  (setq ledger-reconcile-default-date-format ledger-default-date-format
        ledger-reconcile-force-window-bottom t
        ledger-reconcile-toggle-to-pending t))

;;; Visual cleanup Doom applies
(with-eval-after-load 'ledger-mode
  (add-hook 'ledger-mode-hook #'outline-minor-mode)
  (add-hook 'ledger-mode-hook
            (lambda ()
              (setq-local tab-width 4)
              (setq-local indent-tabs-mode nil))))

(provide 'ledger-config)
