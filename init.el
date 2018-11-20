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

;;(require 'ansi-color)
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

;; themes
(add-to-list 'custom-theme-load-path (concat emacsd "themes"))

(unless (package-installed-p 'gruvbox-theme)
  (package-install 'gruvbox-theme))

(load-theme 'gruvbox-dark-hard t)

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
 '(Linum-format "%7i ")
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   ["#454545" "#d65946" "#6aaf50" "#baba36" "#5180b3" "#ab75c3" "#68a5e9" "#bdbdb3"])
 '(css-indent-offset 2)
 '(custom-safe-themes
   (quote
    ("021720af46e6e78e2be7875b2b5b05344f4e21fad70d17af7acfd6922386b61e" "9f1e020c1acc2ef7ba951bb1d009899f04d8a2b40b203d76e49c34f7ca5961f4" "6ac7c0f959f0d7853915012e78ff70150bfbe2a69a1b703c3ac4184f9ae3ae02" "28ec8ccf6190f6a73812df9bc91df54ce1d6132f18b4c8fcc85d45298569eb53" "ed0b4fc082715fc1d6a547650752cd8ec76c400ef72eb159543db1770a27caa7" "6350f0cf3091e574a5de01d7309c0b456d814756a79867eac02c11b262d04a2e" "a4df5d4a4c343b2712a8ed16bc1488807cd71b25e3108e648d4a26b02bc990b3" "bc40f613df8e0d8f31c5eb3380b61f587e1b5bc439212e03d4ea44b26b4f408a" "00d9a65e7f3df37e0a777ee1b21de24548bf1f871b4663f51cf497d6c5b436d7" "a4d03266add9a1c8f12b5309612cbbf96e1291773c7bc4fb685bfdaf83b721c6" "1e7c2cf82a63e5d1acc99b597d7b86e0361cb2f10a213eb7bc47a56bb0f1f3ed" default)))
 '(enh-ruby-bounce-deep-indent t)
 '(enh-ruby-comment-column 50)
 '(enh-ruby-deep-arglist t)
 '(enh-ruby-extra-keywords (quote ("private" "protected" "public" "raise")))
 '(enh-ruby-hanging-indent-level 2)
 '(fringe-mode 4)
 '(ido-case-fold t)
 '(ido-mode (quote both) nil (ido))
 '(js-indent-level 2)
 '(main-line-separator-style (quote chamfer))
 '(package-selected-packages
   (quote
    (markdown-mode go-mode ace-jump-helm-line helm-sql-connect helm-ag ac-helm helm-bind-key helm-projectile projectile undo-tree afternoon-theme gruvbox-theme nimbus-theme dracula-theme soothe-theme darktooth-theme toggle redis enh-ruby-mode company-ansible elixir-yasnippets company-erlang company-inf-ruby alchemist elixir-mode)))
 '(rst-level-face-base-color "black")
 '(ruby-extra-keywords (quote ("private" "protected" "public" "raise")))
 '(ruby-hanging-indent-level 2)
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#d54e53")
     (40 . "goldenrod")
     (60 . "#e7c547")
     (80 . "DarkOliveGreen3")
     (100 . "#70c0b1")
     (120 . "DeepSkyBlue1")
     (140 . "#c397d8")
     (160 . "#d54e53")
     (180 . "goldenrod")
     (200 . "#e7c547")
     (220 . "DarkOliveGreen3")
     (240 . "#70c0b1")
     (260 . "DeepSkyBlue1")
     (280 . "#c397d8")
     (300 . "#d54e53")
     (320 . "goldenrod")
     (340 . "#e7c547")
     (360 . "DarkOliveGreen3"))))
 '(vc-annotate-very-old-color nil))

(when (eq system-type 'darwin)
  (setq ns-command-modifier 'meta)
  (setq-default ispell-program-name "/usr/local/bin/aspell")

  (require 'pbcopy) ; used for copy/paste when emacs runs in the terminal
  (turn-on-pbcopy))

(when (eq system-type 'gnu/linux))

(put 'erase-buffer 'disabled nil)

;; /sudo:host.example.com:
                                        ;(add-to-list 'tramp-default-proxies-alist '(nil "\\`root\\'" "/ssh:%h:"))

;; (custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 ;; '(enh-ruby-heredoc-delimiter-face ((t (:foreground "green"))))
 ;; '(enh-ruby-op-face ((t (:foreground "color-23"))))
 ;; '(enh-ruby-regexp-delimiter-face ((t (:foreground "green"))))
 ;; '(enh-ruby-string-delimiter-face ((t (:foreground "green"))))
 ;; '(erm-syn-errline ((t (:foreground "red" :box (:line-width 1 :color "red") :underline nil))))
 ;; '(erm-syn-warnline ((t (:box (:line-width 1 :color "orange") :underline nil)))))



(setq org-src-fontify-natively t)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'downcase-region 'disabled nil)
