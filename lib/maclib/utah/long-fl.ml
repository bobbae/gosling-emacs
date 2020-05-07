(setq-default matching-ignore "\\.BAK$\\|\\.CKP$\\|\\.o$\\|\\.b$")
(setq-default match/recognize 0); default is to match
(defun
    (Visit-file-matching files i
	(setq files (&get-filename "Visit File"))
	(if (string-index files ' ')
	    (progn
		(message (concat "=> " files))
		(sit-for 0))
;	    (message (concat "Matching Visit File: " files))
	)
	(while (setq i (string-index files ' '))
	    (visit-file (substr files 1 (- i 1)))
	    (setq files (substr files (+ i 1) 1000)))
	(visit-file files))

    (Same-Window-Visit-file-matching files i &pop-up
	(setq files (&get-filename "Same Window Visit File"))
	(if (string-index files ' ')
	    (progn
		(message (concat "=> " files))
		(sit-for 0))
;	    (message (concat "Matching Visit File: " files))
	)
	(setq &pop-up pop-up-windows)
	(setq pop-up-windows 0)
	(while (setq i (string-index files ' '))
	       (error-occured (visit-file (substr files 1 (- i 1))))
	       (setq files (substr files (+ i 1) 1000)))
	(if (error-occured (visit-file files))
	    (progn
		  (setq pop-up-windows &pop-up)
		  (error-message "New file " files))
	    (setq pop-up-windows &pop-up))
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
	(setq files (&get-filename "Read File"))
	(if (string-index files ' ')
	    (progn
		(message (concat "=> " files))
		(sit-for 0))
;		(message (concat "Matching Read File: " files))
	)
	(while (setq i (string-index files ' '))
	    (read-file (substr files 1 (- i 1)))
	    (setq files (substr files (+ i 1) 1000)))
	(read-file files))

    (Insert-file-matching files i
	(setq files (&get-filename "Insert File"))
	(if (string-index files ' ')
	    (progn
		(message (concat "=> " files))
		(sit-for 0))
;		(message (concat "Matching Insert File: " files))
	)
	(while (setq i (string-index files ' '))
	    (insert-file (substr files 1 (- i 1)))
	    (setq files (substr files (+ i 1) 1000)))
	(insert-file files))

    (expand-filespec
	(insert-string
	    (&get-filename "Expand Filename"))
    )

    				; Call either recognize or
				; parse-long-filename depending on the state
				; of match/recognize.
    (&get-filename p
	(setq p (arg 1 ": &get-filename (prompt) "))
	(if match/recognize
	    (recognize (concat p ": "))
	    (parse-long-filename
		(get-tty-no-blanks-input (concat p " Matching: ") "")))
    )
    

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
	(if exact
	    (glob pattern)
	    (&expand-long-filename)
	)
    )
    
    (&expand-long-filename success glob-pattern all
	(setq success "")	; set to matching filename
	(temp-use-buffer "Long Filenames")
	(setq needs-checkpointing 0)
	(erase-buffer)		; check for explicit globbing
	(insert-string pattern)
	(beginning-of-file)
	(setq all (! (error-occured
			 (re-search-forward "[*?[{]"))))
	(setq mode-line-format
	    "[Position cursor at desired file, then press space]")
	(if (& (! all) (> (buffer-size) 200)); yechhh
	    (error-message "File name(s) too long"))
	    
	(erase-buffer)
	(if (! all)
	    (progn
		  (setq pattern (glob pattern))
		  (setq glob-pattern (concat pattern "*")))
	    (setq glob-pattern pattern))
	(if (& (! all)
	       (file-exists pattern)
	       (is-text-file pattern))
	    (setq success pattern)

	    (setq glob-pattern (&long-filename-glob))
	    (if all
		(progn
		    (beginning-of-file)
		    (set-mark)
		    (error-occured (replace-string "\n" " "))
		    (end-of-file)
		    (delete-white-space)
		    (setq success (region-to-string))
		)
		(progn
		    (beginning-of-file)
		    (set-mark)
		    (end-of-line)
		    (if (> glob-pattern 1)	; more than one, check for exact match
			(if (& (= (region-to-string) pattern)
			       (is-text-file pattern))
			    (setq success pattern))

			(is-text-file (region-to-string)); exactly one match
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
		(error-occured
		    (beginning-of-file)
		    (re-replace-string "/\\**\\." "/."))
		(end-of-file)
		(insert-string "*")
		(Mark-Whole-Buffer)
		(setq glob-pattern (region-to-string))
		(if (setq glob-pattern (&long-filename-glob))
		    (if (& (= glob-pattern 1); then only got one filename
			   (is-text-file (region-to-string)))
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
			(setq glob-pattern (region-to-string))
			(&long-filename-glob))
		)
	    )
	)
	(if (! (length success))
	    (progn
		(beginning-of-file)
		(insert-string (concat pattern "\n"))
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
	(setq pattern glob-pattern)	; global value thereof
	(message (concat "(" pattern ")")) ;(sit-for 0)
	(erase-buffer)
	(set-mark)
	(insert-string (glob pattern))
	(message (concat "(" pattern ")")) (sit-for 0)
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
	(if (= pattern (region-to-string))
	    0			; return no success
	    (error-occured
		(beginning-of-file)
		(replace-string " " "\n"))
	    (progn
		(end-of-line)
		(message (concat "(" pattern ") => " (region-to-string)))
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
		(if (= c '^G') (error-message "Aborted.")
		    (= c '^N') (next-line)
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

    (is-text-file text-file
	(setq text-file (arg 1 ": is-text-file "))
	(save-excursion
	    (temp-use-buffer "Scratch")
	    (erase-buffer)
	    (insert-string (glob-command "file " text-file))
	    (beginning-of-file)
	    (looking-at "^.*text$"))
    )
)

(defun 
    (recognize fname num cont prompt
	(setq prompt (arg 1 ": recognize (prompt)"))
	(setq cont 1)
	(setq fname "")
	(if remove-help-window
	    (save-window-excursion (&recognize-helper))
	    (&recognize-helper))
    )

    (&recognize-helper
	(while cont
	       (setq fname (get-tty-no-blanks-input prompt fname))
	       (if (!= fname "")
		   (if (= (last-key-struck) ' ')
		       (save-excursion
			   (message prompt fname)
			   (temp-use-buffer "Scratch")
			   (erase-buffer)
			   (insert-string
			       (glob-command "/usr/local/lib/emacs/recognize "
				   fname))
			   (beginning-of-file)
			   (if (looking-at "\\([0-9][0-9]*\\): \\(.*\\)")
			       (progn
				     (region-around-match 1)
				     (setq num (region-to-string))
				     (region-around-match 2)
				     (setq fname (region-to-string))
				     (if (!= num 1)
					 (send-string-to-terminal "\7")))
			       (send-string-to-terminal "\7"))
		       )
		       (= (last-key-struck) '?')
		       (save-excursion
			   (pop-to-buffer "Help")
			   (setq fname (substr fname 1 -1))
			   (erase-buffer)
			   (insert-string (glob-command "ls -CdF " fname "*")))
		       (setq cont 0)); all done
		   (if (= (last-key-struck) ' ')
		       (send-string-to-terminal "\7")
		       (setq cont 0); allow null filename
		   )
	       )
	)
	(glob fname)
    )
)

(bind-to-key "Visit-file-matching" "\^X\^F"); ^X^F
(bind-to-key "Read-file-matching" "\^X\^R"); ^X^R
(bind-to-key "Same-Window-Visit-file-matching" "\^X\^V")
(bind-to-key "Insert-file-matching" "\^X\^I")
(bind-to-key "expand-filespec" "\^Z$")
(novalue)
