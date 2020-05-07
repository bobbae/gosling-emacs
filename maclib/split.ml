(defun 
    (top-line-of tlo-window tlo-l
	(setq tlo-window (arg 1 "Window: "))
	(setq tlo-l 1)
	(if (> tlo-window (number-of-windows))
	    (error-message "No such window"))
	(save-window-excursion 
	    (top-window)
	    (while (> tlo-window 1)
		   (setq tlo-l (+ tlo-l (window-height) 1))
		   (setq tlo-window (- tlo-window 1))(next-window))
	)
	tlo-l
    )
)

(defun 
    (which-window-has-y wwh-y wwh-w
	(setq wwh-y (arg 1 "Y value: "))
	(save-window-excursion 
	    (setq wwh-w 1)
	    (top-window)
	    (while (& (> wwh-y (+ (window-height) 1))
		      (< wwh-w (number-of-windows)))
		   (setq wwh-w (+ 1 wwh-w))
		   (setq wwh-y (- wwh-y (window-height) 1))
		   (goto-window wwh-w))
	)
	wwh-w
    )
)
    
; find the number of the line that y is on in its window.
; return 0 if y is in the bar below the window.
(defun 
    (line-in-window-of-y liw-y liw-w liw-l
	(setq liw-y (arg 1 "Y value: "))
	(save-window-excursion 
	    (setq liw-w 1)
	    (top-window)
	    (while (& (> liw-y (+ (window-height) 1))
		      (< liw-w (number-of-windows)))
		   (setq liw-w (+ 1 liw-w))
		   (setq liw-y (- liw-y (window-height) 1))
		   (goto-window liw-w))
	    (setq liw-l (<= liw-y (window-height)))
	    (beginning-of-window) (end-of-line)
	    (if wrap-long-lines
		(setq liw-y (- liw-y (/ (- (current-column) 1) (window-width)))))
	    (setq liw-y (- liw-y 1))
	    (if liw-l (while (& (> liw-y 0) (! (eobp)))
			 (setq liw-l (+ 1 liw-l))(next-line)(end-of-line)
			 (if wrap-long-lines
			     (setq liw-y (- liw-y (/ (- (current-column) 1)
				      (window-width)))))
			 (setq liw-y (- liw-y 1))))
	    liw-l
	)
    )
)

(defun
    (which-window-line wwl-i wwl-saved-dot
	(setq wwl-i 0)(setq wwl-saved-dot (dot))
	(save-excursion
	    (beginning-of-window)
	    (end-of-line)
	    (while (< (dot) wwl-saved-dot)
		   (if wrap-long-lines 
		       (setq wwl-i (+ wwl-i (/ (- (current-column) 1) (window-width)))))
		   (setq wwl-i (+ 1 wwl-i))(next-line)(end-of-line)))
	wwl-i
    )
)
    
(defun 
    (slow-move-dot-to-x-y smdtxy-x smdtxy-y smdtxy-w smdtxy-l
	(setq smdtxy-x (arg 1 "X coordinate: "))
	(setq smdtxy-y (arg 2 "Y coordinate: "))
	(setq smdtxy-w (which-window-has-y smdtxy-y))
	(setq smdtxy-l (line-in-window-of-y smdtxy-y))
	(if (= smdtxy-l 0)
	    (error-message "The mouse is not pointing at a window"))
	(goto-window smdtxy-w)
	(beginning-of-window)
	(setq smdtxy-y (- smdtxy-y (top-line-of smdtxy-w)))
	(provide-prefix-argument (- smdtxy-l 1) (next-line))
	(beginning-of-line)
	(setq smdtxy-y (- smdtxy-y (which-window-line)))
	(setq smdtxy-x (+ smdtxy-x (* smdtxy-y (- (window-width) 1))))
	(while (& (> smdtxy-x (current-column)) (! (eolp)))
	       (forward-character))
	(if (& (< smdtxy-x (current-column)) (! (bolp)))
	    (backward-character))
    )
)
    
(defun
    (on-first-window-line ofwl-saved-dot
	(save-excursion 
	    (beginning-of-line)
	    (setq ofwl-saved-dot (dot))
	    (beginning-of-window)
	    (= ofwl-saved-dot (dot)))
    )
)
    
(defun 
    (on-last-window-line olwl-saved-dot
	(save-excursion 
	    (beginning-of-line)
	    (setq olwl-saved-dot (dot))
	    (end-of-window)
	    (beginning-of-line)
	    (= olwl-saved-dot (dot)))
    )
)

(defun 
    (split-window-at-dot old-dot line-in-window first-line last-line
	(setq old-dot (dot))
	(setq line-in-window (which-window-line))
	(setq first-line (on-first-window-line))
	(setq last-line (on-last-window-line))
	(if first-line (progn (next-line)
			      (setq line-in-window (which-window-line)))
	    last-line (progn (previous-line)
			     (setq line-in-window (which-window-line))))
	(if (error-occured 
		(split-current-window)
		(previous-window)
		(error-occured 
		    (provide-prefix-argument 
			(- line-in-window (window-height))
			(enlarge-window))
		)
		(goto-character old-dot)
		(line-to-bottom-of-window)
		(if first-line (goto-character old-dot)
		    (progn 
			   (scroll-one-line-down)
			   (end-of-window)))
		(next-window)
		(goto-character old-dot)
		(line-to-top-of-window)
		(if first-line 
		    (progn 
			   (scroll-one-line-up)
			   (beginning-of-window)
			   (previous-window)))
	    )
	    (message "You can't split a window that small.")
	)
	(novalue)
    )
)

; (global-rebind "split-window-at-dot" "split-current-window")

(novalue)
