;; https://elixirforum.com/t/emacs-elixir-setup-configuration-wiki/19196

(unless (package-installed-p 'elixir-mode)
  (package-install 'elixir-mode))

(unless (package-installed-p 'exunit)
  (package-install 'exunit))


(unless (package-installed-p 'mix)
  (package-install 'mix))


(add-hook 'elixir-mode-hook
          (lambda () (add-hook 'before-save-hook 'elixir-format nil t)))
