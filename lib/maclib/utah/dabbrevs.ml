; DABBREVS - "Dynamic abbreviations" hack, originally written by Don Morrison
; for Twenex Emacs.  Converted to mlisp by Russ Fish.  Supports the table
; feature to avoid hitting the same expansion on re-expand, and the search
; size limit variable.  Bugs fixed from the Twenex version are flagged by
; comments starting with ;;; .
;  
; If anyone feels like hacking at it, Bob Keller (Keller@Utah-20) first
; suggested the beast, and has some good ideas for its improvement, but
; doesn't know TECO (the lucky devil...).  One thing that should definitely
; be done is adding the ability to search some other buffer(s) if you can't
; find the expansion you want in the current one.

(defun

    (dabbrevs-help		; Puts summary into Help buffer.
	(save-excursion
	    (pop-to-buffer "Help")
	    (erase-buffer)
	    (insert-string 
 "Dabbrevs commands and option vars: {prefix args from C-U or Meta-digits.}\n"
 "   M-space     Expand word before dot in buffer, looking back, then forward.\n"
 "   ^X-space    Re-expand: continue search for same abbrev as last M-space.\n"
 " {arg}^X-space Un-expand: Remove expansion, restoring abbrev string.\n"
 " {n}M-space    Take n\'th distinct expansion for abbrev.\n"
 " {-n}M-space   Take n\'th expansion, looking forward only.\n"
 "   dabbrevs-backward-only - Limits search direction, default 0 (both ways).\n"
 " {0}M-space    Override non-0 dabbrevs-backward-only to search both ways.\n"
 "   dabbrevs-limit - Search size in chars, for LARGE files. Default 0 (all.)\n"
 "   dabbrevs-setup-hook - Overrides default bindings, executed if not 0."
	    )
	    (beginning-of-file)
	)
	(novalue)
    )

    (setup-dabbrevs		; Setup DABBREVS Library
	; Puts dabbrevs-expand on Meta-<space> and dabbrevs-re-expand on
	; Control-X-<space>.  Creates lots of global variables, too.  
	; Won''t bind any keys if dabbrevs-setup-hook exists and is 
	; non-zero, but will run the hook instead.
    
	(declare-buffer-specific dabbrevs-limit)
	(setq-default dabbrevs-limit 0)   ; Limits the region searched by 
	; dabbrevs-expand to the specified number of characters away.
    
	(setq-default dabbrevs-backward-only 0)    ; >0 => dabbrevs-expand
	; only looks backwards.  Note that an explicit argument of zero to
	; dabbrevs-expand can be used to over-ride this.
    
	; State vars for dabbrevs-re-expand.
	(declare-global last-dabbrevs-abbreviation)
	(setq last-dabbrevs-abbreviation "")		; Initially null.
	(declare-global last-dabbrevs-direction)	; Initially 0.
	(declare-global last-dabbrevs-abbrev-location)
	(setq last-dabbrevs-abbrev-location -1)		; Initially -1.
	(declare-global last-dabbrevs-expansion)
	(setq last-dabbrevs-expansion "")		; Initially null.
	(declare-global last-dabbrevs-expansion-location)
	(setq last-dabbrevs-expansion-location -1)	; Initially -1
    
	(if (is-bound dabbrevs-setup-hook)		; If hook exists,
	    (execute-mlisp-line dabbrevs-setup-hook)	; parse & execute it.
	    (progn					; Else bind keys:
		  (bind-to-key "dabbrevs-expand" "\e ")      ; M-space
		  (bind-to-key "dabbrevs-re-expand" "\^x ")  ; ^X-space
	    )
	)
    )

    (dabbrevs-expand 	; Expands previous word "dynamically".
	; Expands to the most recent, preceeding word for which this
	; is a prefix.  If no acceptable expansion is found, it normally
	; searches forward, too.  
	; A positive prefix argument, N, says to take the Nth preceeding,
	; DISTINCT possibility.  A negative argument says search forward.
	; The variable dabbrev-backward-only may be used to limit the
	; direction of search, and may be overridden by an argument of 0.

	abbrev expansion which loc i n		; Local vars.

	(save-excursion 

	    (set-mark)		; Get the abbreviation.
	    (backward-word)
	    (setq abbrev (region-to-string))
	    (erase-region)	; Will be replaced w/ expansion or restored.

	    (setq which		; Which distinct possibility to choose.
		  (if prefix-argument-provided
		      prefix-argument		; From arg if provided,
		      (if dabbrevs-backward-only 1 0))) ; else from var.

	    (setq last-dabbrevs-direction which)	; Save for posterity.
	    ;;; Only set last-dabbrevs-abbreviation after successful expand.
	    (setq last-dabbrevs-abbrev-location (dot))	; Original location.

	    (new-dabbrevs-table abbrev)  	; Clear table of things seen.
	    (setq loc -1)  (setq expansion "")

	    (if (>= which 0)			; First look backward.
		(progn 
		    (setq n (if which which 1)) (setq i 1)
		    (while (<= i n) (setq i (+ i 1))
			(setq expansion (dabbrevs-search abbrev 0))
			(if (= 0 (length expansion))
			    (setq n 0)		; Search failed, leave loop.
			    (progn 		; Search succeeded, remember.
				   (setq loc (dot))
				   (insert-entry-in-table expansion)
			    )
			)
		    )
		    (setq last-dabbrevs-direction -1)
		)
	    )

	    (if (& (<= which 0) (= 0 (length expansion))) ; Then look forward.
		(progn 
		    (setq n (if which (- 0 which) 1)) (setq i 1)
		    (while (<= i n) (setq i (+ i 1))
			(setq expansion (dabbrevs-search abbrev 1))
			(if (= 0 (length expansion))
			    (setq n 0)		; Search failed, leave loop.
			    (progn	 	; Search succeeded, remember.
				   (setq loc (dot))
				   (insert-entry-in-table expansion)
			    )
			)
		    )
		    (setq last-dabbrevs-direction 1)
		)
	    )

	    (goto-character last-dabbrevs-abbrev-location)
	    (if (= 0 (length expansion))
		(progn 		; We failed -- beep and give up.
		       (insert-string abbrev) 	; Stick the abbrev back in.
		       (setq last-dabbrevs-expansion abbrev)
		       (setq last-dabbrevs-expansion-location
			     last-dabbrevs-abbrev-location)
		       (error-message "No Expansion.")
		)
		(progn 		; Success: stick it in and return.
		    (insert-string expansion)  
		    ; Save state for re-expand.
		    (setq last-dabbrevs-abbreviation abbrev) ;;; success only.
		    (setq last-dabbrevs-expansion expansion)
		    (setq last-dabbrevs-expansion-location loc)
		)
	    )
	)
    )

    (dabbrevs-search 		; Search function used by dabbrevs library.
	; First arg is string to find as prefix of word.
	; Second arg is direction: 1 for forward, 0 for back.
	; Variable dabbrevs-limit controls the maximum search region size.
	; 
	; Table of expansions already seen is examined in buffer
	; dabbrev-table, so that only distinct possibilities are found
	; by dabbrevs-re-expand. Note that to prevent finding the abbrev
	; itself it must have been entered in the table.
	; 
	; Value is the expansion, or "" if not found.  After a successful
	; search, dot is left right after the expansion found.

	pattern dir missing result	; Local vars.
	
	(setq pattern	; What to look for.
	      (concat "\\b" (arg 1 "pattern: ") "\\w*"))
	(setq dir (arg 2 "direction:"))	; Which way to look.

	(save-restriction 	    ; Uses restriction for limited searches.
	    (if dabbrevs-limit
		(save-excursion
		    (goto-character last-dabbrevs-abbrev-location)
		    (set-mark)	    ; One end of region at expand start loc.
		    (goto-character ; Other end dabbrevs-limit chars away,
			(if dir
			    (+ (dot) dabbrevs-limit)	; forward, or
			    (- (dot) dabbrevs-limit)	; back.
			)
		    )
		    (narrow-region) ; Set the restriction.
		)
	    )

	    ; Keep looking for a distinct expansion.
	    (setq result "")  (setq missing 0)
	    (while  (& (= 0 (length result)) (! missing)) 
		; Look for it, leave loop if search fails.
		(if (! (setq missing (error-occured (if dir
		       (re-search-forward pattern)	   ; Forward.
		       (re-search-reverse pattern) ))))    ; Back.
		    (progn
			(region-around-match 0)		   ; Mark the pattern.
			(if (! dir)	; Put point before if going backward.
			    (exchange-dot-and-mark))
			(setq result (region-to-string))   ; Grab it.
    
			(save-excursion		    ; Reject if already seen.
			    (temp-use-buffer "dabbrev-table")
			    (beginning-of-file)
			    (if
			       (! (error-occured (search-forward (concat 
					"\n" result "\n"))))
			       (setq result "")
			    )
			)
		    )
		)
	    )
	)
	result		; Return the expansion or "".
    )

    (insert-entry-in-table ; Place entry in table of expansions seen.
	; String arg is entry to append.
	(save-excursion
	    (temp-use-buffer "dabbrev-table")
	    (end-of-file)
	    (insert-string (arg 1 "entry: ")
			   "\n") 	; Entries are delimited by newlines.
	)
    )

    (new-dabbrevs-table ; Clear table of items seen in dabbrevs.
	; Argument is abbrev string, which is the only entry so far.
	(save-excursion
	    (temp-use-buffer "dabbrev-table")
	    (erase-buffer)
	    (insert-string "\n"
			   (arg 1 "abbrev: ") 
			   "\n")	; Entries are delimited by newlines.
	)
    )

    (dabbrevs-re-expand  ; Tries the next expansion (see dabbrev-expand).
	; With a prefix argument it just gives up and sticks the original
	; abbreviation back.
	here abbr-loc abbrev exp-loc expansion		; Local vars.

	(setq here (dot))
	(setq abbr-loc last-dabbrevs-abbrev-location)
	
	; Make sure the last expansion is still in place of the abbrev.
	(if (| (< abbr-loc 0) (> abbr-loc (buffer-size)))
	    (error-message "DAbbrev expansion loc is not in buffer."))
	(goto-character abbr-loc)
	(if (! (looking-at last-dabbrevs-expansion))
	    (progn
		  (goto-character here)
		  (error-message "Can't find last DAbbrevs expansion.")
	    )
	)

	(region-around-match 0)		; Get rid of the old expansion.
	(erase-region)

	(if prefix-argument-provided  	; Explicit arg means we''re done.
	    (insert-string last-dabbrevs-abbreviation)	; Restore.

	    (progn 			; Else try to re-expand.
		(setq abbrev last-dabbrevs-abbreviation)
		(setq expansion "")
		(goto-character last-dabbrevs-expansion-location)

		(if (< last-dabbrevs-direction 0) ; Last search backwards?
		    (progn 		; Yep.
			(setq expansion (dabbrevs-search abbrev 0))
			(setq exp-loc (dot))

			; If back failed, try forward if allowed.
			(if (& (= 0 (length expansion))
			       (! dabbrevs-backward-only))
			    (progn 
				(goto-character abbr-loc)
				(setq last-dabbrevs-direction 1)
				(setq expansion
				       (dabbrevs-search abbrev 1))
				(setq exp-loc (dot))
			    )
			)
		    )
		    (progn 		; Last search was forward.
			    (setq expansion (dabbrevs-search abbrev 1))
			    (setq exp-loc (dot))
		    )
		)

		(goto-character abbr-loc)
		(if (= 0 (length expansion)) 	; Couldn''t find expansion?
		    (progn 
			(insert-string abbrev)	; Restore abbrev, and
			(provide-prefix-argument 0
			    (dabbrevs-expand))	; start over again!
		    )
		    (progn 			; Success!
			(setq last-dabbrevs-expansion-location exp-loc)
			(setq last-dabbrevs-expansion expansion)
			(insert-entry-in-table expansion)	;;; Remember.
			(insert-string expansion)
		    )
		)
	    )
	)
    )

)				; End of defun.
(setup-dabbrevs)		; Load-time init.
