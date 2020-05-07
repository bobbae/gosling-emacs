; Run scan to create a fresh version of the folder listing.
; 
(defun
    (&mh-scan
	(message "Scanning headers...") (sit-for 0)
	(temp-use-mh-buffer)
	(erase-buffer)
	(set-mark)
	(fast-filter-region  (concat "scan " mh-folder))
	(&mh-position-to-current)
	(mh-mode)		; not clear why this should be necessary
    )
)

(defun 
    (&mh-folders
	(message "Listing folders...") (sit-for 0)
	(pop-to-buffer "mh-folders")
	(setq needs-checkpointing 0)
	(erase-buffer)
	(set-mark)
	(fast-filter-region "folder -all")
	(beginning-of-file)
    )
)

; Close a folder, that is, process all of the pending deletes and
; moves, and edit the header buffer accordingly.
; 
(defun
    (&mh-close-folder mn sb
	(message "Closing folder...") (sit-for 0)
	(temp-use-buffer "mh-temp")
	(erase-buffer)
	(temp-use-mh-buffer)
	(beginning-of-file)
	(while (! (eobp))
	    (beginning-of-line)
	    (set-mark)
	    (goto-character (+ (dot) 3))
	    (if
		(looking-at "D") (&mh-add-rmm-cmd (region-to-string))
		(looking-at "\\^") (&mh-add-refile-cmd (region-to-string))
		(next-line)
	    )
	)
	(&mh-previous-line)
	(temp-use-buffer "mh-temp")
	(beginning-of-file)
	(split-long-lines)
	(while (! (eobp))
	    (beginning-of-line)
	    (set-mark)
	    (end-of-line)
	    (setq sb (region-to-string))
	    (delete-to-killbuffer)
	    (fast-filter-region sb)
	    (next-line)
	)
	(temp-use-mh-buffer)
	(mh-mode)		; not clear why this should be necessary
    )
)
    
; add delete command to mh-temp
;
(defun 
    (&mh-add-rmm-cmd mn
	(setq mn (arg 1))
	(beginning-of-line)
	(kill-to-end-of-line) (kill-to-end-of-line)
	(save-excursion 
	    (temp-use-buffer "mh-temp")
	    (beginning-of-file)
	    (if (error-occured (search-forward (concat "rmm " mh-folder)))
		(progn 
		    (insert-string "rmm " mh-folder "\n")
		    (backward-character)
		)
	    )
	    (end-of-line)
	    (insert-string " " mn)
	)
    )
)
    
; add refile command(s) to mh-temp
;
(defun 
    (&mh-add-refile-cmd mn sb	; mn = message number
	(setq mn (arg 1))
	(beginning-of-line)
	(kill-to-end-of-line) (kill-to-end-of-line)
	(while (looking-at "\tmove to ")
	    (search-forward "\tmove to ")
	    (set-mark)
	    (end-of-line)
	    (setq sb (concat "refile -src " mh-folder " +" (region-to-string)))
	    (save-excursion 
		(temp-use-buffer "mh-temp")
		(beginning-of-file)
		(if (error-occured (search-forward sb))
		    (progn
			(insert-string sb "\n")
			(backward-character)
		    )
		)
		(end-of-line)
		(insert-string " " mn)
	    )
	    (beginning-of-line)
	    (kill-to-end-of-line) (kill-to-end-of-line)
	    (first-non-blank)
	)
    )
)
    
; make sure no overlong lines in cmd-buffer
; 
(defun 
    (split-long-lines t s
	(save-excursion 
	    (while (! (eobp))
		(while
		    (progn (beginning-of-line)
			(setq t (dot)) (end-of-line) (> (dot) (+ t 200)))
		    (beginning-of-line) (set-mark)
		    (if (looking-at "rmm")
			(progn (forward-word) (forward-word) (forward-word)
			    (backward-word))
			(looking-at "refile")
			(progn (forward-word) (forward-word)
			    (forward-word) (forward-word)
			    (forward-word) (backward-word))
		    )
		    (setq s (region-to-string)) (beginning-of-line)
		    (goto-character (+ (dot) 200)) (backward-word)
		    (delete-previous-character) (newline)
		    (insert-string s)
		)
		(next-line)
	    )
	)
    )
)
    
; Apply "folder -pack" to the current folder, after first
; closing it (see above).
; 
(defun 
    (&mh-pack-folder
	(message "Closing folder first...") (sit-for 0)
	(&mh-close-folder)
	(message "Packing...") (sit-for 0)
	(set-mark)
	(fast-filter-region (concat "folder " mh-folder " -pack"))
	(&mh-scan)
    )
)
