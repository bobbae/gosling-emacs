; This code written at CMU, on or about Sun Jan 25 07:32:39 1981
; by Doug Philips.
;
; Modified:
;	10-Sept-81 Jeffrey Mogul @ Stanford
;	- now self-contained (no external functions needed)
;
; Mlisp code for doing a one-line buffer listing in the mini-buffer.
; If buffer list is longer than one line, it will print a line at a time
; and wait for a character to be input before moving on to the next line...
; Note:  buffers that have been changed since they were last saved are
; prefixed with an Asterisk(*)... and buffers that have no file associated
; with them are prefixed with a hash-mark(#) and empty buffers are flagged
; with a AtSign(@).
; Note: "load"ing this file binds 'one-line-buffer-list' to ^X^B.

(defun

    (first-non-blank				 ; a useful function
	(beginning-of-line)
	(while (| (= (following-char) 32)	 ; space
		  (= (following-char) 9))	 ; tab
	   (forward-character)
	)
	(current-column)			 ; returned for convience
    )

    (skip-forward-matching char			 ; originally in electric-lisp
	(setq char (following-char))
	(forward-character)
	(while (!= (following-char) char)
	    (forward-character)
	)
	(forward-character)
    )    

    (one-line-buffer-list msg puw empty
	(setq puw pop-up-windows)	    ; save value for later
	(setq pop-up-windows 0)		    ; re-use current window.
	(save-excursion
	    (list-buffers)		    ; generate buffer listings
	    (temp-use-buffer "Buffer list")
	    (beginning-of-file)
	    (kill-to-end-of-line)	    ; for loops needed!!!!
	    (kill-to-end-of-line)
	    (kill-to-end-of-line)
	    (kill-to-end-of-line)
	    (beginning-of-file)
; Flag all the modified buffers...
	    (while (! (eobp))
		(beginning-of-line)		    ; back to top of buffer
		(while (! (= 15 (current-column)))
		    (forward-character))
		(if (= (following-char) 'M')
		    (progn
			(delete-next-character)
			(forward-character)
			(insert-character '*')))
		(next-line))
	    (beginning-of-file)
; eliminate Non-file(Scratch?) buffers...
	    (while (! (error-occured (search-forward "   Scr ")))
		(beginning-of-line)
		(kill-to-end-of-line)
		(kill-to-end-of-line)
	    )
	    (beginning-of-file)		    ; start at top again
	    (while (! (eobp))		    ; and wipe out the first -
		(setq empty (is-zero?))     ;    (remember if buffer is empty)
		(beginning-of-line)
		(delete-white-space)	    ; - two columns of the buffer
		(delete-next-word)	    ;   listing which are the size
		(delete-white-space)	    ;   and type columns...
		(delete-next-word)
		(delete-white-space)
		(if empty
		    (progn (beginning-of-line)
			   (insert-string "@")
			   (beginning-of-line)
		    )
		)
		(next-line)
	    )
	    (beginning-of-file)		    ; back at the beginning again
; Flag all the unnamed buffers...
	    (while (! (error-occured (search-forward "[none]")))
		   (beginning-of-line)
		   (insert-character '#')
		   (next-line)
	    )
	    (beginning-of-file)		    ; back to the top!
	    (while (! (eobp))		    ; hack out all but buffer name
		(while (& (!= (following-char) ' '); space or
			  (!= (following-char) 9)); tab!
			  (forward-character)
		)
		(kill-to-end-of-line)
		(next-line)
		(beginning-of-line)
	    )
	    (end-of-file)
	    (delete-previous-character)	    ; kill trailing crlf
	    (beginning-of-file)		    ; go back and change
	    (error-occured (replace-string "\n" ", "))	; newlines to /, /s
	    (beginning-of-file)
	    (set-mark)
	    (end-of-file)		    ; suck in buffer contents
	    (setq msg (concat "Buffers: " (region-to-string)))
	)
	(setq pop-up-windows puw)	    ; restore to previous value
	(if (> (length msg) 76)		    ; attempt to get string on one
		(setq msg (substr msg 10 -9)); line
	)
	(while (> (length msg) 76)	    ; multi-line mode
	    (message (concat (substr msg 1 76) "$")); print nth line
	    (setq msg (substr msg 77 10000000)); hack it off, and
	    (get-tty-character)		    ; wait for more
	)
	(message msg)			    ; print out final line
    )

    (is-zero?
	(first-non-blank)
	(if (= (following-char) '0')
	    (progn (forward-character)
		   (if (| (= (following-char) 32) (= (following-char) 9))
			1
			0
		   )
	    )
	    0
	)
	
    )
)

(bind-to-key "one-line-buffer-list" "\^X\^B")
(novalue)
