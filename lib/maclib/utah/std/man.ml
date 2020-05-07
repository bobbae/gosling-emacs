; A dired-ish manual hack.

(declare-global Manual-level)	; Allow nested invocations properly.
(setq Manual-level 1)

(defun
    ; Enter a buffer to select matching manual entries.
    ; With prefix arg, matches only on entry names, not keywords.
    (manual-entry search-type search-name key buff-name ent-name section
	 (if (! prefix-argument-provided)
	     (progn
		(setq search-type "-k")
		(setq search-name "apropos keyword")
	     )
	     (progn
		(setq search-type "-f")
		(setq search-name "matching filename")
	     )
	 )
	 (setq key (arg 1 (concat ": manual-entries (" search-name ") ")))

	 (save-window-excursion 

	     ; Go to a buffer for manual index entries.
	     (setq buff-name (concat "manual entries<" Manual-level ">"))
	     (pop-to-buffer buff-name)
	     (use-syntax-table "manual-entries")
	     (use-local-map "&manual-keymap")
	     (setq mode-line-format
		   (concat "   Manual entries " search-name " \"" key
			   "\"     %M  %[%p%]"))

	     ; Get manual index entries.
	     (erase-buffer) (sit-for 0)	
	     (set-mark)
	     (filter-region (concat "man " search-type " " key))

	     ; Go straight to manual entry if only one index entry.
	     (beginning-of-file)
	     (next-line)
	     (if (& (eobp)
		    (progn (beginning-of-file)
			   (looking-at "\\(\\w\\w*\\)[^(]*(\\(\\w\\w*\\)")
		    )
		 )
		 (progn 	; Switch to the proper buffer and grab entry.
		     (region-around-match 1) (setq ent-name (region-to-string))
		     (region-around-match 2) (setq section (region-to-string))
		     (switch-to-buffer (concat ent-name "." section ))
		     (temp-use-buffer buff-name)
		     (&get-manual-entry)
		 )
		 (progn		; Otherwise recursive edit to select entry.
		     (beginning-of-file)
		     (&manual-summary)
		     (save-window-excursion (recursive-edit))
		 )
	     )
	 )
    )
)

(defun 
    (&manual-summary
	(message "Space or <CR> to select, q or C-M-Z to pop back up.")
	(sit-for 0)
    )
)

(defun 
    ; To be executed on a line of the manual entries buffer.
    (&get-manual-entry
	entry-name section buff-name old-level

	(beginning-of-line)	; Use first name on the line.
	(if (! (looking-at "\\(\\w\\w*\\)[^(]*(\\(\\w\\w*\\)"))
	    (error-message "Error parsing manual entry.")
	    (progn 

		; Buffer name is composed of manual entry name and section.
		(region-around-match 1) (setq entry-name (region-to-string))
		(region-around-match 2) (setq section (region-to-string))
		(beginning-of-line)
		(setq buff-name (concat entry-name "." section ))
		(save-window-excursion 
		    (pop-to-buffer buff-name)
		    (error-occured	; Set pseudo-filename for buffer menu.
			(write-named-file (concat "/dev/null/man/" buff-name))
		    )
		    (beginning-of-file)
		    (next-line)	; Single line is probably an error message.
		    (if (eobp)		; Just get there if already loaded.
			(progn 
			    (setq mode-line-format
				  (concat "   Manual entry for " 
					  (if (!= section "")
					      (concat entry-name
						      "(" section ")")
					      entry-name)
					  "     %M  %[%p%]"
				  )
			    )

			    ; Warning msg if cat file looks missing.
			    (if (! (file-exists
				       (concat "/usr/man/cat"
					       ; Dumb, misses foo.2x, etc.
					       (substr section 1 1) "/"
					       entry-name "." section)))
				(progn 
				    (message
					 "May have to wait for formatting...")
				    (sit-for 0)
				)
			    )

			    ; Get the manual entry from the man cmd.
			    (erase-buffer)
			    (set-mark)
			    (filter-region
				(concat
				    "man -c "
				    ; Ignore non-numeric sections.
				    (if (| (< (string-to-char section) '0')
					   (> (string-to-char section) '9'))
					""
					(substr section 1 1) ; Ignore suffix.
				    )
				    " " entry-name))
			    (setq needs-checkpointing 0)

			    ; Fixup the format for looking at on a terminal.
			    (beginning-of-file)
			    (if (looking-at "Reformatting page")
				(kill-to-end-of-line))
			    (error-occured (replace-string "_\b" ""))
			    (error-occured (re-replace-string
					       "^[A-Z][A-Z]*([0-9]*).*)$" ""))
			    (error-occured (re-replace-string
					        "^Printed [0-9].*[0-9]$" ""))
			    (error-occured (re-replace-string
					        "\n\n\n\n*" "\n\n"))
			    (if (looking-at "\n\n*")
				(progn
				    (region-around-match 0)
				    (erase-region)))

			    (Not-modified)	; Forget it was changed.
			    (message "")	; Trash msg from Not-modified.
			)
		    )

		    ; Recursive edit on manual page.
		    (message "C-M-Z to pop back up.") (sit-for 0)
		    ; Make nested manual cmds work.
		    (setq old-level Manual-level)
		    (setq Manual-level (+ 1 Manual-level))
		    (recursive-edit)
		    (setq Manual-level old-level)
		)
	    )
	)
	(novalue)
    )
)

