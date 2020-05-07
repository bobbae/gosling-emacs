(defun
    (paren-pause dot instabs
	(if (eolp) (delete-white-space))
	(setq instabs (bolp))
	(setq dot (dot))
	(insert-character ')')
	(save-excursion
	    (backward-paren)
	    (if instabs (save-excursion descol
			    (setq descol (current-column))
			    (goto-character dot)
			    (to-col descol)))
	    (if (dot-is-visible)
		(sit-for 5))))
    
    (nl-indent column
	(save-excursion
	    (backward-balanced-paren-line)
	    (setq column
		(if (bolp)
		    (current-indent)
		    (+ (current-column) 4)))
	    (if (< column 5)
		(setq column 5)))
	(newline)
	(to-col column)
    )
    
    (re-indent-line
	(save-excursion column
	    (beginning-of-line)
	    (delete-white-space)
	    (save-excursion
		(if (= (following-char) ')')
		    (progn
			(forward-character)
			(backward-paren)
			(setq column (current-column))
		    )
		    (progn
			(backward-character)
			(backward-balanced-paren-line)
			(setq column
			    (if (bolp)
				(current-indent)
				(+ (current-column) 4)))
			(if (< column 5)
			    (setq column 5))
		    )
		)
	    )
	    (to-col column)
	)
    )
    
    (indent-lisp-function
	(save-excursion
	    (if (error-occured (end-of-line) (search-reverse "(def"))
		(error-message "Can't find function"))
	    (set-mark)
;	    (forward-character)
	    (forward-paren)
	    (exchange-dot-and-mark)
	    (delete-white-space)
	    (beginning-of-line)
	    (next-line)
	    (while (& (! (eobp)) (<= (dot) (mark)))
		(re-indent-line)
		(next-line)
	    )
	)
	(message "Done!")
    )
    
    (electric-lisp-semi
	(end-of-line)
	(move-to-comment-column)
	(setq left-margin (current-column))
	(setq right-margin 77)
	(setq prefix-string "; ")
	(insert-string "; ")
    )
    
    (electric-lisp-mode
	;	(local-bind-to-key "expand-mlisp-word" '`')
	;	(local-bind-to-key "execute-mlisp-buffer" (+ 128 'c'))
	(local-bind-to-key "electric-lisp-semi" ';')
	(local-bind-to-key "paren-pause" ')')
	(local-bind-to-key "forward-sexpr" (+ 128 ')'))
	(local-bind-to-key "backward-sexpr" (+ 128 '('))
	(local-bind-to-key "indent-lisp-function" (+ 128 'j'))
	(local-bind-to-key "nl-indent" 10)
	(local-bind-to-key "re-indent-line" (+ 128 'i'))
	(local-bind-to-key "pop-back" (+ 128 'g'))
	(local-bind-to-key "zap-defun" (+ 256 '^l'))
	(setq mode-string "lisp")
	(use-abbrev-table "lisp")
	(use-syntax-table "lisp")
    )
    
    (pop-back
	(write-modified-files)
	(pause-emacs)
    )

    (forward-sexpr
	(search-forward "(")
	(forward-paren)
    )

    (backward-sexpr
	(search-reverse ")")
	(backward-paren)
    )
)
(defun
    (zap-defun
	(save-excursion
	    (end-of-line)
	    (search-reverse "(def")
	    (set-mark)
	    (forward-paren)
	    (end-of-line)
	    (forward-character)
	    (region-to-process "lisp")
	)
	(pop-to-buffer "lisp")
	(end-of-file)
    )
)
(use-syntax-table "lisp")
(modify-syntax-entry "()   (")
(modify-syntax-entry ")(   )")
(modify-syntax-entry """    |")
(modify-syntax-entry """    """)
(modify-syntax-entry "\    \")
(modify-syntax-entry "w    -+!$%^&=_~:/?*<>")
(electric-lisp-mode)
