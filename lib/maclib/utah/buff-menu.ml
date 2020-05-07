; 
; Buffer menu main function and support functions.  Autoloaded.
; 
(declare-global &Buffer-menu-current-buffer& &Buffer-menu-argument&)

(defun
    (buffer-menu
	(setq &Buffer-menu-current-buffer& (current-buffer-name))
	(setq &Buffer-menu-argument& prefix-argument-provided)
	(&buffer-menu))
)

(defun
    (&buffer-menu old-buffer buffer-column ; written by Swt
	; Presents a menu of buffers in a buffer.
	; The user may position the cursor on the
	; line containing the desired buffer, then
	; hit space to switch to that buffer.
	(setq old-buffer (current-buffer-name))
	(switch-to-buffer "Buffer list")
	(list-buffers)
	(search-forward "Buffer")
	(backward-word)
	(setq buffer-column (current-column))
	(error-occured cont
	    (setq cont 1)
	    (while cont
		(search-forward (concat " " &Buffer-menu-current-buffer& " "))
		(if (= (&Buffer-menu-name) &Buffer-menu-current-buffer&)
		    (setq cont 0)
		    (beginning-of-next-line))))
	(beginning-of-line)
	(delete-next-character)
	(insert-string ".")
	(beginning-of-file)
	(error-occured cont
	    (setq cont 1)
	    (while cont
		(search-forward (concat " " old-buffer " "))
		(if (= (&Buffer-menu-name) old-buffer)
		    (setq cont 0)
		    (beginning-of-next-line))))
	(beginning-of-line)
	(save-excursion
	    (beginning-of-file)
	    (if (= &Buffer-menu-argument& 0)
		(while (! (error-occured
			      (search-forward " Scr ")))
		    (beginning-of-line)
		    (set-mark)
		    (next-line)
		    (delete-region-to-buffer "SCRATCH")
		    (if (= (following-char) '^J')
			(delete-next-character))))
	)
	(local-bind-to-key "Select-buffer-menu" '\040')
	(local-bind-to-key "Select-buffer-menu" '^m')
	(local-bind-to-key "Select-buffer-menu" '^j')
	(local-bind-to-key "Buffer-menu-2-window" '2')
	(local-bind-to-key "Buffer-menu-1-window" '1')
	(local-bind-to-key "Buffer-menu-." '.')
	(local-bind-to-key "Buffer-menu-save-file" 's')
	(local-bind-to-key "Buffer-menu-save-file" 'S')
	(local-bind-to-key "Buffer-menu-delete-buffer" 'd')
	(local-bind-to-key "Buffer-menu-delete-buffer" 'D')
	(local-bind-to-key "Buffer-menu-not-modified" "~")
	(local-bind-to-key "Buffer-menu-help" "?")
	(local-bind-to-key "Buffer-menu-all" "\030\002"); ^X^B
	(setq wrap-long-lines 0)
    )
)    
(defun
    (Buffer-menu-help
	(if (= prefix-argument-provided 0)
	    (message
		"Commands are space, newline, 1, 2, s, ~, d, ., ^X^B. ^U? gets more help")
	    (save-excursion
		(pop-to-buffer "Help")
		(erase-buffer)
		(insert-string
		    (concat
			"space, newline	Select buffer on line.\n"
			"1\t\tSelect buffer and switch to 1 window mode.\n"
			"2\t\tSelect buffer in the other window.\n"
			".\t\tSelect the buffer you were in before.\n"
			"s,S\t\tSave the file in this buffer.\n"
			"~\t\tUnmodify this buffer.\n"
			"d,D\t\tKill this buffer.\n"
			"^X^B\t\tRedisplay with Scratch buffers too.")))
	)
    )
)    
(defun
    (Select-buffer-menu
	(setq wrap-long-lines 1)
	(use-old-buffer (&Buffer-menu-name)))
)    
(defun
    (Buffer-menu-1-window	; by SWT
				; select a buffer and delete all other
				; windows at the same time.
	(setq wrap-long-lines 1)
	(use-old-buffer (&Buffer-menu-name))
	(delete-other-windows))
)
(defun
    (Buffer-menu-2-window new-buffer
	(setq new-buffer (&Buffer-menu-name))
	(setq wrap-long-lines 1)
	(use-old-buffer &Buffer-menu-current-buffer&)
	(pop-to-buffer new-buffer))
)    
(defun
    (Buffer-menu-.
	(setq wrap-long-lines 1)
	(use-old-buffer &Buffer-menu-current-buffer&)
    )
)	
(defun
    (Buffer-menu-save-file buffer-name
	(progn
	    (use-old-buffer (&Buffer-menu-name))
	    (Write-current-file)
	    (&buffer-menu)
	)
    )
)    
(defun
    (Buffer-menu-delete-buffer
	(delete-buffer (&Buffer-menu-name))
	(beginning-of-line)
	(save-excursion
	    (set-mark)
	    (next-line)
	    (delete-region-to-buffer "SCRATCH"))
	(if (eobp) (previous-line)))
)
(defun
    (Buffer-menu-not-modified
	(use-old-buffer (&Buffer-menu-name))
	(Not-modified)
	(&buffer-menu)
    )
)    
(defun
    (&Buffer-menu-name buffer-column mode-column
	(if (!= (current-buffer-name) "Buffer list")
	    (error-message "Not in Buffer menu")
	)	    
	(save-excursion
	    (beginning-of-file)
	    (search-forward "Buffer")
	    (backward-word)
	    (setq buffer-column (- (current-column) 1))
	    (search-forward "Mode")
	    (backward-word)
	    (setq mode-column (- (current-column) 1))
	)
	(beginning-of-line)
	(provide-prefix-argument buffer-column (forward-character))	
	(set-mark)
	(search-forward " ")
	(while (& (!= (following-char) '\040')
		   (< (current-column) mode-column))
	    (search-forward " "))
	(backward-character)
	(region-to-string)
    )
)
(defun
    (Buffer-menu-all
	(use-old-buffer (&Buffer-menu-name))
	(setq &Buffer-menu-argument& 1)
	(&buffer-menu))
)
