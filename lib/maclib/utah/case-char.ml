(defun			; Functions for case-switching single chars.

    (case-char-lower	; Bind to M-L.
	(provide-prefix-argument prefix-argument
	    (case-char-change (case-region-lower))))

    (case-char-upper	; Bind to M-C and M-U.
	(provide-prefix-argument prefix-argument
	     (case-char-change (case-region-upper))))

    ; Case change a single character, preserving the position of mark.
    ; Implemented in terms of case-region commands, passed as an arg.
    (case-char-change
	(prefix-argument-loop 
	    (if (! (eobp))		; Can''t do it at end-of-buffer.
		(progn
		      (save-excursion 
			  (set-mark)		; Region around character.
			  (forward-character)
			  (arg 1)		; Do it by evaluating the arg.
		      )
		      (forward-character)	; Forward over character.
		)
	    )
	)
    )
)
