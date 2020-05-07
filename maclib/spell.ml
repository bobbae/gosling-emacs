(defun
    (correct-spelling-mistakes word action continue
	(setq continue 1)
	(progn;error-occured
	    (while continue
		(save-excursion
		    (temp-use-buffer "Error log")
		    (beginning-of-file)
		    (set-mark)
		    (end-of-line)
		    (setq word (region-to-string))
		    (forward-character)
		    (delete-to-killbuffer)
		)
		(beginning-of-file)
		(error-occured (re-search-forward (concat "\\b"
							  (quote word)
							  "\\b")))
		(message  (concat word " ? "))
		(setq action (get-tty-character))
		(beginning-of-line)
		(if
		    (|  (= action '^G')
			(= action 'e')) (setq continue 0)
		    (= action 'r') (error-occured
				       (re-query-replace-string ""
					   (get-tty-string
					       (concat word " => "))))
		)
	    )
	)
	(novalue)
    )
)

(defun 
    (spell
	(message (concat "Looking for errors in " (current-file-name)
		     ", please wait..."))
	(sit-for 0)
	(save-excursion
	    (compile-it (concat "spell " (current-file-name))))
	(error-occured (correct-spelling-mistakes))
	(message "Done!")
	(novalue)
    )
)
