(require 'anything-config)
(require 'anything-match-plugin)
(require 'anything-rails)

(defun my-anything ()
  "My Anything command"
  (interactive)
  (anything-other-buffer
   '(anything-c-source-buffers+
     anything-c-source-files-in-current-dir+
     anything-c-source-file-name-history
     anything-c-source-rails-project-files)
   "*my-anything*"))

(global-set-key (kbd "C-\\") 'my-anything)
(global-set-key [(meta fk11)] 'anything-resume)
