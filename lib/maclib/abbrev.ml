(defun (abbreviate-word w
	   (save-excursion
	       (forward-character)
	       (provide-prefix-argument prefix-argument (backward-word))
	       (set-mark)
	       (provide-prefix-argument prefix-argument (forward-word))
	       (setq w (region-to-string)))
	   (define-local-abbrev
	       (get-tty-string (concat ": abbreviate-word \"" w "\" by: "))
	       w)
	   (novalue)
       ))
