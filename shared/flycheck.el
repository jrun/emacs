(unless (package-installed-p 'flycheck)
  (package-install 'flycheck))

(add-hook 'after-init-hook #'global-flycheck-mode)
