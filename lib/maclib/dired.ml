; This is an attempt at a dired package.

    (declare-global Dired-keymap-defined Dired-directory Dired-level)
    (setq Dired-keymap-defined 0)
    (setq Dired-directory (working-directory))
    (setq Dired-level 0)

(defun
    (dired
	  (dired-recurse 1
	      (arg 1 (concat ": dired on directory? ["
				       Dired-directory "] "))
	  )
    )
)

(defun 
    (dired-recurse directory 
	(save-window-excursion
	    (setq Dired-level (arg 1))
	    (setq directory (arg 2))
	    (if (= directory "")
		(setq directory Dired-directory))
	    (if (= "/" (substr directory -1 1))
		(setq directory (substr directory 1 -1)))
	    (setq directory (glob directory))		; Expand directory.
	    (setq Dired-directory directory)

	    (pop-to-buffer (concat "dired" Dired-level))
	    (use-local-map "&dired-keymap")
	    (setq mode-line-format
		(concat "  Editing  directory [" Dired-level "]:  "
			Dired-directory "      %M   %[%p%]"))
	    (erase-buffer)  (set-mark)
	    (message (concat "Getting contents of " directory))
	    (sit-for 0)
	    (filter-region (concat "/bin/ls -l " directory))
	    (beginning-of-file)
	    (if (looking-at "total")
		(progn
		    (kill-to-end-of-line) (kill-to-end-of-line)
		    (beginning-of-file)
		    (re-replace-string "^." " &")
		    (beginning-of-file)
		)
		(progn 
		    (end-of-file)
		    (error-message (region-to-string))
		)
	    )
	    (message "Type C-M-Z to exit, ? for help")
	    (save-excursion (recursive-edit))
	    (&dired-done)
	    (novalue)
	)
    )
)

(defun    
    (&dired-Mark-file-deleted
	(if (= 0 (buffer-size))
	    (error-message "dired already done!")
	    (progn
		(beginning-of-line)
		(if (looking-at " d")
		    (error-message "Can't delete a directory with dired"))
		(delete-next-character)
		(insert-string "D")
		(next-line)
		(beginning-of-line)
	    )
	)
    )
    
    (&dired-summary
	(message
	    "d-elete, u-ndelete, q-uit, r-emove, e,v-isit, n-ext, p-revious, ?-help")
    )

    (&dired-UnMark-file-deleted
	(if (= 0 (buffer-size))
	    (error-message "dired already done!")
	    (progn
		(beginning-of-line)
		(delete-next-character)
		(insert-string " ")
		(next-line)
		(beginning-of-line)
	    )
	)
    )
    
    (&dired-backup-unmark
	(if (= 0 (buffer-size))
	    (error-message "dired already done!")
	    (! (bobp))
	    (previous-line))
	(beginning-of-line)
	(delete-next-character)
	(insert-string " ")
	(beginning-of-line)
    )
)

(defun
    (&dired-examine ans old-dir old-lvl
	(save-excursion
	    (setq old-lvl Dired-level)
	    (setq old-dir Dired-directory)
	    (error-occured
		(beginning-of-line)
		(if (looking-at " d")	; Directory?
		    (dired-recurse (+ Dired-level 1) (&dired-get-fname)) ; Yep.
		    (progn 			; Nope, get the file.
			   (visit-file (&dired-get-fname))
			   (message "Type C-M-Z to return to DIRED")
			   (recursive-edit)
		    )
		)
	    )
	    (setq Dired-level old-lvl)
	    (setq Dired-directory old-dir)
	)
    )
)

