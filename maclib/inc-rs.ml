; Incremental regular expression searches
; Written Wed Feb 24 00:23:03 1982 by Spencer W. Thomas
; Based on Incremental search package by Doug Phillips of CMU

(progn

; This code was written at CMU, on or about Sun Jan 25 07:41:13 1981
; by Doug Philips...
; This file attempts to define a reasonable incremental search-facility
; somewhat similar to the incremental search found in MIT Emacs...
; 
; Modified Wed Feb 24 00:07:26 1982 by Spencer W. Thomas at University of
; Utah to better model Twenex incremental search.  In particular, handling
; of failing searches was made compatible.
(declare-global &Inc-search-failing)
(setq &Inc-search-failing "")
(status-line "Loading RE incremental search")
(defun 
    (inc-re-forward-work-fun next ok nextc failing
	(if (!= &Inc-search-failing "") (send-string-to-terminal "\^G"))
	(setq ok 1)
	(while (= ok 1)
	    (setq next "")			      ; start with nothing
	    (while (= next "")			      ; loop till we get a
						      ; non-nil character
		(message (concat &Inc-search-failing
			     "Incremental-RE-FSearch:" string))
		(setq next (char-to-string (setq nextc
						 (get-tty-character))))
	    )
	    (if (| (= nextc '^[') (= nextc '^M'))	; wants to stay here
		    (progn (setq go-to (dot))	  	; save place
			   (setq ok -1)
			   (if (!= string "") (setq search-string string))
		    )
		(= nextc '^G')			      ; Bell
		    (error-message "Aborted.")
		(= nextc '^S')			      ; Control-S
		    (if (& (= string "") (= search-string ""))
			    (progn
				(message "Nothing to search for")
				(sit-for 2)
			    )
			(progn
			    (if (= string "") (setq string search-string))
			    (save-excursion
				(if (! (error-occured
					   (re-search-forward string)))
					(progn
					    (setq failing &Inc-search-failing)
					    (setq &Inc-search-failing "")
					    (setq ok
						(inc-re-forward-work-fun))
					    (if (= ok 0) (setq ok 1))
					    (setq &Inc-search-failing failing)
					)
					(if (= &Inc-search-failing "")
					    (progn
						(setq &Inc-search-failing
						    "Failing ")
						(setq ok
						    (inc-re-forward-work-fun))
						(if (= ok 0) (setq ok 1))
						(setq &Inc-search-failing "")
					    )
					    (send-string-to-terminal "\^G")
					)
				)
			    )
			)
		    )
		(= nextc '^R')			      ; Control-R
		    (save-excursion
			(setq failing &Inc-search-failing)
			(if (!= string "")
			    (if (error-occured
				    (re-search-reverse string))
				(setq &Inc-search-failing "Failing ")
				(setq &Inc-search-failing ""))
			)
			(setq ok (inc-re-reverse-work-fun))
			(setq &Inc-search-failing failing)
			(if (= ok 0) (setq ok 1))
		    )
		(| (= nextc '^H') (= nextc 127))	; backspace or delete
		    (setq ok 0)
		(| (& (< nextc '^Q') (!= nextc '^I'))
		   (& (> nextc '^Q') (< nextc ' '))
		)
		    (progn
			(setq ok -1)
			(setq go-to (dot))
			(if (!= string "") (setq search-string string))
			(push-back-character nextc)
		    )
		(save-excursion
		    (if (= nextc 17)		      ; Control-Q
			(progn (message (concat &Inc-search-failing
					    "Incremental-RE-QSearch:" string))
			(setq next (char-to-string
				       (setq nextc (get-tty-character)))))
		    )
		    (setq failing &Inc-search-failing)
		    (if (!= string "")
			(region-around-match 0)
			(set-mark)
		    )
		    (exchange-dot-and-mark)
		    (if
			(error-occured
			    (re-search-forward (concat string next)))
			(progn
			    (setq &Inc-search-failing "Failing ")
			    (exchange-dot-and-mark)
			    (inc-re-forward-recurse)
			)
			(progn
			    (setq &Inc-search-failing "")
			    (inc-re-forward-recurse)
			)
		    )
		    (setq &Inc-search-failing failing)
		)
	    )
	)
	ok
    )
    (inc-re-forward-top-level string go-to len
	(setq go-to (dot))
	(setq string "")
	(setq len 0)
	(setq &Inc-search-failing "")
	(inc-re-forward-work-fun)
	(if (!= go-to (dot))
	    (progn
		(goto-character go-to)
		(if search-auto-top-of-window
		    (line-to-top-of-window))))
    )

    (inc-re-forward-recurse
	(setq string (concat string next))
	(setq len (+ 1 len))
	(setq ok (inc-re-forward-work-fun))
	(if (= ok 0)
	    (progn (setq len (- len 1))
		   (if (< len 1)
		       (progn (setq string "")
			      (setq len 0)
		       )
		       (setq string (substr string 1 len))
		   )
		   (setq ok "1")
	    )
	)
    )

    (inc-re-reverse-work-fun next ok nextc failing
	(if (!= &Inc-search-failing "") (send-string-to-terminal "\^G"))
	(setq ok 1)
	(while (= ok 1)
	    (setq next "")
	    (while (= next "")
		(message (concat &Inc-search-failing
			     "Incremental-RE-RSearch:" string))
		(setq next (char-to-string (setq nextc
					       (get-tty-character))))
	    )
	    (if (| (= nextc '') (= nextc '^M'))
		    (progn (setq go-to (dot))
			(setq ok -1)
			(if (!= string "")
			    (setq search-string string))
		    )
		(= nextc '') (error-message "Aborted.")
		(= nextc '')
		    (if (& (= string "") (= search-string ""))
			(progn
			    (message "Nothing to search for")
			    (sit-for 2)
			)
			(progn
			    (if (= string "") (setq string search-string))
			    (save-excursion
				(if (! (error-occured
					   (re-search-reverse string)))
				    (progn
					(setq failing &Inc-search-failing)
					(setq &Inc-search-failing "")
					(setq ok (inc-re-reverse-work-fun))
					(if (= ok 0) (setq ok 1))
					(setq &Inc-search-failing failing)
				    )
				    (if (= &Inc-search-failing "")
					(progn
					    (setq &Inc-search-failing
						"Failing ")
					    (setq ok
						(inc-re-reverse-work-fun))
					    (if (= ok 0) (setq ok 1))
					    (setq &Inc-search-failing "")
					)
					(send-string-to-terminal "\^G")
				    )
				)
			    )
			)
		    )
		(= nextc '')
		    (save-excursion
			(setq failing &Inc-search-failing)
			(if (!= "" string)
			    (if (error-occured (re-search-forward string))
				(setq &Inc-search-failing "Failing ")
				(setq &Inc-search-failing ""))
			)
			(setq ok (inc-re-forward-work-fun))
			(if (= ok 0) (setq ok 1))
			(setq &Inc-search-failing failing)
		    )

		    (| (= nextc '') (= nextc 127))
			(setq ok 0)

		(| (& (< nextc '^Q') (!= nextc '^I'))
		   (& (> nextc '^Q') (< nextc ' '))
		)
		    (progn
			(setq ok -1)
			(setq go-to (dot))
			(if (!= string "") (setq search-string string))
			(push-back-character nextc)
		    )

		    (save-excursion		 ; else
			(if (= nextc '^Q')	      ; Control-Q
			    (progn
				(message
				    (concat &Inc-search-failing
					"Incremental-RE-QRSearch:" string))
				(setq next
				    (char-to-string
					(setq nextc (get-tty-character)))))
			)
			(setq failing &Inc-search-failing)
			(if (!= string "")
			    (region-around-match 0)
			    (set-mark)
			)
			(if
			    (error-occured
				(re-search-reverse (concat string next)))
			    (progn
				(setq &Inc-search-failing "Failing ")
				(exchange-dot-and-mark)
				(inc-re-reverse-recurse)
			    )
			    (progn
				(setq &Inc-search-failing "")
				(inc-re-reverse-recurse))
			)
			(setq &Inc-search-failing failing)
		    )			 ; end of save-excursion
		)				 ; if ...
	)
	(setq &Inc-search-failing failing)
	ok
    )
    (inc-re-reverse-top-level string len go-to
		(setq go-to (dot))
		(setq string "")
		(setq len 0)
		(setq &Inc-search-failing "")
		(inc-re-reverse-work-fun)
		(if (!= go-to (dot))
		    (progn
			(goto-character go-to)
			(if search-auto-top-of-window
			    (line-to-top-of-window))))
    )
    (inc-re-reverse-recurse
	(setq string (concat string next))
	(setq len (+ 1 len))
	(setq ok (inc-re-reverse-work-fun))
	(if (= ok 0)
	    (progn (setq len (- len 1))
		   (if (< len 1)
		       (progn (setq string "")
			      (setq len 0)
		       )
		       (setq string (substr string 1 len))
		   )
		   (setq ok "1")
	    )
	)
    )
)
(declare-global search-string search-auto-top-of-window)
(if (= search-auto-top-of-window "") (setq search-auto-top-of-window 0))
(bind-to-key "inc-re-forward-top-level" "\^[\^S")
(bind-to-key "inc-re-reverse-top-level" "\^[\^R")
(setq mode-line-format default-mode-line-format)
)
