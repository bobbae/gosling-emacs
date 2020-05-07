; This file implements the autoloaded "exit" function (not a command) of mhe.

;  There is a bug here:  When processing the commands in cmd-buffer, they
;  are sent directly to send-to-shell, without prepending mh-progs to the
;  commands.  If the user has his path wrong, these commands won't work.
;  Doing things this way also fails to write ++update files as a result of
;  moves.

;  Could call &mh-close-folder, but this only processes commands for the
;  current folder.  Should fix it so that it can optionally do all folders.
;  Shouldn't be hard.

;  A better possibility that might be better is to have this routine look at
;  cmd-buffer to see what folders need to be closed, and do each one.
(defun 
    (&mh-exit ans retval
	(&mh-pop-to-buffer (concat "+" mh-folder))
	(temp-use-buffer "cmd-buffer")
	(setq retval 0)
	(setq ans (get-response "Preparing to exit. Action? [q, e, u, ?] "
		      "qQeEuU\" 
		      "q: quit (don't process) e: exit (after processing) u: undo (don't exit)"))
	(if (| (= ans 'q') (= ans '\'))
	    (progn
		  (temp-use-buffer "cmd-buffer") (setq ans 'y')
		  (if (> (buffer-size) 0)
		      (setq ans
			    (get-response "Really exit without processing? "
				"yYnN\" "y for Yes or n for No")))
		  (if (| (= ans 'y') (= ans '\'))
		      (progn
			    (temp-use-buffer (concat "+" mh-folder))
			    (erase-buffer)
			    (setq retval 1)
		      )
		  )
	    )
	    (= ans 'e')
	    (progn
		  (temp-use-buffer "cmd-buffer")
		  (if (!= 0 (buffer-size))
		      (progn
			    (message "Preparing to exit. Action? [q, e, u, ?] exiting...")
			    (sit-for 0)
			    (&mh-close-all-folders)
		      )
		  )
		  (setq retval 1)
	    )
	)
	(sit-for 0)
	retval
    )
    
    (&mh-close-all-folders-xx
	(temp-use-buffer "cmd-buffer")
	(beginning-of-file)
	(split-long-lines)
	(beginning-of-file) (set-mark) (end-of-file)
	(progn s
	       (setq s (region-to-string))
	       (message "Processing deletes and moves...")
	       (sit-for 0)
	       (send-to-shell s 'f')
	       (setq buffer-is-modified 0)
	       (temp-use-buffer (concat "+" mh-folder))
	       (&mh-make-headers-current)
	       (setq buffer-is-modified 0)
	)
    )	

    (&mh-close-all-folders
	(&mh-pop-to-buffer (concat "+" mh-folder))
	(temp-use-buffer "cmd-buffer")
	(beginning-of-file)
	(error-occured fn
	    (while (> (buffer-size) 0)
		   (re-search-forward " +\\([^ \t]*\\)")
		   (region-around-match 1)
		   (setq fn (region-to-string))
		   ;  So that headers all re-use same window.
		   (if (error-occured (use-old-buffer (concat "+" fn)))
		       (progn
			     (message "Whoops!  You haven't visited +" fn)
			     (sit-for 10)
			     (beginning-of-line) (set-mark)
			     (next-line) (erase-region)
		       )
		       (progn
			     (message "Processing deletes and moves in +" fn "...")
			     (sit-for 0)
			     (setq mh-folder fn)
			     (&mh-close-folder)
		       )
		   )
	       (temp-use-buffer "cmd-buffer")
	       (beginning-of-file)
	    )
	)
	(erase-buffer)
    )


    (split-long-lines t s	; make sure no overlong lines in cmd-buffer
	(beginning-of-file)
	(while (! (eobp))
	       (next-line)
	       (while
		     (progn (beginning-of-line)
			    (setq t (dot)) (end-of-line) (> (dot) (+ t 200)))
		     (beginning-of-line) (set-mark)
		     (if (looking-at "rmm")
			 (progn (forward-word) (forward-word) (forward-word)
				(backward-word))
			 (looking-at mh-file-command)
			 (progn (forward-word) (forward-word)
				(forward-word) (forward-word)
				(forward-word) (backward-word))
		     )
		     (setq s (region-to-string)) (beginning-of-line)
		     (goto-character (+ (dot) 200)) (backward-word)
		     (delete-previous-character) (newline)
		     (insert-string s)
	       )
	)
	(setq buffer-is-modified 0)
    )
)
