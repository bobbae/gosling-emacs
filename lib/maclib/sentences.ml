(if (! (is-bound sentence-delimiters))
    (progn
	(declare-global sentence-delimiters)
	(setq sentence-delimiters "[.!?][ \n\t][ \n\t]*")
    ))

(defun (forward-sentence
	   (re-search-forward sentence-delimiters)
	   (while (looking-at "")
	       (search-forward "")))
)

(defun (backward-sentence stpos searchp
	   (setq stpos (dot))
	   (preceding-char)
	   (if (error-occured (re-search-reverse sentence-delimiters))
	       (beginning-of-file))
	   (setq searchp (dot))
	   (while (looking-at "")
	       (search-forward ""))
	   (if (>= (dot) stpos)
	       (progn
		   (goto-character searchp)
		   (if (error-occured (re-search-reverse ""))
		       (beginning-of-file))
		   (while (looking-at "")
		       (search-forward "")))
	   )
       )
)
