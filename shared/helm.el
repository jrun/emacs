(unless (package-installed-p 'helm)
  (package-install 'helm))

(unless (package-installed-p 'helm-ag)
  (package-install 'helm-ag))

(unless (package-installed-p 'helm-sql-connect)
  (package-install 'helm-sql-connect))

(semantic-mode 1)

(helm-mode 1)
(helm-autoresize-mode nil)

(setq helm-buffers-fuzzy-matching t
      helm-recentf-fuzzy-match t
      helm-semantic-fuzzy-match t
      helm-M-x-fuzzy-match t
      helm-imenu-fuzzy-match t
      helm-ff-newfile-prompt-p nil
      helm-split-window-in-side-p t
      helm-ff-file-name-history-use-recentf t
      helm-boring-file-regexp-list '("\\.git$" "~$" "\\.elc$"))

(global-set-key (kbd "C-c h")   'helm-command-prefix)
(global-set-key (kbd "C-\\")    'helm-mini)
(global-set-key (kbd "M-y")     'helm-show-kill-ring)
(global-set-key (kbd "C-x b")   'helm-mini)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-x |")   'helm-ag-project-root)
(global-set-key (kbd "M-x")     'helm-M-x)


(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to do persistent action
(define-key helm-map (kbd "C-i")   'helm-execute-persistent-action)   ; make TAB works in terminal
(define-key helm-map (kbd "C-z")   'helm-select-action)              ; list actions using C-z


(ido-mode -1) ;; Turn off ido mode in case I enabled it accidentally
