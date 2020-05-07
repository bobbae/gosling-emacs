(defun
    (current-line lineno
	(save-excursion
	    (beginning-of-line)
	    (set-mark)
	    (setq lineno 1)
	    (beginning-of-file)
	    (while (< (dot) (mark))
		(next-line)
		(setq lineno (+ lineno 1))
	    )
	    (setq lineno lineno)
	)
    )
)
