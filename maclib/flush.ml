; flush.ml
; contains functions flush-lines and keep-lines
; 
; flush-lines kills off all lines containing a specified pattern,
; keep-lines kills off all lines which do not contain a specified pattern.
; 
; The deleted lines are copied to the kill buffer.

(defun
    (flush-lines pattern
	(setq pattern (arg 1 ": flush-lines (pattern) "))
	(save-excursion
	    (beginning-of-file)
	    (set-mark)
	    (delete-region-to-buffer "*flush/keep*")
	    (error-occured
		(while 1
		    (re-search-forward pattern)
		    (beginning-of-line)
		    (set-mark)
		    (next-line)
		    (append-region-to-buffer "*flush/keep*")
		    (erase-region)
		)
	    )
	)
	(save-excursion
	    (temp-use-buffer "*flush/keep*")
	    (Mark-Whole-Buffer)
	    (Copy-region-to-kill-buffer)
	    (message (concat (Count-Lines-In-Region) " flushed.")))
    )
)

(defun
    (keep-lines pattern
	(setq pattern (arg 1 ": keep-lines (pattern) "))
	(save-excursion
	    (beginning-of-file)
	    (set-mark)
	    (delete-region-to-buffer "*flush/keep*")
	    (error-occured
		(while 1
		    (re-search-forward pattern)
		    (beginning-of-line)
;		    (message "Before erase") (sit-for 5)
		    (append-region-to-buffer "*flush/keep*")
		    (erase-region)
		    (next-line)
		    (set-mark)
;		    (message "After erase - next line") (sit-for 5)
		))
	    (end-of-file)
	    (append-region-to-buffer "*flush/keep*")
	    (erase-region)
	)
	(temp-use-buffer "*flush/keep*")
	(Mark-Whole-Buffer)
	(Copy-region-to-kill-buffer)
	(message (concat (Count-Lines-In-Region) " lines killed."))
    )
)
