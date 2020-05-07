(defun    
    (apply-look go-forward
	(save-excursion c
	    (if (! (eolp)) (forward-character))
	    (setq go-forward -1)
	    (backward-word)
	    (setq c (get-tty-character))
	    (if (> c ' ')
		(progn (insert-character '@')
		    (insert-character c)
		    (insert-character '[')
		    (forward-word)
		    (setq go-forward (dot))
		    (insert-character ']')
		)
	    )
	)
	(if (= go-forward (dot)) (forward-character))
    )
)

(defun
    (scribe-mode
	(remove-all-local-bindings)
	(if (! buffer-is-modified)
	    (save-excursion
		(error-occured
		    (goto-character 2000)
		    (search-reverse "LastEditDate=""")
		    (search-forward """")
		    (set-mark)
		    (search-forward """")
		    (backward-character)
		    (delete-to-killbuffer)
		    (insert-string (current-time))
		    (setq buffer-is-modified 0)
		)
	    )
	)
	(local-bind-to-key "justify-paragraph" (+ 128 'j'))
	(local-bind-to-key "apply-look" (+ 128 'l'))
	(setq right-margin 77)
	(setq mode-string "Scribe")
	(setq case-fold-search 1)
	(use-syntax-table "text-mode")
	(modify-syntax-entry "w    -'")
	(use-abbrev-table "text-mode")
	(setq left-margin 1)
	(novalue)
    )
)

(scribe-mode)
(novalue)