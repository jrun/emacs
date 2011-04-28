(vendor 'jump)

(load "shared/cucumber")
(load "shared/javascript")
(load "shared/markdown")
(load "shared/ruby")
(load "shared/sgml")

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(vendor 'magit)
(eval-after-load 'magit
  '(progn
     (set-face-foreground 'magit-diff-add "green3")
     (set-face-foreground 'magit-diff-del "red3")))

; paredit
(autoload 'paredit-mode "paredit"
     "Minor mode for pseudo-structurally editing Lisp code."
     t)
(add-hook 'emacs-lisp-mode-hook (lambda () (paredit-mode +1)))

; yasnippet
(add-to-list 'load-path (concat emacsd "vendor/yasnippet.el"))
(require 'yasnippet)
(yas/initialize)
(yas/load-directory (concat emacsd "vendor/yasnippet.el/snippets"))

; yaml
(vendor 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-hook 'yaml-mode-hook
    '(lambda ()
       (define-key yaml-mode-map "\C-m" 'newline-and-indent)))
