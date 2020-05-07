(progn
    (if (! (is-bound pip-tape))
	(setq-default pip-tape "/dev/nrmt9"))
    (defun
    
	(read-magtape-file fname tapename cont i n
	    (if (interactive)
		(setq n 1)
		(setq n (nargs)))
	    (setq i 1)
	    (while (>= n i)
		   (setq cont 1)
		   (setq fname (arg i ": read-magtape-file "))
		   (while (& cont (! (error-occured
					 (setq tapename (read-header)))))
			  (message "Got to " tapename) (sit-for 0)
			  (if (= fname tapename)
			      (progn
				    (error-occured (visit-file fname))
				    (erase-buffer)
				    (read-pip-file)
				    (skip-trailer)
				    (setq cont 0))
			      (glob-command
				  (concat "mt -t " pip-tape " fsf 2")))
		   )
		   (setq i (+ i 1))
	    )
	    (novalue)
	)
    
	(read-magtape fname
	    (pop-to-buffer "pip")
	    (while 1
		   (setq fname (read-next-magtape-file))
;		   (Write-current-file)
	    )
	)

	(read-next-magtape-file fname
	    (setq fname (read-header))
	    (message "Reading " fname)(sit-for 0)
;	    (error-occured (visit-file fname))
	    (erase-buffer)
	    (read-pip-file fname)
	    (skip-trailer)
	    fname
	)
    
	(read-header
	    (save-excursion
		(temp-use-buffer "Scratch")
		(erase-buffer)
		(set-mark)
		(insert-string (glob-command
				   (concat "dd if=" pip-tape " bs=80")))
		(beginning-of-file)
		(if (error-occured
			(search-forward "HDR1"))
		    (error-message "Not a header record"))
		(set-mark)
		(search-forward " ")
		(backward-character)
		(case-region-lower)
		(region-to-string)
	    )
	)
    
	(read-pip-file
	    (set-mark)
	    (filter-region (concat "pipread " pip-tape " "
				   (if (| (> (nargs) 0) (interactive))
				       (arg 1 "Name? ") "")))
	    (novalue)
	)
    
	(process-pip-file count
	    (setq count 0)
	    (beginning-of-file)
	    (while (! (eobp))
		   (if (= 0 (% count 100))
		       (progn
			     (message "At line " count)
			     (sit-for 0))
		   )
		   (setq count (+ count 1))
		   (process-pip-line)
	    )
	    (message "At line " count)
	    (sit-for 0)
	)
    
	(process-pip-line length
	    (prefix-argument-loop 
		(set-mark)
		(provide-prefix-argument 4 (forward-character))
		(setq length (- (region-to-string) 4))
		(erase-region)
		(provide-prefix-argument length (forward-character))
		(insert-character '\n')
		(if (looking-at "\\(^^*\\)")
		    (progn
			  (region-around-match 1)
			  (erase-region)))
		(if (! (looking-at "[0-9][0-9][0-9][0-9]"))
		    (end-of-file))
	    )
	)

	(rewind
	       (set-mark)
	       (glob-command (concat "mt -t " pip-tape " rew"))
	)
    
	(skip-trailer
	    (save-excursion
		(temp-use-buffer "Scratch")
		(glob-command (concat "dd if=" pip-tape " bs=80"))
	    )
	)
    
	(tape-directory
	    (rewind)
	    (switch-to-buffer "Tape Directory")
	    (erase-buffer)
	    (setq mode-line-format (concat  "Tape Directory on " (current-time)))
	    (while (! (error-occured
			  (insert-string (read-header) "\n")))
		   (glob-command (concat "mt -t " pip-tape " fsf 2")))
	    (novalue)
	)

    (backspace-tape
	(glob-command (concat "mt -t " pip-tape " bsf 2"))
	(glob-command (concat "mt -t " pip-tape " fsf 1"))
	(novalue))
    )
)
