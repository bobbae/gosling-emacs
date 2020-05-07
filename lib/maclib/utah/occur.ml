(progn
; this code was modified on or about Thu Apr  9 06:36:37 1981
; by Doug Philips to add the &Occurances-Extra-Lines variable.
;
; this code was written on or about Mon Feb  2 06:11:03 1981
; by Doug Philips to imitate the $XOccurances command in Twenex Emacs
; Unfortunately, this emacs doesn't allow one to scrible on the screen, and
; then have emacs restore the screen, which would be the way to go with
; this command.
;
; What the global variable is used for:
;
; &Occurances-Extra-Lines is a global variable that controls how many extra
; surrounding lines are printed in addition to the line containing the
; string found.  If this variable is 0 then NO additional lines are printed.
; If this variable is greater than 0 then it will print that many lines
; above and below the line on which the string was found.  When printing
; more than one line per match in this fashion, it will also print a
; seperator of '----------------' so you can tell where the different
; matches begin and end.  At the end of the buffer it prints
; '<<<End of Occur>>>'.
(declare-global &Occurances-Extra-Lines)
(if (= "" &Occurances-Extra-Lines)(setq &Occurances-Extra-Lines 0))
(defun
    (Occurances occ-string c buf-name bpp o-count l-count temp-pos
	Occur-String
	(setq o-count (setq l-count 0))(setq buf-name (current-buffer-name))
	(setq bpp (dot))
	(setq occ-string
	    (get-tty-string "Search for all occurances of: "))
	(switch-to-buffer "excursions")(erase-buffer)
	(switch-to-buffer buf-name)(goto-character bpp)
	(while (! (error-occured (re-search-forward occ-string)))
	    (setq o-count (+ 1 o-count))(setq l-count &Occurances-Extra-Lines)
	    (beginning-of-line)(setq temp-pos (dot))
	    (while (> l-count 0) (&PL-Begin) (setq l-count (- l-count 1)))
	    (set-mark) (goto-character temp-pos) (&NL-Begin)
	    (setq temp-pos (dot)) (setq l-count &Occurances-Extra-Lines)
	    (while (> l-count 0) (&NL-Begin) (setq l-count (- l-count 1)))
	    (setq Occur-String (region-to-string))
	    (switch-to-buffer "excursions") (end-of-file)
	    (if (< 0 &Occurances-Extra-Lines)
		(insert-string "----------------\n"))
	    (insert-string Occur-String)
	    (switch-to-buffer buf-name)(goto-character temp-pos)
	) ;;; End of while loop searching
	(error-occured
	    (switch-to-buffer "excursions")
	    (save-excursion (end-of-file)
		(insert-string "<<<End of Occur>>>\n"))
	    (setq mode-line-format
		(concat "Found " o-count " occurances of '" occ-string
		    "' after position: " bpp " in: " buf-name))
	    (beginning-of-file)
	    (while (! (eobp))
		(message
"--More?--(space=next page, ^G=abort, anything else is executed)")
		(setq c (get-tty-character))	 ; grab a character
		(if (= c ' ')
		    (progn (end-of-window) 	 ; keep going
			(if (! (eobp))	 ; but not if on last page!
			    (next-page)
			)
		    )
		    (= c 7)   (end-of-file)	 	 ; quit
		    (progn (push-back-character c); execute-it
			(end-of-file)
		    )
		)
	    )
	)
	(switch-to-buffer buf-name)
	(goto-character bpp)
	o-count
    ) ;;; End of Occurances

    (&NL-Begin
	(next-line) (beginning-of-line))

    (&PL-Begin
	(previous-line) (beginning-of-line))
)
)
