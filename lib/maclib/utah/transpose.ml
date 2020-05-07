(progn
;;; This is a Semi-Auto-Frobic Transpose neato object library.
;;; It defines two functions: (which do the obvious things)
        Transpose-line		Transpose-word
;;; It also declares 3 Global Variables to control the Transpose line
;;; function and one global variable for communication to another function.
    (declare-global
	&Default-Transpose-Direction
	&Default-Transpose-Follow
	&Default-Transpose-Magic
	&Column-To-Be-At)
    (setq &Default-Transpose-Direction 1)
    (setq &Default-Transpose-Follow 0)
    (setq &Default-Transpose-Magic 0)
    (setq &Column-To-Be-At 1)

;;; What the Global Transpose variables mean:

;;; &Default-Transpose-Direction: (default 1)
;;;    Tells Transpose-line which other line to transpose with the current
;;;	on.  If this is set to 1 (actually your favorite non-zero number
;;;	will do) then Transpose-line will use the line above the current one
;;;	and if it is 0 Transpose-line will use the line below the current
;;;	one.
;;;

;;; &Default-Transpose-Follow: (default 0)
;;;    If this is set Non-zero it will cause Transpose-line to leave
;;;	the cursor(dot) on the line that got transposed, and if this is
;;;	set to Zero it will stay at the same place in the file!

;;; &Default-Transpose-Magic: (default 0)
;;;    This variable controlls some magic inside the Transpose Line
;;;	function.  If it is set to zero, Transpose-line will behave as
;;;	controlled by the settings of the above variables.  If this is set
;;;	Non-Zero then the magic is controlled by the cursor position when
;;;	Transpose-line is invoked.  If the cursor(dot) is somewhere in the
;;;	middle of a line, then it behaves as if this variable were 0.  If
;;;	the cursor  is at the end of a line, or at the beginning of a line,
;;;	the magic will happen.  If the cursor is at the beginning of the
;;;	line Transpose-line will override the above variable settings and
;;;	assert that you want to transpose with the above line and that you
;;;	want to follow the line you were on.  If the cursor is at the end of
;;;	a line Transpose-line will assume that you want to transpose with
;;;	the next line and that you want to follow the line you were on.  The
;;;	main reason for this magic is so that you can blip lines up and down
;;;	in your buffer real easily.
(defun
    (transpose-line foo transpose-up follow EMS mark-pos
			;     ^- Zero - down, NonZero - up
	(setq EMS "")
	(setq follow &Default-Transpose-Follow)
	(setq transpose-up &Default-Transpose-Direction)
	(if &Default-Transpose-Magic
	    (if (bolp)
		(progn (setq transpose-up 1) (setq follow 1))
		(eolp)
		(progn (setq transpose-up 0) (setq follow 1))))
	(save-excursion				 ; just to save the damn mark.
	    (setq &Column-To-Be-At (current-column))
	    (beginning-of-line)
	    (if (& (bobp) transpose-up)
		(setq EMS "Error - Can't transpose up here.")
		(progn 
		    (set-mark)
		    (next-line)(beginning-of-line)
		    (if (! (bolp))(progn (message "foo") (sit-for 5)))
		    (if (& (eobp) (! transpose-up))
			(setq EMS "Error - Can't transpose down here.")
			(delete-region-to-buffer "&&^&&^&&^")))))
	(if (!= EMS "") (error-message EMS))
	(beginning-of-line)
	(if transpose-up (previous-line) (next-line))
	(yank-buffer "&&^&&^&&^")
	(if (& transpose-up follow)
	    (previous-line)
	    transpose-up    ; implicitly (& transpose-up (! follow))
	    (progn
		(goto-column)
		(if (& &Default-Transpose-Magic (eolp)) (backward-character)))
	    follow	    ; implicity (& (! transpose-up) follow)
	    (backward-character)
	    (progn	    ; implicity (& (! transpose-up) (! follow))
		(previous-line)
		(previous-line)
		(goto-column)
		(if (& &Default-Transpose-Magic (eolp)) (backward-character)))))
    

    (transpose-word CurrentWord punc EMS
	(setq EMS "")
	(save-excursion
	    (backward-word)
	    (if (bobp)
		(setq EMS "Can't Transpose here!")
		(progn
		    (set-mark)(forward-word)
		    (setq CurrentWord (region-to-string))
		    (backward-word)(backward-word)(forward-word)
		    (setq punc (region-to-string))(delete-next-word)
		    (backward-word)
		    (insert-string (concat CurrentWord punc)))))
	(if (!= "" EMS) (error-message EMS)))

    (goto-column
	(beginning-of-line)
	(while (& (! (eolp)) (< (current-column) &Column-To-Be-At))
	    (forward-character)))
)
)
