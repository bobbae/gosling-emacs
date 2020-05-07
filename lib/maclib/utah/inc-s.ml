(progn

; This code was written at CMU, on or about Sun Jan 25 07:41:13 1981
; by Doug Philips...
; This file attempts to define a reasonable incremental search-facility
; somewhat similar to the incremental search found in MIT Emacs...
; 
; Modified Wed Feb 24 00:07:26 1982 by Spencer W. Thomas at University of
; Utah to better model Twenex incremental search.  In particular, handling
; of failing searches was made compatible.
; 
; Modified Thu Sep 30 17:22:48 1982 by SWT
; Put work functions together into a single function, improved ^G handling.
; Hitting ^G during a failing search returns to the most recent succeeding
; search.  This is exactly what Twenex emacs does.  Fixed a bug which
; prevented the default search string from being rubbed-out.


(declare-global &Inc-search-failing)
(setq &Inc-search-failing "")

(defun 
    (inc-forward-top-level
	(inc-top-level (inc-forward-work-fun))
    )

    (inc-reverse-top-level
	(inc-top-level (inc-reverse-work-fun))
    )

    (inc-top-level string go-to len minibuf
	(setq go-to (dot))
	(setq string "")
	(setq len 0)
	(setq &Inc-search-failing "")
	(arg 1)
	(if (!= go-to (dot))
	    (progn
		  (goto-character go-to)
		  (if search-auto-top-of-window
		      (line-to-top-of-window))))
    )

    (inc-forward-work-fun
	(inc-work-fun "F" '^S' '^R'
	    (search-forward string) (search-reverse string)
	    (forward-add-char)
	    (inc-forward-work-fun) (inc-reverse-work-fun))
	    
    )

    (inc-reverse-work-fun
	(inc-work-fun "R" '^R' '^S'
	    (search-reverse string) (search-forward string)
	    (reverse-add-char)
	    (inc-reverse-work-fun) (inc-forward-work-fun))
    )

; Generalized incremental work function.  Args are:
; 1:	String for search type ("F" or "R")
; 2:	Char for this direction ('^S' or '^R')
; 3:	inverse of 2
; 4:	Search string ((search-forward string) or (search-reverse string))
; 5:	inverse of 4	
; 6:	Add-char function ((forward-add-char) or (reverse-add-char))
; 7:	Work function ((inc-forward-work-fun) or (inc-reverse-work-fun))
; 8:	inverse of 7

    (inc-work-fun next ok nextc failing 
	(if (!= &Inc-search-failing "") (send-string-to-terminal "\^G"))
	(setq ok 1)
	(while (= ok 1)
	       (setq next "")			      ; start with nothing
	       (while (= next "")		      ; loop till we get a
		      ; non-nil character
		      (message (concat &Inc-search-failing
				       "Incremental-" (arg 1)
				       "Search:" string))
		      (setq next (char-to-string (setq nextc
						       (get-tty-character))))
	       )
	       (if (= nextc '^[')			; wants to stay here
		   (progn (setq go-to (dot))	 	; save place
			  (setq ok -1)
			  (if (!= string "") (setq search-string string))
		   )
		   (= nextc '^G') (error-message "Aborted.")

		   (= nextc (arg 2)); search again for same string
		   (if (& (= string "") (= search-string ""))
		       (progn
			     (message "Nothing to search for")
			     (sit-for 2)
		       )
		       (progn first
			      (if (= string "")
				  (progn
					(setq first 1)
					(setq string search-string))
				  (setq first 0)
			      )
			      (save-excursion
				  (if (! (error-occured (arg 4)))
				      (progn
					    (setq failing &Inc-search-failing)
					    (setq &Inc-search-failing "")
					    (setq ok (arg 7))
					    (if (= ok 0) (setq ok 1))
					    (setq &Inc-search-failing failing)
				      )
				      (if (= &Inc-search-failing "")
					  (progn
						(setq &Inc-search-failing
						      "Failing ")
						(send-string-to-terminal
						    "\^G")
						(setq ok 1); assume ok
						(error-occured
						    (setq ok (arg 7)))
						(if (= ok 0) (setq ok 1))
						(setq &Inc-search-failing "")
					  )
					  (send-string-to-terminal "\^G")
				      )
				  )
				  (if first (setq string ""))
			      )
		       )
		   )

		   (= nextc (arg 3)); search in other dir for same string
		   (save-excursion
		       (setq failing &Inc-search-failing)
		       (if (!= string "")
			   (if (error-occured (arg 5))
			       (setq &Inc-search-failing "Failing ")
			       (setq &Inc-search-failing ""))
		       )
		       (setq ok (arg 8))
		       (setq &Inc-search-failing failing)
		       (if (= ok 0) (setq ok 1))
		   )

		   (| (= nextc '^H') (= nextc 127))	; backspace or delete
		   (setq ok 0)

		   (| (& (< nextc '^Q') (!= nextc '^I')
			 (!= nextc '^J') (!= nextc '^M'))
		      (& (> nextc '^Q') (< nextc ' '))
		   )
		   (progn
			 (setq ok -1)
			 (setq go-to (dot))
			 (if (!= string "") (setq search-string string))
			 (push-back-character nextc)
		   )

		   (save-excursion
		       (if (= nextc '^M')
			   (setq next (char-to-string (setq nextc '^J'))))
		       (if (= nextc '^Q')	      ; Control-Q
			   (progn (message (concat &Inc-search-failing
						   "Incremental-Q" (arg 1)
						   "Search:" string))
				  (setq next
					(char-to-string
					    (setq nextc (get-tty-character))))
			   )
		       )
		       (setq failing &Inc-search-failing)
		       (arg 6)
		       (setq &Inc-search-failing failing)
		   )
	       )
	)
	ok
    )

    (inc-recurse err
	(setq string (concat string next))
	(setq len (+ 1 len))
	(setq err (error-occured  (setq ok (arg 1))))
	(if (| (= ok 0) (= err 1))
	    (progn (setq len (- len 1))
		   (if (< len 1)
		       (progn (setq string "")
			      (setq len 0)
		       )
		       (setq string (substr string 1 len))
		   )
		   (if (= err 1)
		       (error-message "Aborted.")
		       (setq ok 1))
	    )
	)
    )

    (forward-add-char
	(if (c= (following-char) nextc)
	    (progn (forward-character)
		   (inc-recurse (inc-forward-work-fun))
	    )
	    (error-occured (search-forward (concat string next)))
	    (progn
		  (setq &Inc-search-failing "Failing ")
		  (if (error-occured (inc-recurse (inc-forward-work-fun)))
		      (if (= failing "")
			  (setq ok 1)
			  (error-message "Aborted."))
		  )
	    )
	    (progn
		  (setq &Inc-search-failing "")
		  (inc-recurse (inc-forward-work-fun))
	    )
	)
    )

    (reverse-add-char
	(if (looking-at (quote (concat string next)))
	    (inc-recurse (inc-reverse-work-fun))
	    (error-occured (search-reverse (concat string next)))
	    (progn
		  (setq &Inc-search-failing "Failing ")
		  (if (error-occured (inc-recurse (inc-reverse-work-fun)))
		      (if (= failing "")
			  (setq ok 1)
			  (error-message "Aborted."))
		  )
	    )
	    (progn
		  (setq &Inc-search-failing "")
		  (inc-recurse (inc-reverse-work-fun)))
	)
    )


)
(declare-global search-string search-auto-top-of-window)
(if (= search-auto-top-of-window "") (setq search-auto-top-of-window 0))
(bind-to-key "inc-forward-top-level" '')
(bind-to-key "inc-reverse-top-level" '')
"Incremental-search loaded!"
)
