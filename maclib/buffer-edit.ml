; Buffer edit: this package provides an alternative binding for ^X^B. It
; creates a buffer listing in which you can engage in an interactive dialog
; with Emacs about the fate of each buffer. You can mark them for saving,
; deleting, closing, unsaving, and the like;  when you exit from buffer-edit
; mode all of the marks are processed and the various buffers meet their
; fate.
; This is a real win when you are trying to edit a large system with files
; all over the place.
; 
; The listing is sorted so that the file buffers come first, and the cursor
; is left sitting on the line corresponding to the buffer in which you
; typed the ^X^B command. 
; 
;  Brian K. Reid, Stanford University, August 1982
; 
(defun
    (buffer-edit bufn keep line
	(setq bufn (current-buffer-name))
	(list-buffers) (pop-to-buffer "Buffer list")
	(setq mode-line-format "Buffer edit.  Cmds: n p e d s m r u ?  Exit: g or q")
	(end-of-file) (insert-string "x\n")
	(beginning-of-file) (ebuf-pretty-line)
	(next-line) (ebuf-pretty-line) 
	(next-line) (set-mark)
	(while (& (! (looking-at "^x$")) (! (eobp)))
	       (ebuf-pretty-line)
	       (setq keep 1)
	       (if (!= (ebuf-buffer-type) "File") (setq keep 2))
	       (if (= (ebuf-get-name) "Buffer list") (setq keep 0))
	       (if (!= keep 1)
		   (progn
			 (save-excursion 
			     (beginning-of-line) (set-mark)
			     (end-of-line) (forward-character)
			     (setq line (region-to-string))
			     (erase-region)
			     (if (= keep 2)
				 (progn 
					(end-of-file)
					(insert-string line))
			     )
			 )
		   )
		   (next-line)
	       )
	)
	(delete-next-character) (delete-next-character)
	(exchange-dot-and-mark)
	(error-occured
	    (re-search-forward 	; this is so slimy...
		(concat "^.................." bufn))
	    (position-within-line)
	)
	(novalue)
    )
    
    ; Rewrite the listing format to make it nicer, and to leave room for flags
    (ebuf-pretty-line
	(if (= (ebuf-buffer-type) "File")
	    (progn 
		   (ebuf-goto 42)
		   (while (looking-at " ") (delete-next-character))
	    )
	)
	(ebuf-goto 16)
	(insert-string "  ")
	(beginning-of-line)
    )
    
    ;  Return the string type of the buffer listed in the current line.
    (ebuf-buffer-type
	(save-excursion
	    (temp-use-buffer "Buffer list")
	    (ebuf-goto 9)	    
	    (set-mark)
	    (goto-character (+ (dot) 4))
	    (region-to-string)
	)
    )
    
    ; Return the name attached to the buffer listed in the current line    
    ; This is pretty tricky because the buffer listing doesn't really delimit
    ; the buffer name properly.
    (ebuf-get-name
	(save-excursion
	    (ebuf-goto 18)
	    (set-mark)
	    (ebuf-goto 33)
	    (if (= (preceding-char) ' ')
		(progn
		       (backward-word) (forward-word))
		(progn       
		    (end-of-line)
		    (if (= (ebuf-buffer-type) "File")
			(progn 
			       (while (! (| (bolp) (= (preceding-char) ' ')))
				      (backward-character))
			)
		    )
		    (backward-word) (backward-word) (forward-word)
		)
	    )
	    (region-to-string)
	)
    )
    
; return 1 if this is a real buffer and 0 if it is not
    (ebuf-is-real-buffer v
	(setq v (ebuf-buffer-type))
	(& (!= v "Type") (!= v "----"))
    )
    
    ; return the status character (D for deleted, etc.) that we put there
    (ebuf-status
	(ebuf-goto 16)
	(following-char)
    )
    
    (ebuf-next-line
	(next-line)
	(while (! (| (ebuf-is-real-buffer) (eobp)))
	       (next-line)
	)
	(if (eobp) (previous-line))
	(position-within-line)
    )
; move up one line, but don't move into the column headings    
    (ebuf-previous-line
	(previous-line)
	(beginning-of-line)
	(while (! (| (ebuf-is-real-buffer) (eobp)))
	       (next-line)
	)
	(position-within-line)
    )

; enter a recursive edit on this buffer.    
    (ebuf-edit
	(if (ebuf-is-real-buffer)
	    (save-excursion
		(delete-other-windows)
		(pop-to-buffer (ebuf-get-name))
		(message "Beginning recursive edit...") (sit-for 5)
		(recursive-edit)
		(pop-to-buffer "Buffer list")
		(position-within-line)
	    )
	    (error-message "not a buffer")
	)
    )

; exit from this buffer-editing routine, and fill the screen with current buf
    (ebuf-exit where
	(if (ebuf-is-real-buffer)
	    (progn
		   (setq where (ebuf-get-name))
		   (message "Exiting to buffer " where " ...")
		   (ebuf-cleanup)
		   (pop-to-buffer where)
		   (delete-other-windows)
	    )
	    (error-message "not a buffer")
	)
    )
)

