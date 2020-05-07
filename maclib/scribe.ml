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
;;
;; scribe-command: prompt for command name (e.g., "itemize")
;;		and create @begin() ... @end() brackets,
;;		leaving dot between them.
    (scribe-command
	(progn sc-cmd
	    (setq sc-cmd (get-tty-string "Scribe command: "))
	    (insert-string
	    	(concat "@Begin(" sc-cmd ")")
	    )
	    (newline) 	    (newline)
	    (insert-string
	    	(concat "@End(" sc-cmd ")")	    
	    )
	    (newline)
	    (provide-prefix-argument 2 (previous-line))
	    (novalue)
	)
    )
;;
;; index-entry: make Scribe index-entry for "current" word
;;		(or n words with prefix-argument)
;;		(or n previous words with negative prefix-argument)
    (index-entry
    	(save-excursion index-word
	    (error-occured (forward-character))
	    (if (< prefix-argument 0)
		(provide-prefix-argument
		    (- 0 prefix-argument)
		    (backward-word)
		)
		(backward-word)
	    )
	    (set-mark)
	    (if (< prefix-argument 0)
	    	(provide-prefix-argument
		    (- 0 prefix-argument)
		    (forward-word)
		)
		(prefix-argument-loop (forward-word))
	    )
	    (setq index-word (region-to-string))
	    (end-of-line)
	    (newline)
	    (insert-string
	    	(concat "@Index[" index-word "]")
	    )
	    (novalue)
	)
    )
    (paren-pause dot instabs
	(setq instabs (bolp))
	(setq dot (dot))
	(insert-character (last-key-struck))
	(save-excursion
	    (backward-paren)
	    (if (dot-is-visible)
		(sit-for 5))))
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
	(local-bind-to-key "apply-look" (+ 256 'l'))
	(local-bind-to-key "index-entry" (+ 128 'i'))
	(local-bind-to-key "scribe-command" (+ 128 's'))
	(local-bind-to-key "paren-pause" ')')
	(local-bind-to-key "paren-pause" ']')
	(local-bind-to-key "paren-pause" '>')
	(local-bind-to-key "paren-pause" '}')
	(setq right-margin 63)
	(setq mode-string "Scribe")
	(setq case-fold-search 1)
	(use-syntax-table "text-mode")
	(modify-syntax-entry "w    -'")
	(modify-syntax-entry "()   (")
	(modify-syntax-entry ")(   )")
	(modify-syntax-entry "(]   [")
	(modify-syntax-entry ")[   ]")
	(modify-syntax-entry "(}   {")
	(modify-syntax-entry "){   }")
	(modify-syntax-entry "(>   <")
	(modify-syntax-entry ")<   >")
	(modify-syntax-entry """    ""'")
	(use-abbrev-table "text-mode")
	(setq left-margin 1)
	(novalue)
    )
)

(scribe-mode)
(novalue)
