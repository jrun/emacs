;; Use describe-face to help find what to adjust.

(deftheme jtb
  "Emacs 24 theme based on Vibrant Ink for Textmate")

(custom-theme-set-faces
 'jtb

 '(default ((t (:foreground "#eee8d5"))))

 '(cursor ((t (:background "#555577" :foreground "#ffffff"))))
 '(region ((t (:background "#444444"))))

 '(header-line ((t (:background "#002b36" :foreground "#13F77D"))))
 '(mode-line ((t (:background "#000" :foreground "#13F77D"))))
 '(highlight ((t (:background "#000" :foreground "#13F77D"))))

 '(mode-line-inactive ((t (:background "#000" :foreground "#444"))))
 '(fringe ((t (:background "#000000"))))
 '(minibuffer-prompt ((t (:foreground "#ff6600"))))
 '(isearch ((t (:background "#555555"))))
 '(lazy-highlight ((t (:background "#444444"))))

 '(link ((t (:foreground "#aaccff" :underline t))))
 '(link-visited ((t (:foreground "#aaccff" :underline t))))

 '(font-lock-builtin-face ((t (:foreground "#aaccff"))))

 '(font-lock-comment-face ((t (:italic t :foreground "#5A688C"))))
 '(font-lock-comment-delimiter-face ((t (:foreground "#5A688C"))))
 '(show-paren-mismatch ((t (:foreground "red" :background "#465a61"))))

 '(font-lock-function-name-face ((t (:foreground "#ffcc00"))))
 '(font-lock-keyword-face ((t (:foreground "#ff6600"))))
 '(font-lock-preprocessor-face ((t (:foreground "#aaffff"))))
 '(font-lock-constant-face ((t (:foreground "cyan"))))
 '(font-lock-reference-face ((t (:foreground "#92BBFD"))))
 '(font-lock-string-face ((t (:foreground "#5fff00"))))
 '(font-lock-doc-face ((t (:foreground "LightSalmon"))))
 '(font-lock-type-face ((t (:foreground "#FFDD00"))))
 '(font-lock-variable-name-face ((t (:foreground "#2075c7"))))
 '(font-lock-warning-face ((t (:foreground "Pink"))))
 '(show-paren-match ((t (:background "brightcyan"))))

 ;; diff
 '(diff-header ((t f(:background "black") )))
 '(diff-file-header ((t (:foreground "#839496" :background "black") )))

 '(diff-added   ((t (:foreground "green" :background "black") )))
 '(diff-changed ((t (:foreground "blue"  :background "black") )))
 '(diff-removed ((t (:foreground "red"   :background "black") )))

 '(diff-refine-added   ((t (:background "green") )))
 '(diff-refine-changed ((t (:background "blue") )))
 '(diff-refine-removed ((t (:background "red") )))

 ;; magit
 '(magit-item-highlight ((t (:foreground "#839496" :background "#002b36") )))
 '(magit-diff-none ((t (:background "#000") )))

 '(region ((t (:background "black"))))
 '(flymake-errline ((t (:background "LightSalmon" :foreground "black"))))
 '(flymake-warnline ((t (:background "LightSteelBlue" :foreground "black"))))
 '(underlinev((t (:underline t))))

 '(erb-face ((t (:background "brightblack"))))
 '(erb-delim-face ((t (:background "brightblack" :foreground "brightgreen"))))
 '(erb-out-delim-face ((t (:background "brightblack" :foreground "brightgreen"))))

 '(button ((t (:background "#bfbfbf" :underline t))))
 )

;; Local Variables:
;; no-byte-compile: t
;; End:

(provide-theme 'jtb)
