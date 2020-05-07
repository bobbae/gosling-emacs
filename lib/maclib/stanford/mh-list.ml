;  This autoloaded file implements the "l" command of mhe
(defun 
    (&mh-list msgn sm fn
	(setq msgn (&mh-get-msgnum))
	(message  "Listing message " msgn) (sit-for 0)
	(if 
	    (error-occured
		(pop-to-buffer (concat "+" mh-folder))
		(setq fn (&mh-get-fname))
		(setq sm (concat mh-progs "/mhl " fn
				 " | " mh-print-filter
				 " -h 'Printed " (current-time) " from  +"
				 mh-folder "/" msgn "'  "
				 " | " mh-pspool-filter)
		)
		(save-excursion 
		    (switch-to-buffer "mh-temp")
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
	(message  "Listed message " msgn) (sit-for 2)
    )
)
