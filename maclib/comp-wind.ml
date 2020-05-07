; Written about Mon Mar 22 18:31:53 1982 by Spencer W. Thomas
; compare-windows
; 
; 	Compares the text in the current window and the next window
; 	starting at dot in each window.  Stops when a mismatch is
; 	detected, or at the end of the buffer.

(progn
(setq mode-line-format "Loading compare windows")
(defun
    (compare-windows dot1 dot2 str1 str2 match
	(save-excursion
	    (setq match 1)
	    (while (> match 0)
		(set-mark)
		(if (eobp)
		    (setq match -1)
		    (progn
			(end-of-line)
			(forward-character)
			(setq str1 (region-to-string))
		    ))
		(setq dot1 (mark))
		(next-window)
		(set-mark)
		(if (eobp)
		    (if (= match -1)
			(setq match -3)
			(setq match -2))
		    (progn
			(end-of-line)
			(forward-character)
			(setq str2 (region-to-string)))
		)
		(setq dot2 (mark))
		(if (> match 0)
		    (if (!= str1 str2)
			(setq match 0)))
		(previous-window)
;		(message (concat "match: " match)) (sit-for 10)
	    )
	)
	(if (= match 0)
	    (progn
		(goto-character dot1)
		(next-window)
		(goto-character dot2)
		(previous-window)
		(message "Mismatch")
	    )
	    (= match -1)
	    (progn
		(end-of-file)
		(next-window)
		(goto-character dot2)
		(previous-window)
		(message (concat "End of buffer " (current-buffer-name)))
	    )
	    (= match -2)
	    (progn
		(goto-character dot1)
		(next-window)
		(end-of-file)
		(message (concat "End of buffer " (current-buffer-name)))
		(previous-window)
	    )
	    (message "No differences found")
	)
    )
)
(setq mode-line-format default-mode-line-format)
)
