(setq mode-line-format "Loading") (sit-for 0)
(glob-init)
; Additions to the next version of utah-init.ml to be saved:

; Reset the mode line

(save-excursion
    (pop-to-buffer "  Minibuf")
    (enlarge-window)		; make 2 line minibuffer
)

(setq mode-line-format default-mode-line-format)

(defun 
    (igrep string files com
	(progn
	    (setq string (arg 1 ": igrep (string) '"))
	    (setq files (arg 2 (concat
				   (concat ": igrep (string) '" string)
				   "' (files) ")))
	    (setq com  (concat "jagrep -ni '"
			   (concat string
			       (concat "' " files))))
	    (message com)
	    (provide-prefix-argument 1 (new-compile-it com))
	)
    )
)
