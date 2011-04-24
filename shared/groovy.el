(autoload 'groovy-mode "groovy-mode" "Groovy editing mode." t)

(add-to-list 'auto-mode-alist '("\.groovy$" . groovy-mode))
(add-to-list 'interpreter-mode-alist '("groovy" . groovy-mode))

;;(add-to-list 'load-path (concat dotfiles-dir "/vendor/groovy-mode.el"))
(require 'groovy-mode)
