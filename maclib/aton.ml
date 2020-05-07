;;; ATON -- line oriented "fly-by" search capability for Unix-Emacs.
;;; By Jeff Shrager and Duane Williams: CMU.

;;; ATON prompts for an argument which is string to be located in the
;;; current buffer.  It makes a list of all the lines in that buffer
;;; that contain the specified string and then leaves the user in recursive
;;; edit in that list.  The user should place himself on some line of the
;;; file/list and then use ^C to end recursive edit mode.  This will cause
;;; him to be repositioned in the original buffer at the line selected
;;; from the summary list.  If the string entered is nil then THE EXACT
;;; SAME summary list is used.  It will not reflect changes in the file
;;; made since the last use of ATON and the cursor will be placed at the
;;; NEXT location.  This is useful for stepping through located lines
;;; rapidly in order.

;;; The meaning of the name and the prompt are shaded in antiquity.  Let
;;; us know if you figure them out.  You'll be a member of a select few.

    (defun
	(aton-lines-in-buffer count
	    (save-excursion
		(beginning-of-file)
		(setq count 0)
		(while (!(eobp))
		    (next-line)
		    (setq count (+ count 1))
		)
	    )
	    count
	)

	(aton-current-line line-number
	    (save-excursion
		(save-restriction
		    (set-mark)
		    (beginning-of-file)
		    (narrow-region)
		    (setq line-number (aton-lines-in-buffer))
		    (exchange-dot-and-mark)
		    (if (bolp)
			(setq line-number (+ 1 line-number)))
		)
	    )
	    line-number
	)

	(aton s ln l tracking done rebuild-summary
	    (setq s (get-tty-string "@O&P'"))	; get search string
	    (if (!= "" s)
		(setq rebuild-summary 1))
	    (setq tracking track-eol-on-^N-^P)	; remember prev value
	    (setq track-eol-on-^N-^P 0)		; dont track eol
	    (if rebuild-summary
		    (save-excursion			; setup temp buffer
			(pop-to-buffer "String Search")
			(erase-buffer)
			(setq checkpoint-frequency 0)	; no CKP files needed
		    )
	    )
	    (save-excursion
		(beginning-of-file)
		(set-mark)			; init for narrow-region
		(setq ln 0)			; init accumulator
		(setq done 0)
		(if rebuild-summary
			(while (! done)
			    (if (error-occured (search-forward s))
				(setq done 1)
				(progn
				    (end-of-line)	; to pick up entire line
				    (narrow-region)	; dont count lines twice
				    (setq ln (+ ln (aton-current-line)))
				    (set-mark)		; copy line to temp buffer
				    (beginning-of-line)
				    (setq l (region-to-string))
				    (save-excursion
					(pop-to-buffer "String Search")
					(insert-string (concat ln ". " l))
					(newline)
				    )
				    (widen-region)	; continue through file
				    (next-line)
				    (set-mark)		; reset for narrow-region
				)
			    )
			)
		)
		(pop-to-buffer "String Search")		; show user the results
		(if rebuild-summary
			(previous-line)
			(next-line)
		)
		(delete-other-windows)
		(setq buffer-is-modified 0)
		(if (= 0 (aton-lines-in-buffer))
			(error-message "Lusing aton search."))
		(message "Use ^C to expand to the selected line.")
		(recursive-edit)
		(beginning-of-line)
		(search-forward ".")
		(backward-character)
		(set-mark)
		(beginning-of-line)
		(setq ln (region-to-string))
	    )
	    (setq track-eol-on-^N-^P tracking)	; restore old value
	    (goto-line ln)
	    (delete-other-windows)
	)
    )
