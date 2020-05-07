(defun
    (global-delete-lines target delcnt
	(setq delcnt 0)
	(setq target (get-tty-string ": global-delete-lines containing "))
	(save-excursion
	    (error-occured
		(beginning-of-file)
		(while 1
		    (search-forward target)
		    (beginning-of-line)
		    (kill-to-end-of-line)
		    (kill-to-end-of-line)
		    (setq delcnt (+ delcnt 1))
		)
	    )
	)
	(message (concat delcnt " lines deleted"))
    )
)
