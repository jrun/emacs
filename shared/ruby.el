; rvm
(vendor 'rvm)
(rvm-use-default)

; rinari
(vendor 'rinari)
(setq rdinari-tags-file-name "TAGS")
(add-hook 'rinari-minor-mode-hook
          (lambda ()
            (define-key rinari-minor-mode-map (kbd "A-r") 'rinari-test)))

; rspec
;;(vendor 'rspec-mode)
;;(add-to-list 'load-path (concat dotfiles-dir "/vendor/rspec-mode"))
;;(require 'rspec-mode)

; ruby
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.sake\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.ru$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))

(add-to-list 'completion-ignored-extensions ".rbc")

; treetop
(vendor 'treetop-mode)
(add-to-list 'auto-mode-alist '("\\.treetop\\'" . treetop-mode))