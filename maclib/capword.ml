; 
;  This package provides reasonable functions to mess with the case of the
; current word. All of them operate on the word that contains or immediately
; precedes the cursor, and move the cursor to the next word when they are
; done. Normally they are bound to ESC-U, ESC-L, and ESC-C.
; 
; 	Brian Reid	March 82
; 
(defun
    (upper-case-word cp rb
	(setq cp (dot))
	(backward-word) (forward-word) (setq rb (dot))
	(if (> cp rb)
	    (progn (forward-word) (backward-word)
		   (case-word-upper) (forward-word))
	    (case-word-upper))
	(forward-word) (backward-word))

    (lower-case-word cp rb
	(setq cp (dot))
	(backward-word) (forward-word) (setq rb (dot))
	(if (> cp rb)
	    (progn (forward-word) (backward-word)
		   (case-word-lower) (forward-word))
	    (case-word-lower))
	(forward-word) (backward-word))

    (capitalize-word cp rb
	(setq cp (dot))
	(backward-word) (forward-word) (setq rb (dot))
	(if (> cp rb)
	    (progn (forward-word) (backward-word)
		   (case-word-capitalize) (forward-word))
	    (case-word-capitalize))
	(forward-word) (backward-word))
)

