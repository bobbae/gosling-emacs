;   grep.ml -- enables use of UNIX grep command from within EMACS
;
;SYNOPSIS
;
; (grep pattern filenames)	-- interface to UNIX grep
; 
;
;DESCRIPTION
;
; This function is the interface to the grep program from within
; Emacs.  It is not very clean, but it appears to work.  It prompts
; for a pattern and a list of files.  It then calls up /bin/grep
; with the given arguments and /dev/null at the end.  This is necessary
; because otherwise grep won't print the filename in the message line
; if there is only one file specified.  This just forces the filename
; display.
;
;  {1}	17-Feb-84  Stephen J. Friedl (friedl) at Kent State University
; 	created.

(progn m1 m2
   (setq m1 "grep.ml needs a file called ")
   (setq m2 " and it does not exist")
   (if (! (file-exists "/bin/grep"))
      (error-message (concat m1 "/bin/grep" m2)))
)

(defun
    (grep pattern files cmd
	  (save-excursion
	      (setq pattern (arg 1 ": grep for pattern "))
	      (if (= (length pattern) 0)
		  (error-message "missing pattern to grep"))
	      ; check for switch, if there remove the dash
	      ; because we already send a switch to grep
	      (if (= (substr pattern 1 1) '-')                      ; {2}
		  (setq pattern (substr pattern 2 (length pattern))) ; {2}
		  (setq pattern (concat " " pattern))
	      )
	      (setq files (arg 2 ": files "))
	      (setq files (concat files " /dev/null"))              ; {2}
	      (setq cmd (concat "/bin/grep -n" pattern " " files))
	      (setq-default errors-parsed 0)
	      (setq-default grep-mode 1)
	      (save-excursion
		  (pop-to-buffer "Error-log")
		  (setq needs-checkpointing 0)
		  (erase-buffer)
		  (if (>= (process-status "Error-log") 0)
		      (kill-process "Error-log"))
		  (start-process cmd "Error-log")
		  (setq mode-line-format (concat "        Executing: " cmd
						 " (^X^K to kill) %M"))
		  (setq mode-string cmd)
		  (novalue)
	      )
	  )
    )
)

