;;(setq frame-background-mode 'dark)

(deftheme jtb
  "Emacs 24 theme based on Vibrant Ink for Textmate")

(custom-theme-set-faces
 'jtb

 ;; '(default ((t (:background "#111111" :foreground "#ffffff"))))
 '(cursor ((t (:background "#555577" :foreground "#ffffff"))))
 '(region ((t (:background "#444444"))))
 '(mode-line ((t (:background "#bfbfbf" :foreground "#000000"))))
 '(mode-line-inactive ((t (:background "#e5e5e5" :foreground "#333333"))))
 '(fringe ((t (:background "#000000"))))
 '(minibuffer-prompt ((t (:foreground "#ff6600"))))

 '(isearch ((t (:background "#555555"))))
 '(lazy-highlight ((t (:background "#444444"))))
 '(link ((t (:foreground "#aaccff" :underline t))))
 '(link-visited ((t (:foreground "#aaccff" :underline t))))

 '(font-lock-builtin-face ((t (:foreground "#aaccff"))))
 '(font-lock-comment-face ((t (:italic t :foreground "#5A688C"))))
 '(font-lock-comment-delimiter-face ((t (:foreground "#5A688C"))))
 '(font-lock-function-name-face ((t (:foreground "#ffcc00"))))
 '(font-lock-keyword-face ((t (:foreground "#ff6600"))))
 '(font-lock-preprocessor-face ((t (:foreground "#aaffff"))))
 '(font-lock-constant-face ((t (:foreground "cyan"))))
 '(font-lock-reference-face ((t (:foreground "#92BBFD"))))
 '(font-lock-string-face ((t (:foreground "#5fff00"))))
 '(font-lock-doc-face ((t (:foreground "LightSalmon"))))
 '(font-lock-type-face ((t (:foreground "#FFDD00"))))
 '(font-lock-variable-name-face ((t (:foreground "#2075c7"))))
 '(font-lock-warning-face ((t (:bold t :foreground "Pink"))))

 '(show-paren-match ((t (:background "brightcyan"))))
 '(show-paren-mismatch ((t (:foreground "red" :background "#465a61" :weight bold))))
 '(region ((t (:background "black"))))
 '(flymake-errline ((t (:background "LightSalmon" :foreground "black"))))
 '(flymake-warnline ((t (:background "LightSteelBlue" :foreground "black"))))
 '(underlinev((t (:underline t))))

 ;; for rhtml
 ;;
 ;; erb-face
 ;; erb-delim-face
 ;; erb-exec-face
 ;; erb-exec-delim-face
 ;; erb-out-face
 ;; erb-out-delim-face
 ;; erb-comment-face
 ;; erb-comment-delim-face
 '(erb-face ((t (:background "brightblack"))))
 '(erb-delim-face ((t (:background "brightblack" :foreground "brightgreen"))))
 '(erb-out-delim-face ((t (:background "brightblack" :foreground "brightgreen"))))

 '(button ((t (:background "#bfbfbf" :underline t))))
 '(header-line ((t (:background "#e5e5e5" :foreground "#333333")))))

;; Local Variables:
;; no-byte-compile: t
;; End:

(provide-theme 'jtb)
