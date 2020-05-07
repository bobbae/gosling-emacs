(defun
    (dot-in-header wasdot
	(save-excursion
	    (setq wasdot (dot))
	    (beginning-of-file)
	    (search-forward "-------")
	    (beginning-of-line)
	    (> (dot) wasdot)
	)
    )
    (header-line-position
	(beginning-of-line)
	(search-forward ":")
	(if (eolp) 
	    (insert-character ' ')
	    (progn
		(forward-character)
		(if (! (eolp))
		    (progn
			(forward-word)
			(backward-word)
		    )
		)
	    )
	)
    )
    
    (header-next
	(if (dot-in-header)
	    (progn
		(next-line)
		(header-line-position)
	    )
	    (next-line)
	)
    )
    
    (header-previous
	(if (dot-in-header)
	    (progn
		(previous-line)
		(header-line-position)
	    )
	    (previous-line)
	)
    )
    (at-header-separator
	(! (error-occured
	       (bolp)
	       (= (following-char) '-')
	       (while (! (eolp))
		   (forward-character)
		   (= (following-char) '-')
	       )
	   )
	)
    )    
    
    (justify-paragraph
	(error-occured
	    (! (dot-in-header))
	    (save-excursion
		(beginning-of-line)
		(while (& (! (bobp))
			   (! (eolp))
			   (!= (following-char) '	')
			   (! (at-header-separator)
			       (previous-line))
		       )
		    (next-line)
		    (if (& (! (eolp)) (! (eobp)))
			(progn last-col c-col
			    (delete-white-space)
			    (to-col left-margin)
			    (while (progn
				       (end-of-line)
				       (if (! (eobp)) (forward-character))
				       (& (! (eolp))
					   (!= (following-char) '	')))
				(delete-previous-character)
				(delete-white-space)
				(insert-string " ")
			    )
			    (if (bolp) (backward-character))
			    (setq c-col (current-column))
			    (while (progn
				       (setq last-col c-col)
				       (insert-character ' ')
				       (delete-previous-character)
				       (beginning-of-line)
				       (if (= (following-char) '@')
					   (insert-character ' '))
				       (end-of-line)
				       (setq c-col (current-column))
				       (< c-col last-col))
				(novalue))
			)
		    )
		)
		(message "Done!")
		(novalue)
	    )
	)
    )
    
    (mail-draft-mode
	(setq mode-string "mail-draft")
	(set "right-margin" 72)
	(beginning-of-file)
	(header-line-position)
	(local-bind-to-key "header-next" '')
	(local-bind-to-key "header-previous" '')
	(use-syntax-table "text-mode")
	(novalue)
    )
)

(mail-draft-mode)


