; This function slides a region left or right by "argument prefix" spaces.
; It is useful in manually meddling with indentation in block-structured
;    languages.
;  "argument prefix" defaults to 4 if not provided. 
;  I usually bind it to ESC-^I
; 	Brian Reid  March 82
; 	Completely rewritten by Russell Quong, November 1985

(defun 
    (right-shift-line dest		; arg 1 = shift amount
	(beginning-of-line)
	(setq dest (+ (current-indent) (arg 1)))
	(if (< dest 0)
	    (setq dest 0)
	)
	(to-col dest)
	(insert-string ".")		; kill whitespace till first word
	(delete-white-space)
	(delete-previous-character)
    )
    
    (left-shift-line
	(right-shift-line (- 0 (arg 1)))
    )

; undent the current line, if the indentation of the line above 
; is <= to the indentation of this line.  Useful for 'else' in languages.
    (undent-line-depending-on-prev next-line-indent
	(setq next-line-indent (current-indent))
	(if (save-excursion
		(previous-line)
		(<= (current-indent) next-line-indent))
	    (left-shift-line indent-spacing)
	)
    )
    
    (forward-indent (right-shift-line indent-spacing) (end-of-line))
    (backward-indent (left-shift-line indent-spacing) (end-of-line))
    
    (indent-region x
	(if prefix-argument-provided
	    (setq x prefix-argument)
	    (setq x 4))
	(shift-region x)
    )
    
    (undent-region x
	(if prefix-argument-provided
	    (setq x prefix-argument)
	    (setq x 4))
	(shift-region (- 0 x) )
    )

    (shift-region n
	(setq n (arg 1))
	(if (> (dot) (mark))
	    (exchange-dot-and-mark))
	(beginning-of-line)
	(exchange-dot-and-mark)
	(end-of-line)
	(save-excursion 
	    (narrow-region)
	    (beginning-of-file)
	    (right-shift-line n)
	    (end-of-line)
	    (while (! (eobp))
		   (next-line)
		   (right-shift-line n)
		   (end-of-line)
	    )
	    (widen-region)
	)
    )
    
    (indent-init
	(setq-default indent-spacing 4)		
	(if (! (is-bound indent-spacing))
	    (declare-buffer-specific indent-spacing)
	)
    )

)

(indent-init)				; initialize the stuff
