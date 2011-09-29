;; http://www.erlang.org/doc/man/erlang.el.html

;; This is needed for Erlang mode setup
(setq load-path (cons "/usr/local/Cellar/erlang/R14B03/lib/erlang/lib/tools-2.6.6.4/emacs" load-path))
(setq erlang-root-dir "/usr/local/Cellar/erlang/R14B03")
(setq exec-path (cons "/usr/local/Cellar/erlang/R14B03/bin" exec-path))
(require 'erlang-start)

;; Tell Emacs not to wait the usual 60 seconds for an Erlang prompt
(defvar inferior-erlang-prompt-timeout t)

(add-to-list 'auto-mode-alist '("rabbitmq.config" . treetop-mode))
