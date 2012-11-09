;;
;;  ssh and github: please use key authentication since egg doesn't
;;                  handle login/passwd prompt
;;
;;  gpg and tag : please add "use-agent" option in your gpg.conf
;;                since egg doesn't handle passphrase prompt.
(eval-when-compile (require 'cl))
(require 'egg-custom)
(require 'egg-base)
(require 'egg-const)
(require 'egg-git)
(require 'rx)
;;(cl-macroexpand '(egg-text blah 'egg-text-3))
(defun egg-show-branch (branch)
  (interactive (list (egg-head-at-point)))
  (let* ((info (and (stringp branch)
		    (egg-git-to-string-list "for-each-ref"
					    "--format=%(refname:short) %(refname) %(upstream:short)"
					    (concat "refs/heads/" branch))))
	 (name (nth 0 info))
	 (full (nth 1 info))
	 (upstream (nth 2 info)))
    (when (stringp name)
      (message "local-branch:%s full-name:%s upstream:%s" 
	       (egg-text name 'bold) 
	       (egg-text full 'bold)
	       (if upstream (egg-text upstream 'bold) "none")))))

(defvar egg-atag-info-buffer (get-buffer-create "*tag-info*"))

(defun egg-show-atag (tag)
  (interactive (list (egg-tag-at-point)))
  (let ((dir (egg-work-tree-dir))
	(buf egg-atag-info-buffer)
	(new-buf-name (concat "*tag@" (egg-repo-name) ":" tag "*"))
	(inhibit-read-only t)
	target-type sig-beg sig-end verify pos)
    (with-current-buffer buf
      (setq default-directory dir)
      (setq target-type (egg-git-to-string "for-each-ref" "--format=%(objecttype)"
					   (concat "refs/tags/" tag)))
      (unless (equal target-type "tag")
	(error "Not an annotated tag: %s" tag))
      (unless (string-equal (buffer-name) new-buf-name)
	(rename-buffer new-buf-name))
      (erase-buffer)
      (unless (egg-git-ok t "show" "-s" tag)
	(error "Failed to show tag %s" tag))
      (save-match-data
	(goto-char (point-min))
	(re-search-forward "^tag ")
	(put-text-property (match-end 0) (line-end-position) 'face 'egg-branch)
	(re-search-forward "^Tagger:\\s-+")
	(put-text-property (match-end 0) (line-end-position) 'face 'egg-text-2)
	(re-search-forward "^Date:\\s-+")
	(put-text-property (match-end 0) (line-end-position) 'face 'egg-text-2)
	(setq pos (line-end-position))
	(when (re-search-forward "-----BEGIN PGP SIGNATURE-----" nil t)
	  (setq sig-beg (match-beginning 0))
	  (re-search-forward "-----END PGP SIGNATURE-----\n")
	  (setq sig-end (match-end 0))
	  (goto-char sig-beg)
	  (delete-region sig-beg sig-end)
	  (with-temp-buffer
	    (egg-git-ok t "tag" "-v" tag)
	    (goto-char (point-min))
	    (re-search-forward "^gpg:")
	    (setq verify (buffer-substring-no-properties (match-beginning 0)
							 (point-max))))
	  (insert verify "\n"))
	(goto-char pos)
	(re-search-forward "^\\(commit\\|gpg:\\)")
	(put-text-property pos (match-beginning 0) 'face 'egg-text-1)
	(re-search-forward "^Author:\\s-+")
	(put-text-property (match-end 0) (line-end-position) 'face 'egg-text-2)
	(re-search-forward "^Date:\\s-+")
	(put-text-property (match-end 0) (line-end-position) 'face 'egg-text-2)
	(put-text-property (line-end-position) (point-max) 'face 'egg-text-1))
      (set-buffer-modified-p nil))
    (pop-to-buffer buf)))

(defun egg-show-remote-branch (branch)
  (interactive (list (egg-remote-at-point)))
  (let* ((info (and (stringp branch)
		    (egg-git-to-string-list "for-each-ref"
					    "--format=%(refname:short) %(refname)"
					    (concat "refs/remotes/" branch))))
	 (name (nth 0 info))
	 (full (nth 1 info))
	 (site (and (stringp name) (egg-rbranch-to-remote name)))
	 (url (and site (egg-git-to-string "ls-remote" "--get-url" site))))
    (when (stringp name)
      (message "remote-tracking-branch:%s full-name:%s site:%s" 
	       (egg-text name 'bold) 
	       (egg-text full 'bold)
	       (egg-text url 'bold)))))


(defun egg-call-next-action (action &optional ignored-action only-action)
  (when (and action (symbolp action))
    (let ((cmd (plist-get '(log egg-log
				status egg-status
				stash egg-status
				commit egg-commit-log-edit
				reflog egg-reflog)
			  action))
	  (current-prefix-arg nil))
      (when (and (commandp cmd)		;; cmd is a valid command
		 ;; if only-action is specified, then only take
		 ;; action if it's the same as only-action
		 (or (and only-action (eq only-action action))
		     ;; if only-action is not specified, then
		     ;; take the action if it's not ignored.
		     (and (null only-action)
			  (not (if (symbolp ignored-action) 
				   (eq action ignored-action)
				 (memq action ignored-action))))))
	(call-interactively cmd)))))
(defun egg-read-tracked-filename (prompt &optional default no-match-ok)
  (concat (egg-work-tree-dir)
	  (completing-read prompt #'egg-do-completion
			   #'egg-get-match-files-substring
			   (not no-match-ok) default)))

(defun egg-find-tracked-file (file-name)
  "Open a file tracked by git."
  (interactive (list (egg-read-tracked-filename "Find tracked file: ")))
  (switch-to-buffer (find-file-noselect file-name)))

         (squash-head (plist-get state :squash-head))
           (concat "Merging to " (egg-pretty-short-rev sha1) " from: "
	  ((and branch squash-head)
           (concat "Squashed " squash-head " onto " branch))
          (squash-head
           (concat "Squashed " squash-head "  onto " (egg-pretty-short-rev sha1)))
    (or branch (egg-pretty-short-rev (plist-get state :sha1)))))

(defun egg--async-create-signed-commit-handler (buffer-to-update)
  (goto-char (point-min))
  (re-search-forward "EGG-GIT-OUTPUT:\n" nil t)
  (if (not (match-end 0))
      (message "something wrong with git-commit's output!")
    (let* ((proc egg-async-process)
	   (ret-code (process-exit-status proc))
	   res)
      (goto-char (match-end 0))
      (save-restriction
	(narrow-to-region (point) (point-max))
	(setq res (egg--do-show-output 
		   "GIT-COMMIT-GPG"
		   (egg--do-handle-exit (cons ret-code (current-buffer)) 
					#'egg--git-pp-commit-output
					buffer-to-update)))
	(when (plist-get res :success)
	  (setq res (nconc (list :next-action 'status) res)))
	(egg--buffer-handle-result res t)))))
(defsubst egg-buffer-do-amend-no-edit (&rest args)
  (egg--buffer-handle-result (egg--git-amend-no-edit-cmd t) t))
(defun egg--buffer-do-create-tag (name rev stdin &optional short-msg force ignored-action)
  (let ((args (list name rev))
	(check-name (egg-git-to-string "name-rev" name))
	res)
    (cond (stdin (setq args (nconc (list "-F" "-") args)))
	  (short-msg (setq args (nconc (list "-m" short-msg))))
	  (t nil))
    (setq force (egg--git-tag-check-name name force))
    (when force (setq args (cons "-f" args)))
    (when (or stdin short-msg) (setq args (cons "-a" args)))
    (setq res (egg--git-tag-cmd (egg-get-log-buffer) stdin args))
    ;;; useless???
    (when (plist-get res :success)
      (setq res (nconc (list :next-action 'log) res)))

    (egg--buffer-handle-result res t ignored-action)))

;;(setenv "GPG_AGENT_INFO" "/tmp/gpg-SbJxGl/S.gpg-agent:28016:1")
;;(getenv "GPG_AGENT_INFO")

(defun egg--async-create-signed-tag-handler (buffer-to-update name rev)
  (goto-char (point-min))
  (re-search-forward "EGG-GIT-OUTPUT:\n" nil t)
  (if (not (match-end 0))
      (message "something wrong with git-tag's output!")
    (let* ((proc egg-async-process)
	   (ret-code (process-exit-status proc))
	   res)
      (goto-char (match-end 0))
      (save-restriction
	(narrow-to-region (point) (point-max))
	(setq res (egg--do-show-output 
		   "GIT-TAG-GPG"
		   (egg--do-handle-exit (cons ret-code (current-buffer)) 
					#'egg--git-tag-cmd-pp
					buffer-to-update)))
	(when (plist-get res :success)
	  (setq res (nconc (list :next-action 'log) res)))
	(egg--buffer-handle-result res t)))))

(defun egg--async-create-signed-tag-cmd (buffer-to-update msg name rev &optional gpg-uid force)
  (let ((force (egg--git-tag-check-name name force))
	(args (list "-m" msg name rev)))

    (when force (setq args (cons "-f" args)))

    (setq args (if (stringp gpg-uid) (nconc (list "-u" gpg-uid) args) (cons "-s" args)))
    (egg-async-1-args (list #'egg--async-create-signed-tag-handler buffer-to-update name rev)
		      (cons "tag" args))))

(defsubst egg-log-buffer-do-tag-commit (name rev force &optional msg)
  (egg--buffer-do-create-tag name rev nil msg force 'log))

(defsubst egg-status-buffer-do-tag-HEAD (name force &optional msg)
  (egg--buffer-do-create-tag name "HEAD" nil msg force 'status))

(defsubst egg-edit-buffer-do-create-tag (name rev beg end force)
  (egg--buffer-do-create-tag name rev (cons beg end) nil force))

(defun egg--buffer-handle-result (result &optional take-next-action ignored-action only-action)
  "Handle the structure returned by the egg--git-xxxxx-cmd functions.
RESULT is the returned value of those functions. Proceed to the next logical action
if TAKE-NEXT-ACTION is non-nil unless the next action is IGNORED-ACTION.
if ONLY-ACTION is non-nil then only perform the next action if it's the same
as ONLY-ACTION.

See documentation of `egg--git-action-cmd-doc' for structure of RESULT."
  (let ((ok (plist-get result :success))
	(next-action (plist-get result :next-action)))
    (egg-revert-visited-files (plist-get result :files))
    (when (and ok take-next-action)
      (egg-call-next-action next-action ignored-action only-action))
    ok))

(defun egg--buffer-handle-result-with-commit (result commit-args 
						     &optional take-next-action
						     ignored-action only-action)
  "Handle the structure returned by the egg--git-xxxxx-cmd functions.
RESULT is the returned value of those functions. Proceed to the next logical action
if TAKE-NEXT-ACTION is non-nil unless the next action is IGNORED-ACTION.
if ONLY-ACTION is non-nil then only perform the next action if it's the same
as ONLY-ACTION.

See documentation of `egg--git-action-cmd-doc' for structure of RESULT."
  (let ((ok (plist-get result :success))
	(next-action (plist-get result :next-action)))
    (egg-revert-visited-files (plist-get result :files))
    (when (and ok take-next-action)
      (if (eq next-action 'commit)
	  (apply #'egg-commit-log-edit commit-args)
	(egg-call-next-action next-action ignored-action only-action)))
    ok))

(defsubst egg-log-buffer-handle-result (result)
  "Handle the RESULT returned by egg--git-xxxxx-cmd functions.
This function should be used in the log buffer only.

See documentation of `egg--git-action-cmd-doc' for structure of RESULT."
  (egg--buffer-handle-result result t 'log))

(defsubst egg-status-buffer-handle-result (result)
  "Handle the RESULT returned by egg--git-xxxxx-cmd functions.
This function should be used in the status buffer only.

See documentation of `egg--git-action-cmd-doc' for structure of RESULT."
  (egg--buffer-handle-result result t 'status))

(defsubst egg-stash-buffer-handle-result (result)
  "Handle the RESULT returned by egg--git-xxxxx-cmd functions.
This function should be used in the stash buffer only.

See documentation of `egg--git-action-cmd-doc' for structure of RESULT."
  (egg--buffer-handle-result result t 'stash))

(defsubst egg-file-buffer-handle-result (result)
  "Handle the RESULT returned by egg--git-xxxxx-cmd functions.
This function should be used in a file visiting buffer only.

See documentation of `egg--git-action-cmd-doc' for structure of RESULT."

  ;; for file buffer, we only take commit action
  (egg--buffer-handle-result result t nil 'commit))

(defsubst egg-buffer-do-create-branch (name rev force track ignored-action)
  "Create a new branch synchronously when inside an egg special buffer.
NAME is the name of the new branch. REV is the starting point of the branch.
If force is non-nil, then force the creation of new branch even if a branch
NAME already existed. Branch NAME will bet set up to track REV if REV was
a branch and track was non-nil. Take the next logical action unless it's
IGNORED-ACTION."
  (egg--buffer-handle-result
   (egg--git-branch-cmd (egg-get-log-buffer)
			(nconc (if force (list "-f"))
			       (if track (list "--track"))
			       (list name rev))) t ignored-action))

(defsubst egg-log-buffer-do-co-rev (rev &rest args)
  "Checkout REV using ARGS as arguments when in the log buffer."
  (egg-log-buffer-handle-result (egg--git-co-rev-cmd-args t rev args)))

(defsubst egg-status-buffer-do-co-rev (rev &rest args)
  "Checkout REV using ARGS as arguments when in the status buffer."
  (egg-status-buffer-handle-result (egg--git-co-rev-cmd-args t rev args)))
    (define-key map (kbd "n") 'egg-buffer-cmd-navigate-next)
    (define-key map (kbd "p") 'egg-buffer-cmd-navigate-prev)
        (while (re-search-forward (rx line-start
				      (group (= 40 hex-digit)) " "
				      (group (1+ digit)) " "
				      (group (1+ digit)) " "
				      (group (1+ digit)) 
				      line-end)
				  nil t)
	  (put-text-property beg end :navigation commit)
          (when (egg-git-ok t "blame" "-w" "-M" "-C" "--porcelain" "--"
  (interactive "d\nP")
	(egg-do-locate-commit sha1))))
  (put-text-property line-beg (1+ line-end) 'display ""))
  (let ((b (make-marker))
	info)
    (setq info (list name b (- end beg) (- head-end beg)))
    (save-match-data
      (save-excursion
	(goto-char beg)
	(if (re-search-forward "new file mode" head-end t)
	    (setq info (nconc info (list 'newfile))))))
    info))
         (cc-del-no 	11)
         (cc-add-no 	12)
         (del-no 	13)
         (add-no 	14)
         (none-no	15)
                  "diff --git " a ".+ " b "\\(.+\\)\\|"	;1 diff header
                  "\\+\\+<<<<<<< \\(.+\\)\\(?::.+\\)?\\|";8 conflict start
                  "\\+\\+>>>>>>> \\(.+\\)\\(?::.+\\)?\\|";10 conflict end
                  "\\( -.*\\)\\|"			;11 cc-del
                  "\\( \\+.*\\)\\|"			;12 cc-add
                  "\\(-.*\\)\\|"			;13 del
                  "\\(\\+.*\\)\\|"			;14 add
                  "\\( .*\\)"				;15 none
         (hunk-end-re "^\\(?:diff \\|@@\\|\\* \\)")
         (diff-end-re "^\\(?:diff \\|\\* \\)")
         last-diff last-cc current-delta-is tmp pos)
          (cond ((or (match-beginning del-no)
		     (and (match-beginning cc-del-no) (eq current-delta-is 'cc-diff))) ;; del
                ((or (match-beginning add-no)
		     (and (match-beginning cc-add-no) (eq current-delta-is 'cc-diff))) ;; add
                       m-e-x (match-end conf-beg-no)
		       tmp (match-string-no-properties conf-beg-no))
		 (setq pos (egg-safe-search "^++=======" end))
		 (add-text-properties m-b-0 pos (list :conflict-side 'ours
						      :conflict-head tmp))
                 (setq sub-end (egg-safe-search "^++>>>>>>>.+\n" end nil nil t))
		 (egg-delimit-section :conflict (cons sub-beg sub-end) sub-beg sub-end
				      (+ m-b-0 9) conflict-map 'egg-compute-navigation))
                ((match-beginning conf-end-no) ;;++>>>>>>>
                       m-e-x (match-end conf-end-no)
		       tmp (match-string-no-properties conf-end-no))

		 (setq pos (egg-safe-search "^++=======" beg nil t t))
		 (add-text-properties pos (1+ m-e-0) (list :conflict-side 'theirs
						      :conflict-head tmp))

                       head-end (or (egg-safe-search "^\\(@@\\|diff\\)" end) end))
                  sub-beg sub-end m-e-0 diff-map 'egg-compute-navigation)

		 (put-text-property (- sub-end 2) sub-end 'intangible t)		 
		 (setq current-delta-is 'diff))
                       head-end (or (egg-safe-search "^\\(@@@\\|diff\\)" end) end))
                  'egg-compute-navigation)
		 (put-text-property (- sub-end 2) sub-end 'intangible t)
		 (setq current-delta-is 'cc-diff))
                 (egg-decorate-diff-index-line m-b-x m-e-x m-b-0 m-e-0))
  (egg-resolve-merge-with-ediff file))
  (egg--ediff-file-revs file nil nil ":0" "INDEX"))
(defun egg-staged-section-cmd-ediff3 (file &optional ediff2)
  (interactive (list (car (get-text-property (point) :diff)) current-prefix-arg))
  (if ediff2
      (egg--ediff-file-revs file ":0" "INDEX" (egg-branch-or-HEAD) nil)
    (egg--ediff-file-revs file nil nil ":0" "INDEX" (egg-branch-or-HEAD) nil)))

(defvar egg-diff-buffer-info nil
  "Data for the diff buffer.
This is built by `egg-build-diff-info'")
        (diff-info egg-diff-buffer-info))
    (cond ((stringp commit)
	   (egg--commit-do-ediff-file-revs (egg-pretty-short-rev commit) file))
	  ((consp diff-info)
	   (egg--diff-do-ediff-file-revs diff-info file)))))
         (hunk-beg (and hunk-info (+ (nth 1 hunk-info) head-beg)))
         (hunk-end (and hunk-info (+ (nth 2 hunk-info) head-beg)))
         (hunk-ranges (and hunk-info (nth 3 hunk-info))))
    (and hunk-info
	 (list (car diff-info) (car hunk-info) hunk-beg hunk-end hunk-ranges))))
(defun egg-unmerged-conflict-checkout-side (pos)
  "Checkout one side of the conflict at POS."
  (interactive "d")
  (let* ((side (get-text-property pos :conflict-side))
	 (head (get-text-property pos :conflict-head))
	 (file (car (get-text-property pos :diff))))
    (when (y-or-n-p (format "use %s's contents for unmerged file %s? " head file))
      (when (egg-status-buffer-handle-result 
	     (egg--git-co-files-cmd (current-buffer) file (concat "--" (symbol-name side))))
	(when (y-or-n-p (format "stage %s? " file))
	  (egg-status-buffer-handle-result (egg--git-add-cmd (current-buffer) file)))))))

(defun egg-unmerged-conflict-take-side (pos)
  "Interactive resolve conflict at POS."
  (interactive "d")
  (let* ((hunk-info (egg-hunk-info-at pos))
	 (file (and hunk-info (car hunk-info)))
	 (hunk-header (and hunk-info (nth 1 hunk-info)))
	 (hunk-beg (and hunk-info (nth 2 hunk-info)))
	 (hunk-end (and hunk-info (nth 3 hunk-info)))
	 (hunk-ranges (and hunk-info (nth 4 hunk-info)))
	 (line (and hunk-info (egg-hunk-compute-line-no hunk-header hunk-beg hunk-ranges)))
	 (side (get-text-property pos :conflict-side))
	 our-head their-head resolution)
    (save-window-excursion
      (save-excursion
	(with-current-buffer (find-file-noselect file)
	  (select-window (display-buffer (current-buffer)))
	  (let (conf-beg conf-end ours-beg ours-end theirs-beg theirs-end
			 ours theirs conflict bg)
	    (goto-char (point-min))
	    (forward-line (1- line))
	    (if (eq side 'theirs)
		(progn
		  (unless (re-search-backward "^<<<<<<< \\(.+\\)\n" nil t)
		    (error "Failed searching for <<<<<<<"))
		  (setq our-head (match-string-no-properties 1))
		  (setq conf-beg (copy-marker (match-beginning 0) nil))
		  (setq ours-beg (match-end 0))
		  (unless (re-search-forward "^=======\n" nil t)
		    (error "Failed searching for ======="))
		  (setq ours-end (match-beginning 0))
		  (setq theirs-beg (match-end 0))
		  (unless (re-search-forward "^>>>>>>> \\(.+\\)\n")
		    (error "Failed searching for >>>>>>>"))
		  (setq their-head (match-string-no-properties 1))
		  (setq theirs-end (match-beginning 0))
		  (setq conf-end (copy-marker (match-end 0) t)))
	      (unless (re-search-forward "^>>>>>>> \\(.+\\)\n")
		(error "Failed searching for >>>>>>>"))
	      (setq their-head (match-string-no-properties 1))
	      (setq theirs-end (match-beginning 0))
	      (setq conf-end (copy-marker (match-end 0) t))
	      (unless (re-search-backward "^=======\n" nil t)
		(error "Failed searching for ======="))
	      (setq ours-end (match-beginning 0))
	      (setq theirs-beg (match-end 0))
	      (unless (re-search-backward "^<<<<<<< \\(.+\\)\n" nil t)
		(error "Failed searching for <<<<<<<"))
	      (setq our-head (match-string-no-properties 1))
	      (setq ours-beg (match-end 0))
	      (setq conf-beg (copy-marker (match-beginning 0) nil)))
	    (setq ours (buffer-substring-no-properties ours-beg ours-end))
	    (setq theirs (buffer-substring-no-properties theirs-beg theirs-end))
	    (setq conflict (buffer-substring-no-properties conf-beg conf-end))

	    (goto-char conf-beg)
	    (delete-region conf-beg conf-end)
	    (insert (if (eq side 'theirs) theirs ours))
	    (setq bg (make-overlay conf-beg conf-end nil nil t))
	    (overlay-put bg 'face 'egg-add-bg)
	    (setq resolution 
		  (if (y-or-n-p (format "keep %s's delta? " 
					(if (eq side 'theirs) their-head our-head)))
		      side
		    (goto-char conf-beg)
		    (delete-region conf-beg conf-end)
		    (insert (if (eq side 'theirs) ours theirs))
		    (setq bg (move-overlay bg conf-beg conf-end))
		    (if (y-or-n-p (format "keep %s's delta? " 
					  (if (eq side 'theirs) our-head their-head)))
			(if (eq side 'theirs) 'ours 'theirs)
		      nil)))
	    (if resolution
		(basic-save-buffer)
	      (goto-char conf-beg)
	      (delete-region conf-beg conf-end)
	      (insert conflict)
	      (set-buffer-modified-p nil))
	    (delete-overlay bg)))))
    (when resolution
      (egg-buffer-cmd-refresh)
      ;; (when (egg-git-ok nil "diff" "--cc" "--quiet" file)
      ;; 	(when (y-or-n-p (format "no more conflict in %s, stage %s? " file file))
      ;; 	  (egg-status-buffer-handle-result (egg--git-add-cmd (current-buffer) file))))
      )))

(defun egg-hunk-compute-replacement-text (hunk-info)
  (let ((file (nth 0 hunk-info))
	(b-beg (nth 2 hunk-info))
	(b-end (nth 3 hunk-info))
	(ranges (nth 4 hunk-info))
	range
	new-1st-line new-num-lines
	old-1st-line old-num-lines
	hunk-text new-text old-text
	old-ranges new-ranges
	start-c current-prefix current-range)
    (setq range (nth 1 ranges))
    (setq old-1st-line (nth 0 range)
	  old-num-lines (nth 1 range)
	  new-1st-line (nth 2 range)
	  new-num-lines (nth 3 range))
    (setq hunk-text (buffer-substring-no-properties 
		     (save-excursion
		       (goto-char b-beg)
		       (forward-line 1)
		       (point))
		     b-end))
    (with-temp-buffer
      (erase-buffer)
      (insert hunk-text)
      (goto-char (point-min))
      (flush-lines "^\\+")
      (goto-char (point-min))
      (while (not (eobp))
	(delete-char 1)
	(forward-line 1))
      (setq old-text (buffer-string))

      (erase-buffer)
      (insert hunk-text)
      (goto-char (point-min))
      (flush-lines "^-")
      (goto-char (point-min))
      (while (not (eobp))
	(delete-char 1)
	(forward-line 1))
      (setq new-text (buffer-string))

      (erase-buffer)
      (insert hunk-text)
      (goto-char (point-min))
      (setq current-prefix (char-after))
      (while (not (eobp))
	(setq start-c (char-after))
	(delete-char 1)
	(unless (= start-c current-prefix)
	  (cond ((eq current-prefix ?+)
		 (setcdr current-range (1- (point)))
		 (push current-range new-ranges))
		((eq current-prefix ?-)
		 (setcdr current-range (1- (point)))
		 (push current-range old-ranges)))
	  (setq current-range (list (1- (point))))
	  (setq current-prefix start-c))
	(forward-line 1))
      (unless (eq current-prefix ? )
	(cond ((eq current-prefix ?+)
	       (setcdr current-range (1- (point)))
	       (push current-range new-ranges))
	      ((eq current-range ?-)
	       (setcdr current-range (1- (point)))
	       (push current-range old-ranges))))
      (setq hunk-text (buffer-string)))

    (list file
	  (list old-1st-line old-num-lines old-text)
	  (list new-1st-line new-num-lines new-text)
	  (list old-ranges new-ranges hunk-text))))



  "Toggle the hidden state of the current section."
  "Toggle the hidden state of the subsections of the current section."
  "Build a patch string usable as input for git apply.
The patch is built based on the hunk enclosing POS. DIFF-INFO
is the file-level diff information enclosing the hunk. Build a
reversed patch if REVERSE was non-nil."

;; (defun egg-buffer-cmd-refresh ()
;;   "Refresh the current egg special buffer."
;;   (interactive)
;;   (when (and (egg-git-dir)
;;              (functionp egg-buffer-refresh-func))
;;     (funcall egg-buffer-refresh-func (current-buffer))))
  (when (egg-git-dir) 
    (egg-refresh-buffer (current-buffer))))
(defun egg-buffer-cmd-navigate-next (&optional at-level)
  "Move to the next section.
With C-u prefix, move to the next section of the same type."
  (interactive "P")
  (egg-buffer-cmd-next-block
   (if (not at-level) :navigation
     (or (get-text-property (point) :sect-type) :navigation))))
(defun egg-buffer-cmd-navigate-prev (&optional at-level)
  "Move to the previous section.
With C-u prefix, move to the previous section of the same type."
  (interactive "P")
  (egg-buffer-cmd-prev-block 
   (if (not at-level) :navigation
     (or (get-text-property (point) :sect-type) :navigation))))
creat the buffer. FMT is used to construct the buffer name. The name is built
as: (format FMT current-dir-name git-dir-full-path)."
	 (dir (egg-work-tree-dir git-dir))
	 (dir-name (egg-repo-name git-dir))
               (unless (and (not create) (eq major-mode ',buffer-mode-sym))
		   (egg-refresh-buffer buf))))
    (define-key map (kbd "d") 'egg-diff-ref)
    (define-key map (kbd "o") 'egg-status-buffer-checkout-ref)
    (define-key map (kbd "w") 'egg-status-buffer-stash-wip)
    (define-key map (kbd "G") 'egg-status)
    (define-key map (kbd "U") 'egg-unstage-all-files)
    (define-key map (kbd "X") 'egg-status-buffer-undo-wdir)
(defun egg-buffer-do-rebase (upstream-or-action &optional onto current-action)
  (let ((rebase-dir (plist-get (egg-repo-state :rebase-dir) :rebase-dir))
	(git-dir (egg-git-dir))
        res)
          (egg-status nil nil)
      (unless rebase-dir
               (egg-work-tree-dir git-dir))))
    (egg-do-rebase-head upstream-or-action onto current-action)))
  (egg-buffer-do-rebase :continue nil
			(cdr (assq major-mode '((egg-status-buffer-mode . status)
						(egg-log-buffer-mode . log))))))
  (let ((process-environment (copy-sequence process-environment))
      (egg-buffer-do-rebase action nil 
			    (cdr (assq major-mode '((egg-status-buffer-mode . status)
						    (egg-log-buffer-mode . log)))))
    (with-egg-debug-buffer
      (egg-do-async-rebase-continue
       #'egg-handle-rebase-interactive-exit
       (egg-pick-file-contents (concat (egg-git-rebase-dir) "head-name") "^.+$")
       action))))
  (egg-buffer-do-rebase :abort  nil
			(cdr (assq major-mode '((egg-status-buffer-mode . status)
						(egg-log-buffer-mode . log))))))
(defvar egg-status-buffer-changed-files-status nil)
	 (rebase-stopped-sha (plist-get state :rebase-stopped))
      (insert (format "Rebase: commit %s of %s" rebase-step rebase-num))
      (when rebase-stopped-sha
	(insert " (" (egg-git-to-string "log" "--no-walk" "--pretty=%h:%s" 
					rebase-stopped-sha)
		")"))
      (insert "\n")
      (insert egg-status-buffer-diff-help-text)
      (insert egg-stash-help-text))
    (put-text-property (- (point) 2) (point) 'intangible t)
  "Add an ignore pattern based on the string at point."
(defun egg-status-buffer-stage-untracked-file (&optional no-stage)
untracked files. If NO-STAGE, then only create the index entries without
adding the contents."
  (interactive "P")
  (let ((files (if mark-active
		   (progn
		     (if (< (point) (mark))
			 (progn
			   (goto-char (line-beginning-position))
			   (exchange-point-and-mark)
			   (goto-char (line-end-position)))
		       (progn
			 (goto-char (line-end-position))
			 (exchange-point-and-mark)
			 (goto-char (line-beginning-position))))
		     (split-string
		      (buffer-substring-no-properties (point) (mark)) "\n" t))
		 (list (buffer-substring-no-properties
			(line-beginning-position) (line-end-position)))))
	args files-string)
    (setq files (delete "" files))
    (setq files (delete nil files))
    (if (consp files)
	(setq files-string (mapconcat 'identity files ", "))
      (error "No file to stage!"))
    (setq args (nconc (list "-v" "--") files))
    (if no-stage
	(setq args (cons "-N" args)))
    
    (when (apply 'egg--git-add-cmd (current-buffer) args)
      (message "%s %s to git." (if no-stage "registered" "added") files-string))))

    (put-text-property (1+ inv-beg) end 'help-echo (egg-tooltip-func))

    (put-text-property (- end 2) end 'intangible t)))

(defun egg-sb-buffer-show-stash (pos)
  "Load the details of the stash at POS."
  (interactive "d")
  (let* ((next (next-single-property-change pos :diff))
         (stash (and next (get-text-property next :stash))))
    (unless (equal (get-text-property pos :stash) stash)
      (egg-buffer-do-insert-stash pos))))


(defun egg-decorate-stash-list (start line-map section-prefix)
  (let (stash-beg stash-end beg end msg-beg msg-end name msg)
    (save-excursion
      (goto-char start)
      (while (re-search-forward "^\\(stash@{[0-9]+}\\): +\\(.+\\)$" nil t)
        (setq beg (match-beginning 0)
              stash-end (match-end 1)
              msg-beg (match-beginning 2)
              end (match-end 0))

        (setq name (buffer-substring-no-properties beg stash-end)
              msg (buffer-substring-no-properties msg-beg end))

        ;; entire line
        (add-text-properties beg (1+ end)
                             (list :navigation (concat section-prefix name)
                                   :stash name
                                   'keymap line-map))

        ;; comment
        (put-text-property beg stash-end 'face 'egg-stash-mono)
        (put-text-property msg-beg end 'face 'egg-text-2)))))

(defun egg-sb-insert-stash-section ()
  (let ((beg (point)) inv-beg stash-beg end)
    (insert (egg-prepend "Stashed WIPs:" "\n\n"
                         'face 'egg-section-title
                         'help-echo (egg-tooltip-func))
            "\n")
    (setq inv-beg (1- (point)))
    (setq stash-beg (point))
    (egg-list-stash)
    (setq end (point))
    (egg-delimit-section :section 'stash beg end
                         inv-beg egg-section-map 'stash)
    (egg-decorate-stash-list stash-beg egg-stash-map "stash-")
    (put-text-property (- end 2) end 'intangible t)
    ;;(put-text-property (1+ inv-beg) end 'help-echo (egg-tooltip-func))
    ))

(defun egg-sb-decorate-unmerged-entries-in-section (beg end sect-type)
  (save-excursion
    (goto-char beg)
    (let (status tmp path)
      (save-match-data
	(while (re-search-forward (rx line-start "* Unmerged path " 
				      (group (1+ not-newline)) line-end)
				  end t)
	  (setq path (match-string-no-properties 1))
	  (setq tmp (propertize (concat "\n" (substring path 0 1))
				'face 'egg-unmerged-diff-file-header))
	  (add-text-properties (match-beginning 0) (1+ (match-beginning 1))
			       (list 'display tmp 'intangible t))
	  (put-text-property (1+ (match-beginning 1)) (match-end 1)
			     'face 'egg-unmerged-diff-file-header)

	  (setq status (assoc path egg-status-buffer-changed-files-status))
	  (when status
	    (egg-delimit-section sect-type status
				 (match-beginning 0) (match-end 0) nil nil
				 #'egg-compute-navigation)
	    (put-text-property (match-beginning 0) (match-end 0)
			       'keymap (if (eq sect-type :merged) 
					   egg-unmerged-index-file-map
					 egg-unmerged-wdir-file-map))
	    (setq tmp (buffer-substring-no-properties (match-end 0) (1+ (match-end 0))))
	    (setq tmp (concat (cond ((memq :we-deleted status) ": deleted by us")
				    ((memq :they-deleted status) ":  deleted by them")
				    ((memq :both-deleted status) ":  deleted by both")
				    ((memq :both-modified status) ":  modified by both, please resolve in worktree")
				    ((memq :we-added status) ":  added by us, please resolve in worktree")
				    ((memq :they-added status) ":  added by them, please resolve in worktree")
				    ((memq :both-added status) ":  added by both, please reolsve in worktree")
				    (t "")) tmp))
	    
	    (put-text-property (match-end 0) (1+ (match-end 0)) 'display tmp)))))))
  (let ((beg (point)) inv-beg diff-beg end path tmp status)
           (append egg-git-diff-options extra-diff-options))
    (setq end (point))
                               :conflict-map egg-unmerged-conflict-map)
    (egg-sb-decorate-unmerged-entries-in-section diff-beg end :unmerged)
    (put-text-property (- end 2) end 'intangible t)))
  (let ((beg (point)) inv-beg diff-beg end)
    (put-text-property (- beg 2) beg 'intangible t)
           (append egg-git-diff-options extra-diff-options))
    (setq end (point))
                               :hunk-map egg-staged-hunk-section-map)
    (egg-sb-decorate-unmerged-entries-in-section diff-beg end :merged)
    (put-text-property (- end 2) end 'intangible t)))
                                     (copy-sequence range)
                                     (copy-sequence range)))
(defun egg-unmerged-file-del-action (pos)
  (interactive "d")
  (let* ((status (or (get-text-property pos :unmerged) (get-text-property pos :merged)))
	 (file (and status (car status))))
    (unless (or (memq :we-deleted status) (memq :they-deleted status) (memq :both-deleted status))
      (error "don't know how to handle status %S" status))
    (if (y-or-n-p (format "delete file %s?" file))
	(egg-status-buffer-handle-result (egg--git-rm-cmd (current-buffer) file))
      (if (y-or-n-p (format "keep file %s alive?" file))
	  (egg-status-buffer-handle-result (egg--git-add-cmd (current-buffer) file))
	(message "deleted file %s is still unmerged!" file)))))

(defun egg-unmerged-file-add-action (pos)
  (interactive "d")
  (let* ((status (or (get-text-property pos :unmerged) (get-text-property pos :merged)))
	 (file (and status (car status))))
    (unless (or (memq :we-added status) (memq :they-added status) (memq :both-added status))
      (error "don't know how to handle status %S" status))
    (if (y-or-n-p (format "add file %s?" file))
	(egg-status-buffer-handle-result (egg--git-add-cmd (current-buffer) file))
      (if (y-or-n-p (format "delete file %s" file))
	  (egg-status-buffer-handle-result (egg--git-rm-cmd (current-buffer) file))
	(message "added file %s is still unmerged!" file)))))

(defun egg-unmerged-file-checkout-action (pos)
  (interactive "d")
  (let* ((status (get-text-property pos :merged))
	 (file (and status (car status))))
    (unless (memq :unmerged status)
      (error "don't know how to handle status %S" status))
    (when (y-or-n-p (format "undo all merge results in %s? " file))
      (egg-status-buffer-handle-result (egg--git-co-files-cmd (current-buffer) file "-m")))))

(defun egg-unmerged-file-ediff-action (pos)
  (interactive "d")  
  (let* ((status (or (get-text-property pos :unmerged) (get-text-property pos :merged)))
	 (file (and status (car status))))
    (unless (memq :unmerged status)
      (error "don't know how to handle status %S" status))
    (egg-resolve-merge-with-ediff file)))

(defun egg-unmerged-wdir-file-next-action (pos)
  (interactive "d")
  (let* ((status (get-text-property pos :unmerged))
	 (file (and status (car status))))
    (unless (memq :unmerged status)
      (error "don't know how to handle status %S" status))
    (cond ((or (memq :we-added status) (memq :they-added status) (memq :both-added status))
	   (egg-unmerged-file-add-action pos))
	  ((or (memq :we-deleted status) (memq :they-deleted status) (memq :both-deleted status))
	   (egg-unmerged-file-del-action pos))
	  ((memq :both-modified status)
	   (egg-unmerged-file-ediff-action pos))
	  (t (message "don't know how to handle status %S" status)))))

(defun egg-unmerged-index-file-next-action (pos)
  (interactive "d")
  (let* ((status (get-text-property pos :merged))
	 (file (and status (car status))))
    (unless (memq :unmerged status)
      (error "don't know how to handle status %S" status))
    (cond ((or (memq :we-deleted status) (memq :they-deleted status) (memq :both-deleted status))
	   (egg-unmerged-file-del-action pos))
	  ((memq :both-modified status)
	   (egg-unmerged-file-ediff-action pos))
	  (t (message "don't know how to handle status %S" status)))))

(defun egg-status-buffer-checkout-ref (&optional force name)
  "Prompt a revision to checkout. Default is name."
  (interactive (list current-prefix-arg (egg-ref-at-point)))
  (setq name (egg-read-local-ref "checkout (branch or tag): " name))
  (if force 
      (egg-status-buffer-do-co-rev name "-f")
    (egg-status-buffer-do-co-rev name)))

(defun egg-buffer-hide-all (&optional show-all)
  "Hide all sections in current special egg buffer."
  (interactive "P")
  (if show-all
      (setq buffer-invisibility-spec nil) ;; show all
    (let ((pos (point-min)) nav)
      (while (setq pos (next-single-property-change (1+ pos) :navigation))
	(setq nav (get-text-property pos :navigation))
	(add-to-invisibility-spec (cons nav t)))))
  (if (invoked-interactively-p)
      (force-window-update (current-buffer))))
  "UnHide all hidden sections in the current special egg buffer."

(defsubst egg-buffer-hide-section-type (sect-type &optional beg end)
  (let ((pos (or beg (point-min)))
	(end (or end (point-max))) 
	nav)
    (while (and (setq pos (next-single-property-change (1+ pos) sect-type))
		(< pos end))
         (state (egg-repo-state))
          (win (get-buffer-window buf))
         pos)

      (set (make-local-variable 'egg-status-buffer-changed-files-status)
          (egg--get-status-code))
      ;; Emacs tries to be too smart, if we erase and re-fill the buffer
                ((eq sect 'unstaged) 
                (egg-sb-insert-unstaged-section (if (egg-is-merging state)
                                                    "Unmerged Changes:"
                                                  "Unstaged Changes:"))
                (setq pos (point)))
                ((eq sect 'staged) (egg-sb-insert-staged-section 
                                   (if (egg-is-merging state)
                                       "Merged Changes:"
				      "Staged Changes:")))
                ((eq sect 'untracked) (egg-sb-insert-untracked-section))
		((eq sect 'stash) (egg-sb-insert-stash-section))))
	(if init
	    (progn
             (egg-buffer-maybe-hide-all)
             (egg-buffer-maybe-hide-help "help" 'repo))
         (egg-restore-section-visibility))
       (goto-char pos)
       (goto-char (egg-previous-non-hidden (point)))
(defun egg-internal-background-jobs-restart ()
  :set #'egg-set-background-idle-period

(defun egg-status-buffer-background-job ()
  (when egg-refresh-index-in-backround
    (mapcar #'egg-internal-background-refresh-index
            egg-internal-status-buffer-names-list)))

                                      :visble '(and (egg-diff-at-point) 
						    (not (egg-hunk-at-point)))))
				       egg-stage-all-files
				       :enable (egg-wdir-dirty)))
  (define-key menu [unstage] '(menu-item "UnStage All Staged Modifications"
					 egg-unstage-all-files
					 :enable (egg-staged-changes)))
(defvar egg-switch-to-buffer nil
  "Set to nonnil for egg-status to switch to the status buffer in the same window.")

(defun egg-status (called-interactively select &optional caller)
  "Show the status of the current repo."
  (interactive "p\nP")
         (buf (egg-get-status-buffer 'create))
	 (select (if called-interactively ;; only do this for commands
		     (if egg-cmd-select-special-buffer 
			 (not select)	;; select by default (select=nil), C-u not select
		       select)		;; not select by default (select=nil), C-u select
		   select)))
          (select (pop-to-buffer buf))
          (called-interactively (display-buffer buf))
          (t (display-buffer buf)))))
  "Revert the buffers of FILE-OR-FILES.
FILE-OR-FILES can be a string or a list of strings.
Each string should be a file name relative to the work tree."
         (default-directory (egg-work-tree-dir git-dir))
         (files (if (listp file-or-files)
         (default-directory (egg-work-tree-dir git-dir))
(defun egg-hunk-section-apply-cmd (pos &rest args)
  "Apply using git apply with ARGS as arguments.
The patch (input to git apply) will be built based on the hunk enclosing
POS."
  (let ((patch (egg-hunk-section-patch-string pos (member "--reverse" args)))
        (file (car (get-text-property pos :diff)))
	res)
    (setq res (egg--git-apply-cmd t patch args))
    (unless (member "--cached" args)
      (egg-revert-visited-files (plist-get res :files)))
    (plist-get res :success)))

(defun egg-show-applied-hunk-in-buffer (buf before after
					    hunk-text b-ranges a-ranges
					    question yes no)
  (let ((inhibit-read-only t)
	(before-1st-line (nth 0 before))
	(before-num-lines (nth 1 before))
	(before-text (nth 2 before))
	(after-text (nth 2 after))
	beg end bg answer)
    (with-current-buffer buf
      (goto-char (point-min))
      (forward-line (1- before-1st-line))
      (setq beg (point))
      (setq end (save-excursion (forward-line before-num-lines) (point)))
      (delete-region beg end)
      (goto-char beg)
      (insert hunk-text)
      (setq end (point))
      
      (dolist (range b-ranges)
	(setq bg (make-overlay (+ (car range) beg) (+ (cdr range) beg) nil nil t))
	(overlay-put bg 'face 'egg-del-bg)
	(overlay-put bg 'evaporate t))

      (dolist (range a-ranges)
	(setq bg (make-overlay (+ (car range) beg) (+ (cdr range) beg) nil nil t))
	(overlay-put bg 'face 'egg-add-bg)
	(overlay-put bg 'evaporate t)))

    (with-selected-window (display-buffer buf t)
      (goto-char beg)
      (recenter)
      (setq answer (y-or-n-p question))
      (bury-buffer buf))

    (with-current-buffer buf
      (goto-char beg)
      (delete-region beg end)
      (if answer
	  (cond ((eq yes :cleanup)
		 (set-buffer-modified-p nil))
		((eq yes :kill)
		 (kill-buffer buf))
		((eq yes :save)
		 (insert after-text)
		 (basic-save-buffer))
		(t nil))
	(cond ((eq no :cleanup)
	       (set-buffer-modified-p nil))
	      ((eq no :kill)
	       (kill-buffer buf))
	      ((eq no :restore)
	       (insert before-text)
	       (set-buffer-modified-p nil))
	      (t nil)))
      answer)))

(defun egg-hunk-section-show-n-ask-staging (pos)
  (let* ((hunk (egg-hunk-info-at pos))
	 (info (egg-hunk-compute-replacement-text hunk))
	 (file (car info))
	 (index (nth 1 info))
	 (worktree (nth 2 info))
	 (hunk-ranges-n-text (nth 3 info))
	 (hunk-text (nth 2 hunk-ranges-n-text))
	 (index-ranges (nth 0 hunk-ranges-n-text))
	 (worktree-ranges (nth 1 hunk-ranges-n-text))
	 (buf (egg-file-get-other-version file ":0" nil t)))
    (if (egg-show-applied-hunk-in-buffer buf index worktree
					 hunk-text index-ranges worktree-ranges
					 (format "update Index's %s as shown? " file)
					 :kill :kill)
	t
      (message "Cancel staging %s's hunk %s" file (nth 1 hunk))
      nil)))

(defun egg-hunk-section-show-n-ask-unstaging (pos)
  (let* ((hunk (egg-hunk-info-at pos))
	 (info (egg-hunk-compute-replacement-text hunk))
	 (file (car info))
	 (head (nth 1 info))
	 (index (nth 2 info))
	 (hunk-ranges-n-text (nth 3 info))
	 (hunk-text (nth 2 hunk-ranges-n-text))
	 (head-ranges (nth 0 hunk-ranges-n-text))
	 (index-ranges (nth 1 hunk-ranges-n-text))
	 (buf (egg-file-get-other-version file ":0" nil t)))
    (if (egg-show-applied-hunk-in-buffer buf index head
					 hunk-text index-ranges head-ranges
					 (format "restore Index's %s as shown? " file)
					 :kill :kill)
	t
      (message "Cancel unstaging %s's hunk %s" file (nth 1 hunk))
      nil)))

(defun egg-sb-relocate-hunk (hunk-info)
  (let* ((file (nth 0 hunk-info))
	 (ranges (nth 4 hunk-info))
	 (before-type (nth 0 ranges))
	 (type (cond ((eq before-type 'staged) 'unstaged)
		     ((eq before-type 'unstaged) 'staged)
		     (t before-type)))
	 (range (nth 3 ranges))
	 (pos (point-min))
	 hunk found)
    (while (and (not found)
		(setq pos (next-single-property-change (1+ pos) :hunk)))
      (when (and (setq hunk (egg-hunk-info-at pos))
		 (equal (car hunk) file)
		 (equal (car (nth 4 hunk)) type)
		 (equal (nth 3 (nth 4 hunk)) range))
	(setq found pos)))
    (unless (or found (eq type before-type))
      (setq type before-type)
      (setq pos (point-min))
      (while (and (not found)
		  (setq pos (next-single-property-change (1+ pos) :hunk)))
	(when (and (setq hunk (egg-hunk-info-at pos))
		   (equal (car hunk) file)
		   (equal (car (nth 4 hunk)) type)
		   (equal (nth 3 (nth 4 hunk)) range))
	  (setq found pos))))
    (when found
      (goto-char found))))


(defmacro with-current-hunk (pos &rest body)
  "remember the hunk at POS, eval BODY then relocate the moved hunk."
  (declare (indent 1) (debug t))
  (let ((hunk-info (make-symbol "hunk-info")))
    `(let ((,hunk-info (egg-hunk-info-at ,pos)))
       ,@body
       (egg-sb-relocate-hunk ,hunk-info))))
  "Add the hunk enclosing POS to the index."
  (interactive "d")
  (when (or (not egg-confirm-staging) 
	    (egg-hunk-section-show-n-ask-staging pos))
    (with-current-hunk pos
      (egg-hunk-section-apply-cmd pos "--cached"))))
  "Remove the hunk enclosing POS from the index."
  (interactive "d")
  (when (or (not egg-confirm-staging) 
	    (egg-hunk-section-show-n-ask-unstaging pos))
    (with-current-hunk pos
      (egg-hunk-section-apply-cmd pos "--cached" "--reverse"))))


(defun egg-hunk-section-show-n-undo (pos)
  (let* ((hunk (egg-hunk-info-at pos))
	 (info (egg-hunk-compute-replacement-text hunk))
	 (file (car info))
	 (new (nth 2 info))
	 (old (nth 1 info))
	 (hunk-ranges-n-text (nth 3 info))
	 (buf (find-file-noselect file)) bg res)
    (if (egg-show-applied-hunk-in-buffer buf new old
					 (nth 2 hunk-ranges-n-text)
					 (nth 1 hunk-ranges-n-text)
					 (nth 0 hunk-ranges-n-text)
					 (format "restore %s's text as shown? " file)
					 :save :restore)
	(egg-refresh-buffer (current-buffer))
      (message "Cancel undo %s's hunk %s!" file (nth 1 hunk)))))


(defun egg-sb-relocate-diff-file (diff-info)
  (let ((file (car diff-info))
	(marker (nth 1 diff-info))
	(pos (point-min))
	diff found)
    (while (and (not found)
		(setq pos (next-single-property-change (1+ pos) :diff)))
      (when (and (setq diff (get-text-property pos :diff))
		 (equal (car diff) file))
	(setq found (nth 1 diff))))
    (when found
      (goto-char found))))

(defmacro with-current-diff (pos &rest body)
  "remember the diff at POS, eval BODY then relocate the moved diff."
  (declare (indent 1) (debug t))
  (let ((diff-info (make-symbol "diff-info")))
    `(let ((,diff-info (get-text-property ,pos :diff)))
       ,@body
       (egg-sb-relocate-diff-file ,diff-info))))
  "Remove the file's modification described by the hunk enclosing POS."
  (interactive "d")
  (cond ((null egg-confirm-undo)
	 (egg-hunk-section-apply-cmd pos "-p1" "--reverse"))
	((eq egg-confirm-undo 'prompt)
	 (if (y-or-n-p "irreversibly remove the hunk under cursor? ")
	     (egg-hunk-section-apply-cmd pos "-p1" "--reverse")
	   (message "Too chicken to proceed with undo operation!")))
	((eq egg-confirm-undo 'show)
	 (egg-hunk-section-show-n-undo pos))))
  "Update the index with the file at POS.
If the file was delete in the workdir then remove it from the index."
  (interactive "d")
    (cond ((not (stringp file))
	   (error "No diff with file-name here!"))
	  ((file-exists-p file)
	   ;; add file to index, nothing change in wdir
	   ;; diff and status buffers must be updated
	   ;; just update them all
	   (with-current-diff pos
	     (egg--git-add-cmd t "-v" file)))
	  (t ;; file is deleted, update the index
	   (egg--git-rm-cmd t file)))))
  "For the file at POS, revert its stage in the index to original.
If the file was a newly created file, it will be removed from the index.
If the file was added after a merge resolution, it will reverted back to
conflicted state. Otherwise, its stage will be reset to HEAD."
  (interactive "d")
  (let ((is-merging (egg-is-merging (egg-repo-state)))
	(diff-info (get-text-property pos :diff))
	file newfile)
    (setq newfile (memq 'newfile diff-info)
	  file (car diff-info))
    (cond (newfile (egg--git-rm-cmd t "--cached" file))
	  (is-merging (with-current-diff pos
			  (egg--git-co-files-cmd t file "-m")))
	  (t (with-current-diff pos
	       (egg--git-reset-files-cmd t nil file))))))
  "For the file at POS, remove its differences vs the source revision.
Usually, this command revert the file to its staged state in the index. However,
in a diff special egg buffer, it can change the file's contents to the one of
the source revision."
  (interactive "d")
        (src-rev (get-text-property pos :src-revision)))
    
    (egg-revert-visited-files 
     (plist-get (cond ((stringp src-rev)
		       (egg--git-co-files-cmd t file src-rev))
		      ((consp src-rev)
		       (egg--git-co-files-cmd 
			t file (egg-git-to-string "merge-base" 
						  (car src-rev) (cdr src-rev))))
		      (t (egg--git-co-files-cmd t file)))
		:files))))

(defun egg-diff-section-cmd-revert-to-head (pos)
  "Revert the file and its slot in the index to its state in HEAD."
  (interactive "d")
  (let ((file (car (or (get-text-property pos :diff)
                       (error "No diff with file-name here!")))))
    (unless (or (not egg-confirm-undo)
		(y-or-n-p (format "irreversibly revert %s to HEAD? " file)))
      (error "Too chicken to proceed with reset operation!"))
    (egg-revert-visited-files 
     (plist-get (egg--git-co-files-cmd t file "HEAD") :files))))
  "Add the current's file contents into the index."
  (let* ((short-file (file-name-nondirectory (buffer-file-name)))
	 (egg--do-no-output-message (format "staged %s's modifications" short-file)))
    (egg-file-buffer-handle-result (egg--git-add-cmd (egg-get-status-buffer) "-v" 
						     (buffer-file-name)))))
  "Stage all tracked files in the repository."
  (let ((default-directory (egg-work-tree-dir))
	(egg--do-no-output-message "staged all tracked files's modifications"))
    (egg-file-buffer-handle-result (egg--git-add-cmd (egg-get-status-buffer) "-v" "-u"))))

(defsubst egg-log-buffer-do-move-head (reset-mode rev)
  (egg-buffer-do-move-head reset-mode rev 'log))

(defsubst egg-status-buffer-do-move-head (reset-mode rev)
  (egg-buffer-do-move-head reset-mode rev 'status))

(defun egg-unstage-all-files ()
  "Unstage all files in the index."
  (interactive)
  (let ((default-directory (egg-work-tree-dir)))
    (when (egg-status-buffer-do-move-head "--mixed" "HEAD")
      (message "unstaged all modfications in INDEX"))))

(defun egg-sb-undo-wdir-back-to-index (really-do-it take-next-action ignored-action)
  "When in the status buffer, reset the work-tree to the state in the index.
When called interactively, do nothing unless REALLY-DO-IT is non-nil.
Take the next logical action if TAKE-NEXT-ACTION is non-nil unless the
next action is IGNORED-ACTION."
  (interactive (list (or current-prefix-arg
			 (y-or-n-p "throw away all unstaged modifications? "))
		     t nil))
  (when really-do-it
    (let ((default-directory (egg-work-tree-dir))
	  (egg--do-no-output-message "reverted work-dir to INDEX"))
      (egg-status-buffer-do-co-rev :0 "-f" "-a"))))

(defun egg-sb-undo-wdir-back-to-HEAD (really-do-it take-next-action ignored-action)
  "When in the status buffer, reset the work-tree and the index to HEAD.
When called interactively, do nothing unless REALLY-DO-IT is non-nil.
Take the next logical action if TAKE-NEXT-ACTION is non-nil unless the
next action is IGNORED-ACTION."
  (interactive (list (y-or-n-p "throw away all (staged and unstaged) modifications? ")))
  (when really-do-it
    (let ((default-directory (egg-work-tree-dir)))
      (egg-status-buffer-do-move-head "--hard" "HEAD"))))

(defun egg-status-buffer-undo-wdir (harder)
  "When in the status buffer, throw away local modifications in the work-tree.
if HARDER is non-nil (prefixed with C-u), reset the work-tree to its state
in HEAD. Otherwise, reset the work-tree to its staged state in the index."
  (interactive "P")
  (funcall (if harder
	       #'egg-sb-undo-wdir-back-to-HEAD
	     #'egg-sb-undo-wdir-back-to-index) 
	   (y-or-n-p (format "throw away ALL %s modifications? " 
			     (if harder "(staged AND unstaged)" "unstaged")))
	   t 'status))
  "Add all untracked files to the index."
  (let ((default-directory (egg-work-tree-dir))
	(egg--do-git-quiet t))
    (when (egg--git-add-cmd t "-v" ".")
(defun egg-buffer-do-move-head (reset-mode rev &optional ignored-action)
  "Move (reset) HEAD to REV using RESET-MODE.
REV should be a valid git rev (branch, tag, commit,...)
RESET-MODE should be a valid reset option such as --hard.
The command usually takes the next action recommended by the results, but
if the next action is IGNORED-ACTION then it won't be taken."
  (let* ((egg--do-no-output-message 
	  (format "detached %s and re-attached on %s" 
		  (egg-branch-or-HEAD) rev))
	 (res (egg--git-reset-cmd t reset-mode rev)))
    (egg--buffer-handle-result res t ignored-action)
    (plist-get res :success)))
(defun egg-buffer-do-merge-to-head (rev &optional merge-mode-flag msg ignored-action)
  "Merge REV to HEAD.
REV should be a valid git rev (branch, tag, commit,...)
MERGE-MODE should be a valid reset option such as --ff-only.
MSG will be used for the merge commit.
Thecommand  usually take the next action recommended by the results, but
if the next action is IGNORED-ACTION then it won't be taken."
  (let ((msg (or msg (concat "merging in " rev)))
        merge-cmd-ok res modified-files options
	need-commit force-commit-to-status line fix-line-func)

    (setq modified-files (egg-git-to-lines "diff" "--name-only" rev))
    (cond ((equal merge-mode-flag "--commit")
	   (setq options egg-git-merge-strategy-options)
	   (setq need-commit t)
	   (setq merge-mode-flag "--no-commit")
	   (setq fix-line-func
		 (lambda (merge-res)
		   (let (line)
		     (when (and (plist-get merge-res :success)
				(setq line (plist-get merge-res :line)))
		       (save-match-data
			 (when (string-match "stopped before committing as requested" line)
			   (setq line 
				 "Auto-merge went well, please prepare the merge message")
			   (plist-put merge-res :line line)))))
		   merge-res)))
	  ((member merge-mode-flag '("--no-commit" "--squash"))
	   (setq options egg-git-merge-strategy-options)
	   (setq force-commit-to-status t)))

    (setq res (nconc (egg--git-merge-cmd-args 'all fix-line-func
					      (append (cons merge-mode-flag options)
						      (list "--log" rev)))
		     (list :files modified-files)))
    (if need-commit
	(egg--buffer-handle-result-with-commit
	 res (list (concat (egg-text "Merge in:  " 'egg-text-3)
			   (egg-text rev 'egg-branch))
		   (egg-log-msg-mk-closure-input #'egg-log-msg-commit)
		   msg)
	 t ignored-action)
      (when (and (eq (plist-get res :next-action) 'commit)
		 force-commit-to-status)
	(plist-put res :next-action 'status))
      (egg--buffer-handle-result res t ignored-action))))

(defsubst egg-log-buffer-do-merge-to-head (rev &optional merge-mode-flag)
  "Merge REV to HEAD when the log special buffer.
see `egg-buffer-do-merge-to-head'."
  (egg-buffer-do-merge-to-head rev merge-mode-flag nil 'log))

(defun egg-do-rebase-head (upstream-or-action &optional onto current-action)
  "Rebase HEAD based on UPSTREAM-OR-ACTION.
If UPSTREAM-OR-ACTION is a string then it used as upstream for the rebase operation.
If ONTO is non-nil, then rebase HEAD onto ONTO using UPSTREAM-OR-ACTION as upstream.
If UPSTREAM-OR-ACTION is one of: :abort, :skip and :continue then
perform the indicated rebase action."
    (with-egg-debug-buffer
      (unless (eq upstream-or-action :abort) ;; keep for debugging
	(erase-buffer))
      
            (cond ((and (stringp onto) (stringp upstream-or-action))
		   (egg--git-rebase-merge-cmd-args 
		    t nil (append egg-git-merge-strategy-options
				  (list "-m" "--onto" onto upstream-or-action))))
                   (egg--git-rebase-merge-cmd t nil "--abort"))
                   (egg--git-rebase-merge-cmd t nil "--skip"))
                   (egg--git-rebase-merge-cmd t nil "--continue"))
                   (egg--git-rebase-merge-cmd-args
		    t nil (append egg-git-merge-strategy-options
				  (list "-m" upstream-or-action))))))
      (setq modified-files (egg-git-to-lines "diff" "--name-only" pre-merge))
      (when (consp cmd-res) (plist-put cmd-res :files modified-files))
      (egg--buffer-handle-result cmd-res t current-action))))

(defvar egg-log-msg-closure nil 
  "Closure for be called when done composing a message.
It must be a local variable in the msg buffer. It's a list
in the form (func arg1 arg2 arg3...).

func should be a function expecting the following args:
PREFIX-LEVEL the prefix argument converted to a number.
BEG a marker for the beginning of the composed text.
END a marker for the end of the composed text.
NEXT-BEG is a marker for the beginnning the next section.
ARG1 ARG2 ARG3... are the items composing the closure
when the buffer was created.")

(defsubst egg-log-msg-func () (car egg-log-msg-closure))
(defsubst egg-log-msg-args () (cdr egg-log-msg-closure))
(defsubst egg-log-msg-prefix () (nth 0 (egg-log-msg-args)))
(defsubst egg-log-msg-gpg-uid () (nth 1 (egg-log-msg-args)))
(defsubst egg-log-msg-text-beg () (nth 2 (egg-log-msg-args)))
(defsubst egg-log-msg-text-end () (nth 3 (egg-log-msg-args)))
(defsubst egg-log-msg-next-beg () (nth 4 (egg-log-msg-args)))
(defsubst egg-log-msg-extras () (nthcdr 5 (egg-log-msg-args)))
(defsubst egg-log-msg-set-prefix (prefix) (setcar (egg-log-msg-args) prefix))
(defsubst egg-log-msg-set-gpg-uid (uid) (setcar (cdr (egg-log-msg-args)) uid))
(defsubst egg-log-msg-mk-closure-input (func &rest args)
  (cons func args))
(defsubst egg-log-msg-mk-closure-from-input (input gpg-uid prefix beg end next)
  (cons (car input) (nconc (list prefix gpg-uid beg end next) (cdr input))))
(defsubst egg-log-msg-apply-closure (prefix) 
  (egg-log-msg-set-prefix prefix)
  (apply (egg-log-msg-func) (egg-log-msg-args)))


  (setq default-directory (egg-work-tree-dir))
  (set (make-local-variable 'egg-log-msg-closure) nil)
  (set (make-local-variable 'egg-log-msg-ring-idx) nil))
(define-key egg-log-msg-mode-map (kbd "C-c C-s") 'egg-log-msg-buffer-toggle-signed)
(defsubst egg-log-msg-commit (prefix gpg-uid text-beg text-end &rest ignored)
  "Commit the index using the text between TEXT-BEG and TEXT-END as message.
PREFIX and IGNORED are ignored."
  (egg-cleanup-n-commit-msg (if gpg-uid
				#'egg--async-create-signed-commit-cmd
			      #'egg--git-commit-with-region-cmd)
			    text-beg text-end gpg-uid))

(defsubst egg-log-msg-amend-commit (prefix gpg-uid text-beg text-end &rest ignored)
  "Amend the last commit with the index using the text between TEXT-BEG and TEXT-END
as message. PREFIX and IGNORED are ignored."
  (egg-cleanup-n-commit-msg (if gpg-uid
				#'egg--async-create-signed-commit-cmd
			      #'egg--git-commit-with-region-cmd)
			    text-beg text-end gpg-uid "--amend"))

(defun egg-log-msg-buffer-toggle-signed ()
  "Toggle the to-be-gpg-signed state of the message being composed."
  (let* ((gpg-uid (egg-log-msg-gpg-uid))
	 (new-uid (if gpg-uid 
		      "None"
		    (read-string "Sign with gpg key uid: " (egg-user-name))))
	 (inhibit-read-only t))
    (egg-log-msg-set-gpg-uid (if gpg-uid nil new-uid))
    (save-excursion
      (save-match-data
	(goto-char (point-min))
	(re-search-forward "^GPG-Signed by: \\(.+\\)$" (egg-log-msg-text-beg))
	(replace-match (egg-text new-uid 'egg-text-2) nil t nil 1)
	(set-buffer-modified-p nil)))))

(defun egg-log-msg-done (level)
  "Take action with the composed message.
This usually means calling the lambda returned from (egg-log-msg-func)
with the appropriate arguments."
  (interactive "p")
  (let* ((text-beg (egg-log-msg-text-beg))
	 (text-end (egg-log-msg-text-end))
	 (diff-beg (egg-log-msg-next-beg)))
  (goto-char text-beg)
  (if (save-excursion (re-search-forward "\\sw\\|\\-" text-end t))
      (when (functionp (egg-log-msg-func))
                     (buffer-substring-no-properties text-beg text-end))
        (save-excursion (egg-log-msg-apply-closure level))
    (ding))))
  "Cancel the current message editing."
  (let* ((len (ring-length egg-log-msg-ring))
	 (closure egg-log-msg-closure)
	 (text-beg (nth 2 closure))
	 (text-end (nth 3 closure)))
                 (> text-end text-beg)
          (t (delete-region text-beg text-end)
             (goto-char text-beg)
(defun egg-commit-log-buffer-show-diffs (buf &optional init diff-beg)
  "Show the diff sections in the commit buffer.
See `egg-commit-buffer-sections'"
    (let* ((inhibit-read-only t)
	   (diff-beg (or diff-beg (egg-log-msg-next-beg)))
	   beg)
      (goto-char diff-beg)
                            action-closure
                            insert-init-text-function &optional amend-no-msg)
  "Open the commit buffer for composing a message.
With C-u prefix, the message will be use to amend the last commit.
With C-u C-u prefix, just amend the last commit with the old message.
For non interactive use:
TITLE-FUNCTION is either a string describing the text to compose or
a function return a string for the same purpose.
ACTION-CLOSURE is the input to build `egg-log-msg-closure'. It should
be the results of `egg-log-msg-mk-closure-from-input'.
INSERT-INIT-TEXT-FUNCTION is either a string or function returning a string
describing the initial text in the editing area.
if AMEND-NO-MSG is non-nil, the do nothing but amending the last commit
using git's default msg."
  (interactive (let ((prefix (prefix-numeric-value current-prefix-arg)))
		 (cond ((> prefix 15)	;; C-u C-u
			;; only set amend-no-msg
			(list nil nil nil t))
		       ((> prefix 3)	;; C-u
			(list (concat
			       (egg-text "Amending  " 'egg-text-3)
			       (egg-text (egg-pretty-head-name) 'egg-branch))
			      (egg-log-msg-mk-closure-input #'egg-log-msg-amend-commit)
			      (egg-commit-message "HEAD")))
		       (t 		;; regular commit
			(list (concat
				 (egg-text "Committing into  " 'egg-text-3)
				 (egg-text (egg-pretty-head-name) 'egg-branch))
				(egg-log-msg-mk-closure-input #'egg-log-msg-commit)
				nil)))))
  (if amend-no-msg
      (egg-buffer-do-amend-no-edit)
    (let* ((git-dir (egg-git-dir))
	   (default-directory (egg-work-tree-dir git-dir))
	   (buf (egg-get-commit-buffer 'create))
	   (state (egg-repo-state :name :email))
	   (head-info (egg-head))
	   (head (or (cdr head-info)
		     (format "Detached HEAD! (%s)" (car head-info))))
	   (inhibit-read-only inhibit-read-only)
	   text-beg text-end diff-beg)
      (with-current-buffer buf
	(setq inhibit-read-only t)
	(erase-buffer)

	(insert (cond ((functionp title-function)
		       (funcall title-function state))
		      ((stringp title-function) title-function)
		      (t "Shit happens!"))
		"\n"
		(egg-text "Repository: " 'egg-text-1) 
		(egg-text git-dir 'font-lock-constant-face) "\n"
		(egg-text "Committer: " 'egg-text-1) 
		(egg-text (plist-get state :name) 'egg-text-2) " "
		(egg-text (concat "<" (plist-get state :email) ">") 'egg-text-2) "\n"
		(egg-text "GPG-Signed by: " 'egg-text-1)
		(egg-text "None" 'egg-text-2) "\n"
		(egg-text "-- Commit Message (type `C-c C-c` when done or `C-c C-k` to cancel) -"
			  'font-lock-comment-face))
	(put-text-property (point-min) (point) 'read-only t)
	(put-text-property (point-min) (point) 'rear-sticky nil)
	(insert "\n")

	(setq text-beg (point-marker))
	(set-marker-insertion-type text-beg nil)
	(put-text-property (1- text-beg) text-beg :navigation 'commit-log-text)
	
	(insert (egg-prop "\n------------------------ End of Commit Message ------------------------"
			  'read-only t 'front-sticky nil
			  'face 'font-lock-comment-face))
	
	(setq diff-beg (point-marker))
	(set-marker-insertion-type diff-beg nil)
	(egg-commit-log-buffer-show-diffs buf 'init diff-beg)

	(goto-char text-beg)
	(cond ((functionp insert-init-text-function)
	       (funcall insert-init-text-function))
	      ((stringp insert-init-text-function)
	       (insert insert-init-text-function)))

	(setq text-end (point-marker))
	(set-marker-insertion-type text-end t)

	(set (make-local-variable 'egg-log-msg-closure)
	     (egg-log-msg-mk-closure-from-input action-closure 
						nil nil text-beg text-end diff-beg)))
      (pop-to-buffer buf))))
    (define-key map "G"       'egg-diff-buffer-run-command)
    (define-key map "s"       'egg-status)
    (define-key map "l"       'egg-log)
    (define-key map "/"       'egg-search-changes)
    (define-key map "C-c C-/" 'egg-search-changes-all)
    map)
  "\\{egg-diff-buffer-mode-map}")

(defun egg-diff-buffer-run-command ()
  "Re-run the command that create the buffer."
  (interactive)
  (call-interactively (or (plist-get egg-diff-buffer-info :command)
			  #'egg-buffer-cmd-refresh)))

(defun egg-buffer-ask-pickaxe-mode (pickaxe-action search-code &optional default-term)
  (let* ((key-type-alist '((?s "string" identity)
			   (?r "posix regex" (lambda (s) (list s :regexp)))
			   (?l "line matching regex" (lambda (s) (list s :line)))))
	 (search-info (assq search-code key-type-alist))
	 (search-type (nth 1 search-info))
	 (make-term-func (nth 2 search-info))
	 key term)
    (while (not (stringp search-type))
      (setq key (read-key-sequence 
		 (format "match type to %s: (s)tring, (r)egex, (l)line or (q)uit? "
			 pickaxe-action)))
      (setq key (string-to-char key))
      (setq search-info (assq key key-type-alist))
      (when (= key ?q) (error "%s: aborted" pickaxe-action))
      (setq search-type (nth 1 search-info))
      (setq make-term-func (nth 2 search-info))
      (setq search-code key)
      (unless (consp search-info)
	(message "invalid choice: %c! (must be of of s,r,l or q)" key)
	(ding)
	(sit-for 1)))
    (setq term (read-string 
		(format "%s with changes containing %s: " pickaxe-action search-type)
		default-term))    
    (unless (> (length term) 1)
      (error "Cannot match %s: %s!!" (nth 1 key) term))
    (setq term (funcall make-term-func term))
    (when (and (memq search-code '(?r ?l))
	       (y-or-n-p "ignore case when matching regexp? "))
      (setq term (append term (list :ignore-case))))
    term))

(defun egg-buffer-prompt-pickaxe (pickaxe-action default-search default-term
					       &optional ask-mode ask-regexp ask-term)
  "Prompt for pickaxe.
SEARCH-SCOPE is a string such as \"diffs\" or \"history\"
DEFAULT-SEARCH-CODE is used asking the term and is one of: :string,:regexp or :line
DEFAULT-TERM is used a the initial value when reading user's input.
If ASK-MODE is non-nil then ask for the mode (string, regexp or line) then ask for the term.
Else if ASK-REGEXP is non-nil then ask for a regexp (the term).
Else if ASK-TERM is non-nil then ask for the term using DEFAULT-SEARCH as search type."
  (cond (ask-mode
	 (egg-buffer-ask-pickaxe-mode pickaxe-action nil default-term))
	(ask-regexp
	 (egg-buffer-ask-pickaxe-mode pickaxe-action ?r default-term))
	(ask-term
	 (egg-buffer-ask-pickaxe-mode pickaxe-action (assoc-default default-search
								  '((:string . ?s)
								    (:regexp . ?r)
								    (:line   . ?l)))
				      default-term))
	(t nil)))

(defsubst egg-pickaxe-to-args (pickaxe)
  (cond ((stringp pickaxe) (list "-S" pickaxe))
	((and (consp pickaxe) (memq :line pickaxe))
	 (nconc (list "-G" (car pickaxe))
		(if (memq :ignore-case pickaxe) (list "--regexp-ignore-case"))))
	((and (consp pickaxe) (memq :regexp pickaxe))
	 (nconc (list "-S" (car pickaxe) "--pickaxe-regex")
		(if (memq :ignore-case pickaxe) (list "--regexp-ignore-case"))))
	(t nil)))

(defsubst egg-pickaxe-term (pickaxe)
  (if (stringp pickaxe) pickaxe (car pickaxe)))

(defsubst egg-pickaxe-highlight (pickaxe)
  (if (stringp pickaxe) 
      (regexp-quote pickaxe)
    (egg-unquote-posix-regexp (car pickaxe))))

(defsubst egg-pickaxe-pick-item (pickaxe string-item regexp-item line-item)
  (cond ((stringp pickaxe) string-item)
	((and (consp pickaxe) (memq :line pickaxe)) line-item)
	((and (consp pickaxe) (memq :regexp pickaxe)) regexp-item)
	(t nil)))

(defun egg-buffer-highlight-pickaxe (highlight-regexp beg end &optional is-cc-diff)
  (when (stringp highlight-regexp)
    (when (eq (aref highlight-regexp 0) ?^)
      (setq highlight-regexp
	    (concat "^" (make-string (if is-cc-diff 2 1) ?.)
		    (substring highlight-regexp 1))))
    (goto-char beg)
    (while (re-search-forward highlight-regexp end t)
      (unless (or (not (get-text-property (match-beginning 0) :hunk))
		  (if is-cc-diff 
		      (string-equal (buffer-substring-no-properties 
				     (line-beginning-position) 
				     (+ (line-beginning-position) 2))
				    "  ")
		    (eq (char-after (line-beginning-position)) ? ))
		  (eq (char-after (line-beginning-position)) ?@))
	(put-text-property (match-beginning 0) (match-end 0) 'face 'highlight)))))
  "Insert contents from `egg-diff-buffer-info' into BUFFER.
egg-diff-buffer-info is built using `egg-build-diff-info'."
	  (pickaxe (plist-get egg-diff-buffer-info :pickaxe))
	  
	  pickaxe-term highlight-regexp is-cc-diff
          pos beg end inv-beg help-beg help-end help-inv-beg err-code)

      (setq highlight-regexp (and pickaxe (egg-pickaxe-highlight pickaxe)))
      (setq pickaxe-term (and pickaxe (egg-pickaxe-term pickaxe)))

      (egg-cmd-log "RUN: git diff" (mapconcat #'identity args " ") "\n")
      (setq err-code (apply 'call-process egg-git-command nil t nil "diff" args))
      (egg-cmd-log (format "RET:%d\n" err-code))
      (setq end (point))
      (unless (> end beg)
        (if pickaxe
	    (insert (egg-text "No difference containing: " 'egg-text-4)
		    (egg-text pickaxe-term 'egg-text-4)
		    (egg-text "!\n" 'egg-text-4))
	  (insert (egg-text "No difference!\n" 'egg-text-4))))
             ;; :begin (point-min)
             :begin beg
             :end end
      (egg-buffer-highlight-pickaxe highlight-regexp beg end
				    (save-excursion
				      (goto-char beg)
				      (save-match-data
					(re-search-forward "^@@@" end t))))

  "Build the diff buffer based on DIFF-INFO and return the buffer."
  (let* ((default-directory (egg-work-tree-dir))

(defun egg-re-do-diff (file-name pickaxe only-dst-path)
  (let* ((dst (egg-read-rev "Compare rev: " (plist-get egg-diff-buffer-info :dst-revision)))
	 (old-src (plist-get egg-diff-buffer-info :src-revision))
	 (src (egg-read-rev (format "Compare %s vs %s: " dst 
				    (if only-dst-path "upstream" "base revision"))
			    (if (consp old-src) (car old-src) old-src)))
	 (command (plist-get egg-diff-buffer-info :command))
	 (info (egg-build-diff-info src dst file-name pickaxe only-dst-path)))
    (when command
      (plist-put info :command command))
    (egg-do-diff info)))

(defun egg-build-diff-info (src dst &optional file pickaxe only-dst-path)
  "Build the data for the diff buffer.
This data is based on the delta between SRC and DST. The delta is restricted
to FILE if FILE is non-nil. SRC and DST should be valid git revisions.
if DST is nil then use work-dir as destination. if SRC and DST are both
nil then compare the index and the work-dir."
  (let ((dir (egg-work-tree-dir))
	(search-string (if pickaxe (format "Search for %s " 
					   (if (stringp pickaxe) pickaxe (car pickaxe)))
			 ""))
	info tmp options)

    (setq options 
	  (append '("--no-color" "-p")
		  (copy-sequence
		   (if (stringp file)
		       (assoc-default (assoc-default file auto-mode-alist #'string-match)
				      egg-git-diff-file-options-alist #'eq
				      egg-git-diff-options)
		     egg-git-diff-options))))
    
                 (list :args (nconc options (list "--src-prefix=INDEX/"
						  "--dst-prefix=WORKDIR/"))
                       :title (format "%sfrom INDEX to %s" search-string dir)
                 (list :args (nconc options (list "--cached"
						  "--src-prefix=INDEX/"
						  "--dst-prefix=WORKDIR/"))
                       :title (format "%sfrom HEAD to INDEX" search-string)
                 (list :args (nconc options (list (concat src 
							  (if only-dst-path "..." "..") 
							  dst)))
                       :title (format "%sfrom %s to %s" search-string 
				      (if only-dst-path (concat dst "@" src) src)
				      dst)
                       :prologue (format "a: %s\nb: %s" 
					 (if only-dst-path (concat dst "@" src) src) 
					 dst)
                       :src-revision (if only-dst-path (cons src dst) src)
                 (list :args (nconc options (list src))
                       :title (format "%sfrom %s to %s" search-string src dir)
        (progn
	  (plist-put info :file file)
	  (setq file (list file)))
    (when pickaxe
      (plist-put info :pickaxe pickaxe)
      (plist-put info :highlight (egg-pickaxe-highlight pickaxe))
      (plist-put info :args
		 (append (egg-pickaxe-to-args pickaxe) (plist-get info :args))))
(defun egg-diff-ref (&optional default do-pickaxe)
  "Prompt a revision to compare against worktree."
  (interactive (list (egg-ref-at-point) (prefix-numeric-value current-prefix-arg)))
  (let* ((src (egg-read-rev "compare work tree vs revision: " default))
	 (diff-info (egg-build-diff-info src nil nil
					 (egg-buffer-prompt-pickaxe "restrict diffs" 
								    :string nil
								    (> do-pickaxe 15)
								    nil
								    (> do-pickaxe 3))))
         (buf (progn (plist-put diff-info :command 'egg-diff-ref)
		     (egg-do-diff diff-info))))
    (pop-to-buffer buf)))

(defun egg-diff-upstream (ref &optional prefix)
  "Prompt compare upstream to REF."
  (interactive (list (if current-prefix-arg
			 (egg-read-local-ref "ref to compare: " (egg-branch-or-HEAD))
		       (egg-branch-or-HEAD))
		     (prefix-numeric-value current-prefix-arg)))
  (let* ((branch-upstream (egg-upstream ref))
	 (upstream (egg-read-ref (format "upstream of %s: " ref) branch-upstream))
	 (diff-info (egg-build-diff-info upstream ref nil 
					 (egg-buffer-prompt-pickaxe "restrict diffs"
								    :string nil
								    (> prefix 63)
								    nil
								    (> prefix 15)) 
					 t))
         (buf (progn (plist-put diff-info :command 'egg-diff-upstream)
		     (egg-do-diff diff-info))))
    (pop-to-buffer buf)))

(defun egg-buffer-pop-to-file (file sha1 &optional other-win use-wdir-file line)
  "Put the contents of FILE from SHA1 to a buffer and show it.
show the buffer in the other window if OTHER-WIN is not nil.
Use the the contents from the work-tree if USE-WDIR-FILE is not nil.
Jump to line LINE if it's not nil."
  (funcall (if other-win #'pop-to-buffer #'switch-to-buffer)
	   (if (or (equal (egg-current-sha1) sha1)
		   use-wdir-file)
	       (progn
		 (message "file:%s dir:%s" file default-directory)
		 (find-file-noselect file))
	     (egg-file-get-other-version file (egg-short-sha1 sha1) nil t)))
  (when (numberp line)
    (goto-char (point-min))
    (forward-line (1- line))))
(defun egg-log-buffer-get-commit-pos (commit &optional beg end)
  (let* ((sha1 (egg-sha1 commit))
	 (beg (or beg (point-min)))
	 (end (or end (point-max)))
	 (pos beg))
    (while (and pos (not (equal (get-text-property pos :commit) sha1)))
	(setq pos (next-single-property-change pos :commit nil end))
	(unless (< pos end)
	  (setq pos nil)))
    pos))

(defun egg-log-show-ref (pos)
  "Show information about ref at POS."
  (interactive "d")
  (let* ((ref-info (get-text-property pos :ref))
	 (reflog (unless ref-info (get-text-property pos :reflog)))
	 (ref-type (and (cdr ref-info)))
	 (mark-pos (if (get-text-property pos :mark)
		       pos
		     (if (get-text-property (1- pos) :mark) (1- pos))))
	 (mark (and mark-pos (get-text-property mark-pos :mark)))
	 (append-to (and mark-pos (get-text-property mark-pos :append-to)))
	 (followed-by (and mark-pos (get-text-property mark-pos :followed-by)))
	 (reflog-time (and reflog (get-text-property pos :time)))
	 into is-squashed)
    (if (or ref-info mark)
	(cond ((eq ref-type :head) (egg-show-branch (car ref-info)))
	      ((eq ref-type :tag) (egg-show-atag (car ref-info)))
	      ((eq ref-type :remote) (egg-show-remote-branch (car ref-info)))
	      ((eq mark (egg-log-buffer-base-mark)) (message "BASE mark"))
	      (mark
	       (setq is-squashed 
		     (memq mark (list (egg-log-buffer-squash-mark) (egg-log-buffer-fixup-mark)))
		     into (if is-squashed "into" "right after"))
	       (setq append-to (and append-to (egg-pretty-short-rev append-to)))
	       (setq followed-by (and followed-by (egg-pretty-short-rev followed-by)))
	       (message "marked to be %s%s in the upcoming interactive rebase"
			  (cond ((eq mark (egg-log-buffer-pick-mark)) "picked")
				((eq mark (egg-log-buffer-edit-mark)) "edited")
				((eq mark (egg-log-buffer-squash-mark)) "squashed")
				((eq mark (egg-log-buffer-fixup-mark)) "absorbed")
				(t (error "unknown mark: %s" mark)))
			  (cond ((and append-to followed-by)
				 (format " %s %s and to be followed by %s" 
					 into append-to followed-by))
				(append-to (format " %s %s" into append-to))
				(followed-by (format " and followed by %s" followed-by))
				(t ""))))
	      (t nil))
      (when reflog
	(setq reflog (substring-no-properties reflog))
	(setq reflog-time (substring-no-properties reflog-time))
	(put-text-property 0 (length reflog) 'face 'bold reflog)
	(put-text-property 0 (length reflog-time) 'face 'bold reflog-time)
	(message "reflog:%s created:%s" reflog reflog-time)))))


(defun egg-log-buffer-style-command ()
  "Re-run the command that create the buffer."
  (interactive)
  (call-interactively (or (plist-get egg-internal-log-buffer-closure :command)
			  #'egg-buffer-cmd-refresh)))
(defun egg-log-style-buffer-mode (mode name &optional map hook)
  (kill-all-local-variables)
  (setq buffer-read-only t)
  (setq major-mode mode
	mode-name name
	mode-line-process ""
	truncate-lines t)
  (use-local-map (or map egg-log-style-buffer-map))
  (set (make-local-variable 'egg-buffer-refresh-func)
       'egg-log-buffer-simple-redisplay)
  (set (make-local-variable 'egg-log-buffer-comment-column) 0)
  (set (make-local-variable 'egg-internal-log-buffer-closure) nil)
  (setq buffer-invisibility-spec nil)
  (run-mode-hooks (or hook 'egg-log-style-buffer-hook)))
(defconst egg-log-style-help-text
  (concat
   (egg-text "Common Key Bindings:" 'egg-help-header-2) "\n"
   (egg-pretty-help-text
    "\\<egg-log-style-buffer-map>"
    "\\[egg-log-buffer-next-ref]:next thing  "
    "\\[egg-log-buffer-prev-ref]:previous thing  "
    "\\[egg-status]:show repo's status  "
    "\\[egg-log]:show repo's history  "
    "\\[egg-buffer-cmd-refresh]:redisplay  "
    "\\[egg-quit-buffer]:quit\n" )
   (egg-text "Extra Key Bindings for a Commit line:" 'egg-help-header-2) "\n"
   (egg-pretty-help-text
    "\\<egg-secondary-log-commit-map>"
    "\\[egg-log-locate-commit]:locate commit in history  "
    "\\[egg-log-buffer-insert-commit]:load details  "
    "\\[egg-section-cmd-toggle-hide-show]:hide/show details  "
    "\\[egg-section-cmd-toggle-hide-show-children]:hide sub-blocks\n"
    "\\[egg-log-buffer-anchor-head]:anchor HEAD  "
    "\\[egg-log-buffer-checkout-commit]:checkout  "
    "\\[egg-log-buffer-tag-commit]:new tag  "
    "\\[egg-log-buffer-atag-commit]:new annotated tag\n"
    )
   (egg-text "Extra Key Bindings for a Diff Block:" 'egg-help-header-2) "\n"
   (egg-pretty-help-text
    "\\<egg-log-diff-map>"
    "\\[egg-log-diff-cmd-visit-file-other-window]:visit version/line\n")
   ))
(defun egg--log-parse-decoration-refs (dec-ref-start dec-ref-end repo-refs-prop-alist
						     pseudo-refs-list &rest extras-properties)
  (let ((pos dec-ref-start)
	ref-full-name ref
	short-ref-list decorated-refs 
	full-ref-list 
	ref-string)
    (when (and dec-ref-start (> dec-ref-start 0))
      (goto-char pos)
      (while (> (skip-chars-forward "^ ,:" dec-ref-end) 0)
	(setq ref-full-name (buffer-substring-no-properties pos (point)))
	(forward-char 2)
	(setq pos (point))
	(unless (or 
		 ;; (equal ref-full-name "HEAD") 
		 (equal ref-full-name "tag")
		 (and (> (length ref-full-name) 5)
		      (equal (substring ref-full-name -5) "/HEAD")))
	  (setq ref (assoc-default ref-full-name repo-refs-prop-alist))
	  (when ref
	    (add-to-list 'decorated-refs ref)
	    (add-to-list 'full-ref-list ref-full-name)
	    (add-to-list 'short-ref-list (car (get-text-property 0 :ref ref)))))))

    (setq ref-string (mapconcat 'identity (append pseudo-refs-list decorated-refs) " "))
    (if (equal ref-string "")
	(setq ref-string nil)
      (add-text-properties 0 (length ref-string)
			   (nconc (if decorated-refs
				      (list :references short-ref-list
					    :full-references full-ref-list)) 
				  extras-properties)
			   ref-string))
    
    ref-string))



(defun egg-decorate-log (&optional line-map head-map tag-map remote-map remote-site-map
				   sha1-pseudo-refs-alist)
  "Decorate a log buffer.
LINE-MAP is used as local keymap for a commit line.
HEAD-MAP is used as local keymap for the name of a head.
TAG-MAP is used as local keymap for the name of a tag.
REMOTE-MAP is used as local keymap for the name of a remote head.
REMOTE-SITE-MAP is used as local keymap for the name of a remote site."
	(dash-char (aref egg-log-graph-chars 2))
	(graph-map (unless (equal egg-log-graph-chars "*|-/\\")
		     (let (lst)
		       (dotimes (i (length egg-log-graph-chars))
			 (push (cons (aref "*|-/\\" i) (aref egg-log-graph-chars i))
			       lst))
		       lst)))
          (list 'face 'egg-remote-mono 'keymap remote-site-map 'help-echo (egg-tooltip-func))
	  (list 'face 'egg-log-HEAD-name 'keymap head-map 'help-echo (egg-tooltip-func))
	  (list 'face 'egg-reflog-mono 'keymap line-map 'help-echo (egg-tooltip-func))))
        separator ref-string sha1 pseudo-refs-list
        refs-start refs-end
    (dolist (sha1-pseudo-refs sha1-pseudo-refs-alist)
      (dolist (pseudo-ref (cdr sha1-pseudo-refs))
	(put-text-property 0 (length pseudo-ref) 'keymap line-map pseudo-ref)))
    (save-excursion
      (while (< (point) (point-max))
	(if (not (looking-at "^.*\\([0-9a-f]\\{40\\}\\) .+$"))
	    (when graph-map
	      (setq end (line-end-position))
	      (egg-redraw-chars-in-region (line-beginning-position)
					  (1- (line-end-position))
					  graph-map))
	  (setq sha-beg (match-beginning 1)
		sha-end (match-end 1)
		subject-beg (1+ sha-end)
		beg (line-beginning-position)
		end (match-end 0)
		refs-start nil)
	  (setq graph-len (if (= beg sha-beg) 0 (- sha-beg beg 1))
		sha1 (buffer-substring-no-properties sha-beg sha-end)
		subject-beg (if (or (/= (char-after subject-beg) ?\()
				    (not (member (buffer-substring-no-properties 
						  subject-beg (+ subject-beg 6))
						 '("(refs/" "(tag: " "(HEAD," "(HEAD)"))))
				subject-beg
			      (setq refs-start (1+ subject-beg))
			      (goto-char subject-beg)
			      (skip-chars-forward "^)")
			      (setq refs-end (point))
			      (+ (point) 2)))

	  (when (and graph-map graph-len)
	    (egg-redraw-chars-in-region (line-beginning-position) (1- sha-beg) graph-map)
	    (goto-char end))

	  (setq pseudo-refs-list (assoc-default sha1 sha1-pseudo-refs-alist))
	  
	  (setq ref-string
		(egg--log-parse-decoration-refs refs-start refs-end dec-ref-alist 
						pseudo-refs-list 
						:navigation sha1 :commit sha1))
	  ;; common line decorations
	  (setq line-props (nconc (list :navigation sha1 :commit sha1)
				  (if line-map (list 'keymap line-map))
				  (if ref-string 
				      (list :references
					    (get-text-property 0 :references ref-string)))))
	

	  ;; (when (and (not ref-string) pseudo-ref)
	  ;;   (setq ref-string pseudo-ref)
	  ;;   (add-text-properties 0 (length ref-string) line-props ref-string))

	  (setq separator (apply 'propertize " " line-props))
	  (setq ref-string-len (if ref-string (length ref-string)))

	  ;; entire line
	  (add-text-properties beg (1+ end) line-props)

	  ;; comment
	  (put-text-property subject-beg end 'face 'egg-text-2)
	  ;; delete refs list (they're already parsed)
	  (if refs-start
	      (delete-region (1- refs-start) (+ refs-end 2)))

	  ;; shorten sha
	  (delete-region (+ sha-beg 8) sha-end)
	  (put-text-property sha-beg (+ sha-beg 8)
			     'face 'font-lock-constant-face)
	  (put-text-property sha-beg (+ sha-beg 8)
			     'help-echo (egg-tooltip-func))

	  (setq dashes-len (- 300 graph-len 1
			      (if ref-string (1+ ref-string-len) 0)))
	  (setq min-dashes-len (min min-dashes-len dashes-len))

	  (put-text-property sha-beg (1+ sha-beg)
			     :dash-refs
			     (apply 'concat
				    (apply 'propertize
					   (make-string dashes-len dash-char)
					   (nconc (list 'face 'egg-graph)
						  line-props))
				    separator
				    (if ref-string
					(list ref-string separator))))
	  (when (string= sha1 head-sha1)
	    (setq head-line (point-marker))))
	(forward-line 1))
	    (goto-char start)
        ;; (when head-line
        ;;   (goto-char head-line)
        ;;   (overlay-put ov 'face 'egg-log-HEAD)
        ;;   (overlay-put ov 'evaporate t)
        ;;   (move-overlay ov (line-beginning-position)
        ;;                 (1+ (line-end-position))))

(defun egg-insert-logs-with-decoration (ref git-log-extra-options paths
					    keymap-plist sha1-pseudo-refs-alist)
    (egg-run-git-log ref git-log-extra-options paths)
    (unless (= (char-before (point-max)) ?\n)
      (goto-char (point-max))
      (insert ?\n))
    (egg-decorate-log (plist-get keymap-plist :line)
		      (plist-get keymap-plist :branch)
		      (plist-get keymap-plist :tag)
		      (plist-get keymap-plist :remote)
		      (plist-get keymap-plist :site)
		      sha1-pseudo-refs-alist)))

(defun egg-insert-logs-with-simple-decoration (ref &optional git-log-extra-options paths)
  (egg-insert-logs-with-decoration ref 
				   (append '("--graph" "--topo-order") git-log-extra-options) 
				   paths
				   (list :line egg-secondary-log-commit-map
					 :branch egg-secondary-log-commit-map
					 :tag egg-secondary-log-commit-map
					 :remote egg-secondary-log-commit-map
					 :site egg-secondary-log-commit-map)
				   nil))

(defun egg-insert-logs-with-full-decoration (ref &optional git-log-extra-options paths)
  (egg-insert-logs-with-decoration ref 
				   (append '("--graph" "--topo-order") git-log-extra-options) 
				   paths
				   (if paths
				       (list :line egg-file-log-commit-map
					     :branch egg-file-log-commit-map
					     :tag egg-file-log-commit-map
					     :remote egg-file-log-commit-map
					     :site egg-file-log-commit-map)
				     (list :line egg-log-commit-map
					   :branch egg-log-local-branch-map
					   :tag egg-log-local-ref-map
					   :remote egg-log-remote-branch-map
					   :site egg-log-remote-site-map))
				   nil))

(defalias 'egg-log-pop-to-file 'egg-buffer-pop-to-file)

(defun egg-log-diff-cmd-visit-file (file sha1 &optional use-wdir-file)
  "Open revision SHA1's FILE.
With C-u prefix, use the work-tree's version instead."
                     (get-text-property (point) :commit)
		     current-prefix-arg))
  (egg-log-pop-to-file file sha1 nil use-wdir-file))
(defun egg-log-diff-cmd-visit-file-other-window (file sha1 &optional use-wdir-file)
  "Open revision SHA1's FILE in other window.
With C-u prefix, use the work-tree's version instead."
                     (get-text-property (point) :commit)
		     current-prefix-arg))
  (egg-log-pop-to-file file sha1 t use-wdir-file))
(defun egg-log-hunk-cmd-visit-file (sha1 use-wdir-file file hunk-header hunk-beg &rest ignored)
  (interactive (nconc (list (get-text-property (point) :commit) current-prefix-arg)
		      (egg-hunk-info-at (point))))
  (egg-log-pop-to-file file sha1 nil use-wdir-file 
		       (egg-hunk-compute-line-no hunk-header hunk-beg)))

(defun egg-log-hunk-cmd-visit-file-other-window (sha1 use-wdir-file file hunk-header hunk-beg &rest ignored)
  (interactive (nconc (list (get-text-property (point) :commit) current-prefix-arg)
		      (egg-hunk-info-at (point))))
  (egg-log-pop-to-file file sha1 t use-wdir-file (egg-hunk-compute-line-no hunk-header hunk-beg)))
  (let* ((commit (egg-commit-at-point pos))
         (refs (egg-references-at-point pos))
         (first-ref (if (stringp refs) refs (car (last refs))))
         (ref-at-point (egg-ref-at-point pos))
	 (current-branch (egg-get-symbolic-HEAD))
    
    (when (stringp commit)
      (cond ((memq :sha1 options) (if (memq :short options)
				      (substring commit 0 8)
				    commit))
	    ((stringp ref-at-point) ref-at-point)
	    ((and (equal commit head-sha1) (stringp current-branch)) current-branch)
	    ((and (equal commit head-sha1) (not (memq :no-HEAD options))) "HEAD")
	    ((stringp first-ref) first-ref)
	    ((memq :symbolic options) (egg-describe-rev commit))
	    ((memq :short options)(substring commit 0 8))
	    (t commit)))))
(defun egg-log-buffer-do-mark (pos char &optional unmark remove-first &rest extra-properties)
        (step (if unmark -1 (if remove-first 0 1)))
	leader follower-of-leader)
      (goto-char pos)
      (setq leader (get-text-property (point) :append-to))
               (nconc (list :mark char
			    'display
			    (and char
				 (egg-text (char-to-string char)
					   'egg-log-buffer-mark)))
		      extra-properties))
      (when leader
	(save-excursion
	  (goto-char (egg-log-buffer-get-commit-pos leader))
	  (move-to-column col)
	  (setq follower-of-leader (get-text-property (point) :followed-by))
	  (when (equal follower-of-leader commit)
	    (put-text-property (point) (1+ (point)) :followed-by nil))))
      (while (not (or (get-text-property (point) :commit)
  "Mark commit at POS as the BASE commit."
  (egg-log-buffer-do-mark pos (egg-log-buffer-base-mark) nil t))

(defun egg-log-buffer-do-mark-append (pos mark prompt-fmt error-fmt &optional exclusive)
  (let* ((commit (egg-commit-at-point pos))
	 (pretty (egg-pretty-short-rev commit))
	 (parent (car (egg-commit-parents commit)))
	 leader pretty-leader other leader-pos 
	 leader-mark must-mark-leader leader-leader)
    (unless (setq leader (egg-completing-read-sha1 
			  commit (format prompt-fmt pretty) parent))
      (error error-fmt pretty))
    (setq pretty-leader (egg-pretty-short-rev leader))
    (unless (setq leader-pos (egg-log-buffer-get-commit-pos leader))
      (error "Can't find %s in buffer, please configure egg to display more commits"
	     leader))
    (when (functionp mark)
      (setq mark (funcall mark commit leader)))
    (setq leader-pos (+ leader-pos egg-log-buffer-comment-column -10))
    (setq leader-mark (get-text-property leader-pos :mark))
    (unless leader-mark
      (when (y-or-n-p (format "should %s be picked as well? " pretty-leader))
	(setq must-mark-leader t
	      leader-mark (egg-log-buffer-pick-mark))))
    (setq other (get-text-property leader-pos :followed-by))
    (setq leader-leader (get-text-property leader-pos :append-to))
    (when exclusive
      (if (and other
	       (not (y-or-n-p 
		     (format "%s is already exclusively followed by %s! replace it with %s? "
			     pretty-leader other pretty))))
	  (setq exclusive nil)
	(setq must-mark-leader t
	      leader-mark (egg-log-buffer-pick-mark))))
    (when must-mark-leader
      (egg-log-buffer-do-mark leader-pos leader-mark nil nil
			      :followed-by (and exclusive commit)
			      :append-to leader-leader))
    (egg-log-buffer-do-mark pos mark nil nil :append-to leader)))


(defun egg-log-buffer-mark-pick (pos &optional append-to) 
  "Mark commit at POS to be picked in the upcoming interactive rebase.
With C-u prefix, prompt for reordering."
  (interactive "d\nP")
  (if append-to
      (egg-log-buffer-do-mark-append pos (egg-log-buffer-pick-mark)
				     "reorder %s to follow: "
				     "Need a commit for %s to follow!" t)
    (egg-log-buffer-do-mark pos (egg-log-buffer-pick-mark))))

(defun egg-log-buffer-mark-squash (pos &optional append-to)
  "Mark commit at POS to be squashed in the upcoming interactive rebase.
With C-u prefix, prompt for reordering."
  (interactive "d\nP")
  (if append-to
      (egg-log-buffer-do-mark-append 
       pos (lambda (commit leader)
	     (if (y-or-n-p (format "keep %s's message (merge into %s's message)? "
				   (egg-pretty-short-rev commit)
				   (egg-pretty-short-rev leader)))
		 (egg-log-buffer-squash-mark)
	       (egg-log-buffer-fixup-mark)))
       "squash %s into: "
       "Need a commit to squash %s into!")
    (egg-log-buffer-do-mark pos (egg-log-buffer-squash-mark))))

(defun egg-log-buffer-mark-edit (pos &optional append-to)
  "Mark commit at POS to be edited in the upcoming interactive rebase.
With C-u prefix, prompt for reordering."
  (interactive "d\nP")
  (if append-to
      (egg-log-buffer-do-mark-append pos (egg-log-buffer-edit-mark)
				     "reorder %s to follow: "
				     "Need a commit for %s to follow!" t)
    (egg-log-buffer-do-mark pos (egg-log-buffer-edit-mark))))
  "Unmark all commits."
                              (list :mark nil 'display nil 
				    :append-to nil :followed-by nil)))
    (egg-refresh-buffer (current-buffer))))
  "Unmark commit at POS.
With C-u prefix, unmark all."
(defun egg-log-buffer-get-marked-alist (&rest types)
	(when (or (null types) (memq (get-text-property pos :mark) types))
	  (goto-char pos)
	  (setq marker (point-marker))
	  (move-to-column egg-log-buffer-comment-column)
	  (setq subject (buffer-substring-no-properties
			 (point) (line-end-position)))
	  (setq alist (cons (list (get-text-property pos :commit)
				  (get-text-property pos :mark)
				  subject marker
				  (get-text-property pos :append-to)
				  (get-text-property pos :followed-by))
			    alist)))))
(defsubst egg-marked-commit-sha1 (commit) (nth 0 commit))
(defsubst egg-marked-commit-mark (commit) (nth 1 commit))
(defsubst egg-marked-commit-subject (commit) (nth 2 commit))
(defsubst egg-marked-commit-marker (commit) (nth 3 commit))
(defsubst egg-marked-commit-leader (commit) (nth 4 commit))
(defsubst egg-marked-commit-follower (commit) (nth 5 commit))

(defun egg-log-buffer-get-rebase-marked-alist ()
  (let* ((tbd (egg-log-buffer-get-marked-alist (egg-log-buffer-pick-mark) 
					       (egg-log-buffer-squash-mark)
					       (egg-log-buffer-edit-mark)
					       (egg-log-buffer-fixup-mark)))
	 done commit add-func)
    (setq add-func 
	  (lambda (commit)
	    ;;
	    ;; add the commit to the done list
	    ;; prepending is ok because it will be reversed at the end
	    ;;
	    (push commit done)
	    (let ((sha1 (egg-marked-commit-sha1 commit))
		  (second-sha1 (egg-marked-commit-follower commit))
		  (youngers tbd)
		  younger younger second)
	      ;;
	      ;; Look for younger ones that must be squashed into commit
	      ;;
	      (dolist (younger youngers)
		(when (and (equal (egg-marked-commit-leader younger) sha1)
			   (not (memq younger done)))
		  ;;
		  ;; put add the younger one into done if it wasn't second in command
		  ;; save the second in commad for later, it must be added after all
		  ;; the squashed ones.
		  ;;
		  (setq tbd (delq younger tbd))
		  (if (equal (egg-marked-commit-sha1 younger) second-sha1)
		      (setq second younger)
		    (funcall add-func younger))))
	      ;;
	      ;; Now that all the squashed ones were added, add second-in-command
	      ;;
	      (when second
		(funcall add-func second)))))
    (while tbd
      (setq commit (car tbd) tbd (cdr tbd))
      (unless (memq commit done)
	(funcall add-func commit)))
    (nreverse done)))
  (let ((process-environment (copy-sequence process-environment))
        orig-head-sha1 tmp)
      (write-region (point-min) (point-min) (concat rebase-dir "verbose"))
      (write-region (point-min) (point-max) (concat rebase-dir "head-name"))
      (write-region (point-min) (point-max) (concat rebase-dir "orig-head"))
      (write-region (point-min) (point-max) (concat rebase-dir "upstream"))
      (erase-buffer)
      (insert onto "\n")
      (write-region (point-min) (point-max) (concat rebase-dir "onto"))
      (erase-buffer)
      (insert "\n")
      (write-region (point-min) (point-max) (concat rebase-dir "quiet"))

      (save-match-data
	(let* ((split-string-default-separators "=")
	       (strategy-alist (mapcar 'split-string egg-git-merge-strategy-options))
	       (strategy (cadr (assoc "--strategy" strategy-alist)))
	       (strategy-opts 
		(delq nil 
		      (mapcar (lambda (opt-key-val)
				(when (equal (car opt-key-val) "--strategy-option")
				  (cadr opt-key-val)))
			      strategy-alist))))
	  (when strategy 
	    (erase-buffer)
	    (insert strategy "\n")
	    (write-region (point-min) (point-max) (concat rebase-dir "strategy")))
	  (when strategy-opts
	    (erase-buffer)
	    (dolist (option strategy-opts)
	      (insert "  '--" option "'"))
	    (write-region (point-min) (point-max) (concat rebase-dir "strategy_opts")))))
      
                    (concat rebase-dir "stopped-sha"))
        (insert (cond ((eq (nth 1 rev-info) (egg-log-buffer-pick-mark)) "pick")
                      ((eq (nth 1 rev-info) (egg-log-buffer-squash-mark)) "squash")
                      ((eq (nth 1 rev-info) (egg-log-buffer-fixup-mark)) "fixup")
                      ((eq (nth 1 rev-info) (egg-log-buffer-edit-mark)) "edit"))
                    (concat rebase-dir "git-rebase-todo.backup"))
      (setq tmp (buffer-string)))
    (with-egg-debug-buffer
      (erase-buffer)
      ;; debug
      (insert "upstream: " upstream "\n")
      (insert "onto: " onto "\n")
      (insert "orig-head: " orig-head-sha1 "\n")
      (insert (plist-get repo-state :head) "\n")
      (insert "TODO START:\n" tmp "TODO END:\n")
      

(defun egg-sentinel-commit-n-continue-rebase (prefix gpg-uid text-beg text-end next-beg
						     rebase-dir orig-buffer orig-sha1 commit-func)
  (let ((process-environment (copy-sequence process-environment)))
    (mapc (lambda (env-lst)
	    (setenv (car env-lst) (cadr env-lst)))
	  (egg-rebase-author-info rebase-dir))
    (apply commit-func prefix gpg-uid text-beg text-end next-beg nil))
  (with-current-buffer orig-buffer
    (egg-do-async-rebase-continue
     #'egg-handle-rebase-interactive-exit
     orig-sha1)))


(defun egg-search-for-regexps (re-value-alist)
  (save-match-data
    (let (re line)
      (dolist-done (item re-value-alist value)
	(setq re (car item))
	(goto-char (point-min))
	(when (re-search-forward re nil t)
	  (setq line (buffer-substring-no-properties (line-beginning-position)
						     (line-end-position)))
	  (setq value (cons (cdr item) line)))))))


	(debug-rebase-msg (buffer-string))
	(case-fold-search nil)
	(output-buffer (current-buffer))
        state buffer res msg rebase-dir match-code-line)

    (setq match-code-line
	  (egg-search-for-regexps
	   '(("error: could not apply" .			:rebase-conflict)
	     ("When you have resolved this problem" .		:rebase-conflict)
	     ("Automatic cherry-pick failed" .			:rebase-conflict)
	     ("Successfully rebased and updated" .		:rebase-done)
	     ("You can amend the commit now" .			:rebase-edit)
	     ("nothing added to commit" .			:rebase-empty)
	     ("nothing to commit (working directory clean)" .	:rebase-empty)
	     ("If you wish to commit it anyway" .		:rebase-empty)
	     ("Could not commit staged changes" .		:rebase-resolved)
	     ("You have uncommitted changes" .			:rebase-commit)
	     ("You have staged changes in your working tree" .	:rebase-commit)
	     ("Could not apply" .				:rebase-squash)
	     ("please commit in egg" .				:rebase-commit)
	     (": needs merge" .					:rebase-unmerged-file)
	     ("You must edit all merge conflicts" .		:rebase-unresolved)
	     ("\\(?:Cannot\\|Could not\\)" .			:rebase-fail)
	     )))

    (setq res (car match-code-line) msg (cdr match-code-line))
    
    (with-egg-debug-buffer
      ;; debug
      (goto-char (point-max))
      (insert "ASYNC-REBASE-MSG-BEGIN (" (symbol-name res) "):\n" 
	      debug-rebase-msg
	      "ASYNC-REBASE-MSG-END:\n")

      (when (eq res :rebase-resolved)
	(setq res (if (file-exists-p (concat (egg-git-rebase-dir) "amend"))
		      :rebase-amend :rebase-commit)))

      (cond ((eq res :rebase-done)
             (message "GIT-REBASE-INTERACTIVE> %s" msg)
	     (with-current-buffer (egg-get-log-buffer)
	       (egg-log-buffer-do-unmark-all)))

	    ((null res)
             (message "EGG got confused by rebase's output")
	     (pop-to-buffer output-buffer))

	    ((eq res :rebase-unresolved)
             (message "GIT-REBASE-INTERACTIVE: merge conflict(s) needs to be resolved an staged!"))
	    ((eq res :rebase-unmerged-file)
	     (let (file)
	       (save-match-data
	       	 (string-match "\\`\\([^:]+\\): needs merge" msg)
	       	 (setq file (match-string 1 msg)))
	       (message "GIT-REBASE-INTERACTIVE> merge %s before continue with rebase" file)))

            ((memq res '(:rebase-commit :rebase-amend))
                 (egg-text (concat (if (eq res :rebase-commit) "Commit " "Amend ")
				   cherry-op "ed cherry")
              (egg-log-msg-mk-closure-input #'egg-sentinel-commit-n-continue-rebase
					    rebase-dir buffer orig-sha1
					    (if (eq res :rebase-commit) 
						#'egg-log-msg-commit
					      #'egg-log-msg-amend-commit))
              (egg-file-as-string (concat rebase-dir "message")))

	     (message "please commit the changes to continue with rebase."))

	    ((eq res :rebase-squash)
             (egg-commit-log-edit
              (let* ((cherry (plist-get state :rebase-cherry))
                     (cherry-op (save-match-data (car (split-string cherry)))))
		(concat 
		 (egg-text "Rebasing " 'egg-text-3)
		 (egg-text (plist-get state :rebase-head) 'egg-branch) ": "
		 (egg-text (concat "Merge " cherry-op "ed cherry into last commit")
			   'egg-text-3)))
	      (egg-log-msg-mk-closure-input #'egg-sentinel-commit-n-continue-rebase
					    rebase-dir buffer orig-sha1 
					    #'egg-log-msg-amend-commit)
              (egg-file-as-string (concat rebase-dir "message")))
	     (message "please edit the combined message and commit the changes to continue with rebase."))
	      (egg-log-msg-mk-closure-input #'egg-sentinel-commit-n-continue-rebase
					    rebase-dir buffer orig-sha1 #'egg-log-msg-amend-commit)
              (egg-commit-message "HEAD"))
	     (message "please re-edit the message and commit the changes to continue with rebase."))
             (egg-status nil t :sentinel)
             (egg-status nil t :sentinel)
             (message "automatic rebase stopped! this empty commit should be skipped!"))
             (egg-status nil t :sentinel)
(defun egg-log-buffer-merge (pos &optional level)
  "Merge to HEAD the path starting from commit at POS.
With C-u prefix, do not auto commit the merge result.
With C-u C-u prefix, prompt the user for the type of merge to perform."
  (interactive "d\np")
  (let ((rev (egg-log-buffer-get-rev-at pos :no-HEAD :short))
	(merge-options-alist '((?c "(c)ommit" "" "--commit")
			       (?n "(n)o-commit" " (without merge commit)" "--no-commit")
			       (?s "(s)quash" " (without merge data)" "--squash")
			       (?f "(f)f-only" " (fast-forward only)" "--ff-only")))
        res option key)
      (egg-status nil nil)

    (setq option
	  (cond ((> level 15)
		 (or (assq (setq key
				 (string-to-char
				  (read-key-sequence
				   (format "merge option - %s: "
					   (mapconcat 'identity 
						      (mapcar 'cadr 
							      merge-options-alist)
						      " ")))))
			   merge-options-alist)
		     (error "Invalid choice:%c (must be one of: c,n,s,f)" key)))
		((> level 3) (nth 1 merge-options-alist))
		(t (car merge-options-alist))))

    (if  (null (y-or-n-p (format "merge %s to HEAD%s? " rev (nth 2 option))))
        (message "cancel merge from %s to HEAD%s!" rev (nth 2 option))
      (egg-log-buffer-do-merge-to-head rev (nth 3 option)))))

(defun egg-log-buffer-ff-pull (pos)
  (interactive "d")
  (unless (egg-repo-clean)
    (egg-status nil nil)
    (error "Repo is not clean!"))
  (egg-log-buffer-do-merge-to-head (egg-log-buffer-get-rev-at pos :short :no-HEAD)
				   "--ff-only"))

(defun egg-log-buffer-merge-n-squash (pos)
  (interactive "d")
  (unless (egg-repo-clean)
    (egg-status nil nil)
    (error "Repo is not clean!"))
  (egg-log-buffer-do-merge-to-head (egg-log-buffer-get-rev-at pos :short :no-HEAD) "--squash"))

(defun egg-log-buffer-rebase (pos)
  "Rebase HEAD using commit at POS as upstream.
If there was a commit marked as BASE, then rebase HEAD onto the commit under the
cursor using the BASE commit as upstream."
  (interactive "d")
  (let* ((mark (egg-log-buffer-find-first-mark (egg-log-buffer-base-mark)))
         (upstream (if mark (egg-log-buffer-get-rev-at mark :short)))
	 (onto (egg-log-buffer-get-rev-at pos :short :no-HEAD))
	 (head-name (egg-branch-or-HEAD))
	 res modified-files buf)

    (unless upstream
      (setq upstream onto)
      (setq onto nil))

    (unless upstream (error "No upstream to rebase on!"))

    (if (null (y-or-n-p (if onto 
			    (format "rebase %s..%s onto %s? " upstream head-name onto)
			  (format "rebase %s on %s? " head-name upstream))))
	(message (if onto
		     (format "cancelled rebasing %s..%s onto %s!" upstream head-name onto)
		   (format "cancelled rebasing %s on %s!" head-name upstream)) ))
    (egg-buffer-do-rebase upstream onto 'log)))

(defun egg-log-buffer-rebase-interactive (pos)
  "Start an interactive session to rebase the marked commits onto commit at POS."
  (interactive "d")
         (todo-alist (egg-log-buffer-get-rebase-marked-alist))
	 (r-commits (reverse commits))

    (unless (consp commits)
      (error "No commit selected! must select atleast one commit to rebase!"))

    (egg-setup-rebase-interactive rebase-dir upstream nil state todo-alist)
    (egg-status nil t)))
(defun egg-log-buffer-checkout-commit (pos &optional force)
  "Checkout ref or commit at POS.
With C-u prefix, force the checkout even if the index was different
from the new commit."
  (let ((ref (egg-read-rev "checkout: "
	      (egg-log-buffer-get-rev-at pos :short :no-HEAD))))
    (if force 
	(egg-log-buffer-do-co-rev ref "-f")
      (egg-log-buffer-do-co-rev ref))))
(defun egg-log-buffer-tag-commit (pos &optional force)
  "Tag commit at POS.
With C-u prefix, force the creation of the tag
even if it replace an existing one with the same name."
  (let* ((rev (egg-log-buffer-get-rev-at pos :short))
	 (name (read-string (format "tag %s with name: " rev)))
	 (egg--do-no-output-message 
	  (format "new lightweight tag '%s' at %s" name rev)))
    (egg-log-buffer-do-tag-commit name rev force)))

(defun egg-log-buffer-atag-commit (pos &optional sign-tag)
  "Start composing the message to create an annotated tag on commit at POS.
With C-u prefix, the tag will be gpg-signed."
  (interactive "d\np")
  (let* ((commit (get-text-property pos :commit))
	 (name (read-string (format "create annotated tag on %s with name: "
				    (egg-pretty-short-rev commit))))
	 (gpg-uid (cond ((> sign-tag 15) t) ;; use default gpg uid
			((> sign-tag 3)	    ;; sign the tag
			 (read-string (format "sign tag '%s' with gpg key uid: " name)
				      (egg-user-name)))
			(t nil)))
	 (gpg-agent-info 
	  (egg-gpg-agent-info "set GPG_AGENT_INFO environment to `%s' ")))
    (when (and gpg-uid (not gpg-agent-info))
      (error "gpg-agent's info is unavailable! please set GPG_AGENT_INFO environment!"))
    (egg-create-annotated-tag name commit gpg-uid)))
  "Create a new branch pointing to commit at POS, without checking it out.
With C-u prefix, force the branch creation by deleting the old one with the same name."
  (let ((rev (egg-log-buffer-get-rev-at pos :short))
	(upstream (egg-head-at pos)))
    (egg-buffer-do-create-branch 
     (read-string (format "create new branch at %s with name: " rev))
     rev force upstream 'log)))
  "Create a new branch pointing to commit at POS, and make it the new HEAD.
With C-u prefix, force the creation by deleting the old branch with the same name."
  (let ((rev (egg-log-buffer-get-rev-at pos :short :no-HEAD))
	(upstream (egg-head-at pos))
	(force (if force "-B" "-b"))
	name track)
    
    (setq name (read-string (format "start new branch from %s with name: " rev)))
    (setq track (if (and upstream
			 (y-or-n-p (format "should the branch '%s' track '%s'"
					   name upstream)))
		    "--track"
		  "--no-track"))
    (egg-log-buffer-handle-result
     (egg--git-co-rev-cmd t rev force name track))))

(defun egg-log-buffer-anchor-head (pos &optional strict-level)
  "Move the current branch or the detached HEAD to commit at POS.
The index will be reset and files will in worktree updated. If a file that is
different between the original commit and the new commit, the git command will
abort. This is basically git reset --keep.
With C-u prefix, HEAD will be moved, index will be reset and the work tree updated
by throwing away all local modifications (this is basically git reset --hard).
With C-u C-u prefix, prompt for the git reset mode to perform."
  (let* ((rev (egg-log-buffer-get-rev-at pos :short :no-HEAD))
         (commit (egg-commit-at-point pos))
         (hard (> strict-level 3))
         (ask (> strict-level 15))
	 (key-mode-alist '((?s . "--soft")
			   (?h . "--hard")
			   (?x . "--mixed")
			   (?k . "--keep")
			   (?m . "--merge")))
	 (reset-mode "--keep")
	 prompt mode-key)
    
    (setq prompt (format "%s to %s%s? "
                         (cond (ask (setq reset-mode "--bad") " (will prompt for advanced mode)")
                               (hard (setq reset-mode "--hard") " (throw away all un-committed changes)")
                               (t (setq reset-mode "--keep") " (but keep current changes)"))))
    (when (y-or-n-p prompt)
      (when ask
	(setq mode-key (read-key-sequence "git-reset: (s)oft (h)ard mi(x)ed (k)eep (m)erge? "))
	(setq mode-key (string-to-char mode-key))
	(setq reset-mode (cdr (assq mode-key key-mode-alist)))
	(unless (stringp reset-mode)
	  (error "Invalid choice: %c (must be one of s,h,x,k,m)" mode-key)))
      (egg-log-buffer-do-move-head reset-mode rev))))
  "Remove the ref at POS."
  (let ((refs (egg-references-at-point pos))
        (candidate (egg-ref-at-point pos))
	(full-name (get-text-property pos :full-name))
        victim parts delete-on-remote remote-site name-at-remote
	remote-ok)
    (if (invoked-interactively-p)
	(message "interactive")
      (message "non interactive"))
    (unless candidate (setq candidate (last refs)))
    (setq candidate (completing-read "remove reference: " refs nil nil candidate))
    (setq victim (egg-git-to-string "show-ref" candidate))
    (unless (stringp victim) (error "No such ref: %s!!!" candidate))
    (save-match-data
      (setq victim (nth 1 (split-string victim " " t)))
      (setq parts (and (stringp victim) (split-string victim "/" t))))
    
    (unless (equal (car parts) "refs") (error "Invalid ref: %s" victim))
    
    (setq remote-site (and (equal (nth 1 parts) "remotes") (nth 2 parts)))
    (setq name-at-remote (and remote-site (mapconcat 'identity (nthcdr 3 parts) "/")))
    (setq delete-on-remote (and remote-site
				(y-or-n-p (format "delete %s on %s too? "
						  name-at-remote remote-site))))
    (setq remote-ok 
	  (if delete-on-remote (egg--buffer-handle-result
				(egg--git-push-cmd (current-buffer) "--delete" 
						   remote-site name-at-remote))
	    t))
    (when remote-ok
      (egg-log-buffer-handle-result
       (egg--git-push-cmd (current-buffer) "--delete" "." victim)))))

(defun egg-log-buffer-do-pick-partial-cherry (rev head-name files &optional revert prompt cancel-msg)
  (if (not (y-or-n-p (or prompt (format "pick selected files from %s and put i on %s"
					rev head-name))))
      (message (or cancel-msg (format "Nah! that cherry (%s) looks rotten!!!" rev)))
    (let ((dir (egg-work-tree-dir))
	  (args (list "--3way"))
	  patch)
      (with-temp-buffer
	(setq default-directory dir)
	(unless (apply 'egg-git-ok t "--no-pager" "show" "--no-color" rev "--" files)
	  (error "Error retrieving rev %s" rev))
	(setq patch (buffer-string)))
      (when revert (setq args (cons "--reverse" args)))
      (egg--git-apply-cmd t patch args))))

(defun egg-log-buffer-do-pick-1cherry (rev head-name edit-commit-msg)
  (if (not (y-or-n-p (format "pick %s and put it on %s%s? " rev head-name
			     (if edit-commit-msg " (with new commit message)" ""))))
      (message "Nah! that cherry (%s) looks rotten!!!" rev)
    (egg--git-cherry-pick-cmd t rev (if edit-commit-msg "--no-commit" "--ff"))))

(defun egg-log-buffer-pick-1cherry (pos &optional edit-commit-msg)
  "Pick commit at POS and put on HEAD.
With C-u prefix, will not auto-commit but let the user re-compose the message."
  (interactive "d\nP")
  
  (let ((rev (egg-log-buffer-get-rev-at pos :short :no-HEAD))
	(selection (cdr (get-text-property pos :selection)))
	(head-name (egg-branch-or-HEAD))
	res modified-files old-msg)
    (unless (and rev (stringp rev))
      (error "No cherry here for picking! must be a bad season!" ))
    (when (string-equal rev "HEAD")
      (error "Cannot pick your own HEAD!"))

    (setq res (if (null selection)
		  (egg-log-buffer-do-pick-1cherry rev head-name edit-commit-msg)
		(setq edit-commit-msg t)
		(egg-log-buffer-do-pick-partial-cherry rev head-name selection)))

    (setq old-msg (egg-commit-message rev))
    (egg--buffer-handle-result-with-commit
     res (list (concat (egg-text "Newly Picked Cherry:  " 'egg-text-3)
		       (egg-text rev 'egg-branch))
	       (egg-log-msg-mk-closure-input #'egg-log-msg-commit)
	       old-msg)
     t 'log)))

(defsubst egg-log-buffer-do-revert-rev (rev use-default-commit-msg)
  (if (not (y-or-n-p (format "undo changes introduced by %s%s? " rev
			     (if use-default-commit-msg
				 " (with git's default commit message)" ""))))
      (message "Nah! that lump (%s) looks benign!!!" (egg-commit-subject rev))
    (egg--git-revert-cmd t rev use-default-commit-msg)))

(defsubst egg-log-buffer-do-selective-revert-rev (rev files)
  (egg-log-buffer-do-pick-partial-cherry 
   rev nil files t
   (format "undo changes introduced by selected files in %s? " rev)
   (format "Nah! that lump (%s) looks benign!!!" (egg-commit-subject rev))))

(defun egg-log-buffer-revert-rev (pos &optional use-default-commit-msg)
  (interactive "d\nP")
  (let ((sha1 (egg-log-buffer-get-rev-at pos :sha1))
	(rev (egg-log-buffer-get-rev-at pos :symbolic))
	(selection (cdr (get-text-property pos :selection)))
	res)
    (unless (and rev (stringp rev))
      (error "No tumour to remove here! very healthy body!" ))
    (when (and (string-equal rev "HEAD") (null selection))
      (error "Just chop your own HEAD (use anchor a.k.a git-reset)! no need to revert HEAD"))
    
    (setq res (if selection
		  (egg-log-buffer-do-selective-revert-rev rev selection)
		(egg-log-buffer-do-revert-rev rev use-default-commit-msg)))
    (egg--buffer-handle-result-with-commit
       res (list (concat
		  (egg-text "Undo Changes Introduced by:  " 'egg-text-3)
		  (egg-text rev 'egg-branch)) 
		 (egg-log-msg-mk-closure-input #'egg-log-msg-commit)
		 (format "Revert \"%s\"\n\nThis reverts commit %s\n" (egg-commit-subject sha1) sha1))
       t 'log)))
  "Download and update the remote tracking branch at POS."
  "Fetch some refs from remote at POS."
(defun egg-log-buffer-push-to-local (pos &optional level)
  "Push commit at POS onto HEAD.
With C-u prefix, instead of HEAD, prompt for another ref as destination.
With C-u C-u prefix, will force the push evel if it would be non-ff.
When the destination of the push is HEAD, the underlying git command
would be a pull (by default --ff-only)."
  (interactive "d\np")
  (let ((src (or (egg-ref-at-point pos)
		 (egg-log-buffer-get-rev-at pos :short :no-HEAD)))
	(prompt-dst (> level 3))
	(non-ff (> level 15))
	(head-name (egg-branch-or-HEAD))
	dst mark base)
    
    (setq mark (egg-log-buffer-find-first-mark (egg-log-buffer-base-mark)))
    (setq base (if mark (egg-log-buffer-get-rev-at mark :short)))
    (setq dst (or base head-name))

    (if (or prompt-dst (equal dst src))
	(setq dst (egg-read-local-ref (format "use %s to update: " src))))
    (if (y-or-n-p (format "push %s on %s%s? " src dst 
			  (if non-ff " (allowed non-ff move)" "")))
	(if (string-equal dst head-name)
	    (if non-ff
		(if (egg-repo-clean)
		    (egg-log-buffer-do-move-head "--hard" src)
		  (error "Can't push on dirty repo"))
	      (egg-log-buffer-do-merge-to-head src "--ff-only"))
	  (egg--git-push-cmd (current-buffer) (if non-ff "-vf" "-v")
			     "." (concat src ":" dst)))
      (message "local push cancelled!"))))
  "Push HEAD to the ref at POS."
  (let* ((dst (egg-ref-at-point pos)))
	(egg--git-push-cmd (current-buffer) (if non-ff "-v" "-vf")
			   "." (concat "HEAD:" dst))
      (message "local push cancelled!"))))
  "Upload the ref at POS to a remote repository.
If the ref track a remote tracking branch, then the repo to
upload to is the repo of the remote tracking branch. Otherwise,
prompt for a remote repo."
  "Push some refs to the remote at POS"
  "Move cursor to the next ref."
  (let ((current-ref (egg-references-at-point pos))
      (setq n-ref (egg-references-at-point n-pos))
  "Move cursor to the previous ref."
  (let ((current-ref (egg-references-at-point pos))
      (setq p-ref (egg-references-at-point p-pos))
(defun egg-log-diff-toggle-file-selection (pos)
  "(un)select the file at POS for the next partial cherry-pic/revert operation."
  (interactive "d")
  (let* ((diff (get-text-property pos :diff))
	 (diff-beg (and diff (nth 1 diff)))
	 (file (and diff (car diff)))
	 (selection (get-text-property pos :selection))
	 (files (and selection (cdr selection)))
	 (inhibit-read-only t))
    (unless (consp selection)
      (error "Cannot select a commit's file at the cursor!"))
    (unless (stringp file)
      (error "Failed to pick a commit's file at the cursor!"))
    (save-excursion
      (goto-char diff-beg)
      (setcdr selection
	      (if (member file files)
		  (progn
		    (put-text-property (line-end-position)
				       (1+ (line-end-position))
				       'display nil)
		    (delete file files))
		(put-text-property (line-end-position)
				   (1+ (line-end-position))
				   'display 
				   (propertize (string ?  egg-commit-file-select-mark ?\n)
					       'face 'egg-diff-file-header))
		(cons file files))))))

(defcustom egg-commit-box-chars "-|++"
  "horz line, vert line, up-left corner and low-left corner"
  :group 'egg
  :type '(radio :tag "Commit Box Characters"
		(const :tag "- | + +" "-|++")
		(vector :tag "Pick individual character"
			(radio :tag "line"
			       (const :tag "■" #x25a0)
			       (const :tag "□" #x25a1)
			       (const :tag "█" #x2588)))))

(defun egg-log-buffer-box-inserted-commit (beg end)
  (save-excursion
    (let ((inhibit-read-only t))
      (goto-char beg)
      (insert (aref egg-commit-box-chars 2)
	      (make-string 100 (aref egg-commit-box-chars 0))
	      "\n")
      (while (< (point) end)
	(forward-line 1)
	(insert (aref egg-commit-box-chars 1) " "))
      (forward-line 1)
      (insert (aref egg-commit-box-chars 3)
	      (make-string 100 (aref egg-commit-box-chars 0))
	      "\n"))))

(defun egg-log-buffer-do-insert-commit (pos &optional args highlight-regexp path-args)
          (ref (egg-references-at-point pos))
          commit-beg beg end diff-beg diff-end is-cc-diff face-end hide-sect-type)
      (setq commit-beg (line-beginning-position))
      (unless (egg-git-ok-args 
	       t (nconc (list "show" "--no-color" "--show-signature")
			(copy-sequence egg-git-diff-options)
			(copy-sequence args)
			(list (concat "--pretty=format:"
				      indent-spaces "%ai%n"
				      indent-spaces "%an%n"
				      "%b")
			      sha1)
			path-args))
      (setq end (point-marker))

      ;; car is the sha1 of the commit
      ;; cdr is a list of selected files from the commit.
      ;; use commit-beg to include the commit line as well
      (put-text-property commit-beg end :selection (list sha1))

      (save-excursion
	(save-match-data
	  (goto-char beg)
	  (while (re-search-forward "^\\(gpg\\|Signed-off-by\\):" end t)
	    (save-excursion
	      (goto-char (match-beginning 0))
	      (insert indent-spaces)))
	  (goto-char beg)
	  (setq is-cc-diff (re-search-forward "^@@@" end t))))
      (setq diff-end end)
                                 :hunk-map egg-log-hunk-map
				 :cc-diff-map egg-log-diff-map
                                 :cc-hunk-map egg-log-hunk-map)
      (setq diff-beg (or (next-single-property-change beg :diff) end))

      (while (< (point) diff-beg)
	(if (equal (buffer-substring-no-properties (line-beginning-position)
						   (+ (line-beginning-position)
						      indent-column))
		   indent-spaces)
	    (progn
	      (put-text-property (line-beginning-position) 
				 (+ (line-beginning-position) indent-column) 
				 'face 'egg-diff-none)
	      (put-text-property (+ (line-beginning-position) indent-column)
				 (line-end-position) 'face 'egg-text-2))
	  (put-text-property (line-beginning-position) (line-end-position) 
			     'face 'egg-text-2))
	(forward-line 1)
	(goto-char (line-end-position)))

      (when (stringp highlight-regexp)
	(egg-buffer-highlight-pickaxe highlight-regexp diff-beg diff-end is-cc-diff))
      (when (setq hide-sect-type (cdr (assq 'egg-log-buffer-mode 
					    egg-buffer-hide-section-type-on-start)))
	(egg-buffer-hide-section-type hide-sect-type beg end))
  "Load and show the details of commit at POS."
         (sha1 (and next (get-text-property next :commit)))
	 (pickaxe-args (and egg-internal-log-buffer-closure 
			(plist-get egg-internal-log-buffer-closure :pickaxe-args)))
	 (pickaxed-paths (and egg-internal-log-buffer-closure 
			(plist-get egg-internal-log-buffer-closure :paths)))
	 (highlight (and egg-internal-log-buffer-closure 
			 (plist-get egg-internal-log-buffer-closure :highlight))))
      (egg-log-buffer-do-insert-commit pos pickaxe-args highlight pickaxed-paths))))

(defun egg-log-show-marked-commits (marked-list)
  (when marked-list
    (let ((beg (point)) end sha1)
      (mapc (lambda (marked-commit)
	      (egg-log-buffer-do-mark (egg-log-buffer-get-commit-pos (egg-marked-commit-sha1 marked-commit))
				      (egg-marked-commit-mark marked-commit)
				      nil nil
				      :followed-by (egg-marked-commit-follower marked-commit)
				      :append-to (egg-marked-commit-leader marked-commit)))
	    marked-list)
      (goto-char beg)
      (insert (egg-text "Commits marked for interactive rebase!\n" 'egg-header))
      (dolist (commit marked-list)
	(setq sha1 (egg-marked-commit-sha1 commit))
	(insert " " 
		(egg-text (string (egg-marked-commit-mark commit)) 'egg-log-buffer-mark)
		" " 
		(egg-text (substring sha1 0 8) 'font-lock-constant-face)
		" "
		(egg-text (egg-marked-commit-subject commit) 'egg-text-2))
	(add-text-properties (line-end-position) (point)
			     (list :commit-sha1 sha1
				   :commit-pos (egg-marked-commit-marker commit)))
	(insert "\n"))
      (setq end (point))
      (insert "\n"))))
	(rebase-commits (plist-get egg-internal-log-buffer-closure :rebase-commits))
        inv-beg beg pos help-beg marked-alist)
    (setq marked-alist (unless init (egg-log-buffer-get-rebase-marked-alist)))
      (insert help)
                           inv-beg egg-section-map :help)
      (insert "\n")
      (if init (egg-buffer-maybe-hide-help :help)))
    (setq pos (point))
    (setq beg (or (funcall closure) pos))
    (when marked-alist
      (goto-char pos)
      (egg-log-show-marked-commits marked-alist))
    (goto-char beg)))
C-u \\[egg-log-buffer-tag-commit] create a new lightweight tag pointing at the current commit,
  replacing the old tag with the same name.
\\[egg-log-buffer-atag-commit] create a new annotated tag pointing at the current commit.
C-u \\[egg-log-buffer-atag-commit] create a new gpg-signed tag pointing at the current commit.
\\[egg-log-buffer-anchor-head] move HEAD (and maybe the current branch tip) as well as
the index to the current commit if it's safe to do so
 (the underlying git command is `reset --keep'.)
C-u \\[egg-log-buffer-anchor-head] move HEAD (and maybe the current branch tip) and
the index to the current commit, the work dir will also be updated,
uncommitted changes will be lost (the underlying git command is `reset --hard').
C-u C-u \\[egg-log-buffer-anchor-head] will let the user specify a mode to run git-reset.
\\[egg-log-buffer-push-to-local] update HEAD or BASE using the ref.
C-u \\[egg-log-buffer-push-to-local] update a local ref using the ref.
C-u C-u \\[egg-log-buffer-push-to-local] update (non-ff allowed) a local ref using the ref.
Each remote ref on the commit line has extra extra extra keybindings:\\<egg-log-remote-branch-map>
(defun egg-log-commit-line-menu-attach-head-ignore-changes (pos)
  (egg-log-buffer-anchor-head pos 4))
    (define-key map [update] (list 'menu-item "Push to HEAD or Another Local Branch"
    (define-key map [unmark] (list 'menu-item "Unmark for interactive Rebase "
    (define-key map [edit] (list 'menu-item "Mark for Editing in upcoming interactive Rebase "
    (define-key map [squash] (list 'menu-item "Mark to be Squashed in upcoming interactive Rebase "
    (define-key map [pick] (list 'menu-item "Mark to be Picked in upcoming interactive Rebase "
    (define-key map [rh-4] (list 'menu-item "Anchor HEAD (ignore changes)"
                                 'egg-log-commit-line-menu-attach-head-ignore-changes
                                 'egg-log-buffer-anchor-head
				  :enable ' (not (egg-head-at-point))
        (references (egg-references-at-point pos))
                    (egg-pretty-short-rev commit))))
        (with-current-buffer buffer
	  (goto-char pos)
	  (setq menu
		(nconc (list 'keymap
			     (egg-log-commit-line-menu-heading pos))
		       (cdr generic-menu)))
	  (setq keys (progn
		       (force-mode-line-update)
		       (x-popup-menu event menu)))
	  (setq cmd (and keys (lookup-key menu (apply 'vector keys))))
	  (when (and cmd (commandp cmd))
	    (call-interactively cmd)))))))
    "\\[egg-log-buffer-anchor-head]:anchor HEAD  "
    "\\[egg-log-buffer-push-to-local]:update HEAD (or a local ref) with ref  "
    "\\[egg-log-buffer-push-head-to-local]:update this ref with HEAD\n"
    "\\<egg-log-remote-branch-map>"
    "\\[egg-log-buffer-fetch-remote-ref]:download this ref from remote\n")
   (egg-text "  HEAD  " 'egg-log-HEAD-name) " "

(defun egg-log-buffer-diff-revs (pos &optional do-pickaxe pickaxe)
  "Compare HEAD against commit at POS.
With C-u prefix, prompt for a string and restrict to diffs introducing/removing it.
With C-u C-u prefix, prompt for a regexp and restrict to diffs introducing/removing it.
With C-u C-u C-u prefix, prompt for a pickaxe mode.
A ready made PICKAXE info can be provided by the caller when called non-interactively."
  (interactive "d\np")
         (mark (egg-log-buffer-find-first-mark (egg-log-buffer-base-mark)))
	 (head-name (egg-branch-or-HEAD))
         (base (if mark (egg-log-buffer-get-rev-at mark :short) head-name))
	 (pickaxe pickaxe)
	 buf diff-info)
    (unless pickaxe
      (setq pickaxe 
	    (egg-buffer-prompt-pickaxe "restrict diffs" :string (egg-string-at-point)
				       (> do-pickaxe 63)
				       (> do-pickaxe 15)
				       (> do-pickaxe 3))))
    (setq diff-info (egg-build-diff-info rev base nil pickaxe))
    (plist-put diff-info :command 
	       (lambda (prefix)
		 (interactive "p")
		 (egg-re-do-diff nil
				 (egg-buffer-prompt-pickaxe "restrict diffs" :string
							    (egg-string-at-point)
							    (> prefix 63)
							    (> prefix 15)
							    (> prefix 3))
				 nil)))
    (setq buf (egg-do-diff diff-info))
    (pop-to-buffer buf)))

(defun egg-log-buffer-diff-upstream (pos &optional do-pickaxe)
  "Compare commit at POS against its upstream."
  (interactive "d\np")
  (let* ((ref (egg-ref-at-point pos :head))
         (mark (egg-log-buffer-find-first-mark (egg-log-buffer-base-mark)))
         (upstream (if mark (egg-log-buffer-get-rev-at mark :symbolic)))
	 pickaxe buf diff-info)
    (unless (and ref (stringp ref))
      (error "No ref here to compare"))
    (when (equal ref upstream)
      (error "It's pointless to compare %s vs %s!" ref upstream))
    (unless (stringp upstream)
      (setq upstream (egg-read-ref (format "upstream of %s: " ref)
				    (egg-upstream ref))))
    (setq pickaxe
	  (egg-buffer-prompt-pickaxe "restrict diffs" :string (egg-string-at-point)
				     (> do-pickaxe 63)
				     (> do-pickaxe 15)
				     (> do-pickaxe 3)))
    (setq diff-info (egg-build-diff-info upstream ref nil pickaxe t))
    (plist-put diff-info :command 
	       (lambda (prefix)
		 (interactive "p")
		 (egg-re-do-diff nil
				 (egg-buffer-prompt-pickaxe "restrict diffs" :string
							    (egg-string-at-point)
							    (> prefix 63)
							    (> prefix 15)
							    (> prefix 3))
				 t)))
    (setq buf (egg-do-diff diff-info))
    (pop-to-buffer buf)))


(defun egg-insert-yggdrasil-with-decoration (ref &optional git-log-extra-options ignored)
  (egg-do-insert-n-decorate-yggdrasil ref git-log-extra-options))

(defun egg-do-insert-n-decorate-yggdrasil (refs &optional git-log-extra-options)
  (let* ((ref (cond ((stringp refs) 
		     (setq refs (list refs))
		     (car refs))
		    ((consp refs)
		     (car refs))))
	 (mappings 
	  (cdr (egg-git-to-lines 
		"--no-pager" "log" "-g" "--pretty=%H~%gd%n" 
		(format "--max-count=%d" (1+ egg-max-reflogs))
		(concat ref "@{now}"))))
	 (beg (point)) 
	 (head-name (egg-branch-or-HEAD))
	 sha1-list sha1-reflog-alist sha1 reflog-time time reflog dup pair)
    (setq mappings (save-match-data 
		     (mapcar (lambda (line) 
			       (split-string line "~" t)) 
			     mappings)))
    (save-match-data
      (dotimes (i (length mappings))
	(setq pair (pop mappings))
	(setq sha1 (car pair))
	(setq reflog-time (cadr pair))
	(setq reflog (format "%s@{%d}" ref (1+ i)))
	(string-match "{\\(.+\\)}\\'" reflog-time)
	(setq time (match-string-no-properties 1 reflog-time))
	(put-text-property 0 (length reflog) :reflog (substring-no-properties reflog) reflog)
	(put-text-property 0 (length reflog) 'face 'egg-reflog-mono reflog)
	(put-text-property 0 (length reflog) :time time reflog)
	(setq dup (assoc sha1 sha1-reflog-alist))
	(if dup
	    (setcdr dup (cons reflog (cdr dup)))
	  (add-to-list 'sha1-list sha1)
	  (add-to-list 'sha1-reflog-alist (list sha1 reflog)))))

    (egg-run-git-log (nconc refs sha1-list) 
		     (append '("--graph" "--topo-order") git-log-extra-options))
    (goto-char beg)
    (egg-decorate-log egg-log-commit-map
                      egg-log-local-branch-map
                      egg-log-local-ref-map
                      egg-log-remote-branch-map
                      egg-log-remote-site-map
		      sha1-reflog-alist)))


(defun egg-build-log-closure (refs file-name buf help &optional single-mom &rest closure-items)
  "Show the commit DAG of REF-NAME.
if SINGLE-MOM is non-nil, only show the first parent.
if FILE-NAME is non-nil, restrict the logs to the commits modifying FILE-NAME."
  (let* ((ref-name (cond ((stringp refs) (setq refs (list refs)) (car refs))
			 ((consp refs) (car refs))))
	 (egg-internal-current-state
         (default-directory (egg-work-tree-dir 
			     (egg-git-dir (invoked-interactively-p))))
	 (description (concat (egg-text "history scope: " 'egg-text-2)
			      (if ref-name 
				  (egg-text ref-name 'egg-term)
				(egg-text "all refs" 'egg-term))))
         paths decorating-func)
      (when single-mom
	(setq single-mom (list "--first-parent")))
      (when file-name
	(setq paths (list file-name)))
      (setq decorating-func
	    (if (and (null file-name) ref-name)
		#'egg-insert-yggdrasil-with-decoration
	      #'egg-insert-logs-with-full-decoration))
       (append (list :description description
		     :closure
		     `(lambda ()
			(,decorating-func (list ,@refs) (list ,@single-mom) (list ,@paths))))
	       closure-items))
      (when (and (memq :log egg-show-key-help-in-buffers) help)
	(plist-put egg-internal-log-buffer-closure :help help))
      egg-internal-log-buffer-closure)))

(defun egg-log-interactive ()
  (let ((level (prefix-numeric-value current-prefix-arg))
	(head-name (egg-branch-or-HEAD))
	(pickup (egg-string-at-point))
	ref)
    (cond ((> level 15) ;; ask
	   (setq ref (egg-read-ref "show history of: " (or pickup head-name) t))
	   (if (equal ref "") (setq ref nil))
	   (list (if (and (not (equal head-name ref))
			  (y-or-n-p (format "combine history with %s? " head-name)))
		     (list ref head-name)
		   ref)
		 (y-or-n-p "only show 1st parent? ")))
	  ((> level 3) ;; all refs
	   (list nil))
	  (t ;; default head
	   (list head-name)))))

(defun egg-log (ref-name &optional single-mom)
  "Show the commit DAG of REF-NAME."
  (interactive (egg-log-interactive))
  (let* ((egg-internal-current-state
          (egg-repo-state (if (invoked-interactively-p) :error-if-not-git)))
         (default-directory (egg-work-tree-dir 
			     (egg-git-dir (invoked-interactively-p))))
         (buf (egg-get-log-buffer 'create)))
    (egg-build-log-closure ref-name nil buf egg-log-buffer-help-text single-mom
			   :command 'egg-log)
    (egg-log-buffer-redisplay buf 'init)
    (cond (egg-switch-to-buffer (switch-to-buffer buf))
	  (t (pop-to-buffer buf)))))


  (egg-log-style-buffer-mode 'egg-file-log-buffer-mode
			     "Egg-FileHistory"
			     egg-log-buffer-mode-map
			     'egg-file-log-buffer-mode-hook))

(defvar egg-rev-file-buffer-closure nil)

(defun egg-grok-n-map-single-hunk-buffer (header-end prefix-len prefix-mapping)
  (let* ((inhibit-read-only t)
	 (prefix (make-string prefix-len ? )) ;; start with no-change
	 (range (list :type (cdr (assoc prefix prefix-mapping)) :beg nil :end nil))
	 ranges-list line-start)
    (delete-region (point-min) header-end)
    (goto-char (point-min))
    (plist-put range :beg (point))
    (while (not (eobp))
      (setq line-start (buffer-substring-no-properties (point) (+ (point) prefix-len)))
      (delete-region (point) (+ (point) prefix-len))
      (unless (equal line-start prefix) ;; keep going if it's same prefix
	(plist-put range :end (point))
	(setq ranges-list (cons range ranges-list))
	(setq prefix line-start)
	(setq range (list :type (cdr (assoc prefix prefix-mapping))
			  :beg (point) :end nil)))
      (forward-line 1)
      (goto-char (line-beginning-position)))
    ranges-list))

(defun egg-decorate-single-hunk-buffer (ranges-list mode)
  (funcall mode)
  (dolist (range ranges-list)
    (let* ((beg (plist-get range :beg))
	   (end (plist-get range :end))
	   (type (plist-get range :type))
	   (ov (make-overlay beg end)))
      (overlay-put ov 'evaporate t)
      (overlay-put ov 'face (cdr (assq type '((add . egg-add-bg)
					      (del . egg-del-bg))))))))

(defun egg-file-log-walk-show-buffer ()
  (let ((pos (point))
	(log-buffer (current-buffer))
	(dir (egg-work-tree-dir))
	(repo (egg-repo-name))
	(git-name (car (plist-get egg-internal-log-buffer-closure :paths)))
	(rev-file-buffer (plist-get egg-internal-log-buffer-closure :rev-file-buffer))
	(inhibit-read-only inhibit-read-only)
	sha1 short-sha1 mode cc-diff ranges-list)
    (setq sha1 (egg-commit-at-point))
    (setq short-sha1 (and sha1 (egg-short-sha1 sha1)))
    (setq mode (assoc-default git-name auto-mode-alist 'string-match))
    (unless (and (bufferp rev-file-buffer) (buffer-live-p rev-file-buffer))
      (setq rev-file-buffer (get-buffer-create (concat "*egg@" git-name "*")))
      (plist-put egg-internal-log-buffer-closure :rev-file-buffer rev-file-buffer))
    (with-current-buffer rev-file-buffer
      (setq default-directory dir)
      (setq inhibit-read-only t)
      (erase-buffer)
      (egg-git-show-file t git-name sha1 "-U1000000000")
      ;; (egg-git-ok t "--no-pager" "show" "--patience" "-U1000000000" sha1 "--" git-name)
      (rename-buffer (concat "*" repo ":" short-sha1 "@" git-name "*"))
      (set (make-local-variable 'egg-rev-file-buffer-closure)
	   (list :sha1 sha1 :path git-name :work-tree dir))
      (goto-char (point-min))
      (save-match-data
	(re-search-forward "^@@\\(@\\)?.+@@\\(@\\)?\n")
	(setq cc-diff (and (match-beginning 1) (match-beginning 2))) ;; the delta is a cc diff
	(setq ranges-list 
	      (egg-grok-n-map-single-hunk-buffer
	       (match-end 0) (if cc-diff 2 1)
	       (if cc-diff '(("  " . keep)
			     ("++" . add)
			     ("+ " . add)
			     (" +" . add)
			     ("--" . del)
			     ("- " . del)
			     (" -" . del)
			     ("+-" . bad)
			     ("-+" . bad))
		 '((" " . keep)
		   ("+" . add)
		   ("-" . del))))))
      (egg-decorate-single-hunk-buffer ranges-list mode)
      (set-buffer-modified-p nil)
      (setq buffer-read-only t)
      (put-text-property (point-min) (point-max) :commit sha1))
    (display-buffer rev-file-buffer t)))

(defun egg-file-log-walk-rev-next ()
  (interactive)
  (egg-buffer-cmd-next-block :commit)
  (egg-file-log-walk-show-buffer))

(defun egg-file-log-walk-rev-prev ()
  (interactive)
  (egg-buffer-cmd-prev-block :commit)
  (egg-file-log-walk-show-buffer))

(defun egg-file-log-walk-current-rev ()
  (interactive)
  (when (egg-commit-at-point)
    (egg-file-log-walk-show-buffer)))
    "\\<egg-secondary-log-commit-map>"
    "\\[egg-log-buffer-anchor-head]:anchor HEAD  "
  "Show the commits in the current branch's DAG that modified FILE-NAME.
if ALL is not-nil, then do not restrict the commits to the current branch's DAG."
  (let ((egg-internal-current-state
	 (egg-repo-state (if (invoked-interactively-p) :error-if-not-git)))
	(default-directory (egg-work-tree-dir 
			    (egg-git-dir (invoked-interactively-p))))
	(buffer (egg-get-file-log-buffer 'create))
	(head-name (egg-branch-or-HEAD))
	(title (concat (egg-text "history of " 'egg-text-2) (egg-text file-name 'egg-term)))
	ref help single-mom)
    (egg-build-log-closure (if all nil head-name) 
			   file-name buffer egg-file-log-help-text single-mom
			   :title title
			   :command `(lambda (&optional all)
				       (interactive "P")
				       (egg-file-log ,file-name all)))
    (cond (egg-switch-to-buffer (switch-to-buffer buffer))
	  (t (pop-to-buffer buffer)))))
    (set-keymap-parent map egg-secondary-log-commit-map)
    (define-key map (kbd "=") 'egg-query:commit-buffer-diff-revs)
    ;;


(defun egg-query:commit-buffer-diff-revs (pos prefix)
  (interactive "d\np")
  (let* ((rev (egg-log-buffer-get-rev-at pos :short))
	 (mark (egg-log-buffer-find-first-mark (egg-log-buffer-base-mark)))
	 (head-name (egg-branch-or-HEAD))
	 (base (if mark (egg-log-buffer-get-rev-at mark :short) head-name))
	 (pickaxe (plist-get egg-internal-log-buffer-closure :pickaxe))
	 (file (nth 1 (plist-get egg-internal-log-buffer-closure :paths)))
	 buf diff-info)
    (unless (and rev (stringp rev))
      (error "No commit here to compare against %s!" base))
    (when (string-equal rev base)
      (error "It's pointless to compare %s vs %s!" rev base))
    (setq diff-info (egg-build-diff-info rev base file pickaxe nil))
    (plist-put diff-info :command
	       (if file `(lambda () (egg-re-do-diff ,file nil nil))
		 (lambda (prefix)
		   (interactive "p")
		   (egg-re-do-diff nil (egg-buffer-prompt-pickaxe "restrict diffs" :string
								  (egg-string-at-point)
								  (> prefix 15)
								  (> prefix 3)
								  t)
				   nil))))
    (pop-to-buffer (egg-do-diff diff-info))))

(defun egg-do-locate-commit (sha1)
  (let ((buf (egg-get-log-buffer 'create))
	(head-name (egg-branch-or-HEAD))
	(short-sha1 (egg-short-sha1 sha1))
	pos)
    (setq short-sha1 (egg-short-sha1 sha1))
                         (egg-text head-name 'egg-term)
                         (egg-text short-sha1 'egg-term))
                 `(lambda ()
		    (egg-insert-logs-with-full-decoration (list ,head-name ,sha1)))))
    (pop-to-buffer buf)
(defun egg-log-locate-commit (pos)
  "Relocate the commit at POS back to the full history in the log buffer."
  (interactive "d")
  (egg-do-locate-commit (get-text-property pos :commit)))

  (egg-log-style-buffer-mode 'egg-query:commit-buffer-mode
			     "Egg-Query:Commit")
  (setq egg-buffer-refresh-func #'egg-query:commit-buffer-rerun)
(defun egg-async-mark-log-buffer-commits (args log-buffer closure)
  "Run pickaxe as specified in ARGS asynchronously then mark the commits in LOG-BUFFER.
CLOSURE specifies how the commits will be marked."
  (egg-async-0-args
   (list (lambda (log-buffer closure)
	   (let ((all-commits (plist-get closure :commits))
		 (matched-mark (plist-get closure :matched-mark))
		 (unmatched-mark (plist-get closure :unmatched-mark))
		 (commits (save-match-data 
			   (goto-char (point-min))
			   (re-search-forward "EGG-GIT-OUTPUT:\n")
			   (split-string (buffer-substring-no-properties 
					  (match-end 0)
					  (point-max))
					 "\n" t)))
		 pos wins)
	     (with-current-buffer log-buffer
	       (dolist (commit all-commits)
		 (egg-buffer-goto-section commit)
		 (egg-log-buffer-do-mark (point) (if (member commit commits) 
						     matched-mark
						   unmatched-mark)))
	       (setq pos (point)))
	     (setq wins (get-buffer-window-list log-buffer))
	     (when (consp wins)
	       (dolist (win wins)
		 (set-window-point win pos)))))
	 log-buffer closure)
   (nconc (list "--no-pager" "log" "--pretty=%H" "--no-color")
	  args)))

(defun egg-log-buffer-mark-commits-matching (level &optional default-search-term)
  "Mark commits between HEAD and the commit under POINT for rebase.
Prompt user for a search term and the type of match (string, regex or line).
For each commits between the commit under POINT and HEAD, if the commit introduced
or removed the term, then mark the commit as EDIT for the up-comming interactive
rebase. Otherwise mark the commit as PICK."
  (interactive (list (prefix-numeric-value current-prefix-arg)
		     (egg-string-at-point)))
  (let* ((end-rev (egg-branch-or-HEAD))
	 (start-rev (egg-commit-at-point))
	 (revs (concat start-rev ".." end-rev))
	 (all-commits (egg-git-to-lines "--no-pager" "log" "--pretty=%H" revs))
	 (pickaxe-term (egg-buffer-prompt-pickaxe "mark commits" :string default-search-term
						  (> level 15) (> level 3) t))
	 (args (cond ((stringp pickaxe-term) (list "-S" pickaxe-term))
		     ((and (consp pickaxe-term) (memq :regexp pickaxe-term))
		      (list  "--pickaxe-regex" "-S" (car pickaxe-term)))
		     ((and (consp pickaxe-term) (memq :line pickaxe-term))
		      (list "-G" (car pickaxe-term))))))
    (setq args (nconc args (list revs)))
    (egg-async-mark-log-buffer-commits args (current-buffer)
				       (list :matched-mark (egg-log-buffer-edit-mark)
					     :unmatched-mark (egg-log-buffer-pick-mark)
					     :commits all-commits))))

(defun egg-async-insert-n-decorate-query-logs (args)
  (let* ((closure egg-internal-log-buffer-closure)
	 (fetched-data (and closure (plist-get closure :fetched-data)))
	 (beg (point)))
    (cond ((null fetched-data)
	   (insert "\t" (egg-text "Please be patient! Searching in background..." 'egg-text-2))
	   (egg-async-0-args 
	    (list (lambda (log-buffer closure) 
		    (let ((output (save-match-data 
				    (goto-char (point-min))
				    (re-search-forward "EGG-GIT-OUTPUT:\n")
				    (split-string (buffer-substring-no-properties 
						   (match-end 0)
						   (point-max))
						  "\n" t))))
		      (plist-put closure :fetched-data
				 (if output output "Nothing found!!!"))
		      (egg-refresh-buffer log-buffer)))
		  (current-buffer) closure)
	    (nconc (list "--no-pager" "log" "--pretty=oneline" "--decorate=full" "--no-color")
		   args)))

	  ((stringp fetched-data)
	   (insert fetched-data "\n"))

	  ((consp fetched-data)
	   (dolist (line fetched-data)
	     (insert line "\n"))
	   (goto-char beg)
	   (egg-decorate-log egg-query:commit-commit-map
			     egg-query:commit-commit-map
			     egg-query:commit-commit-map
			     egg-query:commit-commit-map))
	  (t (error "fetched-data is: %s" fetched-data)))
    beg))

(defun egg-do-search-file-changes (prefix default-term file-name search-action-format
					  &optional do-all)
  (let* ((head-name (egg-branch-or-HEAD))
	 (file-name (or file-name (buffer-file-name)))
	 (short-name (file-name-nondirectory file-name))
	 (search-action (format search-action-format short-name head-name))
	 (pickaxe (egg-buffer-prompt-pickaxe search-action :string default-term
					     (> prefix 15) (> prefix 3) t))
	 (closure (egg-do-search-changes pickaxe file-name (and do-all (list "--all"))))) 
    (plist-put closure :command
	       `(lambda (prefix default-term)
		  (interactive (list (prefix-numeric-value current-prefix-arg)
				     (egg-string-at-point)))
		  (egg-do-search-file-changes prefix default-term 
					      ,file-name
					      ,search-action-format
					      ,do-all)))
    closure))


(defun egg-search-file-changes (prefix &optional default-term file-name)
  "Search current file's history for changes introducing or removing a string
term, default to DEFAUL-TERM. The search is restricted to the current branch's history.
With C-u prefix, search for a regexp instead of a string.
With C-u C-u prefix, prompt the user for advanced search mode."
  (interactive (list (prefix-numeric-value current-prefix-arg)
		     (egg-string-at-point)))
  (egg-do-search-file-changes prefix default-term file-name "search %s's history in %s"))

(defun egg-search-file-changes-all (prefix &optional default-term file-name)
  "Search current file's history for changes introducing or removing a string
term, default to DEFAUL-TERM. The search is done on the full history.
With C-u prefix, search for a regexp instead of a string.
With C-u C-u prefix, prompt the user for advanced search mode."
  (interactive (list (prefix-numeric-value current-prefix-arg)
		     (egg-string-at-point)))
  (egg-do-search-file-changes prefix default-term file-name "search %s's full history"
			      'all))

(defun egg-search-changes (prefix default-term)
  "Search the current branch's history for changes introducing/removing a term.
DEFAULT-TERM is the default search term."
  (interactive (list (prefix-numeric-value current-prefix-arg)
		     (egg-string-at-point)))
  (let* ((mark (egg-log-buffer-find-first-mark (egg-log-buffer-base-mark)))
	 (head-name (egg-branch-or-HEAD))
	 (start-rev (if mark (egg-log-buffer-get-rev-at mark :short)))
	 (revs (and start-rev (list (concat start-rev "^.." head-name))))
	 (pickaxe (egg-buffer-prompt-pickaxe 
		   (if revs (concat "search " (car revs))
		     (format "search %s's history" head-name))
		   :string default-term 
		   (> prefix 15) (> prefix 3) t))
	 closure)
    (setq closure (egg-do-search-changes pickaxe nil revs))
    (plist-put closure :command
	       (lambda (prefix default-term)
		 (interactive (list (prefix-numeric-value current-prefix-arg)
				    (egg-string-at-point)))
		 (egg-search-changes prefix default-term)))
    closure))



(defun egg-search-changes-all (prefix default-term)
  "Search entire history for changes introducing/removing a term.
DEFAULT-TERM is the default search term.
If called non-interactively, the caller can provide ready-made PICKAXE info
and a FILE-NAME. If FILE-NAME is non-nil then restrict the search to FILE-NAME's
history."
  (interactive (list (prefix-numeric-value current-prefix-arg)
		     (egg-string-at-point)))
  (let* ((pickaxe (egg-buffer-prompt-pickaxe "search entire history"
					     :string default-term 
					     (> prefix 15) (> prefix 3) t))
	 closure)
    (setq closure (egg-do-search-changes pickaxe nil (list "--all")))
    (plist-put closure :command
	       (lambda (prefix default-term)
		 (interactive (list (prefix-numeric-value current-prefix-arg)
				    (egg-string-at-point)))
		 (egg-search-changes-all prefix default-term)))
    closure))

(defun egg-do-search-changes (pickaxe file-name &optional extras)
  "Pickaxe history for TERM.
TERM is specified by PICKAXE-TYPE to be either a string, a regexp or a line-matching regexp.
If CASE-INSENSITIVE is non nil, then regexp matching will ignore case.
If FILE-NAME is non nil then only search the file history instead of the repo's history.
EXTRAS is what ever arguments should be added to the git log command."
  (let* ((default-directory (egg-work-tree-dir (egg-git-dir t)))
	 (git-file-name (if file-name (file-relative-name file-name)))
	 (label-prefix (if git-file-name
			   (concat git-file-name "'s commits")
			 "Commits "))
	 (term (egg-pickaxe-term pickaxe))
	 (highlight (egg-pickaxe-highlight pickaxe))
	 (pickaxe-args (egg-pickaxe-to-args pickaxe))
	 (label (egg-pickaxe-pick-item pickaxe
				       (concat label-prefix " containing: ")
				       (concat label-prefix " containing regexp: ")
				       (concat label-prefix " with lines matching: ")))
	 args desc func help closure)

    (setq args (append pickaxe-args extras (if git-file-name (list "--" git-file-name))))
    (setq desc (concat (egg-text label 'egg-text-2) (egg-text term 'egg-term)))
    (setq func `(lambda ()
		  (egg-async-insert-n-decorate-query-logs (list ,@args))
		  ))

           (list :description desc :closure func
		 :highlight highlight
		 :pickaxe pickaxe
		 :pickaxe-args pickaxe-args
		 :paths (when git-file-name (list "--" git-file-name))))
      (when (memq :query egg-show-key-help-in-buffers)
        (setq help egg-log-style-help-text))
      (if help (plist-put egg-internal-log-buffer-closure :help help))
      (setq closure egg-internal-log-buffer-closure)
    (pop-to-buffer buf)
    closure))

(defun egg-do-grep-commit (grep-info revs)
  "Grep commit's for words.
REVS are revision to search for or '--all'.
GREP-INFO is plist with
:regexp posix regular-expression to search for.
:author regular-expression to match the author's name.
:committer regular-expression to match the commiter's name.
:match-all if non-nil, then limits the commits to the ones which match all regexps instead
of at least one."
  (let* ((default-directory (egg-work-tree-dir (egg-git-dir t)))
         (buf (egg-get-query:commit-buffer 'create))
	 (desc "")
	 (op-name "or")
	 (first-criterion t)
	 regex args func help closure)
    
    (when (plist-get grep-info :match-all)
      (add-to-list 'args "--all-match")
      (setq op-name "and"))
    (when (setq regex (plist-get grep-info :author))
      (add-to-list 'args (concat "--author=" regex))
      (setq desc (concat desc (if first-criterion
				  (egg-text "Commits" 'egg-text-2) 
				(egg-text op-name 'egg-text-2))			 
			 (egg-text " with author: " 'egg-text-2)
			 (egg-text regex 'egg-term) "\n"))
      (setq first-criterion nil))
    (when (setq regex (plist-get grep-info :committer))
      (add-to-list 'args (concat "--committer=" regex))
      (setq desc (concat desc (if first-criterion
				  (egg-text "Commits" 'egg-text-2) 
				(egg-text op-name 'egg-text-2))			 
			 (egg-text " with commiter: " 'egg-text-2)
			 (egg-text regex 'egg-term) "\n"))
      (setq first-criterion nil))
    (when (setq regex (plist-get grep-info :regexp))
      (add-to-list 'args (concat "--grep=" regex))
      (setq desc (concat desc (if first-criterion
				  (egg-text "Commits" 'egg-text-2) 
				(egg-text op-name 'egg-text-2))			 
			 (egg-text " with message matching: " 'egg-text-2)
			 (egg-text regex 'egg-term) "\n"))
      (setq first-criterion nil))
    
    (setq args (nconc args revs))
    (setq func `(lambda ()
		  (egg-async-insert-n-decorate-query-logs (list ,@args))
		  ))

    (with-current-buffer buf
      (set (make-local-variable 'egg-internal-log-buffer-closure)
           (list :description desc :closure func
		 :grep-args args))
      (when (memq :query egg-show-key-help-in-buffers)
        (setq help egg-log-style-help-text))
      (if help (plist-put egg-internal-log-buffer-closure :help help))
      (setq closure egg-internal-log-buffer-closure)
      (egg-query:commit-buffer-rerun buf 'init))
    (pop-to-buffer buf)
    closure))

(defun egg-grep-commit (prefix term)
  "Grep files tracked by git."
  (interactive (list (prefix-numeric-value current-prefix-arg)
		     (egg-string-at-point)))
  (let (info)
    (setq info (list :regexp
		     (read-string "Search for commits with message matching: " term)))
    (when (> prefix 3)
      (plist-put info :author
		 (read-string "Search for commits with author: ")))
    (when (> prefix 15)
      (plist-put info :committer
		 (read-string "Search for commits with commiter: ")))
    (when (> (length info) 2)
      (if (y-or-n-p "limits commits to those matching ALL criteria? ")
	  (plist-put info :match-all t)))
    (egg-do-grep-commit info nil)))

(defun egg-reflog (ref &optional prefix)
  "Show commit DAG of BRANCH and its reflogs.
This is just an alternative way to launch `egg-log'"
  (interactive (list (egg-branch-or-HEAD) (prefix-numeric-value current-prefix-arg)))
  (let ((head-name (egg-branch-or-HEAD)))
    (egg-log 
     (delq nil
	   (cond ((> prefix 15) 
		  (setq ref (egg-read-ref "show history of ref: " ref))
		  (list ref
			(unless (equal head-name ref)
			  (when (and (y-or-n-p 
				      (format "combine %s's history with %s? " 
					      ref head-name)))
			    head-name))))
		 ((> prefix 3) 
		  (setq ref (egg-read-ref "show history of ref: " ref))
		  (list ref (unless (equal head-name ref) head-name)))
		 (t (list ref)))))))

(defun egg-log-buffer-reflog-ref (pos &optional prefix)
  "Show reflogs for the ref at POS"
  (interactive "d\np")
  (egg-reflog (egg-ref-at-point) prefix))
(defun egg-buffer-do-insert-stash (pos)
      (unless (egg-git-ok-args t
			       (append '("stash" "show" "-p")
				       egg-git-diff-options
				       (list "--src-prefix=BASE:/" "--dst-prefix=WIP:/"
					     stash)))
(defun egg-sb-buffer-do-unstash (cmd &rest args)
  (let ((default-directory (egg-work-tree-dir))
	(cmd (or cmd "pop")))
    (unless (egg-has-stashed-wip)
      (error "No WIP was stashed!"))
    (unless (egg-repo-clean)
      (unless (y-or-n-p (format "repo is NOT clean, still want to apply stash? "))
	(error "stash %s cancelled!" cmd)))
    (egg-status-buffer-handle-result (egg--git-stash-unstash-cmd t cmd args))))
(defun egg-sb-buffer-apply-stash (pos &optional prefix)
  "Apply the stash at POS."
  (interactive "d\np")
  (let* ((stash (get-text-property pos :stash))
	 (args (list "--index" stash))
	 (do-it t))
    (when (stringp stash)
      (cond ((and (> prefix 15)
		  (not (y-or-n-p (format "apply WIP %s with index? " stash))))
	     (setq args (list stash)))
	    ((< prefix 4)
	     (setq do-it (y-or-n-p (format "apply WIP %s to repo? " stash)))))
      (when do-it
	(apply #'egg-sb-buffer-do-unstash "apply" args)))))

(defun egg-sb-buffer-pop-stash (&optional no-confirm)
  "Pop and apply the stash at POS."
    (egg-sb-buffer-do-unstash "pop" "--index")))
(defun egg-sb-buffer-drop-stash (pos &optional all)
  "Drop the stash at POS."
  (interactive "d\nP")
  (let ((stash (get-text-property pos :stash)))
    (unless stash
      (error "No stash here!!!"))
    (if all
	(error "Drop all stash not supported yet!")
      (when (y-or-n-p (format "delete %s? " stash)) 
	(egg-status-buffer-handle-result (egg--git-stash-drop-cmd (current-buffer) stash))))))

(defun egg-status-buffer-stash-wip (msg &optional include-untracked)
  "Stash current work-in-progress in workdir and the index.
MSG is the is the description for the WIP. Also stash untracked/unignored files
if INCLUDE-UNTRACKED is non-nil."
  (interactive "sshort description of this work-in-progress: \nP")
  (let ((default-directory (egg-work-tree-dir))
	(include-untracked (and include-untracked
				(y-or-n-p "stash untracked files too? ")))
	res files action)
    (if (egg-repo-clean)
        (error "No WIP to stash")
      (setq res (if include-untracked
		    (egg--git-stash-save-cmd t "-u" msg)
		  (egg--git-stash-save-cmd t msg)))
      (when (egg-status-buffer-handle-result res)
	(egg-buffer-goto-section "stash-stash@{0}")))))
;;;========================================================
;;; annotated tag
;;;========================================================
;; (setenv "GPG_AGENT_INFO" "/tmp/gpg-peL1m4/S.gpg-agent:16429:1")
;; (getenv "GPG_AGENT_INFO")
(defun egg-tag-msg-create-tag (prefix gpg-uid text-beg text-end ignored name commit)
  (if gpg-uid				;; sign the tag
      (let ((egg--do-no-output-message (format "signed %s with tag '%s'" commit name))
	    (gpg-agent-info (egg-gpg-agent-info 'set))
	    (force (> prefix 3)))
	(unless gpg-agent-info
	  (error "gpg-agent's info is unavailable! please set GPG_AGENT_INFO environment!"))
	(egg--async-create-signed-tag-cmd (egg-get-log-buffer)
					  (buffer-substring-no-properties text-beg text-end)
					  name commit gpg-uid force))
    (let ((egg--do-no-output-message (format "annotated %s with tag '%s'" commit name))
	  (force (> prefix 3)))
      (egg-edit-buffer-do-create-tag name commit text-beg text-end force))))
(defun egg-create-annotated-tag (name commit-1 &optional gpg-uid)
         (default-directory (egg-work-tree-dir git-dir))
         (pretty (egg-pretty-short-rev commit))
         (inhibit-read-only inhibit-read-only)
	 text-beg text-end)
    (pop-to-buffer buf)
    
    (insert (egg-text "Create Annotated Tag" 'egg-text-2) "  "
	    (egg-text name 'egg-branch) "\n"
            (egg-text "on commit:" 'egg-text-1) " "
            (egg-text commit 'font-lock-constant-face) "\n"
            (egg-text "a.k.a.:" 'egg-text-1) " "
	    (egg-text "GPG-Signed by: " 'egg-text-1)
	    (if gpg-uid (egg-text gpg-uid 'egg-text-2)
	      (egg-text "None" 'egg-text-2)) "\n"
            (egg-text "Repository: " 'egg-text-1)
;;    (put-text-property (point-min) (point) 'keymap egg-tag-buffer-heading-map)
    (setq text-beg (point-marker))
    (set-marker-insertion-type text-beg nil)
    (setq text-end (point-marker))
    (set-marker-insertion-type text-end t)

    (set (make-local-variable 'egg-log-msg-closure)
	 (egg-log-msg-mk-closure-from-input
	  (egg-log-msg-mk-closure-input #'egg-tag-msg-create-tag name commit-1)
	  nil gpg-uid text-beg text-end nil))
    nil))
  "Toggle blame mode for the current-file.
With C-u prefix, do not ask for confirmaton before saving the buffer."
        (src-rev (and ask (egg-read-rev "diff against: " (egg-branch-or-HEAD))))
    (pop-to-buffer buf)))
With C-u prefix, ask for confirmation if the current file contains unstaged changes.
That's the NO-CONFIRM parameter in non-interactive use."
  (let* ((file (file-name-nondirectory (buffer-file-name)))
	 (egg--do-no-output-message egg--do-no-output-message)
	 (head-name (egg-branch-or-HEAD))
    (setq rev (egg-read-rev (format "checkout %s version: " file) head-name))
    (setq egg--do-no-output-message (format "checked out %s's contents from %s" file rev))
    (egg-file-buffer-handle-result
     (egg--git-co-files-cmd (egg-get-status-buffer) file rev))))
With C-u prefix, then ask for confirmation if the current file contains unstaged changes.
That's the CONFIRM-P paramter in non-interactive use."
  (let* ((file (file-name-nondirectory (buffer-file-name)))
	 (git-file (egg-buf-git-name))
	 (egg--do-no-output-message egg--do-no-output-message)
    (unless git-file
      (error "%s doesn't seem to be tracked by git!" file))
    (setq egg--do-no-output-message (format "checked out %s's contents from index" file))
    (egg-file-buffer-handle-result
     (egg--git-co-files-cmd (egg-get-status-buffer) git-file))))
(defun egg-start-new-branch (&optional force)
  "Start a new branch from HEAD."
  (interactive "P")
  (let* ((upstream (egg-current-branch))
	 (rev (or (egg-get-symbolic-HEAD) (egg-HEAD)))
	 (force (if force "-B" "-b"))
	 name track)
    (setq name (read-string (format "start new branch from %s with name: " rev)))
    (setq track (if (and upstream
			 (y-or-n-p (format "should the branch '%s' track '%s'"
					   name upstream)))
		    "--track"
		  "--no-track"))
    (egg-status-buffer-handle-result
     (egg--git-co-rev-cmd t rev force name track))))
	 (dir (egg-work-tree-dir))
         (buf (get-buffer-create (concat "*" (if name (concat name ":" canon-name) git-name) "*"))))
      (setq default-directory dir)
    (pop-to-buffer buf)))

(add-hook 'ediff-quit-hook 'egg--kill-ediffing-temp-buffers)
  "Compare, using ediff, the current file's contents in work-dir with vs a rev.
If ASK-FOR-DST is non-nil, then compare the file's contents in 2 different revs."
	 (short-file (file-name-nondirectory file))
         (dst (if ask-for-dst (egg-read-rev (format "(ediff) %s's newer version: "
						    short-file)
					    (egg-branch-or-HEAD))))
	 (src (egg-read-rev (if dst (format "(ediff) %s's %s vs older version: "
					    short-file  dst)
			      (format "(ediff) %s vs version: " short-file)))))
    (egg--ediff-file-revs file dst nil src nil)))


(defun egg-resolve-merge-with-ediff (file)
  "Launch a 3-way ediff session to resolve the merge conflicts in FILE."
  (let* ((short-file (file-name-nondirectory file))
	 (ours ":2")
	 (pretty-ours "ours")
	 (theirs ":3")
	 (pretty-theirs "theirs"))
    (if (egg-rebase-in-progress)
	(egg--ediff-file-revs file nil nil theirs pretty-theirs ours pretty-ours)
      (egg--ediff-file-revs file nil nil ours pretty-ours theirs pretty-theirs))))

(defun egg--ediff-file-revs (file-name new-rev new-rev-pretty parent-1 parent-1-pretty
				       &optional parent-2 parent-2-pretty)
  (let* ((default-directory (egg-work-tree-dir))
	 (git-file-name (egg-file-git-name file-name))
	 (short-file (file-name-nondirectory file-name))
	 (buffer-3 (if new-rev
		       (egg-file-get-other-version git-file-name new-rev nil t new-rev-pretty)
		     (find-file-noselect file-name)))
	 (buffer-1 (egg-file-get-other-version git-file-name parent-1 nil t parent-1-pretty))
	 (buffer-2 (and parent-2 
			(egg-file-get-other-version git-file-name parent-2 nil t parent-2-pretty))))
    (when new-rev (egg--add-ediffing-temp-buffers buffer-3))
    (when parent-1 (egg--add-ediffing-temp-buffers buffer-1))
    (when parent-2 (egg--add-ediffing-temp-buffers buffer-2))

    (add-hook 'ediff-before-setup-hook #'egg--ediff-save-windows-config-hook)
    (add-hook 'ediff-quit-hook #'egg--ediff-restore-windows-config-hook)

    (cond ((and (bufferp buffer-1) (bufferp buffer-2) (bufferp buffer-3))
	   (ediff-buffers3 buffer-2 buffer-1 buffer-3))
	  ((and (bufferp buffer-1) (bufferp buffer-3))
	   (ediff-buffers buffer-1 buffer-3) )
	  (t (error "internal error: something wrong")))))

(defun egg--commit-do-ediff-file-revs (commit file)
  (let ((parents (egg-commit-parents commit)))
    (egg--ediff-file-revs file commit nil (car parents) nil (cadr parents) nil))
  ;; (let* ((default-directory (egg-work-tree-dir))
  ;; 	 parents)
  ;;   (with-temp-buffer
  ;;     (egg-git-ok t "--no-pager" "cat-file" "-p" commit)
  ;;     (goto-char (point-min))
  ;;     (while (re-search-forward (rx line-start 
  ;; 				    "parent " (group (= 40 hex-digit)) 
  ;; 				    (0+ space)
  ;; 				    line-end) nil t)
  ;; 	(add-to-list 'parents (match-string-no-properties 1)))
  ;;     (setq parents (mapcar (lambda (long)
  ;; 			      (substring-no-properties long 0 8))
  ;; 			    (nreverse parents)))
  ;;     (egg--ediff-file-revs file commit nil (car parents) nil (cadr parents) nil)))
  )

(defun egg--diff-do-ediff-file-revs (diff-info file)
  (let ((default-directory (egg-work-tree-dir))
	(src (plist-get diff-info :src-revision))
	(src-pretty (plist-get diff-info :src))
	(dst (plist-get diff-info :dst-revision))
	(dst-pretty (plist-get diff-info :dst)))
    (setq src (cond ((consp src) (egg-git-to-string "merge-base" (car src) (cdr src)))
		    ((stringp src) src)
		    ((null src)
		     (setq src-pretty (concat "INDEX:" file))
		     ":0")))
    (egg--ediff-file-revs file dst dst-pretty src src-pretty nil nil)))
         (default-directory (egg-work-tree-dir git-dir))
                      (egg-work-tree-dir)
  "Guess and perform the next logical action.
With C-u prefix, ask for confirmation before executing the next-action."
	 (current-prefix-arg nil)
  (define-key map (kbd "f") 'egg-find-tracked-file)
  (define-key map (kbd "/") 'egg-search-file-changes)
  (define-key map (kbd "?") 'egg-search-changes)
  (define-key map (kbd "~") 'egg-file-version-other-window)
  )
    (egg-log-buffer-ff-pull egg-ref-or-commit-at "update HEAD with %s")
    (egg-log-buffer-anchor-head egg-ref-or-commit-at "anchor HEAD at %s")
      (egg-status nil nil)