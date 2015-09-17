(add-to-list 'load-path (concat emacsd "vendor/enhanced-ruby-mode"))

;; doesn't seem to work with ruby 2.0
;;(setq enh-ruby-program "~/.rbenv/versions/ruby-2.1.4/bin/ruby")
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
