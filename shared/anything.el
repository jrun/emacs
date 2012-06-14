(require 'anything)
(require 'anything-config)
(require 'anything-match-plugin)
(require 'anything-etags)

(defun my-anything ()
  "My Anything command"
  (interactive)
  (anything-other-buffer
   '(anything-c-source-fixme
     anything-c-source-buffers+
     anything-c-source-files-in-current-dir+
     anything-c-source-file-name-history)
   "*my-anything*"))

(global-set-key (kbd "C-\\") 'my-anything)
(global-set-key [(meta fk11)] 'anything-resume)
(global-set-key (kbd "M-.") 'anything-etags-select-from-here)
