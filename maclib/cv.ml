; Number conversion function
; Written Thu Apr 15 1982 by Spencer W. Thomas
; Convert numbers from one base to another.
; Normally bound to ^Zc, uses the preceding word for the input number,
; prompts for 'from' and 'to' bases.  If the number starts with 0x, it
; assumes the number is hexadecimal.  It uses the 'cv' program to actually
; do the conversion.
(defun
    (convert num from to answer
	(save-excursion
	    (forward-character)
	    (backward-word)
	    (set-mark)
	    (forward-word)
	    (exchange-dot-and-mark)
	    (setq num (region-to-string))
	    (if (looking-at "0x")
		(progn
		    (setq num (substr num 3 10000))
		    (setq from "x"))
		(progn
		    (message (concat "Convert " num " from base "))
		    (setq from (char-to-string (get-tty-character))))
	    )
	    (message (concat "Convert " num " from base " from " to base"))
	    (setq to (char-to-string (get-tty-character)))
	    (message
		(concat "Convert " num " from base " from " to base " to))
	    (sit-for 0)
	    (setq answer (glob-command "cv -" from to " " num))
	    (delete-region-to-buffer "Scratch")
	    (set-mark)
	    (insert-string answer)
	    (delete-previous-character); get rid of extra space
	    (exchange-dot-and-mark)
	    (if (looking-at "Error")
		(progn
		    (erase-region)
		    (yank-buffer "Scratch")
		    (error-message "Badly formed number"))
		(= to "x") (insert-string "0x")
		(= to "o") (insert-string "0")
	    )
	)
    )
)

(bind-to-key "convert" "\^Zc")
