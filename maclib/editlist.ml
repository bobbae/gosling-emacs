; A replacement for the ailing matching-visit-files, based on a 
; version by Bill Mitchell.
;
(declare-global EditList)
(defun
    (expand-names
	(save-excursion
	    (temp-use-buffer "matching-tmp")
	    (erase-buffer)
	    (set-mark)
	    (filter-region (concat "echo -n " (arg 1)))
	    (setq EditList (concat (region-to-string) " ")))
    )
    
    (matching-visit-files i file quit names
	(setq names (arg 1 "visit files: "))
	(if (!= names "")
	    (expand-names names))
	(if (= EditList "")
	    (error-message "No more files to edit"))
	(setq i 1)
	(while (! quit)
	    (if (= (substr EditList i 1) " ")
		(progn
		    (setq file (substr EditList 1 (- i 1)))
		    (setq EditList (substr EditList (+ i 1) -1))
		    (setq quit 1))
		(setq i (+ i 1))))
	(message (concat "Remaining files: " EditList))
	(visit-file file)
	(novalue)
    )

    (region-around-word
	(re-search-forward "\\=[ ]*\\(.[^ ]*\\)")
	(region-around-match 1)
    )
)
