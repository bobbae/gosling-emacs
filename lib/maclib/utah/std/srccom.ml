; srccom: compare text in two windows

; To begin the comparison, place the dot at the beginning of one of the
; two pieces of text to be compared, switch to the other window, and place
; the dot at the beginning of the other piece of text.  (If there are more
; than two windows, the two windows to be compared must be adjacent, and
; the dot must be left in the upper one.)  When this command is invoked, it
; will search forward, stopping when either a difference is encountered
; or the end of the buffer is reached.  case-fold-search governs comparison
; of case differences.  The region is left around the equal portions in both
; windows.

; HISTORY:
; 	1 June 1982 -- Jerry Agin at Carnegie-Mellon University -- created

(defun
    (srccom c1 c2 success
	(set-mark)
	(next-window)
	(set-mark)
	(previous-window)
	(setq success 1)
	(while (& success (!(eobp)))
	    (setq c1 (following-char))
	    (next-window)
	    (if (eobp)
		(setq success 0)
		(progn
		    (setq c2 (following-char))
		    (if (c= c1 c2)
			(progn
			    (forward-character)
			    (previous-window)
			    (forward-character)
			)
			(progn
			    (previous-window)
			    (setq success 0)
			)
		    )
		)
	    )
	)
	(if (= (dot) (mark))
	    (error-message "")	; ring the bell if dot didn't move
	)
    )
)
