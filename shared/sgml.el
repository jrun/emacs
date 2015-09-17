;; (require 'zencoding-mode)
;; (add-hook 'sgml-mode-hook 'zencoding-mode)
;; (setq-default sgml-basic-offset 2)

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))

(defun web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-indent-style 2)
  (setq web-mode-style-padding 2)
  (setq web-mode-script-padding 2)
  (setq web-mode-enable-current-element-highlight t)
)

(add-hook 'web-mode-hook 'web-mode-hook)
