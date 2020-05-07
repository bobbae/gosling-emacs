;  Emacs "list directory" package. Defines functions "vdirectory",
; "wdirectory, "gdirectory", and qdirectory. 
; 	Brian Reid, September 1983
(defun
    (directory what how which
	(setq which (concat ": " (arg 1) "directory (of files)? "))
	(setq what (get-tty-string which))
	(setq how (arg 2 "huh?"))
	(pop-to-buffer "directory")
	(set-mark)
	(erase-buffer)
	(if (= what "")
	    (fast-filter-region (concat "ls -" how " " what))
	    (filter-region (concat "ls -" how " " what))
	)
	(beginning-of-file)
    )
    (vdirectory (directory "v" "al"))
    (wdirectory (directory "w" "alt"))
    (gdirectory (directory "g" "alg"))
    (qdirectory (directory "q" "Cx"))
)
