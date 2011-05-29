;; Turn off mouse interface early in startup to avoid momentary display
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

(prefer-coding-system 'utf-8)
(setq-default truncate-lines t)

; save the session on exit
(desktop-save-mode 1)

; Transparently open compressed files
(auto-compression-mode t)

; Enable syntax highlighting for older Emacsen that have it off
(global-font-lock-mode t)

; Save a list of recent files visited.
(recentf-mode 1)

; Highlight matching parentheses when the point is on them.
(show-paren-mode 1)

; Spell check
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'text-mode-hook 'turn-on-flyspell)

; Prevent messages about closing buffer
(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)

; Open files via emacsclient
(server-start)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(ansi-color-for-comint-mode-on)

(setq uniquify-buffer-name-style 'reverse)
(setq uniquify-separator "|")
(setq uniquify-after-kill-buffer-p t) ; rename after killing uniquified
(setq uniquify-ignore-buffers-re "^\\*") ; don't muck with special buffers

; Mostly to make it easier to hop out of org-mode since it's key bindindings override windmove.
(global-set-key [C-tab] 'other-window)