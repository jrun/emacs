; https://github.com/nonsequitur/inf-ruby
(unless (package-installed-p 'inf-ruby)
  (package-install 'inf-ruby))

; https://github.com/zenspider/enhanced-ruby-mode
(unless (package-installed-p 'enh-ruby-mode)
  (package-install 'enh-ruby-mode))

(add-to-list 'interpreter-mode-alist '("ruby" . enh-ruby-mode))
(autoload 'enh-ruby-mode "enh-ruby-mode" "Major mode for ruby files" t)

(add-to-list 'auto-mode-alist '("\\.gemspec$" . enh-ruby-mode))
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

; inferior
(autoload 'inf-ruby "inf-ruby" "Run an inferior Ruby process" t)
(autoload 'inf-ruby-setup-keybindings "inf-ruby" "" t)
(eval-after-load 'enh-ruby-mode
  '(add-hook 'enh-ruby-mode-hook 'inf-ruby-setup-keybindings))
