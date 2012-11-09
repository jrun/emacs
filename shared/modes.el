(vendor 'cheat)
(vendor 'jump)
(vendor 'json)

(load "shared/anything")
(load "shared/javascript")
(load "shared/markdown")
(load "shared/ruby")
(load "shared/sgml")
(load "shared/erlang")

(load "git-commit-mode/git-commit")

(require 'mouse)
(xterm-mouse-mode t)
(defun track-mouse (e))

;; Default to unified diffs
(setq diff-switches "-u")

(eval-after-load 'diff-mode
  '(progn
     (set-face-foreground 'diff-added "green4")
     (set-face-foreground 'diff-removed "red3")))

;; git
(vendor 'egg)

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
(add-to-list 'yas/snippet-dirs (concat emacsd "snippets"))
(yas/load-directory (concat emacsd "snippets"))

;; yaml
(vendor 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-hook 'yaml-mode-hook
          '(lambda ()
             (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

;; mustache
(vendor 'mustache-mode)
(add-to-list 'auto-mode-alist '("\\.mustache$" . tpl-mode))
(add-to-list 'auto-mode-alist '("\\.hbs$" . tpl-mode))


;; haml & sass
(require 'haml-mode)
(vendor 'sass-mode)

(add-to-list 'auto-mode-alist '("\\.scss$" . sass-mode))

(eval-after-load "sql"
  '(progn
     (sql-set-product 'postgres)))

;; php
;; (require 'php-mode)

(require 'slim-mode)

;; dtrace
(autoload 'd-mode "d-mode" () t)
(add-to-list 'auto-mode-alist '("\\.d\\'" . d-mode))
;; go
(vendor 'go-mode-load)
