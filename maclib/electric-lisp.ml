; History
;    8/19/86  removed reference to first-non-blank in re-indent-line
;                Roger Crew (RFC)
;
;    ?/??/??  (SWT) made a bunch of changes

; This function gets bound to ')' -- it flashes to the corresponding
; '(' and fixes the indentation of the ')'.
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
		(sit-for 5)
		(progn
		      (beginning-of-line)
		      (set-mark)
		      (end-of-line)
		      (message (region-to-string))
		)
	    )
	)
    )
    (electric-mlisp-close
	(save-excursion
	    (insert-character '.')
	    (backward-character)
	    (delete-white-space)
	    (delete-next-character)
	)
    	(paren-pause)
    )
)

; This function gets bound to linefeed, it inserts a newline and
; properly indents the next line.
; (SWT) Deletes white space at the end of the line.
(defun
    (nl-indent column
	(save-excursion
	    (insert-string ".")	; SWT
	    (backward-character)
	    (delete-white-space)
	    (delete-next-character); SWT
	    (backward-balanced-paren-line)
	    (setq column
		  (if (bolp)
		      (current-indent)
		      (progn lim here
			     (setq lim (+ (current-column) 8))
			     (error-occured (re-search-forward "([ \t]*\\w*[ \t]*"))
			     (if (> (setq here (current-column)) lim)
				 (- lim 4)
				 here))))
	    (if (< column 5)
		(setq column 5)))
	(newline)
	(to-col column)
    )
)

; This function repairs the indentation of the current line.
(defun    
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
		    (| (looking-at "else") (looking-at "then"))
		    (progn
			  (insert-character ')')
			  (set-mark)
			  (backward-paren)
			  (setq column (+ (current-column) 1))
			  (exchange-dot-and-mark)
			  (delete-previous-character)
		    )
		    (progn
			  (backward-character)
			  (backward-balanced-paren-line)
			  (setq column
				(if (bolp)
				    (if (| (looking-at "[ \t]*else")
					   (looking-at "[ \t]*then"))
					(+ (current-indent) 3)
					(current-indent)
				    )
				    (progn lim here
					   (setq lim (+ (current-column) 8))
					   (error-occured (re-search-forward "([ \t]*\\w*[ \t]*"))
					   (if (> (setq here (current-column)) lim)
					       (- lim 4)
					       here))))
			  (if (< column 5)
			      (setq column 5))
		    )
		)
	    )
	    (to-col column)
	)
	(if (bolp)
	    (while (| (= (following-char) ' ')
		      (= (following-char) '\t'))
		   (forward-character)
	    )
	); (SWT) otherwise it''s a pain
	 ; (RFC) fine, but don''t use "first-non-blank"
    )
)

; this function fixes up the indentation of
; an entire lisp function: (defXX to )
(defun
    (indent-lisp-function
	 (save-excursion
	      (if (error-occured (end-of-line) (re-search-reverse "^(def"))
		  (error-message "Can't find function"))
	      (set-mark)
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
)

(defun
    (semi-electric-lisp
	 (if (eolp)
	     (progn (if (! (bolp)) (to-col comment-column))
		    (setq left-margin comment-column)
		    (setq right-margin 77)
		    (setq prefix-string "; ")
		    (insert-string "; "))
	     (insert-character ';'))
    )
)

(defun    
    (electric-lisp-mode		; electric-lisp mode initialization
	(remove-all-local-bindings)
	(local-bind-to-key "semi-electric-lisp" ";")
	(local-bind-to-key "paren-pause" ")")
	(local-bind-to-key "forward-paren" "\e)")
	(local-bind-to-key "backward-paren" "\e(")
	(local-bind-to-key "indent-lisp-function" "\ej")
	(local-bind-to-key "nl-indent" 10)
	(local-bind-to-key "re-indent-line" "\ei")
	(local-bind-to-key "zap-defun" "\^X\^L")
	(setq mode-string "lisp")
	(use-abbrev-table "lisp")
	(use-syntax-table "lisp")
	(novalue)
    )

    (ml-paren
	(if (& (!= (preceding-char) '\'')
	       (!= (preceding-char) '"')
	       (!= (preceding-char) '\\'; '
	       ))
	    (progn
		  (insert-character '(')
		  (if (error-occured (insert-string (get-tty-command "  (")))
		      (delete-previous-character)
		      (insert-character ' '))
		  (novalue))
	    (insert-character '('))
    )

    (electric-mlisp-mode	; electric-mlisp mode initialization
	(remove-all-local-bindings)
	(local-bind-to-key "ml-paren" "(")
	(local-bind-to-key "expand-mlisp-word" "\e$")
	(local-bind-to-key "expand-mlisp-variable" "\^X$")
	(local-bind-to-key "semi-electric-lisp" ";")
	(local-bind-to-key "electric-mlisp-close" ")")
	(local-bind-to-key "forward-paren" "\e)")
	(local-bind-to-key "backward-paren" "\e(")
	(local-bind-to-key "up-paren" "\e\^P")
	(local-bind-to-key "down-paren" "\e\^N")
	(local-bind-to-key "indent-lisp-function" "\ej")
	(local-bind-to-key "nl-indent" 10)
	(local-bind-to-key "re-indent-line" "\ei")
	(local-bind-to-key "re-indent-line" "\^i")
	(local-bind-to-key "self-insert" "\e\^i")
	(setq mode-string "mlisp")
	(use-abbrev-table "mlisp")
	(use-syntax-table "mlisp")
	(novalue)
    )


    (forward-sexpr
	(search-forward "(")
	(backward-character)
	(forward-paren)
    )

    (backward-sexpr
	(search-reverse ")")
	(forward-character)
	(backward-paren)
    )

    (up-paren
	(backward-balanced-paren-line)
	(while (& (!= (following-char) '(')
		   (! (bobp)))
	    (backward-balanced-paren-line))
    )

    (down-paren
	(up-paren)
	(if (bobp)
	    (end-of-file)
	    (forward-paren))
    )

    (zap-defun			; take the current "(defXX" to ")" region and
				; stuff it as input to the "lisp" process
				; then whip into the lisp buffer to interact.
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
(modify-syntax-entry "\\    \\")
(modify-syntax-entry "w    -+!$%^&=_~:/?*<>")
(use-syntax-table "mlisp")
(modify-syntax-entry "()   (")
(modify-syntax-entry ")(   )")
(modify-syntax-entry "\"    '")
(modify-syntax-entry "\"    \"")
(modify-syntax-entry "\\    \\")
(modify-syntax-entry "w    -+!$%^&=_~:/?*<>|a-zA-Z0-9")
(novalue)
