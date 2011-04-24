(setq explicit-shell-file-name "/bin/zsh")
(global-set-key "\C-x\C-z" 'shell) ; shortcut for shell
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(eval-after-load 'shell
  '(progn
     (define-key shell-mode-map "\C-p" 'comint-previous-input)
     (define-key shell-mode-map "\C-n" 'comint-next-input)))
