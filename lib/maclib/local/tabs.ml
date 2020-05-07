; Tabs package, ala Twenex Emacs
; Written Sat Oct  3 1981 by Spencer W. Thomas
; 
; Functions implemented in this package:
; 
; indent-nested
; 	Indent line for specified nesting level. With no argument
; 	(or argument 1) indents the line at the same nesting level
; 	as the last nonblank line (ie, directly under it). A
; 	negative argument means indent that many extra levels
; 	(indent-increment, or 4, is the size of a level). An
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
; tab-under
; 	Prompts for a string and searches backwards in the file for it.  The
; 	cursor is moved  so that it is
; 	under the first character of the string, if possible.  At least one
; 	blank will always be left.  An argument will search
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

(declare-buffer-specific comment-start comment-begin comment-end)
(declare-buffer-specific tab-stops indent-increment)
(setq-default tab-stops
"        :       :       :       :       :       :       :       :       :       :")
(setq-default indent-increment 4)
(declare-buffer-specific &last-indent-under-string&)

(defun
    (indent-nested col goal		; by SWT
					; Indent the same as the first line
					; above which doesnt start with a
					; comment.  Currently only works in
					; C mode.
	(setq goal 10000)	; less than this to start
	(provide-prefix-argument (if (< prefix-argument 0) 1 prefix-argument)
	    (&indent-nested-helper)
	)
	(if (< prefix-argument 0)
	    (setq col (- col (* prefix-argument indent-increment))))
	(save-excursion
	    (first-non-blank)
	    (delete-white-space)
	    (to-col col))
	(if (bolp)
	    (first-non-blank))
	(novalue)
    )

    (&indent-nested-helper
	(prefix-argument-loop 
	    (save-excursion cont
		(setq cont 1) 
		(while (& (!= cont 0) (! (bobp)))
		       (previous-line)
		       (first-non-blank)
		       (if (& (! (eolp))
			      (!= (current-column) 1)
			      (< (current-column) goal)
			      (! (looking-at (quote comment-start))))
			   (setq cont 0)
			   (beginning-of-line))
		)
		(setq goal (setq col (current-column)))
	    )
	)
    )

    (indent-region		; by SWT
				; indent all the lines in the region by
				; arg-prefix notches [includes negative]
	(save-excursion
	    (if (< (mark) (dot))
		(exchange-dot-and-mark)); start at dot, go to mark
	    (while (> (mark) (dot))
		(provide-prefix-argument prefix-argument (indent-line))
		(beginning-of-line)
		(if (looking-at "^ *$")
		    (delete-white-space))
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

    (indent-under col	; by SWT
	(provide-prefix-argument prefix-argument
	    (setq col (&indentation-under (arg 1 ": indent-under "))))
	(save-excursion
	    (beginning-of-line)
	    (delete-white-space)
	    (to-col col))
	(if (< (current-column) col)
	    (first-non-blank))
	(novalue)
    )

    (tab-under col	; by SWT
	(provide-prefix-argument prefix-argument
	    (setq col (&indentation-under (arg 1 ": tab-under "))))
	(delete-white-space)
	(to-col col)
	(if (> (current-column) col)
	    (insert-character ' '))
	(novalue)
    )

    (&indentation-under string
	(setq string (arg 1 ": &indentation-under "))
	(if (= string "")
	    (setq string &last-indent-under-string&)
	    (setq &last-indent-under-string& string))
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
	    (current-column))
    )

    (tab-to-tab-stop col n incr len stops	; by SWT
	(setq col (current-column))
	(if (>= prefix-argument 0)
	    (progn
		(setq n prefix-argument)
		(setq col (+ col 1))
		(setq incr 1))
	    (progn
		(setq n (- 0 prefix-argument))
		(setq incr -1)))
	(setq stops tab-stops)
	(save-excursion
	    (temp-use-buffer "tab-stops")
	    (setq needs-checkpointing 0)
	    (erase-buffer)
	    (insert-string stops)
	    (insert-character '\n')
	    (to-col col)
	    (previous-line)
	    (while (& (> n 0)
		      (! (error-occured
			     (if (< incr 0)
				 (search-reverse ":")
				 (search-forward ":")))))
		(setq n (- n 1)))
	    (if (> n 0)
		(if (> incr 0)
		    (end-of-line)
		    (beginning-of-line))
		(if (> incr 0)
		    (backward-character)))
	    (setq col (current-column))
	)
	(insert-character '.')
	(backward-character)
	(delete-white-space)
	(to-col col)
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

    (edit-tab-stops stops old-buffer
	(setq stops tab-stops)
	(setq old-buffer (current-buffer-name))
	(save-window-excursion
	    (switch-to-buffer "tab-stops")
	    (local-bind-to-key "exit-emacs" '^]')
	    (setq needs-checkpointing 0)
	    (setq mode-line-format (concat "%[Editing tab stops for buffer "
					   old-buffer "%]"))
	    (erase-buffer)
	    (insert-string "    .    1    .    2    .    3    .    4    .    5    .    6    .    7    .    8    .    9    .    0\n")
	    (insert-string stops)
	    (insert-character '\n')
	    (previous-line)
	    (message "Abort with ^]")
	    (recursive-edit)
	    (if (!= (last-key-struck) '^]')
		(progn
		      (beginning-of-file)
		      (next-line)
		      (set-mark)
		      (end-of-line)
		      (setq stops (region-to-string))
		      (message "Tab stops redefined"))
		(error-message "Aborted"))
	)
	(setq tab-stops stops)
	(novalue)
    )

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
