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
; 
; Modified Thu Sep 30 17:48:49 1982 by SWT
; Converted to use new generic incremental search functions.
; Fixed "first time fail" bug.

(declare-global &Inc-search-failing)
(status-line "Loading RE incremental search")
(setq &Inc-search-failing "")

(defun 
    (inc-re-forward-top-level string go-to len
	(inc-top-level (inc-re-forward-work-fun))
    )
    
    (inc-re-reverse-top-level string len go-to
	(inc-top-level (inc-re-reverse-work-fun))
    )

    (inc-re-forward-work-fun next ok nextc failing
	(inc-work-fun "RE-F" '^S' '^R'
	    (re-search-forward string) (re-search-reverse string)
	    (re-forward-add-char)
	    (inc-re-forward-work-fun) (inc-re-reverse-work-fun))
    )

    (re-forward-add-char error
	(| (!= string "") (looking-at "\\="))
	(region-around-match 0)
	(if (! (setq error (error-occured (looking-at (concat string next)))))
	    (exchange-dot-and-mark))
	(if (& (! error)
	       (error-occured (re-search-forward (concat string next))))
	    (progn
		  (setq &Inc-search-failing "Failing ")
		  (exchange-dot-and-mark)
		  (if (error-occured (inc-recurse (inc-re-forward-work-fun)))
		      (if (= failing "")
			  (setq ok 1)
			  (error-message "Aborted."))
		  )
	    )
	    (progn
		  (setq &Inc-search-failing "")
		  (inc-recurse (inc-re-forward-work-fun))
	    )
	)
    )

    (inc-re-reverse-work-fun
	(inc-work-fun "RE-R" '^R' '^S'
	    (re-search-reverse string) (re-search-forward string)
	    (re-reverse-add-char)
	    (inc-re-reverse-work-fun) (inc-re-forward-work-fun))
    )

    (re-reverse-add-char 
	(if (| (error-occured (looking-at (concat string next)))
	       (looking-at (concat string next)))
	    (inc-recurse (inc-re-reverse-work-fun))
	    (error-occured (re-search-reverse (concat string next)))
	    (progn
		  (setq &Inc-search-failing "Failing ")
		  (if (error-occured (inc-recurse (inc-re-reverse-work-fun)))
		      (if (= failing "")
			  (setq ok 1)
			  (error-message "Aborted."))
		  )
	    )
	    (progn
		  (setq &Inc-search-failing "")
		  (inc-recurse (inc-re-reverse-work-fun)))
	)
    )
)
(declare-global search-string search-auto-top-of-window)
(if (= search-auto-top-of-window "") (setq search-auto-top-of-window 0))
(bind-to-key "inc-re-forward-top-level" "\^[\^S")
(bind-to-key "inc-re-reverse-top-level" "\^[\^R")
"Incremental-search loaded!"
(setq mode-line-format default-mode-line-format)
)
