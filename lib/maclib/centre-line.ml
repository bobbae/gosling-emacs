; function to centre the current line
(defun
    (centre-line width
        (save-excursion
	    (beginning-of-line)
	    (delete-white-space)
	    (end-of-line)
	    (delete-white-space)
	    (setq width (current-column))
	    (beginning-of-line)
	    (to-col (+ left-margin (/ (- right-margin width) 2)))
        )
    )
)

