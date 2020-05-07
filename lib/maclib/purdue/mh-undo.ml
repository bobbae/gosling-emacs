; This function implements the "u" command of mhe.
; It removes a delete or move mark that has been placed on a
; message. To do this, we must remove the "D" or "^" flag in the header
; line, and also remove the message number from the requisite "rmm"
; or "file" command in the command buffer.
; 
(defun 
    (&mh-undo msgnum
	(pop-to-mh-buffer)
	(beginning-of-line)
	(setq msgnum (&mh-get-msgnum))
	(goto-character (+ (dot) 3))
	(if (= (following-char) 'D')
	    (progn
		(delete-next-character)
		(insert-character ' ')
	    )
	    (= (following-char) '^')
	    (progn
		(delete-next-character)
		(insert-character ' ')
		(next-line)
		(beginning-of-line)
		(while (looking-at "\tmove to ")
		    (kill-to-end-of-line)
		    (kill-to-end-of-line)
		    (next-line)
		)
		(previous-line)
	    )
	)
	(another-line)
    )
)

