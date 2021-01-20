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

(load-theme 'doom-outrun-electric t)

(defun on-after-init ()
  (unless (display-graphic-p (selected-frame))
    (set-face-background 'default "unspecified-bg" (selected-frame))))

(add-hook 'window-setup-hook 'on-after-init)

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
 '(css-indent-offset 2)
 '(custom-safe-themes
   '("c9ddf33b383e74dac7690255dd2c3dfa1961a8e8a1d20e401c6572febef61045" "4f01c1df1d203787560a67c1b295423174fd49934deb5e6789abd1e61dba9552" "7d708f0168f54b90fc91692811263c995bebb9f68b8b7525d0e2200da9bc903c" "1623aa627fecd5877246f48199b8e2856647c99c6acdab506173f9bb8b0a41ac" "8e51e44e5b079b2862335fcc5ff0f1e761dc595c7ccdb8398094fb8e088b2d50" "6c3b5f4391572c4176908bb30eddc1718344b8eaff50e162e36f271f6de015ca" "efc8341e278323cd87eda7d7a3736c8837b10ebfaa0d2be978820378d3d1b2e2" "7b3d184d2955990e4df1162aeff6bfb4e1c3e822368f0359e15e2974235d9fa8" "5036346b7b232c57f76e8fb72a9c0558174f87760113546d3a9838130f1cdb74" "188fed85e53a774ae62e09ec95d58bb8f54932b3fd77223101d036e3564f9206" "3c2f28c6ba2ad7373ea4c43f28fcf2eed14818ec9f0659b1c97d4e89c99e091e" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "cae81b048b8bccb7308cdcb4a91e085b3c959401e74a0f125e7c5b173b916bf9" "54cf3f8314ce89c4d7e20ae52f7ff0739efb458f4326a2ca075bf34bc0b4f499" "2cdc13ef8c76a22daa0f46370011f54e79bae00d5736340a5ddfe656a767fddf" "36ca8f60565af20ef4f30783aa16a26d96c02df7b4e54e9900a5138fb33808da" "bf387180109d222aee6bb089db48ed38403a1e330c9ec69fe1f52460a8936b66" "01cf34eca93938925143f402c2e6141f03abb341f27d1c2dba3d50af9357ce70" "711efe8b1233f2cf52f338fd7f15ce11c836d0b6240a18fffffc2cbd5bfe61b0" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "e61752b5a3af12be08e99d076aedadd76052137560b7e684a8be2f8d2958edc3" "74ba9ed7161a26bfe04580279b8cad163c00b802f54c574bfa5d924b99daa4b9" "5d09b4ad5649fea40249dd937eaaa8f8a229db1cec9a1a0ef0de3ccf63523014" "990e24b406787568c592db2b853aa65ecc2dcd08146c0d22293259d400174e37" "76bfa9318742342233d8b0b42e824130b3a50dcc732866ff8e47366aed69de11" "e1ef2d5b8091f4953fe17b4ca3dd143d476c106e221d92ded38614266cea3c8b" "a3b6a3708c6692674196266aad1cb19188a6da7b4f961e1369a68f06577afa16" "be9645aaa8c11f76a10bcf36aaf83f54f4587ced1b9b679b55639c87404e2499" "71e5acf6053215f553036482f3340a5445aee364fb2e292c70d9175fb0cc8af7" "3df5335c36b40e417fec0392532c1b82b79114a05d5ade62cfe3de63a59bc5c6" "730a87ed3dc2bf318f3ea3626ce21fb054cd3a1471dcd59c81a4071df02cb601" "dde8c620311ea241c0b490af8e6f570fdd3b941d7bc209e55cd87884eb733b0e" "c4bdbbd52c8e07112d1bfd00fee22bf0f25e727e95623ecb20c4fa098b74c1bd" "4bca89c1004e24981c840d3a32755bf859a6910c65b829d9441814000cf6c3d0" "79278310dd6cacf2d2f491063c4ab8b129fee2a498e4c25912ddaa6c3c5b621e" "e6ff132edb1bfa0645e2ba032c44ce94a3bd3c15e3929cdf6c049802cf059a2a" "2f1518e906a8b60fac943d02ad415f1d8b3933a5a7f75e307e6e9a26ef5bf570" "8d7684de9abb5a770fbfd72a14506d6b4add9a7d30942c6285f020d41d76e0fa" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "96d217b4af0ed02111ae8eb6e28e0ed90fdbeed77aeb3267c361b0b13438145a" "eb5c79b2e9a91b0a47b733a110d10774376a949d20b88c31700e9858f0f59da7" "1cd4df5762b3041a09609b5fb85933bb3ae71f298c37ba9e14804737e867faf3" "42b9d85321f5a152a6aef0cc8173e701f572175d6711361955ecfb4943fe93af" "26d49386a2036df7ccbe802a06a759031e4455f07bda559dcf221f53e8850e69" "bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" "a77ced882e25028e994d168a612c763a4feb8c4ab67c5ff48688654d0264370c" "021720af46e6e78e2be7875b2b5b05344f4e21fad70d17af7acfd6922386b61e" "9f1e020c1acc2ef7ba951bb1d009899f04d8a2b40b203d76e49c34f7ca5961f4" "6ac7c0f959f0d7853915012e78ff70150bfbe2a69a1b703c3ac4184f9ae3ae02" "28ec8ccf6190f6a73812df9bc91df54ce1d6132f18b4c8fcc85d45298569eb53" "ed0b4fc082715fc1d6a547650752cd8ec76c400ef72eb159543db1770a27caa7" "6350f0cf3091e574a5de01d7309c0b456d814756a79867eac02c11b262d04a2e" "a4df5d4a4c343b2712a8ed16bc1488807cd71b25e3108e648d4a26b02bc990b3" "bc40f613df8e0d8f31c5eb3380b61f587e1b5bc439212e03d4ea44b26b4f408a" "00d9a65e7f3df37e0a777ee1b21de24548bf1f871b4663f51cf497d6c5b436d7" "a4d03266add9a1c8f12b5309612cbbf96e1291773c7bc4fb685bfdaf83b721c6" "1e7c2cf82a63e5d1acc99b597d7b86e0361cb2f10a213eb7bc47a56bb0f1f3ed" default))
 '(enh-ruby-bounce-deep-indent t)
 '(enh-ruby-comment-column 50)
 '(enh-ruby-deep-arglist t)
 '(enh-ruby-extra-keywords '("private" "protected" "public" "raise" "test"))
 '(enh-ruby-hanging-indent-level 2)
 '(fringe-mode 4 nil (fringe))
 '(ido-case-fold t)
 '(ido-mode 'both nil (ido))
 '(js-indent-level 2)
 '(main-line-separator-style 'chamfer)
 '(menu-bar-mode nil)
 '(package-selected-packages
   '(flymake-yaml flycheck-yamllint yaml-mode mix helm-lsp lsp-mode exunit vscode-dark-plus-theme snazzy-theme projectile-ripgrep ripgrep sql-indent ample-theme vuiet doom-themes color-theme-sanityinc-tomorrow nix-env-install purple-haze-theme exec-path-from-shell gulp-task-runner rubocopfmt rubocop dockerfile-mode ox-asciidoc markdown-mode go-mode ace-jump-helm-line helm-sql-connect helm-ag ac-helm helm-bind-key helm-projectile projectile undo-tree toggle redis enh-ruby-mode company-ansible elixir-yasnippets company-erlang company-inf-ruby elixir-mode))
 '(robe-completing-read-func 'helm-robe-completing-read)
 '(ruby-extra-keywords '("private" "protected" "public" "raise" "test"))
 '(ruby-hanging-indent-level 2)
 '(show-paren-mode t)
 '(tool-bar-mode nil))

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
 '(default ((t (:family "Anonymous Pro" :foundry "nil" :slant normal :weight normal :height 141 :width normal))))
 '(diff-removed ((t (:extend t :background "#1B111C" :foreground "#ea4261"))))
 '(font-lock-keyword-face ((t (:foreground "#ff2afc" :weight normal))))
 '(font-lock-variable-name-face ((t (:foreground "#1ea8fc" :weight bold))))
 '(helm-selection ((t (:inherit bold :extend t :background "#1f1147"))))
 '(magit-diff-added-highlight ((t (:extend t :background "#2b331f" :foreground "#a7da1e" :weight normal))))
 '(magit-diff-removed-highlight ((t (:extend t :background "#1B111C" :foreground "#ea4261" :weight bold)))))


(put 'downcase-region 'disabled nil)
