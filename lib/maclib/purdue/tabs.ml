; Tabs package, ala Twenex Emacs
; Written Sat Oct  3 1981 by Spencer W. Thomas
; modified Wed Mar 24 19:29:26 1982 by Christopher A. Kent
; modified Sat Jan 15 10:53:10 1983 by Richard L. Hyde
; 
; Functions implemented in this package:
; 
; indent-nested
; 	Indent line for specified nesting level. With no argument
; 	(or argument 1) indents the line at the same nesting level
; 	as the last nonblank line (ie, directly under it). A
; 	negative argument means indent that many extra levels
; 	(indent-increment, or 1, is the size of a level). An
; 	argument > 1 means that this line is that many levels
; 	closer to the surface, and should indent under the last
; 	line above it whose level is the same.  The previous lines
; 	are scanned under the assumption that any line less
; 	indented than its successors is one level higher than they.
; 	However, unindented lines and comment lines are ignored. If
; 	the cursor is not at the beginning of a line, the whole
; 	line is indented, but the cursor stays fixed with respect
; 	to the text.
; 
; tab-to-tab-stop
; 	Uses the string tab-stops to determine tabbing.  This string
; 	consists of a sequence of :s and spaces.  Each colon defines a
; 	column at which a tab stop is set.  Tab-to-tab-stop will insert
; 	spaces and tabs to move to the next tab stop after the current
; 	location.  If an argument is given, the argth tab stop after the
; 	current position will be used.
; 
; edit-tab-stops
; 	This function puts the tab-stops string into a buffer for editing.
; 
; indent-to-tab-stop
; 	Like tab-to-tab-stop but indents the current line to the next tab
; 	stop after its current indentation.  A negative argument will
; 	'dedent' the line.
; 
; dedent-to-tab-stop
; 	Just indent-to-tab-stop but in the other direction.
; 
; indent-line
; 	Indent the current line by arg spaces.  Negative args work.
; dedent-line
; 	Indent-line with a negative argument.
; 
; indent-under
; 	Prompts for a string and searches backwards in the file for it.  The
; 	current line is indented so that its first non-blank character is
; 	under the first character of the string.  An argument will search
; 	for the argth occurrence, searching forward in the file for negative
; 	arguments.  If more than one occurence of the target string appears
; 	on the line where it is found, the one closest to the beginning
; 	of the line will be used to determine the indentation.
; 
; indent-region
; 	Shifts all the text in the region by arg spaces.
; 
; delete-indentation
; 	Deletes the indentation at the beginning of this line.
; 
; do-a-tab
; 	A more sane binding for ^I. At the beginning of the line,
;	indent to the current indent level. Otherwise, tab-to-tab-stop.
; 
(declare-global comment-start comment-begin comment-end)
(declare-global tab-stops indent-increment)
(setq tab-stops
"        :       :       :       :       :       :       :       :       :       :")
(setq indent-increment 1)
(defun
    (indent-nested col goal		; by SWT and RLH
					; Indent the same as the first line
					; above which doesnt start with a
					; comment.  Currently only works in
					; C mode.
	(setq goal 10000)	; less than this to start
	(prefix-argument-loop prefix-argument
	    (save-excursion cont
		(setq cont 1)
		(while (& (!= cont 0) (! (bobp)))
		    (previous-line)
		    (first-non-blank)
		    (if (& (!= (current-column) 1)
			    (< (current-column) goal)
			    (! (looking-at (quote comment-start))))
			(setq cont 0)
			(beginning-of-line))  ; else goto beginning of line
		)
		(setq goal (setq col (current-column)))
	    )
	)
	(if (< prefix-argument 0)
	    (provide-prefix-argument (* prefix-argument indent-increment)
		 (dedent-line))
	    (save-excursion
		(first-non-blank)
		(delete-white-space)
		(to-col col)))
	(if (bolp)
	    (first-non-blank))
	(novalue)
    )
    (indent-region		; by SWT
				; indent all the lines in the region by
				; arg-prefix notches [includes negative]
	(save-excursion
	    (if (< (mark) (dot))
		(exchange-dot-and-mark)); start at dot, go to mark
	    (while (> (mark) (dot))
		(provide-prefix-argument prefix-argument (indent-line))
		(next-line)
	    ))
	(novalue)
    )
    (indent-line col		; from CMU
				; change the indentation of the current line
				; in by one notch.
	(save-excursion
	    (setq col (+ (current-indent) prefix-argument))
	    (beginning-of-line)
	    (delete-white-space)
	    (to-col col)
	)
	(if (< (current-column) col)
	    (first-non-blank))
	(novalue)
    )
    (dedent-line 		; by SWT
				; move the current line indentation out by
				; one level.
	(provide-prefix-argument (- 0 prefix-argument) (indent-line))
	(novalue)
    )
    (indent-under string col	; by SWT
	(setq string (arg 1 ": indent-under "))
	(save-excursion
	    (beginning-of-line)
	    (if (> prefix-argument 0)
		(prefix-argument-loop
		    (beginning-of-line)
		    (search-reverse string)
		    (beginning-of-line)
		    (search-forward string))
		(provide-prefix-argument (- 0 prefix-argument)
		    (prefix-argument-loop
			(end-of-line)
			(search-forward string))))
	    (search-reverse string)
	    (setq col (current-column)))
	(save-excursion
	    (beginning-of-line)
	    (delete-white-space)
	    (to-col col))
	(if (< (current-column) col)
	    (first-non-blank))
	(novalue)
    )
    (tab-to-tab-stop col n incr len	; by SWT
	(setq col (current-column))
	(if (>= prefix-argument 0)
	    (progn
		(setq n prefix-argument)
		(setq incr 1))
	    (progn
		(setq n (- 0 prefix-argument))
		(setq incr -1)))
	(setq col (+ col incr))
	(setq len (length tab-stops))
	(while (& (> n 0) (> col 0) (< col len))
	    (if (= (substr tab-stops col 1) ":")
		(setq n (- n 1)))
	    (setq col (+ col incr)))
	(insert-character '.')
	(backward-character)
	(delete-white-space)
	(to-col (- col incr))
	(delete-next-character)
    )
    (indent-to-tab-stop
	(save-excursion
	    (first-non-blank)
	    (provide-prefix-argument prefix-argument (tab-to-tab-stop)))
	(if (bolp) (first-non-blank))
	(novalue)
    )
    (dedent-to-tab-stop
	(provide-prefix-argument (- 0 prefix-argument)
	    (indent-to-tab-stop))
	(novalue)
    )
    (edit-tab-stops
	(error-message "Sorry, cant do this yet"))
    (delete-indentation		; SWT
	(save-excursion
	    (beginning-of-line)
	    (delete-white-space))
    )
    (do-a-tab
	(if (bolp)
	    (indent-nested)
	    (tab-to-tab-stop)
	)
    )
)
