(vendor 'rvm)
(rvm-use-default)

(require 'inf-ruby)
(setf (first inf-ruby-implementations) '("ruby" . "pry"))
(setq inf-ruby-eval-binding "TOPLEVEL_BINDING")

(vendor 'rspec-mode)

(vendor 'rinari)
(setq rdinari-tags-file-name "TAGS")
(add-hook 'rinari-minor-mode-hook
          (lambda ()
            (define-key rinari-minor-mode-map (kbd "A-r") 'rinari-test)))


(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.sake\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.ru$" . ruby-mode))
(add-to-list 'auto-mode-alist '("pryrc$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Thorfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))

(add-to-list 'completion-ignored-extensions ".rbc")

(vendor 'treetop-mode)
(add-to-list 'auto-mode-alist '("\\.treetop\\'" . treetop-mode))

