(progn 
(declare-global calendar-date-format) 
; Default date format inherited from the DEC-20: 1-JAN-82.
(setq calendar-date-format "\\3-\\2-\\4")

(defun

    ; Position calendar to current date.
    (calendar uname
	(setq uname (arg 1 "Calendar (for user named): "))
	(visit-file (concat "~" uname "/.calendar"))
	(beginning-of-file)
	(error-occured
	    (search-forward (date-for-calendar)) )
	(novalue)
    )

    ; Return current date in calendar format.
    (date-for-calendar
	(save-excursion rep-mode
	    (setq rep-mode replace-case)
	    (setq replace-case 0)
	    (temp-use-buffer "CalDate")
	    (erase-buffer)
	    (current-date-and-time)
	    (beginning-of-file)
	    (re-replace-string	; Parse date: week-day, mon, day, yr.
		 "\\(\\w\\w\\w\\) \\(\\w\\w\\w\\)  *\\([0-9]*\\) [0-9:]* 19\\(\\w\\w\\)"
		 calendar-date-format)	; Put in proper format.
	    (setq replace-case rep-mode)
	    (Mark-Whole-Buffer)
	    (region-to-string)
	)
    )
	    
)
)
