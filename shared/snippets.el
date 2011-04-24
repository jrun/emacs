(add-to-list 'load-path (concat emacsd "vendor/yasnippet.el"))
(require 'yasnippet)
(yas/initialize)
(yas/load-directory (concat emacsd "vendor/yasnippet.el/snippets"))
