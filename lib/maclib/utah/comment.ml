; comment.ml - Commenting functions
; Written by Spencer W. Thomas
; Tue Nov  3 1981
; 
; begin-global-comment
;   Enter a recursive edit to insert a global comment.
; 
; edit-global-comment
;   Enter a recursive edit to re-edit a global comment.
; 
; fill-global-comment-paragraph
;   Fill a paragraph in a global comment
; 

(progn 
(declare-buffer-specific comment-continuation)
(declare-buffer-specific comment-begin)
(declare-buffer-specific comment-start)
(declare-buffer-specific comment-end)
(declare-buffer-specific dont-wrap-comments)
(setq-default comment-begin "# ")
(setq-default comment-start "#")
(setq-default comment-end "")
(setq-default comment-continuation "")
(setq-default dont-wrap-comments 0)

; If no argument is given, executes begin-global-comment, 
; if an argument is given, execute edit-global-comment.
(defun
    (global-comment
	(if prefix-argument-provided
	    (edit-global-comment)
	    (begin-global-comment))
    )
)

; Enter a recursive edit to build a big comment. The portion of the line
; to the left of the cursor is used as a prefix for each comment line.
(defun 
    (begin-global-comment &comment-prefix& &comment-continuation&
		&comment-continuation-fill& &comment-continuation-size&
	(save-excursion		; set prefix from current line
	    (set-mark)
	    (beginning-of-line)
	    (setq &comment-prefix& (region-to-string))
	    (&create-comment-continuation &comment-prefix&))
	(insert-string comment-begin)
	(if (! (looking-at "$"))
	    (save-excursion (insert-string "\n")))
	(global-comment-recurse)
	(if (save-excursion
		(set-mark)
		(beginning-of-line)
		(if (= (region-to-string)
		       (concat &comment-prefix& comment-begin))
		    (progn
			  (delete-to-killbuffer)
			  0)
		    
		    (= (region-to-string) &comment-continuation-fill&)
		    (progn
			  (exchange-dot-and-mark)
			  (provide-prefix-argument &comment-continuation-size&
			      (delete-previous-character))
			  1
		    )
		    1
		)
	    )
	    (insert-string comment-end)
	)
	(novalue)
    )
)

; Enter a recursive edit to edit an already existing comment.  Finds the
; beginning of the comment and sets the fill prefix from there.
(defun
    (edit-global-comment &comment-continuation& &comment-continuation-fill& 
			 &comment-continuation-size&
	(save-excursion
	    (search-reverse comment-start)
	    (set-mark)
	    (beginning-of-line)
	    (&create-comment-continuation (region-to-string))
	)
	(global-comment-recurse)
    )
)

(defun
    (global-comment-recurse old-return old-lf old-c-o old-right-margin
		old-mode old-auto-fill old-m-j
	(setq old-return (local-binding-of '^M'))
	(setq old-lf (local-binding-of '^J'))
	(setq old-c-o (local-binding-of '^O'))
	(setq old-right-margin right-margin)
	(setq old-m-j (local-binding-of "\ej"))
	(setq old-mode mode-string)
	(setq old-auto-fill "")
	(error-occured 		; catch ^Gs and the such-like
	    (setq mode-string (concat mode-string " Global Comment"))
	    (setq right-margin 72)
	    (local-bind-to-key "comment-return" '^M')
	    (local-bind-to-key "comment-lf" '^J')
	    (local-bind-to-key "comment-c-o" '^O')
	    (local-bind-to-key "fill-global-comment-paragraph" "\ej")
	    (setq old-auto-fill (set-auto-fill-hook "comment-auto-fill"))
	    (recursive-edit))
	(local-bind-to-key old-return "\^M")
	(local-bind-to-key old-lf "\^J")
	(local-bind-to-key old-c-o "\^O")
	(local-bind-to-key old-m-j "\ej")
	(if (!= old-auto-fill "")
	    (set-auto-fill-hook old-auto-fill))
	(setq mode-string old-mode)
	(setq right-margin old-right-margin)
    )
)

; Figure out what the comment continuation string looks like, given
; the fill prefix as an argument.
(defun
    (&create-comment-continuation middle cont
	(if (= comment-continuation "")
	    (setq comment-continuation
		  (concat comment-end "\^J" comment-begin)))
	(setq middle (arg 1 "fill "))
	(setq cont comment-continuation)
	(temp-use-buffer "Scratch")
	(erase-buffer)
	(insert-string cont)
	(beginning-of-file)
	(if (error-occured (search-forward "\^J"))
	    (insert-character '^j'))
	(setq &comment-continuation-size& (+ 1 (- (buffer-size) (dot))))
	(set-mark)
	(insert-string middle)
	(end-of-file)
	(setq &comment-continuation-fill& (region-to-string))
	(set-mark)
	(beginning-of-file)
	(setq &comment-continuation& (region-to-string))
    )
)

(defun
    (comment-return
	(prefix-argument-loop
	    (insert-string &comment-continuation&))
    )
    (comment-lf
	(comment-return)
	(tab-to-tab-stop)
    )
    (comment-c-o
	(save-excursion
	    (if (bolp)
		(backward-character))
	    (prefix-argument-loop
		(insert-string &comment-continuation&))
	)
    )
    (comment-auto-fill
	(save-restriction
	    (save-excursion
		(set-mark)
		(beginning-of-line)
		(narrow-region)
	    )
	    (save-excursion
		(while (& (>= (current-column) right-margin)
			  (! (error-occured (re-search-reverse "[ \t]"))))
		       (novalue))
		(delete-white-space)
		(insert-string &comment-continuation&)
		(insert-string prefix-string)
	    )
	)
    )
)

; fill-global-comment-paragraph
; 
; Fill a paragraph in a "global comment".

(defun
    (fill-global-comment-paragraph old-right old-left cont col
	(if (!= (local-binding-of '^M') "comment-return")
	    (error-message "Must be in global comment edit to run"
		" fill-global-comment-paragraph"))
	(save-excursion
	    (setq cont &comment-continuation-fill&)
	    (temp-use-buffer "Scratch")
	    (erase-buffer)
	    (insert-string (quote cont))
	    (end-of-file)
	    (setq col (current-column))
	    (delete-white-space)
	    (insert-string "[ \t]*")
	    (set-mark)
	    (beginning-of-file)
	    (setq cont (region-to-string))
	)
;	(message cont)(sit-for 10)
	(save-excursion
	    (beginning-of-line)
	    (while (& (looking-at cont)
		      (! (looking-at (concat cont "$")))
		      (! (bobp)))
;		   (sit-for 5)
		   (previous-line))
;	    (message "beginning")(sit-for 5)
	    (next-line)
	    (set-mark)
	    (while (& (looking-at cont)
		      (! (looking-at (concat cont "$")))
		      (| (= comment-end "")
			 (! (looking-at (concat "[ \t]*" (quote comment-end))))
		      )
		      (! (eobp)))
;		   (sit-for 5)
		   (next-line))
;	    (message "end")(sit-for 5)

	    (backward-character)

	    (save-restriction
		(narrow-region)
		(beginning-of-file)
		(insert-character '.')
		(error-occured (replace-string &comment-continuation& " "))
		(setq old-left left-margin)
		(setq left-margin 1)
;		(message "right " right-margin " left " left-margin)
;				(sit-for 5)
		(justify-paragraph)
		(beginning-of-file)
		(delete-next-character)
;		(sit-for 10)
		(setq left-margin old-left)
	    )
	)
    )
)

(defun
    (load-comment))
)

