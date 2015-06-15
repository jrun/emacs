(require 'ag)

(setq ag-highlight-search t
      ag-ignore-list '("\\.git$" "~$" "\\.elc$"))

(global-set-key (kbd "C-x \\")  'ag)
