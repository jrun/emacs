(add-to-list 'auto-mode-alist '("\.vm$" . html-mode))
(autoload 'turn-on-vtl-mode "vtl" nil t)
(add-hook 'html-mode-hook 'turn-on-vtl-mode)
;;(add-hook 'xml-mode-hook 'turn-on-vtl-mode t t)
;;(add-hook 'text-mode-hook 'turn-on-vtl-mode t t)

