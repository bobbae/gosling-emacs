(defun 
    ;  pages you through the current buffer, <space> means next screen,
    ; <bs> means previous screen, <esc> or rubout
    ; just exits, and anything else exits and executes.
    (*more* d char
	(end-of-window)
	(setq d (dot))
	(if (< d (buffer-size) ) (progn (message "--more--") (sit-for 100)))
	(setq char (get-tty-character))
	(if (= char '')
	    (progn (previous-page)(*more*))
	    (if (= char 32)
		(progn (next-page) (*more*))
		(if (& (!= char '')
			(!= char ''))
		    (push-back-character char)))))
    
    ; view a buffer using *more*, then go back where you were.
    (view-buffer b dot cb
	(setq cb (current-buffer-name))
	(setq dot (dot))  
	(setq b (get-tty-string "View Buffer: "))
	(switch-to-buffer b)
	(*more*)
	(switch-to-buffer cb)
	(goto-character dot))
)