(defun 
; mark current buffer for closing (write and then delete)
    (ebuf-close
	(ebuf-flag-column 16 'C'))
    
; mark the current buffer for deletion without writing
    (ebuf-delete
	(ebuf-flag-column 16 'D'))
    
; mark the current buffer for saving
    (ebuf-save
	(ebuf-flag-column 16 'S'))    
    
; mark the current buffer for nonnsaving (ignore "buffer-is-modified" flag)
    (ebuf-mark
	(ebuf-flag-column 16 'N'))    
    
;  mark current buffer for reverting (reread file contents)
    (ebuf-revert
	(ebuf-flag-column 16 'R'))

; unmark the current buffer for all actions
    (ebuf-undelete
	(ebuf-flag-column 16 ' ')
    )
    
; Put a flag character given as argument 2 into the column given as arg 1
    (ebuf-flag-column
	(temp-use-buffer "Buffer list")
	(ebuf-goto (arg 1))
	(delete-next-character)
	(insert-character (arg 2))
	(position-within-line)
    )
    (ebuf-goto
	(beginning-of-line)
	(goto-character (+ (dot) (arg 1)))
    )
;  put the cursor where we want it
    (position-within-line
	(ebuf-goto 17)
    )
)

(defun     
    (ebuf-cleanup bstat
	(pop-to-buffer "Buffer list")
	(beginning-of-file)
	(next-line) (next-line)
	(while (! (eobp))
	       (setq bstat (ebuf-status))
	       (if (= bstat 'D')	; delete without saving
		   (progn
			 (error-occured
				 (delete-buffer (ebuf-get-name)))
			 (beginning-of-line)
			 (kill-to-end-of-line) (delete-next-character)
		   )
		   (= bstat 'S')	; save buffer
		   (progn
			 (temp-use-buffer (ebuf-get-name))
			 (if (= (ebuf-buffer-type) "File")
			     (progn 
				    (write-current-file)
				    (ebuf-flag-column 14 ' ')
			     )
			 )
			 (next-line)
		   )
		   (= bstat 'C') 	; close--save then delete
		   (progn 
			  (save-excursion 
			      (temp-use-buffer (ebuf-get-name))
			      (if (= (ebuf-buffer-type) "File")
				  (write-current-file)
			      )
			  )
			  (delete-buffer (ebuf-get-name))
			  (beginning-of-line)
			  (kill-to-end-of-line) (delete-next-character)
		   )
		   (= bstat 'N')	; nonsave: mark unmodified
		   (progn 
			  (save-excursion 
			      (temp-use-buffer (ebuf-get-name))
			      (setq buffer-is-modified 0)
			  )
			  (ebuf-flag-column 14 ' ')
			  (next-line)
		   )
		   (= bstat 'R')	; revert buffer
		   (progn
			 (temp-use-buffer (ebuf-get-name))
			 (if (= (ebuf-buffer-type) "File")
			     (progn 
				    (read-file (current-file-name))
				    (ebuf-flag-column 14 ' ')
			     )
			 )
			 (next-line)
		   )
		   (next-line)
	       )
	       (beginning-of-line)
	)
    )    
    (ebuf-beep
	(error-message "Commands: Next, Prev, Edit, Delete, Save, Mark, Reread, Unmark, Goto, Quit, ?")
    )
)