; 
; Following are functions to handle one line comments.
; 
(defun
    (comment i		; by SWT
				; temporary until real comment stuff is
				; written.  This will insert a /*  */ pair
				; and position dot between them.  If a /*
				; already exists on the line, just goes to
				; it.  An argument will align the comments
				; on that many lines, starting at the
				; current line and proceeding forward
				; for a positive argument or backward
				; for a negative argument.
				; If the variable dont-wrap-comments is set,
				; an attempt will be made to make sure that
				; the comment doesn't pass the right margin
				; (of the screen, not right-margin var).
	(setq i prefix-argument)
	(while i
	    (end-of-line)
	    (if (save-excursion eoldot
		    (setq eoldot (dot))
		    (beginning-of-line)
		    (if  (error-occured (search-forward comment-start))
			0		; return value
			(< (dot) eoldot); return value
		    ))
		(progn
		    (beginning-of-line)
		    (search-forward comment-start)
		    (save-excursion diff
			(search-reverse comment-start)
			(if (!= (current-column) comment-column)
			    (progn
				(delete-white-space)
				(if (>= (current-column) comment-column)
				    (insert-string "\t")
				    (to-col comment-column))))
			(if (& dont-wrap-comments
			       (save-excursion
				   (end-of-line)
				   (> (setq diff(- (current-column) 79)) 0)))
			    (progn was-col
				   (setq was-col (current-column))
				   (delete-white-space)
				   (if (>= (current-column)
					   (- was-col diff))
				       (insert-string " ")
				      (to-col (- was-col diff)))))
				   
		    )
		    (if (= (following-char) ' ')
			(forward-character))
		)
		(progn
		    (if (>= (current-column) comment-column)
			(insert-string "\t")
			(to-col comment-column)
		    )
		    (insert-string comment-begin)
		    (save-excursion (insert-string comment-end))
		)
	    )
	    (if (> i 0)
		(progn
		    (setq i (- i 1))
		    (if (> i 0)
			(progn
			    (delete-empty-comment)
			    (next-line))))
			    
		(< i 0)
		(progn
		    (setq i (+ i 1))
		    (if (< i 0)
			(progn
			    (delete-empty-comment)
			    (previous-line))))
	    )
	)
    )

    (delete-comment
	(save-excursion
	    (end-of-line)
	    (set-mark)
	    (beginning-of-line)
	    (narrow-region)
	    (if (! (error-occured (search-forward comment-start)))
		(progn
		      (search-reverse comment-start)
		      (delete-white-space)
		      (set-mark)
		      (if (= comment-end "")
			  (end-of-line)
			  (search-forward comment-end))
		      (delete-to-killbuffer)
		))
	    (widen-region)
	)
    )

    (indent-new-comment	; by SWT
				; insert a new line and start a comment on
				; it.  Align the comment with the one on the
				; current line.
	(end-of-line)
	(newline)
	(comment)
	(indent-under comment-start)
    )

    (next-comment		; by SWT
				;'go to the next line's comment.  If there
				;'isn't one then make it.  If the current
				;'line's comment is empty delete it.
	(delete-empty-comment)
	(next-line)
	(comment)
    )

    (previous-comment		; by SWT
				;'go to the previous line's comment.  If
				;'there isn't one then make it.  If this
				;'line's comment is empty then kill it.
	(delete-empty-comment)
	(previous-line)
	(comment)
    )

    (delete-empty-comment	; by SWT
				; delete the C comment on the current line
				; if it is empty.
	(comment)		; make or move to the comment
	(search-reverse comment-start)
	(if (looking-at (concat "\\(" (quote comment-start) "[ \t]*"
				(if (= comment-end "")
				    "$"
				    (quote comment-end))
				"\\)")) ; an empty comment
	    (save-excursion
		(region-around-match 1)
		(delete-to-killbuffer)
		(delete-white-space))
	)
    )
)

(error-occured (_comment-hook))
)
