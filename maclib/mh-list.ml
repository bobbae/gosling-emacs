;  This autoloaded file implements the "l" command of mhe
(defun 
    (&mh-list msgn sm fn
	(setq msgn (&mh-get-msgnum))
	(message  "Listing message " msgn) (sit-for 0)
	(if 
	    (error-occured
		(pop-to-buffer (concat "+" mh-folder))
		(setq fn (&mh-get-fname))
		(setq sm (concat mh-print-filter
				 (if (= mh-print-filter "mp")
				     " "
				     (concat " -h 'Printed " (current-time)
					     " from  +" mh-folder "/" msgn "'  ")
				 )
				 fn " | " mh-pspool-filter)
		)
		(save-window-excursion 
		    (temp-use-buffer "mh-temp")
		    (erase-buffer) (insert-string sm)
		    (beginning-of-file) (set-mark) (end-of-file)
		    (fast-filter-region "sh")
		)
		(&mh-set-cur)
	    )
	    (progn (delete-window)
		   (error-message "message " msgn " does not exist!")
	    )
	)
	(message  "Listed message " msgn " on "
	    (if (error-occured (getenv "PRINTER"))
		"the system printer"
		(getenv "PRINTER")
	    )
	)
	(sit-for 2)
    )
)
