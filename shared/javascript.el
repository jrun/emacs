(autoload 'js2-mode "js2" nil t)
(load "js2-improvements")

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

