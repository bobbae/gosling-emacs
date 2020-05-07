(defun
    ;  pages you through the current buffer, <space> means next screen,
    ; <bs> means previous screen, <esc> or rubout
    ; just exits, and anything else exits and executes.
    (*more* char dot
	    (setq dot (dot))
	    (while (! (eobp) )
		(end-of-window)
		(if (eobp)
		    (message "-- End --")
		    (message "-- More --"))
		(setq char (get-tty-character))
		(if (= char '')
		    (previous-page)
		    (& (= char 32) (! (eobp)))
		    (next-page)
		    (progn
			(if (& (!= char '') (!= char '')
			       (!= char '^M') (!= char '^J'))
			    (push-back-character char)
			    (| (= char '^M') (= char '^J'))
			    (setq dot (dot)))
			(end-of-file))
		)
	    )
	    (goto-character dot)
    )
    
    ; view a buffer using *more*, then go back where you were.
    (view-buffer b
	(save-window-excursion
	    (setq b (get-tty-buffer "View Buffer: "))
	    (use-old-buffer b)
	    (beginning-of-file)
	    (*more*)
	)
    )
)
