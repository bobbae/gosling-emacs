;;
;; capword.ml
;;
;; capitalize first letter of current word
;;
;; Jeffrey Mogul @ Stanford		11 January 82
;;
(defun
    (capitalize-word
	(save-excursion
	    (error-occured (forward-character))
	    (backward-word)
	    (case-word-lower)
	    (set-mark)
	    (forward-character)
	    (case-region-upper)
	    (novalue)
	)
    )
)
