(defun
    (man entry-name section buff-name file-name
	 (setq entry-name (arg 1 ": manual-entry (for) "))
	 (setq section
	       (if (interactive)
		   (get-tty-input
		        (concat ": manual-entry (for) " entry-name
				" (section) ")
			"1"
		   )
		   (arg 2)
	       )
	 )
	 (setq buff-name (concat entry-name "." section ))
	 (setq file-name (concat "/usr/man/cat" section "/" buff-name))
	 (if (| (file-exists file-name)
		(& (file-exists (concat "/usr/man/man" section "/"
					entry-name "." section ))
		   (& (save-window-excursion 
			  (confirm "Want to wait for reformatting? ")
			  (glob-command 
			      (concat "man " section " " entry-name
				      " > /tmp/foo"))  ; Not tty, avoids MORE.
			  1
		      )
		   )
		)
	     )
	     (progn (visit-file file-name) (save-excursion
		 (setq mode-line-format (concat "   Manual entry for "
						entry-name
						"     %M  %[%p%]"))
		 (setq needs-checkpointing 0)
		 (beginning-of-file)
		 (error-occured (replace-string "_\b" ""))
		 (error-occured (re-replace-string
				    "^[A-Z][A-Z]*([0-9]*).*)$"
				    ""))
		 (error-occured (re-replace-string "^Printed [0-9].*[0-9]$"
				     ""))
		 (error-occured (re-replace-string "\n\n\n\n*" "\n\n"))
		 (if (looking-at "\n\n*")
		     (progn
			  (region-around-match 0)
			  (erase-region)))
		 (Not-modified)		; Forget it was changed.
	     ))
	     (message "No manual entry for " entry-name " in section " section)
	 )
	 (novalue)
    )
)
