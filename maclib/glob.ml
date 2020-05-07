; Provide Csh globbing functions to Emacs.  Does this by actually
; starting a Csh as a subprocess, then feeding 'echo' commands to
; do the globbing.  The Csh variable 'nonomatch' is initially set,
; so unsucessful globs will return the original string.
; 
; (glob string) - feed the string to csh for globbing.  Returns a
; 			string with the result (multiple matches
; 			are separated by spaces).
; 
; (glob-command string ...) - Concatenate the string arguments and
;			Send the string to the csh as a command.
; 			Useful for declaring new variables, etc.
; 			Returns the command output as a string.
; 
; (glob-nowait-command string ...) - like glob-command but doesn't wait for
; 			termination.
; 
; (glob-wait) - Wait for conclusion of a command started with
;			glob-nowait-command.
; 
; (glob-cd string) - Execute a cd command with the string as argument.
; 			Also executes an Emacs change-directory command.
; 			Returns the new directory.  Useful if you have
; 			a Csh cdpath variable.  [Note - cdpath won't work
; 			because of necessity to use oldcsh!]
; 
; (glob-init) - Initializes the globber.  Tries to source a file
; 			~/.cshinit which supposedly contains variable
; 			declarations.  Also sets the Csh prompt to
; 			a presumably unique string.

(defun 
    (glob
;	(error-occured (error-message "glob")) (sit-for 5)
	(&glob-exec (concat "echo " (arg 1 ": glob (string) "))))
)

(defun
    (glob-command com-string i n
;	(error-occured (error-message "glob-command")) (sit-for 5)
	(if (interactive)
	    (setq n 1)
	    (setq n (nargs)))
	(setq com-string "")
	(setq i 1)
	(while (<= i n)
	       (setq com-string (concat com-string (arg i ": glob-command ")))
	       (setq i (+ i 1)))
	(&glob-exec com-string))
)

(defun 
    (glob-cd dir todir
;	(error-occured (error-message "glob-cd")) (sit-for 5)
	(setq todir (arg 1 ": glob-cd "))
	(if (!= (setq dir (&glob-exec (concat "cd " todir))) "")
	    (progn
		  (temp-use-buffer "Scratch")
		  (erase-buffer)
		  (insert-string dir)
		  (beginning-of-file)
		  (if (looking-at ".*: No such file or directory")
		      (error-message dir))))
	(setq dir (&glob-exec "pwd"))
	(change-directory dir)
	(pwd)
;	dir
    )
)

(defun
    (glob-init
;	(error-occured (error-message "glob-init")) (sit-for 5)
	(save-excursion
	    (error-occured (kill-process "glob-csh"))
	    (start-process "exec csh" "glob-csh")
	    (string-to-process "glob-csh"
		"source /usr/local/lib/emacs/maclib/utah/glob-csh.init\n")
	    (&glob-start "")
	    (novalue)
	)
    )
)

(defun
    (glob-nowait-command com-string i n
;	(error-occured (error-message "glob-nowait-command")) (sit-for 5)
	(if (interactive)
	    (setq n 1)
	    (setq n (nargs)))
	(setq com-string "")
	(setq i 1)
	(while (<= i n)
	       (setq com-string (concat com-string
					(arg i ": glob-nowait-command ")))
	       (setq i (+ i 1)))
	(&glob-start com-string)
	(novalue)
    )

    (glob-wait
;	(error-occured (error-message "glob-wait")) (sit-for 5)
	(&glob-wait))
)

(setq-default &glob-running 0)

(defun
    (&glob-exec
;	(error-occured (error-message "&glob-exec")) (sit-for 5)
	(&glob-start (arg 1 ": &glob-exec "))
	(&glob-wait)
    )

    (&glob-start cont str
;	(error-occured (error-message "&glob-start")) (sit-for 5)
	(if (!= (process-status "glob-csh") 1)
	    (glob-init))
	(if (!= &glob-running 0)
		  (&glob-wait "glob - waiting"))
	(setq &glob-running 1)	; waiting for something
	(save-excursion 
	    (temp-use-buffer "glob-csh")
	    (setq needs-checkpointing 0)
	    (erase-buffer)
	    (setq str (arg 1 ": &glob-wait "))
	    (if (> (length str) 0)
		(string-to-process "glob-csh" (concat str "\n")))
	)
    )

    (&glob-wait cont
;	(error-occured (error-message "&glob-wait")) (sit-for 5)
	(if (nargs) (progn
			  (message (arg 1 ": &glob-wait "))
			  (sit-for 0)))
	(setq cont &glob-running)
	(setq &glob-running 0); avoid possible deadlock at expense of
			      ; possible errors
	(if (!= cont 0)
	    (save-excursion
		(temp-use-buffer "glob-csh")
		(setq cont 1)
		(while cont
		       (end-of-file)
		       (beginning-of-line)
		       (if (looking-at "~GlOb#PrOmPt~")
			   (setq cont 0)
			   (await-process-input)
		       )
		)
		(end-of-file)
		(set-mark)
		(beginning-of-line)
		(backward-character)
		(erase-region)
		(if (error-occured (search-reverse "~GlOb#PrOmPt~"))
		    (beginning-of-file)
		    (region-around-match 0)
		)
		(set-mark)
		(end-of-file)
		(while (= (preceding-char) '\n')
		       (delete-previous-character))
		(region-to-string)
	    )
	    (setq &glob-running 0)
	)
    )
)
