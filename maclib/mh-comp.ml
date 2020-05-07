; Common stuff for message composition.
; 	Glenn Trewitt, 7/86


; Edit a buffer and (possibly) mail it.
;	(&mh-compose message other-buffer file)
; 		message		- buffer containing message
;		other-buffer	- other buffer to display on screen
;					("" for none)
; 		file		- file to use to send message
; 
;  If the user "quits" and doesn't send the message, the calling program
;  must provide the error message.
; 
;  When we are done, the two buffers will have their mode lines set
;  "reasonably".  The message buffer will be current and visible on the
;  screen.  No other guarantees.
; 
;  We will also try to remove the checkpoint files for the `edit' buffer.
;  This won't always work, since we may have changed directory and the
;  checkpoint file won't be in the current one.
(defun
    (&mh-compose edit other file exfl resp return-dot
	(setq edit (arg 1))
	(setq other (arg 2))
	(setq file (arg 3))
	(temp-use-buffer edit)
	(save-excursion 
	    (beginning-of-file)
	    (re-search-forward "^-\\|^[ \t]*$")
	    (next-line) (beginning-of-line)
	    (setq return-dot (dot))
	)
	(if (length other)
	    (progn
		  (&mh-pop-to-buffer other)
		  (setq mode-line-format mhml-comp-other)
		  (delete-other-windows)
	    ))
	(setq exfl 0)
	(while (= exfl 0)
	       (error-occured
		   (if (length other)
		       (progn 
			      (temp-use-buffer other)
			      (setq mode-line-format mhml-comp-other)
		       ))
		   (&mh-pop-to-buffer edit)
		   (setq mode-line-format
			 (concat mhml-comp-1
				 (strip-home (current-file-name))
				 mhml-comp-2))
		   (&mh-restore-killbuffer)
		   (recursive-edit)
		   (if (length other)
		       (progn 
			      (temp-use-buffer other)
			      (setq mode-line-format mhml-blank)
		       ))
		   (&mh-pop-to-buffer edit)
		   (setq mode-line-format
			 (concat mhml-comp-done-1
				 (strip-home (current-file-name))
				 mhml-comp-done-2))
		   (beginning-of-file) (sit-for 0)
		   (goto-character return-dot)
		   (if (! (dot-is-visible)) (beginning-of-file))
	       )
	       (error-occured (save-excursion (mh-compose-hook)))
	       (error-occured
		   (setq resp 'e')
		   (setq resp
			 (get-response
			     "Ready to send. Action? (m, d, q, e, or ?) "
			     "mMdDqQeE\" 
			     "m: mail it, d: delayed mail, q: quit, e: resume editing, ?: this msg.")
		   )
	       )

	       (if (= resp 'm')
		   (progn (message "Sending...") (sit-for 0)
			  (temp-use-buffer edit)
			  (write-named-file file)
			  (send-to-shell 
			      (concat mh-progs "/send -noverbose " file)
			  )
			  (if (= (show-shell-errors) 0)
			      (progn (setq exfl 1)
				     (message "Sending... done.") (sit-for 0))
			  )
		   )

		   (= resp 'd')
		   (&mh-delay-send)

		   (= resp 'q')
		   (progn
			 (setq exfl 1)
		   )
	       )
	)
	;  Now restore things.
	(&mh-restore-killbuffer)
	(if (length other)
	    (progn 
		   (temp-use-buffer other)
		   (setq mode-line-format mh-mode-line)
	    ))
	(temp-use-buffer edit)

	;  Try to remove checkpoint and backup files.
	(unlink-file (concat file ".BAK"))
	(unlink-file (concat file ".CKP"))

	resp
    )

    ;  Attempt to queue the message for later delivery with at.
    ;  Sets exfl if successful.
    (&mh-delay-send time
	(if (! (error-occured
		   (setq time
			 (get-tty-string
			     "Delivery Time (hh|hhmm[AM|PM] [day [WEEK]] [month date]) : "))
	       )
	    )
	    (progn 
		   (temp-use-buffer "mh-delay")
		   (erase-buffer)
		   ; If your version of "at" supports the "-c" option to
		   ; force the use of the c-shell, you can get rid of this
		   ; conditional.
		   (if
			(= "/csh" (substr (getenv "SHELL") -4 4))
			(progn
			      (insert-string "set fn=$USER.$$\nset t=/tmp/\n")
			)
			(= "/sh" (substr (getenv "SHELL") -3 3))
			(progn
			      (insert-string "fn=$USER.$$\nt=/tmp/\n")
			)
			(progn 
			       (message "No shell!")
			       (send-string-to-terminal "\^G")
			       (sit-for 20)
			)
		   )
		   (insert-string "/bin/cat <<FrObNiTz >$t$fn\n")
		   (insert-string "Queued-For-Delivery: ")
		   (insert-string (arpa-fmt-date)) (insert-character '\n')
		   (yank-buffer edit)
		   (if (!= (current-column) 1)
		       (insert-character '\n'))
		   (insert-string "FrObNiTz\n")
		   (insert-string (concat mh-progs "/send -noverbose -nopush $t$fn\n"))
		   (insert-string "/bin/rm -f $t,$fn $t$fn\n")
		   (set-mark) (beginning-of-file)
		   ; Alternate:   (fast-filter-region (concat "at -c " time))
		   (fast-filter-region (concat "at " time))
		   (if (= (buffer-size) 0)
		       (progn 
			      (delete-buffer "mh-delay")
			      (message "Queued for delivery.")
			      (setq exfl 1))
		       (progn line
			      (beginning-of-file) (set-mark)
			      (end-of-line)
			      (setq line (region-to-string))
			      (beginning-of-file)
			      (if (looking-at "[0-9.]*$")
				  (progn
					(delete-buffer "mh-delay")
					(message "Queued for delivery:  " line)
					(setq exfl 1))
				  (progn
					(message "Error: " line)
					(send-string-to-terminal "\^G"))
			      )
		       )
		   )
	    )
	)
    )

)

(autoload "arpa-fmt-date" "mh-annot.ml")
(novalue)
