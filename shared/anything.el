(require 'anything)
(require 'anything-config)
(require 'anything-match-plugin)
(require 'anything-rails)

(defun my-anything ()
  "My Anything command"
  (interactive)
  (anything-other-buffer
   '(anything-c-source-fixme
     anything-c-source-buffers+
     anything-c-source-rails-project-files
     anything-c-source-files-in-current-dir+
     anything-c-source-file-name-history)
   "*my-anything*"))

;(global-set-key (kbd "M-X") 'anything)
(global-set-key [f11] 'my-anything)
(global-set-key [(meta f11)] 'anything-resume)