; $Header: RCS/newcomp.ml,v 1.3 83/05/08 01:59:01 thomas Exp $
; This package provides a replacement for the standard ^X^E/^X^N compilation
; package.  It operates pretty much the same as the old except that the
; process control facilities are used.  Consequently, while a compilation is
; going on you can go off and do other things and (a major win) you can
; interrupt the compilation partway through.

(declare-global compilation-may-be-active last-command compile-dir
     default-compile-command)
(setq last-command "")

(defun
    (new-compile-it command
	(if prefix-argument-provided
	    (progn last-command comval
		   (setq last-command (concat "last-command" prefix-argument))
		   (execute-mlisp-line
		       (concat "(declare-global " last-command ")"))
		   (execute-mlisp-line
		       (concat "(setq comval " last-command ")"))
		   (if (= comval "0")
		       (setq comval ""))
		   (if (interactive)
		       (setq command
			     (get-tty-input
				 (concat ": compile-it using command "
					 prefix-argument ": ")
				 comval))
		       (setq command
			     (arg 1 (concat ": compile-it using command "
					     prefix-argument ": ")))
		   )
		   (if (= command "")
		       (if (= (execute-mlisp-line last-command)  "")
			   (error-message "No previous command")
			   (progn
				 (setq command
				       (execute-mlisp-line last-command))
			   ))
		    (execute-mlisp-line
			(concat "(setq " last-command " command)"))))
	    (if (= default-compile-command "")
		(setq command "make -k")
		(setq command default-compile-command)))
	(setq compilation-may-be-active 1)
	(setq compile-dir (working-directory))
	(save-excursion
	    (pop-to-buffer "Error-log")
	    (setq needs-checkpointing 0)
	    (erase-buffer)
	    (write-modified-files)
	    (if (>= (process-status "Error-log") 0)
		(kill-process "Error-log"))
	    (start-process command "Error-log")
	    (insert-sentinel "Error-log" "new-compile-exit")
	    (setq mode-line-format (concat "%m"
					   (if prefix-argument-provided
					       (concat " " prefix-argument)
					       "")
					   ": " command
					   "      %M"))
	    (setq mode-string "Executing")
	    (novalue)
	)
    )
    
    (kill-compilation
	(save-excursion
	    (temp-use-buffer "Error-log")
	    (setq mode-line-format "       Dead!       %M")
	    (kill-process "Error-log")
	    (setq compilation-may-be-active 0)
	    (setq buffer-is-modified 0)
	    (novalue)
	)
    )
    
    (new-next-error
	(save-excursion
	    (if (!= (working-directory) compile-dir)
		(progn
		      (send-string-to-terminal "\7\7")
		      (if (c= (string-to-char
				  (get-tty-no-blanks-input 
				      (concat "Not on directory "
					      compile-dir ", connect? ") "" ))
			      'y')
			  (glob-cd compile-dir)))
	    )
	    (if compilation-may-be-active
		(progn
		    (if (& (>= (process-status "Error-log") 0)
			   (= (get-tty-string "The compilation is still running, do you want to kill it? ") "y"))
			(kill-compilation))
		    (pop-to-buffer "Error-log")
		    (setq mode-string "Diagnostics")
		    (setq buffer-is-modified 0)
		    (beginning-of-file)
		    (set-mark)
		    (end-of-file)
		    (parse-error-messages-in-region)
		    (setq compilation-may-be-active 0)
		)
		prefix-argument-provided
		(progn
		    (pop-to-buffer "Error-log")
		    (setq mode-string "Diagnostics")
		    (setq buffer-is-modified 0)
		    (beginning-of-file)
		    (set-mark)
		    (end-of-file)
		    (parse-error-messages-in-region)
		)
	    )
	)
	(next-error)
    )

    (list-commands
	(variable-apropos "last-command")
	(temp-use-buffer "Help")
	(beginning-of-file)
	(re-replace-string "^last-command" "Command ")
	(while (! (eobp))
	       (forward-word)
	       (forward-character)
	       (if (! (looking-at "[-0-9][0-9]* "))
		   (progn
			 (beginning-of-line)
			 (set-mark)
			 (next-line)
			 (erase-region)
		   )
 		   (beginning-of-next-line)
	       )
	)
    )
)

(defun
    (new-compile-exit why
	(temp-use-buffer MPX-process)
	(end-of-file)
	(insert-string (setq why (>> prefix-argument 16)) ","
	    (bit& prefix-argument 0177777) ":" (process-output))
	(if
	   (= why 2)
	   (setq mode-string "Executing")
	   (= why 1)
	   (setq mode-string "Stopped")
	   (= why 4)
	   (setq mode-string "Exited")
	)
    )
)

(bind-to-key "new-compile-it" (+ 256 '^E'))
(bind-to-key "new-next-error" (+ 256 '^N'))
(bind-to-key "kill-compilation" (+ 256 '^K'))
(novalue)
