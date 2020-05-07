; This autoloaded file defines the "^" command in mhe. It marks a message
; to be moved into another folder. This mark is represented in two ways:
; a "^" character is placed in column 4 of the header line, and the number
; of the message is placed in the text of an appropriate "file" command 
; in the command buffer. 

(defun 
    (&mh-refile
	(save-excursion 
	    (pop-to-mh-buffer)
	    (beginning-of-line)
	    (goto-character (+ (dot) 3))
	    (if (| (= (following-char) ' ') (= (following-char) '+'))
		(progn
		    (setq mh-last-destination
			(get-folder-name "Destination" "" 1))
		    (&mh-xfer mh-last-destination)
		)
	    )
	)
	(another-line)
    )
    
    (&mh-rerefile
	(if (= mh-last-destination "")
	    (error-message "No previous move command."))
	(save-excursion 
	    (pop-to-mh-buffer)
	    (beginning-of-line)
	    (goto-character (+ (dot) 3))
	    (if (| (= (following-char) ' ') (= (following-char) '+'))
		(progn
		    (&mh-xfer mh-last-destination)
		)
	    )
	)
	(another-line)
    )
    
    (&mh-xfer destn
	(progn
	    (setq destn (arg 1))
	    (delete-next-character)
	    (insert-string "^")
	    (beginning-of-line)
	    (next-line)
	    (insert-string "\tmove to " destn "\n")
	    (previous-line)
	)
    )
)

(defun 
    (get-folder-name		; (g-f-n "prompt" "default" can-create)
	exists msgg name defarg t-buffer-filename
	(setq exists 0)
	(if (> (nargs) 1) (setq defarg (arg 2)) (setq defarg ""))
	(setq msgg (concat (arg 1) " folder name? "))
	(while (! exists)
	    (if (= 0 (length defarg))
		(setq name (get-tty-string msgg))
		(setq name defarg)
	    )
	    (setq defarg "")
	    (if (= 0 (length name))
		(error-message "Abandoned."))
	    (if (!= (string-to-char (substr name 1 1)) '/')
		(setq t-buffer-filename (concat mh-path "/" name))
		(setq t-buffer-filename name)
	    )
	    (setq exists (file-exists t-buffer-filename))
	    (if (& (!= exists 1) (!= (arg 3) 0))
		(progn ans
		    (setq ans (get-response
				  (concat "Folder +" name " does not exist. May I create it for you? ")
				  "yYnN\"
				  "Please answer y or n"))
		    (if (= ans 'y')
			(progn 
			    (message "OK, I will create one for you.")
			    (set-mark)
			    (fast-filter-region (concat "mkdir " t-buffer-filename))
			    (setq exists 1)
			)
		    )
		)
	    )
	    (if (!= exists 1)
		(setq msgg  (concat "Sorry, no such folder as `" name
				"'.  Folder name? "))
	    )
	)
	name
    )
    
    (get-response chr ok s c pr
	(setq ok 0) (setq pr (arg 1))
	(while (! ok)
	    (setq chr
		(string-to-char 
		    (setq c
			(get-tty-string pr)
		    )
		)
	    )
	    
	    (setq s (arg 2))
	    (while (> (length s) 0)
		(if (= chr (string-to-char (substr s 1 1)))
		    (progn (setq ok 1) (setq s ""))
		    (setq s (substr s 2 -1))
		)
	    )
	    (if (= ok 0)
		(progn (if (!= chr '?')
			   (setq pr (concat "Illegal response '"
					(char-to-string chr)
					"'. " (arg 1)))
			   (setq pr (arg 3))
		       )
		)
	    )
	)
	(if (& (>= chr 'A') (<= chr 'Z'))
	    (+ chr (- 'a' 'A'))
	    chr
	)
    )
)

