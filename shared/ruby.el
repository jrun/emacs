;; https://github.com/nonsequitur/inf-ruby
(unless (package-installed-p 'inf-ruby)
  (package-install 'inf-ruby))

;; https://github.com/zenspider/enhanced-ruby-mode
(unless (package-installed-p 'enh-ruby-mode)
  (package-install 'enh-ruby-mode))

(add-to-list 'interpreter-mode-alist '("ruby" . enh-ruby-mode))
(autoload 'enh-ruby-mode "enh-ruby-mode" "Major mode for ruby files" t)

(add-to-list 'auto-mode-alist '("\\.gemspec$" . enh-ruby-mode))
(add-to-list 'auto-mode-alist '("\\.jbuilder$" . enh-ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . enh-ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rb$" . enh-ruby-mode))
(add-to-list 'auto-mode-alist '("\\.ru$" . enh-ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . enh-ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . enh-ruby-mode))
(add-to-list 'auto-mode-alist '("Guardfile$" . enh-ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . enh-ruby-mode))
(add-to-list 'auto-mode-alist '("Thorfile$" . enh-ruby-mode))
(add-to-list 'auto-mode-alist '("pryrc$" . enh-ruby-mode))

(add-to-list 'completion-ignored-extensions ".rbc")

;; inferior
;; (autoload 'inf-ruby "inf-ruby" "Run an inferior Ruby process" t)
;; (autoload 'inf-ruby-setup-keybindings "inf-ruby" "" t)
;; (eval-after-load 'enh-ruby-mode
;;   '(add-hook 'enh-ruby-mode-hook 'inf-ruby-setup-keybindings))

(add-hook 'compilation-filter-hook 'inf-ruby-auto-enter)


;; rubocopfmt
;; ==========

(unless (package-installed-p 'rubocopfmt)
  (package-install 'rubocopfmt))

(setq rubocopfmt-use-bundler-when-possible nil)

(add-hook 'enh-ruby-mode-hook #'rubocopfmt-mode)


;; rubocop
;; =======

(unless (package-installed-p 'rubocop)
  (package-install 'rubocop))

(add-hook 'enh-ruby-mode-hook #'rubocop-mode)


;; projectile
;; ==========

(unless (package-installed-p 'projectile-rails)
  (package-install 'projectile-rails))

(add-hook 'projectile-mode-hook 'projectile-rails-on)

(projectile-global-mode)
(projectile-rails-global-mode)

(with-eval-after-load 'projectile-rails
  (define-key projectile-rails-mode-map (kbd "C-c r") 'projectile-rails-command-map)
  (define-key projectile-rails-mode-map (kbd "s-m")   'projectile-rails-find-model)
  (define-key projectile-rails-mode-map (kbd "s-c")   'projectile-rails-find-controller)
  (define-key projectile-rails-mode-map (kbd "s-v")   'projectile-rails-find-view)
  (define-key projectile-rails-mode-map (kbd "s-t")   'projectile-rails-rake)
  (define-key projectile-rails-mode-map (kbd "s-c")   'projectile-rails-console)
  (define-key projectile-rails-mode-map (kbd "s-RET") 'projectile-rails-goto-file-at-point)
  (define-key projectile-rails-mode-map (kbd "C-c g")  projectile-rails-mode-goto-map))


;; Robe
;; ====
;; https://github.com/dgutov/robe
(unless (package-installed-p 'robe)
  (package-install 'robe))

(add-hook 'enh-ruby-mode-hook 'robe-mode)

(custom-set-variables
 '(robe-completing-read-func 'helm-robe-completing-read))

;;(add-hook 'after-init-hook 'global-company-mode)

(global-company-mode t)
(push 'company-robe company-backends)
