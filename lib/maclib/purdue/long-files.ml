(declare-global matching-ignore)
(setq matching-ignore "\\.BAK$\\|\\.CKP$\\|\\.o$\\|\\.b$")
(defun
    (Visit-file-matching files i
	(setq files (parse-long-filename (arg 1 "Matching Visit File: ")))
	(if (string-index files ' ')
	    (message (concat "=> " files))
	    (message (concat "Matching Visit File: " files)))
	(sit-for 0)
	(while (setq i (string-index files ' '))
	    (visit-file (substr files 1 (- i 1)))
	    (setq files (substr files (+ i 1) 1000)))
	(visit-file files))
    
    (Same-Window-Visit-file-matching files i pop-up
	(setq files (parse-long-filename (arg 1 "Matching Visit File: ")))
	(if (string-index files ' ')
	    (message (concat "=> " files))
	    (message (concat "Matching Visit File: " files)))
	(sit-for 0)
	(setq pop-up pop-up-windows)
	(setq pop-up-windows 0)
	(while (setq i (string-index files ' '))
	    (visit-file (substr files 1 (- i 1)))
	    (setq files (substr files (+ i 1) 1000)))
	(visit-file files)
	(setq pop-up-windows pop-up)
    )
    
    (string-index s i c l
	(setq s (arg 1 "string: "))
	(setq c (arg 2 "char: "))
	(setq i 1)
	(setq l (length s))
	(while (<= i l)
	    (if (= (string-to-char (substr s i 1)) c)
		(setq l -1)
		(setq i (+ i 1))))
	(if (>= l 0)
	    0
	    i
	)
    )
    
    (Read-file-matching files i
	(setq files (parse-long-filename (arg 1 "Matching Read File: ")))
	(if (string-index files ' ')
	    (message (concat "=> " files))
	    (message (concat "Matching Read File: " files)))
	(sit-for 0)
	(while (setq i (string-index files ' '))
	    (read-file (substr files 1 (- i 1)))
	    (setq files (substr files (+ i 1) 1000)))
	(read-file files))
    
    (parse-long-filename pattern buffer exact; by SWT
	; given a pattern (with no *s), inserts a *
	; at the beginning, before each . and at the
	; end of the pattern, then globs for this
	; filename.  If there is only one result,
	; this is used, otherwise, the names are
	; displayed one per line in a menu for
	; selection.  An initial ! will force the
	; string to be returned as given (without
					     ; the !).
	; A leading $var will look up var in the
	; environment and substitute the value.
	; If the argument is an empty string, the
	; current buffer filename will be returned.
	; Mon Nov  9 1981 SWT
	; if initial pattern has *, ? or [] in it,
	; then return ALL file names found.
	(setq buffer (current-buffer-name))
	(setq exact 0)
	(setq pattern (arg 1 "Matching file name: "))
	(if (= pattern "")
	    (progn
		(setq pattern (current-file-name))
		(setq exact 1)))
	(if (= (substr pattern 1 1) "!")
	    (progn
		(setq pattern (substr pattern 2 1000))
		(setq exact 1)))
	(if (= (substr pattern 1 1) "$")
	    (setq pattern (Expand-file-name pattern)))
	(if (= (substr pattern 1 1) "~")
	    (setq pattern (expand-file-name pattern)))
	(if exact
	    pattern
	    (&expand-long-filename)
	)
    )
    
    (&expand-long-filename success glob all
	(setq success "")	; set to matching filename
	(temp-use-buffer "Long Filenames")
	(erase-buffer)		; check for explicit globbing
	(insert-string pattern)
	(beginning-of-file)
	(setq all (! (error-occured
			 (re-search-forward "[*?[]"))))
	(setq mode-line-format
	    "[Position cursor at desired file, then press space]")
	(erase-buffer)
	(if (! all)
	    (setq glob (concat pattern "*"))
	    (setq glob pattern))
	(if (file-exists pattern)
	    (setq success pattern)
	    
	    (setq glob (&long-filename-glob))
	    (if all
		(progn
		    (beginning-of-file)
		    (set-mark)
		    (error-occured (replace-string "\n" " "))
		    (end-of-file)
		    (delete-white-space)
		    (setq success (region-to-string)))
		(progn
		    (beginning-of-file)
		    (set-mark)
		    (end-of-line)
		    (if (> glob 1)	; more than one, check for exact match
			(if (= (region-to-string) pattern)
			    (setq success pattern))
			(setq success (region-to-string)))))	; filename
	    (if all
		(error-message "No match"))
	)
	
	(if (! (length success))
	    (progn		; else, try fancier pattern
		(erase-buffer)
		(insert-string pattern)
		(if (error-occured
			(end-of-file)
			(search-reverse "/")
			(forward-character))
		    (beginning-of-file))
		(insert-string "*")
		(error-occured
		    (replace-string "." "*."))
		(error-occured
		    (beginning-of-file)
		    (re-replace-string "^\\**\\." "."))
		(end-of-file)
		(insert-string "*")
		(Mark-Whole-Buffer)
		(setq glob (region-to-string))
		(if (setq glob (&long-filename-glob))
		    (if (= glob 1); then only got one filename
			(setq success (region-to-string)); return value
		    )
		    
		    (progn	; else no files, look for ..../*
			(erase-buffer)
			(insert-string pattern)
			(if (error-occured
				(search-reverse "/")	; look for a directory
				(forward-character))
			    (beginning-of-file))
			(kill-to-end-of-line)
			(insert-string "*")
			(Mark-Whole-Buffer)
			(setq glob (region-to-string))
			(&long-filename-glob))
		)
	    )
	)
	(if (! (length success))
	    (progn
		(beginning-of-file)
		(insert-string (concat (expand-file-name pattern) "\n"))
		(switch-to-buffer "Long Filenames")
		(beginning-of-file)
		(if (&long-select)
		    (progn
			(switch-to-buffer buffer)
			(error-message ""))
		)
		(switch-to-buffer buffer)
		(temp-use-buffer "Long Filenames")
		(setq success (region-to-string))
	    )
	)
	(switch-to-buffer buffer); return to original buffer
	success
    )
    
    (&long-filename-glob pattern
	(setq pattern glob)	; global value thereof
	;	(message (concat "(" pattern ")")) (sit-for 0)
	(erase-buffer)
	(set-mark)
;	(fast-filter-region (concat "/bin/sh -c /bin/echo -n " pattern))
;	(fast-filter-region (concat "echo -n " pattern))
    	(quick-filter-region (concat "echo -n " pattern))
	(save-excursion
	    (error-occured
		(beginning-of-file)
		(replace-string " " "\n")
		(while 1
		    (re-search-forward matching-ignore)
		    (beginning-of-line)
		    (kill-to-end-of-line)
		    (delete-next-character)))
	    (beginning-of-file)
	    (error-occured
		(re-replace-string "\n\n*" " ")
		(re-replace-string " *$" "")))
	(if (= pattern (region-to-string)); assumes filter-region uses sh
	    0			; return no success
	    (error-occured
		(beginning-of-file)
		(replace-string " " "\n"))
	    (progn
		(end-of-line)
		;		(message (concat "(" pattern ") => " (region-to-string)))
		(sit-for 0)
		1			; only got 1 match
	    )
	    (progn
		(end-of-file)
		(insert-character '^J'); put a newline on the end
		(beginning-of-file)
		2		; got more than 1 match
	    )
	)
    )		
    
    (&long-select c file cont
	(error-occured
	    (setq cont 1)
	    (while cont
		(setq c (get-tty-character))
		(if (= c '^N') (next-line)
		    (= c '^P') (previous-line)
		    (= c '^V') (next-page)
		    (= c '^S') (inc-forward-top-level)
		    (= c '^R') (inc-reverse-top-level)
		    (= c '^L') (redraw-display)
		    (= c '\033')
		    (if (= (get-tty-character) 'v') (previous-page))
		    (& (!= c ' ') (!= c '^M') (!= c '^J'))
		    (send-string-to-terminal "\007"); beep
		    (progn
			(beginning-of-line)
			(sit-for 0)
			(set-mark)
			(end-of-line)
			(setq cont 0)
		    )
		)
	    ))
    )
)

(bind-to-key "Visit-file-matching" "\^X\^V"); ^X^V
(bind-to-key "Read-file-matching" "\^X\^R"); ^X^R
(bind-to-key "Same-Window-Visit-file-matching" "\^Xv"); ^Xv
(progn)
