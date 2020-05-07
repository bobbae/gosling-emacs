; These utility functions return message number, file name, or path
; information. They are explicitly loaded from the root.
(defun     
    (&mh-get-msgnum
	(save-excursion
	    (temp-use-buffer (concat "+" mh-folder))
	    (beginning-of-line)
	    (while (= (following-char) ' ') (forward-character))
	    (set-mark)
	    (beginning-of-line)
	    (goto-character (+ (dot) mh-msgnum-cols))
	    (region-to-string)
	)
    )
    
    (&mh-get-fname
	(save-excursion 
	    (temp-use-buffer (concat "+" mh-folder))
	    (concat mh-buffer-filename "/" (&mh-get-msgnum))
	)
    )

    ; Look in mh-profile to find mh-path and mh-folder 
    (find-path old-dir cf-file
	(if (= 0 (file-exists mh-profile))
	    (progn
		  (&mh-pop-to-buffer "sorry") (delete-other-windows)
		  (insert-string "\n\nI can't find your .mh_profile file.\n"
				 "That means I can't continue. Sorry.\n"
				 "If you don't know what this means, then"
				 " you should run the program\n"
				 "'" mh-lib "/install-mh' now,\n"
				 "to build that file.\n")
		  (sit-for 0)
		  (setq stack-trace-on-error 0)
		  (exit-emacs)
	    )
	)
	(setq mh-path (&mh-find-key mh-profile "path"))
	(if (= "" mh-path) (setq mh-path "Mail"))

	; Make mh-path a UNIX-style absolute name
	(setq old-dir (working-directory))
	(cd "~")
	(setq mh-path (expand-file-name mh-path))
	(cd old-dir)
	
	;  Set up for mhe.
	(if (= "" (&mh-find-key mh-profile "mhe"))
	    (&mh-find-key mh-profile "mhe" "audit")
	)

	;  Determine the current folder.
	(setq cf-file (if mh-version-6-or-later
			  (concat mh-path "/context")
			  mh-profile))
	(setq mh-folder (&mh-find-key cf-file "current-folder"))
	(if (= "" mh-folder)
	    (progn
		  (&mh-find-key cf-file "current-folder" "inbox")
		  (setq mh-folder "inbox")
	    )
	)

	;  Remove current-folder from .mh_profile if present.
	(if mh-version-6-or-later
	    (&mh-find-key mh-profile "current-folder" "")
	)
    )
)



;  &mh-find-key looks in the given file for the given key and returns the
;  value associated with it.  If the key is not found, it returns the empty
;  string.
;	(&mh-find-key file key)
;  If given a third argument, it replaces the existing value with the third
;  argument.  If the third argument is the empty string, the entire line
;  containing the key will be removed, if it was there.  The old value is
;  returned.
;	(&mh-find-key file key value)
(defun
    (&mh-find-key file rv old-cfs
	(setq old-cfs case-fold-search)
	(save-excursion
	    (setq file (arg 1))
	    (temp-use-buffer "mh-db")

	    ;  Get the file -- empty buffer if not found.
	    ;  We used to test to see if this was the same file and not read,
	    ;  but mh routines often changed .mh_sequences behind our back,
	    ;  causing harmless inconsistencies and the annoying and
	    ;  unexpected "file has changed on disk" question.
	    ;  Now we just read the file and get on with it.
	    ;		-- Glenn Trewitt 1-27-92
	    (if (error-occured (read-file file))
		(erase-buffer)
	    )

	    (if (error-occured (re-search-forward
				   (concat "^" (arg 2) ":[ \t]*\\(.*\\)")))
		(progn			;  no key.
		    (setq rv "")
		    ;  insert key and value.
		    (if (& (> (nargs) 2) (!= (arg 3) ""))
			(progn
			      (end-of-file)
			      (insert-string (arg 2) ": " (arg 3) "\n")
			)
		    )
		)
		(progn			;  found the key.
		    (region-around-match 1)
		    (setq rv (region-to-string))
		    (if (> (nargs) 2)
			(if (!= (arg 3) "")
			    (progn		;  replace value
				  (erase-region)
				  (insert-string (arg 3))
			    )
			    (progn		;  delete key/value
				  (beginning-of-line)
				  (set-mark)
				  (next-line)
				  (erase-region)
			    )
			)
		    )
		)
	    )
	    (if buffer-is-modified (write-named-file file))
	)
	(setq case-fold-search old-cfs)
	rv
    )
)
