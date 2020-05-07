(defun (manual-entry entry-name
	       (setq entry-name (arg 1 ": manual-entry (for) "))
	   (save-excursion
	       (pop-to-buffer "man-entry")
	       (setq mode-line-format (concat "   Manual entry for "
					      entry-name
					      "     %M  %[%p%]"))
	       (setq needs-checkpointing 0)
	       (erase-buffer)
	       (set-mark)
	       (filter-region (concat "man " entry-name))
	       (beginning-of-file)
	       (error-occured (re-replace-string "_\b" ""))
	       (error-occured (re-replace-string
				  "^[A-Z][A-Z]*([0-9]*).*)$"
				  ""))
	       (error-occured (re-replace-string "^Printed [0-9].*[0-9]$" ""))
	       (error-occured (re-replace-string "\n\n\n\n*" "\n\n"))
	       (if (looking-at "\n\n*")
		   (progn
			 (region-around-match 0)
			 (erase-region)))
	   )
       )
)
