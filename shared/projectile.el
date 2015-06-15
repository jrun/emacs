;; helm-projectile
(add-to-list 'load-path (concat emacsd "vendor/projectile"))
(require 'helm-projectile)

(add-hook 'enh-ruby-mode-hook 'projectile-mode)
(setq projectile-completion-system 'helm)
(helm-projectile-on)

;; projectile-rails
(require 'projectile-rails)
(add-hook 'projectile-mode-hook 'projectile-rails-on)
