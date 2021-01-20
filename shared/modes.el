(vendor 'jump)
(vendor 'json)

(load "shared/desktop")
(load "shared/git")
(load "shared/ag")
(load "shared/helm")
(load "shared/projectile")
(load "shared/javascript")
(load "shared/elixir")
(load "shared/ruby")
(load "shared/markdown")
(load "shared/sgml")
(load "shared/erlang")

(require 'mouse)
(xterm-mouse-mode t)
(defun track-mouse (e))

;; Default to unified diffs
(setq diff-switches "-u")

(eval-after-load 'diff-mode
  '(progn
     (set-face-foreground 'diff-added "green4")
     (set-face-foreground 'diff-removed "red3")))

;; redis
(unless (package-installed-p 'redis)
  (package-install 'redis))

;; toggle
(unless (package-installed-p 'toggle)
  (package-install 'toggle))

(global-set-key (kbd "C-x C-t") 'toggle-buffer)

;; paredit
(autoload 'paredit-mode "paredit"
  "Minor mode for pseudo-structurally editing Lisp code." t)
(add-hook 'emacs-lisp-mode-hook (lambda () (paredit-mode +1)))

;; mode-compile
(autoload 'mode-compile "mode-compile"
  "Command to compile current buffer file based on the major mode" t)
(global-set-key "\C-cc" 'mode-compile)
(autoload 'mode-compile-kill "mode-compile"
  "Command to kill a compilation launched by `mode-compile'" t)
(global-set-key "\C-ck" 'mode-compile-kill)

;; yasnippet
(vendor 'yasnippet)
(yas-global-mode 1)
(add-to-list 'yas-snippet-dirs (concat emacsd "snippets"))
(yas-load-directory (concat emacsd "snippets"))

;; yaml
(vendor 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
;; (add-hook 'yaml-mode-hook
;;           '(lambda ()
;;              (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

;; mmm-mode
(unless (package-installed-p 'inf-ruby)
  (package-install 'inf-ruby))

;; (require 'mmm-auto)
(setq mmm-global-mode 'maybe)

;; mmm-jinja
(require 'mmm-jinja2)
(add-to-list 'auto-mode-alist '("\\.yml.jinja\\'" . yaml-mode))
(mmm-add-mode-ext-class 'yaml-mode "\\.yml.jinja\\'" 'jinja2)
(mmm-add-mode-ext-class 'yaml-mode "\\.yml\\'" 'jinja2)

;; sass
(require 'scss-mode)
(add-to-list 'auto-mode-alist '("\\.scss$" . scss-mode))

;; rainbow mode
(unless (package-installed-p 'rainbow-mode)
  (package-install 'rainbow-mode))

(add-hook 'css-mode-hook
          '(lambda ()
             (rainbow-mode 1)))


(defun my-html-mode-hook ()
  (auto-fill-mode -1))

(add-hook 'html-mode-hook 'my-html-mode-hook)

;; go
(vendor 'go-mode-load)

;; sql
(defun sql-add-newline-first (output)
  "Add newline to beginning of OUTPUT for `comint-preoutput-filter-functions'"
  (concat "\n" output))

(defun sqli-add-hooks ()
  "Add hooks to `sql-interactive-mode-hook'."
  (add-hook 'comint-preoutput-filter-functions 'sql-add-newline-first))

(eval-after-load "sql"
  '(progn
     (sql-set-product 'postgres)
     (add-hook 'sql-interactive-mode-hook 'sqli-add-hooks)
     (add-hook 'sql-interactive-mode-hook 'sql-set-sqli-buffer-generally)))

;; highlighting
(require 'highlight-indentation)
(set-face-background 'highlight-indentation-current-column-face "#042D4B")
(add-hook 'enh-ruby-mode-hook
          (lambda () (highlight-indentation-current-column-mode)))

;; systemd

(unless (package-installed-p 'systemd)
  (package-install 'systemd))

(add-to-list 'auto-mode-alist '("\\.service.j2$" . systemd-mode))
(add-to-list 'auto-mode-alist '("\\.timer.j2$" . systemd-mode))
