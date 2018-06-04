(setq emacsd "~/.emacs.d/")

(add-to-list 'load-path emacsd)
(add-to-list 'load-path (concat emacsd "vendor"))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(push "/usr/local/bin" exec-path)
(push (concat (substring (shell-command-to-string "rbenv root") 0 -1) "/bin") exec-path)

(require 'ansi-color)
(require 'cl)
(require 'compile)
(require 'ffap)
(require 'ido)
(require 'recentf)
(require 'saveplace)
(require 'unbound)
(require 'uniquify)
(require 'whitespace)

(load "shared/defuns")
(load "shared/global")

(add-to-list 'custom-theme-load-path (concat emacsd "themes"))
(load-theme 'jtb t)

;; shell
(setq explicit-shell-file-name "/usr/local/bin/zsh")
(global-set-key "\C-x\C-z" 'shell) ; shortcut for shell
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(eval-after-load 'shell
  '(progn
     (define-key shell-mode-map "\C-p" 'comint-previous-input)
     (define-key shell-mode-map "\C-n" 'comint-next-input)))

(load "shared/bindings")
(load "shared/modes")
(load "shared/temp-files")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(css-indent-offset 2)
 '(custom-safe-themes
   (quote
    ("362694989b93eacbdbf641ee09cfc2411400ff713cd53e1b33986a3c97e82997" "9c8fc2c63d101dd5e5ebfb21fb56b6b4032fa9c098f598c17a408f27da9f35ea" default)))
 '(enh-ruby-bounce-deep-indent t)
 '(enh-ruby-comment-column 50)
 '(enh-ruby-deep-arglist t)
 '(enh-ruby-extra-keywords (quote ("private" "protected" "public" "raise")))
 '(enh-ruby-hanging-indent-level 2)
 '(ido-case-fold t)
 '(ido-mode (quote both) nil (ido))
 '(js-indent-level 2)
 '(rst-level-face-base-color "black")
 '(ruby-extra-keywords (quote ("private" "protected" "public" "raise")))
 '(ruby-hanging-indent-level 2))


(when (eq system-type 'darwin)
  (setq ns-command-modifier 'meta)
  (setq-default ispell-program-name "/usr/local/bin/aspell")

  ; used for copy/paste when emacs runs in the terminal
  (require 'pbcopy)
  (turn-on-pbcopy))

(when (eq system-type 'gnu/linux))

(put 'erase-buffer 'disabled nil)

;; /sudo:host.example.com:
;(add-to-list 'tramp-default-proxies-alist '(nil "\\`root\\'" "/ssh:%h:"))
(put 'downcase-region 'disabled nil)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(enh-ruby-heredoc-delimiter-face ((t (:foreground "green"))))
 '(enh-ruby-op-face ((t (:foreground "color-23"))))
 '(enh-ruby-regexp-delimiter-face ((t (:foreground "green"))))
 '(enh-ruby-string-delimiter-face ((t (:foreground "green"))))
 '(erm-syn-errline ((t (:foreground "red" :box (:line-width 1 :color "red") :underline nil))))
 '(erm-syn-warnline ((t (:box (:line-width 1 :color "orange") :underline nil)))))
