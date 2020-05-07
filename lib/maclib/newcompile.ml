; This package provides a replacement for the standard ^X^E/^X^N compilation
; package.  It operates pretty much the same as the old except that the
; process control facilities are used.  Consequently, while a compilation is
; going on you can go off and do other things and (a major win) you can
; interrupt the compilation partway through.

(declare-global errors-parsed last-command)
(setq last-command "")

(defun
    (new-compile-it command
	(if prefix-argument-provided
	    (progn
		(setq command (arg 1 ": compile-it using command: "))
		(if (= command "")
		    (if (= last-command "")
			(error-message "No previous command")
			(setq command last-command))
		    (setq last-command command)))
	    (setq command "make -k"))
	(setq errors-parsed 0)
	(save-excursion
	    (pop-to-buffer "Error-log")
	    (setq needs-checkpointing 0)
	    (erase-buffer)
	    (write-modified-files)
	    (if (>= (process-status "Error-log") 0)
		(kill-process "Error-log"))
	    (start-process command "Error-log")
	    (setq mode-line-format (concat "        Executing: " command
				       " (^X^K to kill) %M"))
	    (setq mode-string command)
	    (novalue)
	)
    )
    
    (kill-compilation
	(save-excursion 
	    (temp-use-buffer "Error-log")
	    (setq mode-line-format "       Dead!       %M")
	    (kill-process "Error-log"))
    )
    
    (parse-errors
	(pop-to-buffer "Error-log")
	(setq mode-string "     Compilation diagnostics")
	(setq buffer-is-modified 0)
	(beginning-of-file)
	(set-mark)
	(end-of-file)
	(parse-error-messages-in-region)
	(setq errors-parsed 1)
	(next-error)
    )
    
    (new-next-error
	(if (= errors-parsed 1)
	    (next-error)
	    (if (< (process-status "Error-log") 0)
		(parse-errors)
		(if (= (get-tty-string "The compilation is still running, do you want to kill it? ") "y")
		    (progn
			(kill-compilation)
			(parse-errors)))
	    )
	)
	
    )
)

(bind-to-key "new-compile-it" (+ 256 '^E'))
(bind-to-key "new-next-error" (+ 256 '^N'))
(bind-to-key "kill-compilation" (+ 256 '^K'))
(novalue)