; Setup.
(save-excursion
    (temp-use-buffer "manual entries<1>")
    (use-syntax-table "manual-entries")
    (modify-syntax-entry "w    _")
    (modify-syntax-entry "w    .")
    (modify-syntax-entry "w    +")

    ; Swiped this from dired.ml...
    (defun
	(&clear-keymap loop
	    (define-keymap (arg 1))
	    (use-local-map (arg 1))
	    (setq loop 0)
	    (while (<= loop 127)
		(local-bind-to-key (arg 2) loop)
		(setq loop (+ loop 1))
	    )
	)
    )
    (progn loop
	(&clear-keymap "&manual-esc-keymap" "&manual-summary")
	(setq loop '0')
	(while (<= loop '9')
	    (local-bind-to-key "meta-digit" loop)
	    (setq loop (+ loop 1))
	)
	(local-bind-to-key "execute-extended-command" "x")
	(local-bind-to-key "describe-key" "/")
	(local-bind-to-key "apropos" "?")
	(&clear-keymap "&manual-^x-keymap" "&manual-summary")
	(&clear-keymap "&manual-^z-keymap" "&manual-summary")

	(&clear-keymap "&manual-keymap" "&manual-summary")
	(local-bind-to-key "&manual-^x-keymap" "\^x")
	(local-bind-to-key "&manual-^z-keymap" "\^z")
	(local-bind-to-key "&manual-esc-keymap" "\e")
	(setq loop '0')
	(while (<= loop '9')
	    (local-bind-to-key "digit" loop)
	    (setq loop (+ loop 1))
	)
	(local-bind-to-key "&get-manual-entry" " ")
	(local-bind-to-key "&get-manual-entry" "\^m")	; <CR>

	(local-bind-to-key "Doc" "\^_")			; C-?
	(local-bind-to-key "redraw-display" "\^L")
	(local-bind-to-key "beginning-of-line" "\^A")
	(local-bind-to-key "end-of-line" "\^E")
	(local-bind-to-key "forward-word" "\ef")
	(local-bind-to-key "backward-word" "\eb")
	(local-bind-to-key "previous-line" "\^H")
	(local-bind-to-key "previous-line" "p")
	(local-bind-to-key "previous-line" "P")
	(local-bind-to-key "previous-line" "\^P")
	(local-bind-to-key "next-line" "n")
	(local-bind-to-key "next-line" "N")
	(local-bind-to-key "next-line" "\^N")
	(local-bind-to-key "next-line" 13)
	(local-bind-to-key "next-line" 10)
	(local-bind-to-key "inc-forward-top-level" "\^s")
	(local-bind-to-key "inc-reverse-top-level" "\^r")
	(local-bind-to-key "argument-prefix" "\^U")
	(local-bind-to-key "previous-window" "\^Xp")
	(local-bind-to-key "previous-window" "\^XP")
	(local-bind-to-key "next-window" "\^Xn")
	(local-bind-to-key "next-window" "\^XN")
	(local-bind-to-key "delete-window" "\^Xd")
	(local-bind-to-key "delete-window" "\^XD")
	(local-bind-to-key "delete-other-windows" "\^X1")
	(local-bind-to-key "next-page" "\^V")
	(local-bind-to-key "previous-page" "\ev")
	(local-bind-to-key "previous-page" "\eV")
	(local-bind-to-key "beginning-of-file" "\e<")
	(local-bind-to-key "end-of-file" "\e>")
	(local-bind-to-key "Pop-level" "\^C")
	(local-bind-to-key "Pop-level" "q")
	(local-bind-to-key "Pop-level" "Q")
	(local-bind-to-key "Pop-level" "\e\^z")
	(local-bind-to-key "Pop-level" "\^z\^z")
    )
)
(novalue)
