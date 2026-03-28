;;; llms.el -*- lexical-binding: t; -*-

(defun my/openrouter-api-key ()
  "Read OpenRouter API key from pass."
  (or (bound-and-true-p my/--openrouter-key)
      (setq my/--openrouter-key
            (string-trim
             (shell-command-to-string "pass LLMs/openrouter.ai")))))

(defun my/gemini-api-key ()
  "Read Gemini API key from pass."
  (or (bound-and-true-p my/--gemini-key)
      (setq my/--gemini-key
            (string-trim
             (shell-command-to-string "pass LLMs/geminikey")))))

(use-package gptel
  :defer t
  :config
  (setq gptel-default-mode 'org-mode)

  (setq gptel-backend
        (gptel-make-openai "OpenRouter"
                           :host "openrouter.ai"
                           :endpoint "/api/v1/chat/completions"
                           :stream t
                           :key #'my/openrouter-api-key
                           :models '(anthropic/claude-haiku-4-5
                                     anthropic/claude-sonnet-4-5
                                     qwen/qwen3-coder:free
                                     meta-llama/llama-3.3-70b-instruct:free
                                     mistralai/mistral-small-3.1-24b-instruct:free
                                     google/gemma-3-27b-it:free)))

  ;; gemini backend
  (setq gptel-backend
        (gptel-make-gemini "Gemini"
                           :key #'my/gemini-api-key
                           :stream t
                           :models '(gemini-3-flash-preview
                                     gemini-2.5-flash
                                     gemini-2.5-pro
                                     gemini-flash-latest)))
  (setq gptel-model 'gemini-3-flash-preview)

  ;; Ollama backend
  (gptel-make-ollama "Ollama"
                     :host (pcase (system-name)
                             ("theologica" "logos:11434")
                             ("logos"       "localhost:11434")
                             (_            "logos:11434"))
                     :stream t
                     :models '(qwen2.5-coder:14b-instruct-q4_K_M
                               ;; qwen3-coder-next
                               qwen3.5:9b
                               glm-4.7-flash:latest
                               deepseek-r1:8b)))

(provide 'llms)
