(defun
    (pwd cwd
	(setq cwd (working-directory))
	(message (concat
		     ": pwd => "
		     (if (= (substr cwd -1 1) "/")
			 (substr cwd 1 -1)
			 cwd)))
	(novalue))

    (cd dir
	(setq dir (arg 1 ": cd "))
	(if (= dir "") (setq dir "~"))
	(if (error-occured (change-directory dir))
	    (change-directory (concat "~/" dir)))
	(quietly-read-abbrev-file ".abbrevs")
	(message (concat ": cd " (working-directory)))
	(novalue))
    
)
