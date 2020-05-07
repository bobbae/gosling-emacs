(extend-database-search-list "describe"
    "/usr/local/lib/emacs/databases/describe")

(defun
    (describe-command word
	(setq word (get-tty-command ": describe-command "))
	(save-excursion
	    (temp-use-buffer "Help")
	    (erase-buffer)
	    (if (error-occured (fetch-database-entry "describe" word))
		(error-message (concat "No help concerning " word))
		(progn
		    (pop-to-buffer "Help")
		    (setq buffer-is-modified 0)
		    (beginning-of-file))
	    )
	    (novalue)
	))
    
    (describe-variable word
	(setq word (get-tty-variable ": describe-variable "))
	(save-excursion
	    (temp-use-buffer "Help")
	    (erase-buffer)
	    (if (error-occured (fetch-database-entry "describe" word))
		(error-message (concat "No help concerning " word))
		(progn
		    (pop-to-buffer "Help")
		    (setq buffer-is-modified 0)
		    (beginning-of-file))
	    )
	    (novalue)
	))
)
