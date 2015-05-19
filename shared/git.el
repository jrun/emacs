;;(add-to-list 'load-path (concat emacsd "vendor/git-modes"))
(add-to-list 'load-path (concat emacsd "vendor/magit"))

(eval-after-load 'info
  '(progn (info-initialize)
          (add-to-list 'Info-directory-list (concat emacsd "vendor/magit"))))


(require 'magit)
;;0(require 'magit-blame)

(global-set-key (kbd "C-x v a") 'magit-blame-mode)
(global-set-key (kbd "C-x v l") 'magit-log)
(global-set-key (kbd "C-x v s") 'magit-status)


;; (load "git-modes/git-commit-mode")
;; (load "git-modes/git-rebase-mode"
;; (load "git-modes/gitconfig-mode"))
;; (load "git-modes/gitignore-mode")
