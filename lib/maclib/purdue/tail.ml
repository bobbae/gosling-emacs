(defun 
    (tail file buffer 
	(setq file (arg 1 "tail file: "))
	(setq buffer (base-name file))
	(if (< (process-status buffer) 0)
	    (save-excursion
		(temp-use-buffer buffer)
		(start-process 
		    (concat "exec tail -f <" file) buffer)
		(setq needs-checkpointing 0)))
	(pop-to-buffer buffer)
	(novalue)
    )
    (base-name name
	(setq name (arg 1))
	(temp-use-buffer "base-name-tmp")
	(erase-buffer)
	(insert-string name)
	(set-mark)
	(if (! (error-occured (search-reverse "/")))
	    (forward-character)
	    (beginning-of-line))
	(region-to-string)
    )
)
