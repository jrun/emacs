(global-set-key "\C-xg" 'magit-status)
(global-set-key "\C-xr" 'run-ruby)

(global-set-key [C-tab] 'other-window)

;; Taken from emacs-starter-kit

;; Align your code in a pretty way.
(global-set-key (kbd "C-x \\") 'align-regexp)

;; Font size
(define-key global-map (kbd "C-+") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

;; File finding
;;(global-set-key (kbd "C-x f") 'recentf-ido-find-file)
;;(global-set-key (kbd "C-c r") 'revert-buffer)
;;(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Window switching. (C-x o goes to the next window)
(windmove-default-keybindings) ;; Shift+direction
(global-set-key (kbd "C-x O") (lambda () (interactive) (other-window -1))) ;; back one
(global-set-key (kbd "C-x C-o") (lambda () (interactive) (other-window 2))) ;; forward two

;; Help should search more than just commands
(global-set-key (kbd "C-h a") 'apropos)

; A better buffer
(global-set-key (kbd "C-x C-b") 'ibuffer)

; Rename buffer & visited file
(global-set-key (kbd "C-c r") 'rename-file)


(global-set-key "\C-co" 'browse-url-at-point)
