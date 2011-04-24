;; Load shared code
(load-file (concat dotfiles-dir "shared.el"))

;; Font
(set-default-font "-microsoft-Consolas-normal-normal-normal-*-14-*-*-*-m-0-iso10646-1")

;; Minor Modes

;; Velocity
(add-to-list 'auto-mode-alist '("\.vm$" . html-mode))
(autoload 'turn-on-vtl-mode "vtl" nil t)
(add-hook 'html-mode-hook 'turn-on-vtl-mode)
;;(add-hook 'xml-mode-hook 'turn-on-vtl-mode t t)
;;(add-hook 'text-mode-hook 'turn-on-vtl-mode t t)


;; Major Modes

;;; use groovy-mode when file ends in .groovy or has #!/bin/groovy at start
(autoload 'groovy-mode "groovy-mode" "Groovy editing mode." t)
(add-to-list 'auto-mode-alist '("\.groovy$" . groovy-mode))
(add-to-list 'interpreter-mode-alist '("groovy" . groovy-mode))
(add-to-list 'load-path (concat dotfiles-dir "/vendor/groovy-mode.el"))
(require 'groovy-mode)


