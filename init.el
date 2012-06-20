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

;; color theme
(require 'color-theme)
(setq color-theme-is-global t)
(load-file (concat emacsd "vendor/color-theme-vibrant-ink.el"))
(color-theme-vibrant-ink)

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
 '(ido-case-fold t)
 '(ido-mode (quote both) nil (ido)))

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
(add-to-list 'tramp-default-proxies-alist '(nil "\\`root\\'" "/ssh:%h:"))
