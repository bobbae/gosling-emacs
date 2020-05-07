; 
; Buffer menu main function and support functions.  Autoloaded.
; 
(progn 
(status-line "Loading buffer menu")
(declare-global &Buffer-menu-current-buffer& &Buffer-menu-argument&)
(defun
    (buffer-menu
	(setq &Buffer-menu-current-buffer& (current-buffer-name))
	(setq &Buffer-menu-argument& prefix-argument)
	(&buffer-menu))
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
	    (if (= &Buffer-menu-argument& 1)
		(while (! (error-occured
			      (search-forward " Scr ")))
		    (beginning-of-line)
		    (kill-to-end-of-line)
		    (if (= (following-char) '^J')
			(delete-next-character))))
	)
	(local-bind-to-key "Select-buffer-menu" '\040')
	(local-bind-to-key "Select-buffer-menu" '^m')
	(local-bind-to-key "Select-buffer-menu" '^j')
	(local-bind-to-key "Buffer-menu-2-window" '2')
	(local-bind-to-key "Buffer-menu-1-window" '1')
	(local-bind-to-key "Buffer-menu-save-file" 's')
	(local-bind-to-key "Buffer-menu-save-file" 'S')
	(local-bind-to-key "Buffer-menu-delete-buffer" 'd')
	(local-bind-to-key "Buffer-menu-delete-buffer" 'D')
	(local-bind-to-key "Buffer-menu-not-modified" "~")
	(local-bind-to-key "Buffer-menu-help" "?")
	(local-bind-to-key "Buffer-menu-all" "\^X\^B"); ^X^B
	(setq wrap-long-lines 0)
    )
    
    (Buffer-menu-help
	(if (= prefix-argument 1)
	    (message
		"Commands are space, newline, 1, 2, s, ~, d. ^U? gets more help")
	    (save-excursion
		(pop-to-buffer "Help")
		(erase-buffer)
		(insert-string
		    (concat
			"space, newline	Select buffer on line.\n"
			"1\t\tSelect buffer and switch to 1 window mode.\n"
			"2\t\tSelect buffer in the other window.\n"
			"s,S\t\tSave the file in this buffer.\n"
			"~\t\tUnmodify this buffer.\n"
			"d,D\t\tKill this buffer.\n")))
	)
    )
    
    (Select-buffer-menu
	(setq wrap-long-lines 1)
	(use-old-buffer (&Buffer-menu-name)))
    
    (Buffer-menu-1-window	; by SWT
				; select a buffer and delete all other
				; windows at the same time.
	(use-old-buffer (&Buffer-menu-name))
	(delete-other-windows))
    (Buffer-menu-2-window new-buffer
	(setq new-buffer (&Buffer-menu-name))
	(setq wrap-long-lines 1)
	(use-old-buffer &Buffer-menu-current-buffer&)
	(pop-to-buffer new-buffer))
    
    (Buffer-menu-save-file buffer-name
	(progn
	    (use-old-buffer (&Buffer-menu-name))
	    (Write-current-file)
	    (&buffer-menu)
	)
    )
    
    (Buffer-menu-delete-buffer
	(delete-buffer (&Buffer-menu-name))
	(&buffer-menu))
    (Buffer-menu-not-modified
	(use-old-buffer (&Buffer-menu-name))
	(Not-modified)
	(&buffer-menu)
    )
    
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
    (Buffer-menu-all
	(setq &Buffer-menu-argument& 4)
	(&buffer-menu)
    )
)
(setq mode-line-format default-mode-line-format)
)
