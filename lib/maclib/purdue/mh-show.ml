;  This autoloaded file implements the "t" command of mhe
; 
(defun 
    (&mh-show msgn sm fn fl
	(setq msgn (&mh-get-msgnum))
	(message "Typing message " msgn "...") (sit-for 0)
	(if (error-occured
		(pop-to-mh-buffer)
		(setq fn (&mh-get-fname))
		(setq fl mh-folder)
		(pop-to-buffer "show")
		(read-file fn)
		(use-local-map "&mh-keymap")
		(setq mode-string "mhe-show")
		(&mh-set-cur)
	    )
	    (progn
		(delete-window)
		(error-message "Message " msgn " does not exist!")
	    )
	)
    )
)