(defun     
    (ebuf-help
	(pop-to-buffer "Help")
	(erase-buffer)
	(insert-string 
"Move cursor to line for a buffer, then type a command:\n"
"  n,sp -- move to next line		  p,^H -- move to previous line\n"
"  d -- delete buffer (no save)		  s -- save buffer\n"
"  m -- (mark as not modified)		  u -- unmark (remove all marks)\n"
"  e -- recursive edit this buffer	  r -- reread from file\n"
"  g -- exit with processing, goto buf	  q -- quit without processing\n"
"Save means to write the buffer now. Delete means to erase the buffer\n"
"without touching the file. Mark means to remove the 'needs saving' flag.\n"
"Unmark means to remove all flags. Reread means to replace current buffer\n"
"contents with file contents.\n"
	)
	(sit-for 0)
    )
)
    (bind-to-key "buffer-edit" "")
    (progn loop
	(save-excursion
	    (temp-use-buffer "Buffer list")
	    (define-keymap "ebuf-keymap")
	    (use-local-map "ebuf-keymap")
	    (setq loop 0)
	    (while (<= loop 127)
		(local-bind-to-key "ebuf-beep" loop)
		(setq loop (+ loop 1))
	    )
	    (setq loop '0')
	    (while (<= loop '9')
		(local-bind-to-key "digit" loop)
		(setq loop (+ loop 1))
	    )
	    (local-bind-to-key "ebuf-help" "?")
	    (local-bind-to-key "ebuf-delete" "d")
	    (local-bind-to-key "ebuf-delete" "D")
	    (local-bind-to-key "ebuf-delete" "")
	    (local-bind-to-key "ebuf-previous-line" "p")
	    (local-bind-to-key "ebuf-previous-line" "P")
	    (local-bind-to-key "ebuf-previous-line" "")
	    (local-bind-to-key "ebuf-previous-line" "")
	    (local-bind-to-key "ebuf-next-line" "n")
	    (local-bind-to-key "ebuf-next-line" "N")
	    (local-bind-to-key "ebuf-next-line" "")
	    (local-bind-to-key "ebuf-next-line" " ")
	    (local-bind-to-key "ebuf-close" "c")
	    (local-bind-to-key "ebuf-close" "C")
	    (local-bind-to-key "ebuf-edit" "e")
	    (local-bind-to-key "ebuf-edit" "E")
	    (local-bind-to-key "ebuf-undelete" "u")
	    (local-bind-to-key "ebuf-undelete" "U")
 	    (local-bind-to-key "ebuf-exit" "g")
 	    (local-bind-to-key "ebuf-exit" "G")
 	    (local-bind-to-key "ebuf-save" "s")
 	    (local-bind-to-key "ebuf-save" "S")
 	    (local-bind-to-key "ebuf-mark" "m")
 	    (local-bind-to-key "ebuf-mark" "M")
	    (local-bind-to-key "ebuf-revert" "r")
	    (local-bind-to-key "ebuf-revert" "R")
	    (local-bind-to-key "ebuf-beep" "")
	    (local-bind-to-key "redraw-display" "\")
	    (local-bind-to-key "search-forward" "\")
	    (local-bind-to-key "search-reverse" "\")
	    (local-bind-to-key "argument-prefix" "\^U")
	    (local-bind-to-key "previous-window" "\^Xp")
	    (local-bind-to-key "previous-window" "\^XP")
	    (local-bind-to-key "next-window" "\^Xn")
	    (local-bind-to-key "next-window" "\^XN")
	    (local-bind-to-key "delete-other-windows" "\^X1")
	    (local-bind-to-key "next-page" "\^V")
	    (local-bind-to-key "redraw-display" "\")
	    (local-bind-to-key "previous-page" "\ev")
	    (local-bind-to-key "previous-page" "\eV")
	    (local-bind-to-key "scroll-one-line-up" "")
	    (local-bind-to-key "scroll-one-line-down" "\e")
	    (local-bind-to-key "beginning-of-file" "\e<")
	    (local-bind-to-key "end-of-file" "\e>")
	    (local-bind-to-key "return-to-monitor" "\")
	    (local-bind-to-key "exit-emacs" "\\")
	)
    )
