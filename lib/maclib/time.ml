(defun
    (time
	(if (< (process-status "newtime") 0)
	    (save-excursion
		(setq global-mode-string "time and load")
		(start-filtered-process 
		    "exec /a3/kent/emacs/lib/loadst 60"
		    "newtime" "newtime-filter")
		(temp-use-buffer "newtime")
		(setq needs-checkpointing 0)))
	(novalue)
    )
)

(defun
    (newtime-filter
	(temp-use-buffer "newtime")
	(erase-buffer)
	(insert-string (process-output))
	(end-of-file)
	(previous-line)
	(set-mark)
	(end-of-line)
	(setq global-mode-string (region-to-string))
	(sit-for 0)
    )
)
