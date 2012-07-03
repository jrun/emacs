;; color-theme-vibrant-ink
;;
;; This is an emacs color-theme library.  A port of the TextMate theme VibrantInk
;; Most of it was found on the emacs-rails google group
;;
;; Vibrant Ink Textmate: http://alternateidea.com/blog/articles/2006/1/3/textmate-vibrant-ink-theme-and-prototype-bundle
;; Vivid Chalk in emacs-rails Google Groups: http://groups.google.com/group/emacs-on-rails/browse_thread/thread/f99e3707e59eff6d


(defun color-theme-vibrant-ink ()
  "Emacs Vibrant Ink"
  (interactive)
  (color-theme-install
   '(color-theme-vibrant-ink
     ((default ((t (nil))))
      (background-mode  . dark)
      (foreground-color . "#81908f")
      (border-color . "black")
      (cursor-color . "#e9e2cb")
      (foreground-color . "#EDE8D5")
      (list-matching-lines-face . bold)
      (view-highlight-face . highlight))
     (bold ((t (:bold t))))
     (bold-italic ((t (:italic t :bold t))))
     (font-lock-builtin-face ((t (:foreground "#aaccff"))))
     (font-lock-comment-face ((t (:italic t :foreground "#9933cc"))))
     (font-lock-comment-delimiter-face ((t (:foreground "#9933cc"))))
     (font-lock-constant-face ((t (:foreground "#00384C"))))
     (font-lock-function-name-face ((t (:foreground "#ffcc00"))))
     (font-lock-keyword-face ((t (:foreground "#ff6600"))))
     (font-lock-preprocessor-face ((t (:foreground "#aaffff"))))
     (font-lock-reference-face ((t (:foreground "#92BBFD"))))
     (font-lock-string-face ((t (:foreground "#5fff00"))))
     (font-lock-doc-face ((t (:foreground "LightSalmon"))))
     (font-lock-type-face ((t (:foreground "#FFDD00"))))
     (font-lock-variable-name-face ((t (:foreground "#2075c7"))))
     (font-lock-warning-face ((t (:bold t :foreground "Pink"))))
     (show-paren-match ((t (:background "brightcyan"))))
     (show-paren-mismatch ((t (:foreground "red" :background "#465a61" :weight bold))))
     (highlight ((t (:background "black" :foreground "white"))))
     (italic ((t (:italic t))))
     (region ((t (:background "#555577"))))
     (primary-selection ((t (:background "#555577"))))
     (zmacs-region ((t (:background "#555577"))))
     (secondary-selection ((t (:background "darkslateblue"))))
     (flymake-errline ((t (:background "LightSalmon" :foreground "black"))))
     (flymake-warnline ((t (:background "LightSteelBlue" :foreground "black"))))
     (underlinev((t (:underline t))))

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
     (erb-face ((t (:background "brightblack"))))
     (erb-delim-face ((t (:background "brightblack" :foreground "brightgreen"))))
     (erb-out-delim-face ((t (:background "brightblack" :foreground "brightgreen"))))

     (minibuffer-prompt ((t (:bold t :foreground "#00384C")))))))
