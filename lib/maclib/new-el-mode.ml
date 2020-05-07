(defun    
    (new-electric
	(declare-global new-point-char)
	(setq new-point-char '>')
	(declare-global new-open-mode)
	(setq new-open-mode 1)
	(declare-global new-prefix-string)
	(setq new-prefix-string "  ")
	(setq left-margin 1)
	(setq right-margin 77)
	(local-bind-to-key "new-make-point" new-point-char)
	(local-bind-to-key "new-indent-line" (+ 128 'i')); esc i
	(local-bind-to-key "new-dedent-line" (+ 128 'u')); esc u
	(local-bind-to-key "new-justify" (+ 128 'j')); esc j
	(local-bind-to-key "new-close" (+ 256 'c')); ^Xc
	(local-bind-to-key "new-open" (+ 256 'o')); ^Xo
	(setq mode-string "New electric")
    )
)

(defun
    (new-justify
        (error-occured
	    (save-excursion
		(end-of-line)
		(new-back-to-point-setting-margin)
	        (if (! (eolp))
		    (while	; for each line in the current paragraph
		        (progn
			    (while ; while this line is too long
			        (progn
				    (end-of-line)
				    (> (current-column) right-margin))
			        (while ; back up to a space or tab
				    (& (| (> (current-column) right-margin)
					     (& (!= (preceding-char) ' ')
					        (!= (preceding-char) '	')))
					  (! (bolp)))
				       (backward-character)
			        )
			        (if  (bolp) ; If line is all one word
				    (next-line); forget about justifying it
				    (progn ; else delete whitespace just found
				        (delete-previous-character)
				        (delete-white-space)
					(newline) ; and break the line
					(to-col left-margin)
					(insert-string prefix-string)
				    )
			        )
			    )	; end while line is too long
			    (beginning-of-line) ; try the next line
			    (next-line)
			    (if (eolp) ; This is the end of the test in the
				       ; while loop that goes through all
				       ; lines in the current paragraph.
				       ; If we pass, we're not on the blank
				       ; line at the end (in open mode) or
				       ; on the point line of the next
				       ; paragraph (in closed mode)
			       0
			       (save-excursion
				   (while
				       (! (= (current-column)
					      (current-indent)))
				       (forward-character))
				   (! (new-at-point))
			       )
			    )
		        )
			(beginning-of-line)
		        (delete-previous-character) ; Tack this non-blank
						    ; line onto the
						    ; previous one.
		        (delete-white-space)
		        (insert-string " ")
		    )		; end while [for each line...]
	        )		; end if ! eolp
	    )			; end save-excursion
        )
    )

    (new-back-to-point-setting-margin
	(if			; if not at last point
	    (& (! (bobp))
		(! (new-at-point))
		)
	    (while		; then go back to last point
		(if
		    (progn
			(beginning-of-line)
			(bobp))
		    0		; quit while loop if at start of buffer
		    (progn	; else check the first printing character
		       (while
			   (! (= (current-column)
				  (current-indent)))
			   (forward-character))
			(! (new-at-point)))
		)		; end of while test
		(previous-line)
	    )
	)			; end if not at last point
	(setq prefix-string new-prefix-string); SIDE EFFECT!!!
	(setq left-margin (current-indent)); SIDE EFFECT!!!
    )

    (new-forward-to-no-more-indented-point
	(while			; move ahead to next point with level <= col
	    (&  (! (eobp))
		(!
		    (& (new-at-point)
			(<= (current-indent) left-margin)
			)
		    )
		)
	    (next-line)
	    (beginning-of-line)
	    (while
	       (! (= (current-column)
		      (current-indent)))
	       (forward-character))
	    )
    )
    
    (new-back-to-end-of-non-blank-line
	(while
	    (&   (!   (blankline))
		(!  (bobp))
		)
	    (previous-line)
	    )
	(end-of-line)
    )

    (new-make-point
	(if (new-making-first-point)
	    (progn		; Making first point
		(setq left-margin 1)
		(setq prefix-string new-prefix-string)
		(while
		    (&  (! (new-at-point))
			(! (eobp))
			)
		    (forward-character)
		    )
		(if (! (bolp))
		    (newline)
		    (newline-and-backup)
		    )
		(if new-open-mode (newline-and-backup))
		)
	    (progn		; Not making first point
		(new-back-to-point-setting-margin)
		(end-of-line)
		(new-forward-to-no-more-indented-point)
		(beginning-of-line)
		(previous-line)	; Back up
		(while
		    (&	(blankline)
			(! (first-line))
			)
		    (previous-line)
		    )
		(end-of-line)
		(newline)	; and sit in the middle of 2 newlines
		(if new-open-mode (newline))
		)
	    )			; end if
	(to-col left-margin)
	(insert-character new-point-char)
	(insert-character ' ')	; The convention calls for a space after the
				; point char
    )

    (new-making-first-point	; returns true if dot is positioned before
				; the first point.
	(if (bobp)
	    1			; This should really be here
	    (save-excursion
		(while
		    (&  (! (new-at-point))
			(! (bobp))
			)
		    (backward-character)
		    )
		(! (new-at-point))
		)
	    )
    )

    (first-line
	(save-excursion
	    (beginning-of-line)
	    (bobp)
	    )
    )

    (blankline
	(save-excursion
	    (end-of-line)
	    (= (current-column) (current-indent))
	    )
    )

    (new-at-point
	(&
	    (= (following-char) new-point-char)
	    (= (current-column) (current-indent)))
    )

    (new-dedent-line (beginning-of-line)
		 (to-col (- (current-indent) 4))
		 (insert-string ".")
		 (delete-white-space)
		 (delete-previous-character)
		 (end-of-line)
		 (if (> left-margin 3)
		    (setq left-margin (- left-margin 4))
		    )
    )

    (new-indent-line (beginning-of-line)
		 (to-col (+ (current-indent) 4))
		 (insert-string ".")
		 (delete-white-space)
		 (delete-previous-character)
		 (end-of-line)
		 (setq left-margin (+ left-margin 4))
    )

    (new-close
	(setq new-open-mode 0)
	(save-excursion
	    (beginning-of-file)
	    (while (! (eobp))
		(beginning-of-line)
		(if (blankline)
		    (kill-to-end-of-line)
		    (next-line)
		)
	    )
	)
    )
    
    (new-open col
	(setq col left-margin)
	(setq new-open-mode 1)
	(save-excursion
	    (end-of-file)
	    (while
		(progn
		    (new-back-to-point-setting-margin)
		    (! (bobp))
		)
		(previous-line)
		(end-of-line)
		(if (! (blankline)) (newline))
	    )
	    (if (blankline) (kill-to-end-of-line))
	)
	(setq left-margin col)
    )
)
