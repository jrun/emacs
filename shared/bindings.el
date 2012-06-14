(global-set-key "\C-co" 'browse-url-at-point)

;; Ruby
(global-set-key "\C-cr" 'run-pry)
(global-set-key [f9] 'pry-intercept-rerun)
(global-set-key [S-f9] 'pry-intercept)

;; Rename buffer & visited file
(global-set-key (kbd "C-x C-r") 'rename-file)

;; Font size
(define-key global-map (kbd "C-+") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

;; File finding
;;(global-set-key (kbd "C-x f") 'recentf-ido-find-file)

;; Window switching using shift arrows
;;
;; When running emacs in tmux set the following in .tmux.conf
;;     set-window-option -g xterm-keys on
;;
(global-set-key "\M-[1;2A" 'windmove-up)
(global-set-key "\M-[1;2B" 'windmove-down)
(global-set-key "\M-[1;2C" 'windmove-right)
(global-set-key "\M-[1;2D" 'windmove-left)

;; Help should search more than just commands
(global-set-key (kbd "C-h a") 'apropos)

;; A better buffer
(global-set-key (kbd "C-x C-b") 'ibuffer)


(global-set-key (kbd "C-M-\\") '(lambda () (interactive)
                                  (indent-region (point-min) (point-max) nil)))
