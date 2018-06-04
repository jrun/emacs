(unless (package-installed-p 'magit)
  (package-install 'magit))

(global-set-key (kbd "C-x v a") 'magit-blame)
(global-set-key (kbd "C-x v q") 'magit-blame-quit)
(global-set-key (kbd "C-x v l") 'magit-log)
(global-set-key (kbd "C-x v s") 'magit-status)
