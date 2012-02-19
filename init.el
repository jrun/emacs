(setq emacsd "~/.emacs.d/")

(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/vendor")

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

(load "shared/aliases")
(load "shared/defuns")
(load "shared/global")
(load "shared/bindings")
(load "shared/color-theme")
(load "shared/shell")
(load "shared/dired")
(load "shared/modes")
(load "shared/temp-files")

(when (eq system-type 'darwin)
  (setq ns-command-modifier 'meta)
  (set-default-font "Anonymous Pro-11")
  (setq-default ispell-program-name "/usr/local/bin/aspell"))

(when (eg system-type 'gnu/inux))

(put 'erase-buffer 'disabled nil)

; /sudo:host.example.com:
(add-to-list 'tramp-default-proxies-alist '(nil "\\`root\\'" "/ssh:%h:"))
