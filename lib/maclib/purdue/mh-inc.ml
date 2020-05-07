;  Incorporate new mail into inbox.
; 
(defun 
    (&mh-inc
	(message "Checking for new mail...") (sit-for 0)
	(&mh-save-killbuffer)
	(mh "+inbox")
	(pop-to-mh-buffer)
	(&mh-unmark-all-headers)
	(end-of-file)
	(set-mark)
	(fast-filter-region  (concat "inc " mh-folder))
	(exchange-dot-and-mark)
	(if (looking-at "Incorporating")
	    (progn 
		(set-mark)
		(next-line)
		(next-line)
		(delete-to-killbuffer)
		(setq mh-direction 1)
	    )
	    (progn		; else -- no new mail
		(delete-to-killbuffer)
		(previous-line)
		(message "No new mail.")
	    )
	)
	; update mail string
	(temp-use-buffer "mh-temp")
	(erase-buffer)
	(insert-string global-mode-string)
	(beginning-of-file)
	(error-occured (replace-string " New mail" ""))
	(error-occured (replace-string " Mail" ""))
	(beginning-of-file)
	(set-mark)
	(end-of-line)
	(setq global-mode-string (region-to-string))

	(&mh-restore-killbuffer)
    )
)