(defun    
    (&dired-remove
	(beginning-of-line)
	(kill-to-end-of-line) (kill-to-end-of-line)
    )
    
    (&dired-get-fname
	(save-excursion
	    (beginning-of-line)
	    (goto-character (+ (dot) 46))
	    (set-mark)
	    (end-of-line)
	    (concat Dired-directory "/" (region-to-string))
	)
    )
    
    (&dired-done ans
	(beginning-of-file)
	(re-replace-string "^ .*\n" "")
	(if (!= 0 (buffer-size))
	    (progn
		(message
		    "? [y-go through marked files; e-don't delete, exit; Anything else return]")
		(setq ans (get-tty-character))
		(if (| (= ans 'e') (= ans 'E'))
		    (progn
			(message
			    "Really exit without deleting?[y-yes, anything else continue dired]")
			(setq ans (get-tty-character))
			(if (| (= ans 'y') (= ans 'Y'))
			    (delete-buffer (concat "dired" Dired-level))
			    (error-message "Aborted.")))
		    (| (= ans 'y') (= ans 'Y'))
		    (progn
			(while (! (eobp))
			    (if (= (following-char) 'D')
				(progn thisfile ans
				    (setq thisfile (&dired-get-fname))
				    (message (concat "Delete " thisfile "?"))
				    (setq ans (get-tty-character))
				    (if (| (= ans 'y') (= ans 'Y'))
					(if (unlink-file thisfile)
					    (progn
						(message "Couldn't delete it!")
						(sit-for 2))))
				)
			    )
			    (next-line)
			)
			(delete-buffer (concat "dired" Dired-level))
		    )
		    (error-message "?Aborted.")
		)			
	    )
	    (if (= Dired-level 1)
		(message "Dired says ""Adios""")
	    )
	)
    )
)    

(defun			; Setup fn.
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

(save-excursion
    (temp-use-buffer "dired1")
    (progn loop
	(&clear-keymap "&dired-esc-keymap" "&dired-summary")
	(setq loop '0')
	(while (<= loop '9')
	    (local-bind-to-key "meta-digit" loop)
	    (setq loop (+ loop 1))
	)
	(local-bind-to-key "execute-extended-command" "x")
	(local-bind-to-key "describe-key" "/")
	(local-bind-to-key "apropos" "?")
	(&clear-keymap "&dired-^x-keymap" "&dired-summary")

	(&clear-keymap "&dired-keymap" "&dired-summary")
	(local-bind-to-key "&dired-^x-keymap" "\^x")
	(local-bind-to-key "&dired-esc-keymap" "\e")
	(temp-use-buffer "dired1")
	(define-keymap "&dired-keymap")
	(use-local-map "&dired-keymap")
	(setq loop 0)
	(while (<= loop 127)
	    (local-bind-to-key "&dired-summary" loop)
	    (setq loop (+ loop 1))
	)
	(setq loop '0')
	(while (<= loop '9')
	    (local-bind-to-key "digit" loop)
	    (setq loop (+ loop 1))
	)
	(local-bind-to-key "redraw-display" "\^L")
	(local-bind-to-key "&dired-Mark-file-deleted" "d")
	(local-bind-to-key "&dired-Mark-file-deleted" "D")
	(local-bind-to-key "&dired-Mark-file-deleted" "")
	(local-bind-to-key "&dired-backup-unmark" "\0177")
	(local-bind-to-key "previous-line" "\^H")
	(local-bind-to-key "previous-line" "p")
	(local-bind-to-key "previous-line" "P")
	(local-bind-to-key "previous-line" "\^P")
	(local-bind-to-key "next-line" "n")
	(local-bind-to-key "next-line" "N")
	(local-bind-to-key "next-line" "\^N")
	(local-bind-to-key "next-line" 13)
	(local-bind-to-key "next-line" 10)
	(local-bind-to-key "next-line" " ")
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
	(local-bind-to-key "&dired-examine" "\^X\^V")
	(local-bind-to-key "next-page" "\^V")
	(local-bind-to-key "previous-page" "\ev")
	(local-bind-to-key "previous-page" "\eV")
	(local-bind-to-key "beginning-of-file" "\e<")
	(local-bind-to-key "end-of-file" "\e>")
	(local-bind-to-key "&dired-UnMark-file-deleted" "u")
	(local-bind-to-key "&dired-UnMark-file-deleted" "U")
	(local-bind-to-key "Pop-level" "\^C")
	(local-bind-to-key "Pop-level" "q")
	(local-bind-to-key "Pop-level" "Q")
	(local-bind-to-key "Pop-level" "\e\^z")
	(local-bind-to-key "&dired-examine" "e")
	(local-bind-to-key "&dired-examine" "E")
	(local-bind-to-key "&dired-examine" "v")
	(local-bind-to-key "&dired-examine" "V")
	(local-bind-to-key "&dired-remove" "r")
	(local-bind-to-key "&dired-remove" "R")
    )
)
