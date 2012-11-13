(add-to-list 'load-path (concat emacsd "vendor/Enhanced-Ruby-Mode"))
(autoload 'ruby-mode "ruby-mode" "Major mode for ruby files" t)

(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.ru$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.sake\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Guardfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Thorfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("pryrc$" . ruby-mode))

(add-to-list 'completion-ignored-extensions ".rbc")

;; rhtml
(add-to-list 'load-path (concat emacsd "vendor/rhtml-mode"))
(vendor 'rhtml-mode)
(add-to-list 'auto-mode-alist '("\\.rhtml$" . rhtml-mode))

;; treetip
(vendor 'treetop-mode)
(add-to-list 'auto-mode-alist '("\\.treetop\\'" . treetop-mode))
