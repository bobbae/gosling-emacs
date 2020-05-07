(defun
    (find-line char-per-line line-number increment; SWT
				; Determine the line number using a Newton
				; approximation algorithm
	(setq char-per-line 40)	; a first guess
	(save-excursion start-dot prev-incr curr-incr
	    (beginning-of-line)
	    (setq start-dot (dot))
	    (beginning-of-file)
	    (setq line-number 1)
	    (setq prev-incr 0)
	    (setq increment (/ start-dot char-per-line))
	    (while (!= (dot) start-dot)
		(set-mark)
		(if (< (dot) start-dot)
		    (progn
			(provide-prefix-argument increment
			    (next-line))
			(setq curr-incr increment)
			(if (& (eobp) (!= increment 1))
			    (goto-character (mark))
			    (setq line-number (+ line-number increment))))
		    (progn
			(provide-prefix-argument increment
			    (previous-line))
			(setq curr-incr (- 0 increment))
			(if (& (bobp) (!= increment 1))
			    (goto-character (mark))
			    (setq line-number (- line-number increment))))
		)
		(if (!= (dot) (mark))
		    (setq char-per-line (/ (dot) line-number))
		    (setq char-per-line (* 2 char-per-line)))
		(setq increment (/ (- start-dot (dot)) char-per-line))
		(if (> 0 increment)
		    (setq increment (- 0 increment)))
		(if (= curr-incr prev-incr)
		    (setq increment (- increment 1)))
		(setq prev-incr (- 0 curr-incr))
		(if (>= 0 increment)
		    (setq increment 1))
;		(message (concat "line " line-number
;			     " char-per-line " char-per-line
;			     " inc " increment
;			     " dot " (dot)
;			     " goal " start-dot))
;		(sit-for 20)
	    )
	)
	(if (interactive)
	    (message (concat "Current line is " line-number))
	    line-number)
    )

    (goto-line line-number
	(if (= prefix-argument 1)
	    (setq line-number (arg 1 ": goto-line "))
	    (setq line-number prefix-argument))
	(beginning-of-file)
	(if (> line-number 1)
	    (provide-prefix-argument
		(- line-number 1)
		(next-line))))
    
    (goto-percentage-of-file pof ppof input done ; another "Cute" function
	(setq pof 0) (setq ppof "") (setq done 1)
	(while (= done 1)
	    (message (concat "go to " ppof "% of file"))
	    (setq input (get-tty-character))
	    (if (& (= input '') (> (length ppof) 0))
		(progn (setq ppof (substr ppof 1 (- (length ppof) 1)))
		    (setq pof (/ pof 10)))
		(= input 7)			 ; Bell
		(error-message "Aborted.")
		(= input 21)			 ; Control-U
		(progn (setq ppof "")
		    (setq pof 0)
		)
		(| (= input '')		 ; escape
		    (= input '\015')		 ; cr
		    (= input 10))		 ; lf
		(setq done 0)
		(& (>= input '0') (<= input '9'))
		(progn (setq ppof (concat ppof (char-to-string input)))
		    (setq pof (+ (* pof 10) (- input '0'))))
	    )
	)
	(goto-character (/ (* (buffer-size) (+ pof 1)) 100))
    )

    (Count-Lines-In-Region count
	(save-restriction
	    (narrow-region)
	    (end-of-file)
	    (setq count (find-line))
	    (if (interactive)
		(progn
		      (message
			   (concat "There are " count " lines in the region"))
		      (novalue))
		count))
    )
)
