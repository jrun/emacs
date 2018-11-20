;; Turn off mouse interface early in startup to avoid momentary display
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(setq-default truncate-lines t)

;; suppress annoying prompts
(setq-default confirm-kill-processes nil)
;;
;; Choosing a Window:
;; http://www.gnu.org/software/emacs/manual/html_node/elisp/Choosing-Window.html
;;
;; Prevent splitting when visiting another buffer.
;;
(setq split-width-threshold nil)
(setq split-height-threshold nil)

(prefer-coding-system 'utf-8)

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
;(add-hook 'text-mode-hook 'turn-on-auto-fill)
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

; Use shift arrow keys to navigate windows.
(windmove-default-keybindings)

(global-set-key (kbd "C-c r") 'replace-string)
