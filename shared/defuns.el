;; aliases
(defalias 'e 'find-file-other-window)
(defalias 'll "ls -l $*")
(defalias 'yes-or-no-p 'y-or-n-p)

;; for loading libraries in from the vendor directory
(defun vendor (library)
  (let* ((file (symbol-name library))
         (normal (concat "~/.emacs.d/vendor/" file))
         (suffix (concat normal ".el"))
         (shared (concat "~/.emacs.d/shared/" file)))
    (cond
     ((file-directory-p normal) (add-to-list 'load-path normal) (require library))
     ((file-directory-p suffix) (add-to-list 'load-path suffix) (require library))
     ((file-exists-p suffix) (require library)))
    (when (file-exists-p (concat shared ".el"))
      (load shared))))
