;  This autoloaded file defines the "^" command in mhe. It marks a message
; to be moved into another folder. This mark is represented in two ways:
; a "^" character is placed after the number in the header line, and the number
; of the message is placed in the text of an appropriate "file" command 
; in the command buffer. When it is autoloaded, it redefines the function
; &mh-re-move (defined as a no-op in the base file) so that it will repeat
; the last move command with the same destination but a new source.

;  fixed minor bug with partial matches on moves, 
;  eg move to +p could become move to +programs. rjs 21/10/92

(defun 
    (&mh-move
	(progn
	      (&mh-pop-to-buffer (concat "+" mh-folder))
	      (beginning-of-line)
	      (goto-character (+ (dot) mh-msgnum-cols))
	      (if (| (= (following-char) ' ') (= (following-char) '+'))
		  (progn
			(setq mh-last-destination
			      (get-folder-name "Destination" "" 1))
			(&mh-xfer mh-last-destination)
		  )
	      )
	      (message "^ " mh-last-destination)
	      (another-line)
	)
    )
    
    (&mh-re-move
	(&mh-pop-to-buffer (concat "+" mh-folder))
	(beginning-of-line)
	(goto-character (+ (dot) mh-msgnum-cols))
	(if (| (= (following-char) ' ') (= (following-char) '+'))
	    (progn
		  (&mh-xfer mh-last-destination)
	    )
	)
	(message "^ " mh-last-destination)
	(another-line)
    )
    
    (&mh-xfer destn
	(progn 
	       (setq destn (arg 1))
	       (delete-next-character)
	       (insert-string "^")
	       (setq buffer-is-modified 0)
	       (temp-use-buffer "cmd-buffer")
	       (beginning-of-file)
	       (set "stack-trace-on-error" 0)
	       (if (error-occured 
		       (re-search-forward 
			   ; avoid matching on partial substring rjs 21/10/92
			   (concat "^" mh-file-command
				   " -src +" mh-folder " +" destn " "))
		   )
		   (progn 
			  (end-of-file)
			  (insert-string
			      (concat mh-file-command 
				      " -src +" mh-folder " +" destn "\n"))
			  (backward-character)
		   )
	       )
	       (set "stack-trace-on-error" mhe-debug)
	       (end-of-line)
	       (insert-string (concat " " (&mh-get-msgnum)))
	       (setq buffer-is-modified 0)
	       (&mh-pop-to-buffer (concat "+" mh-folder))
	)
    )
)
