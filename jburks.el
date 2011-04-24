;; Load shared code
(load-file (concat dotfiles-dir "shared.el"))

;; override the deafult aquamacs meta key to command
;;(setq mac-command-modifier 'meta)
(setq ns-command-modifier 'meta)

;; Font
;;(set-default-font "-microsoft-consolas-medium-r-normal--0-0-0-0-m-0-iso8859-13")
(set-default-font "-apple-Menlo-medium-normal-normal-*-13-*-*-*-m-0-fontset-auto3")

;; Minor Modes

;; Major Modes

;; XCODE
(require 'objc-c-mode)
(require 'xcode)
(define-key objc-mode-map [(meta r)] 'xcode-compile)
(define-key objc-mode-map [(meta K)] 'xcode-clean)
(add-hook 'c-mode-common-hook
          (lambda()
            (local-set-key  [(meta O)] 'ff-find-other-file)))
(add-hook 'c-mode-common-hook
          (lambda()
            (local-set-key (kbd "C-c <right>") 'hs-show-block)
            (local-set-key (kbd "C-c <left>")  'hs-hide-block)
            (local-set-key (kbd "C-c <up>")    'hs-hide-all)
            (local-set-key (kbd "C-c <down>")  'hs-show-all)
            (hs-minor-mode t)))             ; Hide and show blocks

(setq-default ispell-program-name "/usr/local/bin/aspell")
