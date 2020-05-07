(extend-database-search-list "subr-names"
	"/usr/local/lib/emacs/maclib/databases/quickinfo")
(error-occured
    (extend-database-search-list "subr-names"
	(concat (getenv "HOME") "/.subr-names")))

(defun
    (describe-word-in-buffer subr-name
	(if (> prefix-argument 1)
	    (progn
		(error-occured (forward-character))
		(backward-word)
		(set-mark)
		(forward-word)
		(edit-description (region-to-string)))
	    (progn
		(save-excursion
		    (error-occured (forward-character))
		    (backward-word)
		    (set-mark)
		    (forward-word)
		    (setq subr-name (region-to-string))
		    (temp-use-buffer "subr-help")
		    (erase-buffer)
		    (if (error-occured
			    (fetch-database-entry "subr-names" subr-name))
			(error-message (concat "No help for " subr-name))
			(progn
			    (beginning-of-file)
			    (set-mark)
			    (end-of-line)
			    (message (region-to-string))))
		)
	    )
	)
	(novalue)
    )
    
    (edit-description
	(setq edit-name (arg 1 ": edit-description (of routine) "))
	(pop-to-buffer "Edit description")
	(erase-buffer)
	(if (error-occured (fetch-database-entry "subr-names" edit-name))
	    (message "New entry."))
	(setq mode-string (concat "  Editing database entry for " edit-name))
	(setq user-mode-line 1)
	(local-bind-to-key "replace-db-entry" (+ 256 19)); ^X^S
	(local-bind-to-key "replace-db-entry" (+ 256 6)); ^X^F
	(local-bind-to-key "replace-db-entry" (+ 256 23)); ^X^W
	(local-bind-to-key "replace-db-entry" (+ 256 3)); ^X^C
	(local-bind-to-key "replace-db-entry" 3); ^C
	(novalue)
    )
    
    (replace-db-entry
	(put-database-entry "subr-names" edit-name)
	(delete-window)
    )
)

(declare-global edit-name)
