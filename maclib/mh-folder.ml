(error-message "mh-folder.ml is obsolete.  See mh-cache.ml instead.")

(defun 
    (&mh-read-folder mh-fold-name mh-fold-range
	(&mh-pop-to-buffer (concat "+" mh-fold-name)) (sit-for 0)
	(if (= (buffer-size) 0)
	    (insert-string " "))
	(setq mode-line-format " please wait ")
	(message "scan +" mh-fold-name " " mh-fold-range mh-width)
	(sit-for 0)
	(erase-buffer) (set-mark)
	(fast-filter-region
	    (concat mh-progs "/scan +" mh-fold-name " " mh-fold-range mh-width))
	(beginning-of-file)
	
	(if (! (looking-at "No messages "))
	    (progn t
		   (end-of-file) (beginning-of-window)
		   (if (! (bobp))
		       (progn 
			      (end-of-file)
			      (setq t (dot))
			      (while (= t (dot))
				     (progn 
					    (scroll-one-line-down)
					    (sit-for 0)
				     ))
			      (scroll-one-line-up)
		       )
		   )
		   (end-of-file)
		   (&mh-previous-line)
	    )
	    (progn 
		   (if (= mh-fold-range "")
		       (message "Folder +" mh-fold-name " is empty.")
		       (message "No messages in +" mh-fold-name
				" range " mh-fold-range)
		   )
		   (sit-for 15)
	    )
	)
        (setq mh-mode-line
	      (concat "{%b} %[+ " mh-fold-name
		      "%] (npd^!u tTel mfrRyi gbx ? ^X^C)   %M"))
	(setq mode-line-format mh-mode-line)
	(setq buffer-is-modified 0)
    )
)
