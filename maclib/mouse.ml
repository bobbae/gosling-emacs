(defun

    (left-button
	(move-dot-to-x-y (arg 1) (arg 2))
	(setq middle-button-binding 0)
    )
    
    (middle-left
	; the save-excursion is to cause an error in case we are in the mode
	; line. This is so that thumbing will work.
	(save-excursion (move-dot-to-x-y (arg 1) (arg 2)))
	(yank-from-killbuffer)
    )

    (middle-right
	; the save-excursion is to cause an error in case we are in the mode
	; line. This is so that thumbing will work.
	(save-excursion (move-dot-to-x-y (arg 1) (arg 2)))
	(delete-to-killbuffer)
	(setq middle-button-binding 0)
    )

    (right-button
	(set-mark)
	(move-dot-to-x-y (arg 1) (arg 2))
	(if (! (eobp)) (forward-character))
	(exchange-dot-and-mark)
	(copy-region-to-buffer "Kill buffer")
	(setq middle-button-binding 1)
    )

    (scroll-window 
	(move-dot-to-x-y 1 (- (arg 3) 1))
	(if (= (arg 1) 0) (next-page))
	(if (= (arg 1) 1)
	    (goto-percent (/ (* (arg 2) 100) 80))
	)
	(if (= (arg 1) 2) (previous-page))
    ) 
    
    (do-edit-action
	(if (= (arg 1) 0) (left-button (arg 2) (arg 3)))
	(if (= (arg 1) 1)
	    (if (= middle-button-binding 0)
		(middle-left (arg 2) (arg 3))
		(middle-right (arg 2) (arg 3))
	    )
	)
	(if (= (arg 1) 2) (right-button (arg 2) (arg 3)))
    )
    
    (goto-percent
	(goto-character (/ (* (buffer-size) (arg 1)) 100))
    )
)

(setq-default middle-button-binding 0)
