(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/vendor")

(setq emacsd "~/emacs.d/")


(load "shared/defuns")
(load "shared/global")
(load "shared/bindings")
(load "shared/color-theme")
(load "shared/shell")
(load "shared/dired")
(load "shared/modes")
(load "shared/temp-files")

(require 'ansi-color)
(require 'cl)
(require 'ffap)
(require 'recentf)
(require 'saveplace)
(require 'unbound)
(require 'uniquify)
(require 'whitespace)

(setq system-specific-config (concat emacsd system-name ".el")
      user-specific-config (concat emacsd user-login-name ".el")
      user-specific-dir (concat emacsd user-login-name))
(add-to-list 'load-path user-specific-dir)

(if (file-exists-p system-specific-config) (load system-specific-config))
(if (file-exists-p user-specific-config) (load user-specific-config))
(if (file-exists-p user-specific-dir)
  (mapc #'load (directory-files user-specific-dir nil ".*el$")))
