(global-set-key "\C-co" 'browse-url-at-point)

;; Rename buffer & visited file
(global-set-key (kbd "C-x C-r") 'rename-file)

;; Font size
(define-key global-map (kbd "C-+") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

;; Help should search more than just commands
(global-set-key (kbd "C-h a") 'apropos)

;; A better buffer
(global-set-key (kbd "C-x C-b") 'ibuffer)


(global-set-key (kbd "C-M-\\") '(lambda () (interactive)
                                  (indent-region (point-min) (point-max) nil)))


(global-set-key "\C-ct" 'touch)
