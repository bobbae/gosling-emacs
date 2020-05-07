;  Utilities for mhe.
; 

; Save and restore contents of kill buffer.
; 
(defun     
    (&mh-save-killbuffer
	(save-excursion 
	    (temp-use-buffer "Kill buffer")
	    (temp-use-buffer "Kill save")
	    (setq backup-before-writing 0)
	    (erase-buffer)
	    (yank-buffer "Kill buffer")
	    (setq buffer-is-modified 0)
	)
    )
    
    (&mh-restore-killbuffer
	(save-excursion 
	    (temp-use-buffer "Kill buffer")
	    (erase-buffer)
	    (yank-buffer "Kill save")
	)
    )
)

; Move the cursor around in a header buffer, and possibly
; display the message to which the cursor points.
(defun     
    (&mh-next-line
	(pop-to-mh-buffer)
	(setq mh-direction 1)
	(prefix-argument-loop 
	    (next-line)
	    (beginning-of-line)
	    (while (& (looking-at "\tmove to ") (! (eobp)))
		(next-line)
	    )
	)
	(if (eobp)
	    (&mh-previous-line)
	)
    )
    (&mh-previous-line
	(pop-to-mh-buffer)
	(setq mh-direction -1)
	(prefix-argument-loop 
	    (previous-line)
	    (beginning-of-line)
	    (while (& (looking-at "\tmove to ") (! (bobp)))
		(previous-line)
	    )
	)
	(if (bobp)
	    (setq mh-direction 1))
    )
    
    (another-line
	(pop-to-mh-buffer)
	(if (> mh-direction 0)
	    (&mh-next-line)
	    (&mh-previous-line)
	)
    )
)

; Get message number at current cursor position in mh-buffer.
; 
(defun     
    (&mh-get-msgnum
	(save-excursion
	    (temp-use-mh-buffer)
	    (beginning-of-line)
	    (while (= (following-char) ' ') (forward-character))
	    (set-mark)
	    (beginning-of-line)
	    (goto-character (+ (dot) 3))
	    (region-to-string)
	)
    )
)
    
(defun 
    (&mh-get-fname
	(save-excursion 
	    (temp-use-mh-buffer)
	    (concat mh-directory (&mh-get-msgnum))
	)
    )
)
    
; Read .mh_profile in home directory. Get path and current-folder. Set
; variable mh-path. Returns mh-folder, from which caller should set the
; buffer-specific mh-folder, mh-buffer, and mh-directory.
; 
(defun 
    (&mh-read-profile mh-folder
	(save-window-excursion sb
	    (setq sb (concat (getenv "HOME") "/.mh_profile"))
	    (if (= 0 (file-exists sb))
		(error-message "No .mh_profile in home directory(?)")
	    )
	    (visit-file sb)
	    
	    (setq mh-path "Mail")
	    (error-occured 
		(search-forward "path:")
		(while (looking-at "[\t ]") (forward-character))
		(set-mark) (end-of-line)
		(setq mh-path (region-to-string))
	    )
	    (if (!= (string-to-char (substr mh-path 1 1)) '/')
		(setq mh-path (concat (getenv "HOME") "/" mh-path)))
	    
	    (beginning-of-file)
	    (setq mh-folder "+inbox")
	    (error-occured 
		(search-forward "current-folder:")
		(while (looking-at "[\t ]") (forward-character))
		(set-mark) (end-of-line)
		(setq mh-folder (region-to-string))
	    )
	    (if (!= (substr mh-folder 1 1) "+")
		(setq mh-folder (concat "+" mh-folder)))
	    (setq-default mh-folder mh-folder)
	)
    )
)

; Remove all "+" flags from the headers.
;
(defun 
    (&mh-unmark-all-headers
	(save-excursion 
	    (temp-use-mh-buffer)
	    (beginning-of-file)
	    (while (! (error-occured (re-search-forward "^...\\+")))
		(delete-previous-character)
		(insert-character ' ')
	    )
	)
    )
)
    
; Find the current (+) message in the folder and position the cursor there.
; 
(defun
    (&mh-position-to-current curmsg
	(temp-use-mh-buffer)
	(save-window-excursion 
	    (if (error-occured (visit-file (concat mh-directory "cur")))
		(setq curmsg 0)
		(progn
		    (beginning-of-file)
		    (set-mark)
		    (end-of-line)
		    (setq curmsg (region-to-string))
		)
	    )
	)
	(end-of-file)
	(error-occured (re-search-reverse "^[ 0-9][ 0-9]"))
	(if (!= curmsg 0)
	    (error-occured (re-search-reverse (concat "^[ ]*" curmsg "[^0-9]")))
	)
	(if (looking-at "[ 0-9]")
	    (save-excursion 
		(goto-character (+ (dot) 3))
		(delete-next-character)
		(insert-character '+')
	    )
	)
    )
)
    
; Set the "current message" (+ sign) to equal the number of
; the message that the cursor is pointing to. I.e. it write cur to stable
; storage.
; 
(defun 
    (&mh-set-cur cm
	(save-window-excursion 
	    (temp-use-mh-buffer)
	    (setq cm (&mh-get-msgnum))
	    (error-occured (visit-file (concat mh-directory "cur")))
	    (erase-buffer)
	    (insert-string cm)
	)
    )
)
    
; temp-use-mh-buffer -- find and temp-use an mh-buffer
; 
(defun
    (temp-use-mh-buffer
	(if (!= "+" (substr (current-buffer-name) 1 1))
	    (if (= mh-buffer "")
		(temp-use-buffer t-mh-buffer)
		(temp-use-buffer mh-buffer)
	    )
	)
    )
)

; pop-to-mh-buffer -- find and pop-to an mh-buffer
; 
(defun
    (pop-to-mh-buffer
	(if (!= "+" (substr (current-buffer-name) 1 1))
	    (if (= mh-buffer "")
		(pop-to-buffer t-mh-buffer)
		(pop-to-buffer mh-buffer)
	    )
	)
    )
)

