(setq emacsd "~/.emacs.d/")

(add-to-list 'load-path emacsd)
(add-to-list 'load-path (concat emacsd "vendor"))

(push "/usr/local/bin" exec-path)

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
 '(egg-buffer-hide-help-on-start (quote (egg-status-buffer-mode egg-log-buffer-mode egg-file-log-buffer-mode egg-diff-buffer-mode egg-commit-buffer-mode)))
 '(ido-case-fold t)
 '(ido-mode (quote both) nil (ido))
 '(js2-basic-offset 2)
 '(js2-highlight-level 3)
 '(js2-include-gears-externs nil)
 '(js2-indent-on-enter-key t)
 '(js2-mirror-mode t)
 '(rst-level-face-base-color "black")
 '(ruby-extra-keywords (quote ("private" "protected" "public" "raise")))
 '(ruby-hanging-indent-level 2))


(when (eq system-type 'darwin)
  (setq ns-command-modifier 'meta)
  (set-frame-font "Anonymous Pro-11")
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
 )
