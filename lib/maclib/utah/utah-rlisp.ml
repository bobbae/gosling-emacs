; local rlisp mode procedures, try to duplicate the functions on the 20 as far
; as possible.
; Written Sun Sep 20 1981 by Spencer W. Thomas
; Converted from utah-c-mode Wed Jul 14 1982 by SWT (following earlier
; 	conversion by RDF)

(defun
    (make-rlisp-standard-header author comment year filename; by SWT
				; Insert a standard program header at the
				; beginning of the buffer.  Tries to get the
				; authors name from the environment
				; variable USERNAME.
	(if (error-occured (setq author (getenv "USERNAME")))
	    (setq author (get-tty-string "Author: ")))
	(setq comment (get-tty-string "One line comment: "))
	(setq filename (current-file-name))
	(progn i j
	    (setq i (length filename))
	    (setq j 0)
	    (while (&  (> i 0)
		       (!= (substr filename i 1) "/"))
		(setq i (- i 1))
		(setq j (+ j 1))
	    )
	    (setq filename (substr filename (+ 1 i) j))
	)
	(if (bobp) (error-occured (forward-character)))
	(save-excursion
	    (beginning-of-file)
	    (save-excursion (insert-string "\n"))
	    (insert-string (concat
			       "% \n"
			       "% " filename " - " comment "\n"
			       "% \n"
			       "% Author:\t"
			       author
			       "\n% \t\tComputer Science Dept.\n"
			       "% \t\tUniversity of Utah\n"
			       "% Date:\t"))
	    (save-excursion (current-date-and-time))
	    (provide-prefix-argument 3 (forward-word))
	    (forward-character)
	    (set-mark)
	    (end-of-line)
	    (backward-word)
	    (delete-to-killbuffer)
	    (end-of-line)
	    (setq year (region-to-string))
	    (insert-string (concat "\n"
			       "% Copyright (c) " year " " author 
			       "\n%"))
	)
	(if (bobp) (end-of-file)); this only happens when file was empty
	(novalue)
    )
)

; (defun
;     (make-includes ifile cont file
; 	(if (! (interactive))
; 	    (setq cont (nargs))
; 	    (setq cont -1))
; 	(while (!= cont 0)
; 	       (setq ifile (arg 1 ": include file "))
; 	       (if (!= ifile "")
; 		   (error-occured
; 		       (while 1
; 			      (save-excursion
; 				  (temp-use-buffer "Scratch")
; 				  (erase-buffer)
; 				  (insert-string ifile " ")
; 				  (beginning-of-file)
; 				  (set-mark)
; 				  (re-search-forward ". ")
; 				  (backward-character)
; 				  (setq file (region-to-string))
; 				  (re-search-forward " *")
; 				  (erase-region)
; 				  (set-mark)
; 				  (end-of-file)
; 				  (setq ifile (region-to-string)))
; 			      (insert-string "#include\t\"" file "\"\n")))
; 		   (setq cont 1))
; 	       (setq cont (- cont 1))
; 	)
; 	(novalue)
;     )
; )

(defun
    (up-rlisp-prog-block	; by SWT
				; Rlips prog blocks delimited by <<...>>
				; moves up one level of block nesting.
				; if there was a mark stack, this should set
				; the mark, but since there isnt, it
				; doesnt
	(backward-balanced-paren-line)
	(while (& (! (bobp)) (! (looking-at "<<")))
	    (backward-balanced-paren-line))
    )

    (down-rlisp-prog-block	; by SWT
				; like up-brace, but looks for close-brace
	(up-rlisp-prog-block)
	(if (bobp)
	    (end-of-file)
	    (forward-paren))
    )
)

(defun
    (rlisp-paren c		; from CMU
				; Inserts a paren-type character, then
				; finds the matching paren, goes to it if
				; its on the screen, otherwise it just
				; shows it at the bottom of the screen.
	(setq c
	    (if prefix-argument-provided
		prefix-argument
		(last-key-struck) )  )
	(insert-character c)
	(save-excursion
	    (backward-paren)
	    (if (dot-is-visible)
		(sit-for 5)
		(progn
		    (beginning-of-line)
		    (set-mark)
		    (end-of-line)
		    (message (region-to-string)))
	    )
	)
    )

;     ; rlisp-indent not supported because "indent" only works for C code.
;     (c-indent old-dot old-begin old-size	; from CMU
; 				; Tries to find the bounds of the current C
; 				; function and filters it through indent.
; 				; A function must end with a } at the
; 				; beginning of a line for this to work.
;         (setq old-dot (dot))
; 	(save-excursion
; 	    (previous-line)
; 	    (re-search-forward "^}")
; 	    (set-mark)
; 	    (backward-paren)
; 	    (beginning-of-line)
; 	    (save-restriction
; 		(narrow-region)
; 		(setq old-size (buffer-size)))
; 	    (setq old-begin (dot))
; 	    (setq old-dot (- old-dot old-begin))
; 	    (exchange-dot-and-mark)
; 	    (end-of-line)
; 	    (forward-character)
; 	    (filter-region "indent -st")
; 	    (save-restriction
; 		(narrow-region)
; 		(goto-character (+ old-begin
; 				   (/ (* (buffer-size) old-dot) old-size)))
; 		(setq old-dot (dot)))
; 	)
; 	(goto-character old-dot)
; 	(novalue)
;     )

    (electric-<<		; from CMU, Modified by SWT
		    		; Insert a matching << >> pair, properly
				; indented and indent one level between
				; them.  Intended to be bound to M-{
				; If not at end of line, then indent
				; the current block
		(if (eolp)
		    (progn col
			(setq col (current-column))
			(insert-string "<<")
			(if (save-excursion (first-non-blank) (= col 1))
			    (C-newline)
			    (C-newline-and-indent))
			(insert-string ">>")
			(if (eobp)
			    (progn
				(insert-string "\n")
				(previous-line)))
			(previous-line)
			(end-of-line)
			(if (save-excursion (first-non-blank) (= col 1))
			    (C-newline)
			    (C-newline-and-indent))
			(indent-to-tab-stop)
		    )
		    (save-excursion Mark
			(up-rlisp-prog-block)
			(setq Mark (dot))
			(forward-paren)
			(beginning-of-line)
			(set-mark)
			(goto-character Mark)
			(next-line)
			(provide-prefix-argument prefix-argument
			    (indent-region)))
		)
    )

    (electric->>		; by SWT
				; Insert a >>, show the matching << and adjust
				; the indentation to match
	(insert-character '>')
	(provide-prefix-argument '>' (rlisp-paren))
	(if (eolp)
	    (save-excursion col
		(backward-paren)
		(save-excursion
		    (first-non-blank)
		    (setq col (current-column)))
		(forward-paren)
		(backward-character)
		(backward-character)
		(delete-white-space)
		(to-col col)))
    )

    (skip-spaces		; from CMU
				; Skip over spaces, tabs and newlines
	(forward-character)
	(while (| (| (= (following-char) ' ')
		      (= (following-char) '	'))
		   (= (following-char) 10))
	    (forward-character)
	)
    )

    (C-newline			; by SWT
				; Do newline function for rlisp mode.  If
				; dot is just before the end of a comment,
				; then do end-of-line before inserting the
				; newline.  (Note - same as C-newline.)
	(save-excursion (insert-character ' '))
	(if (looking-at (concat "[ \t]*"
				(if (= comment-end "")
				    "$"
				    (quote comment-end))))
	    (progn
		  (delete-next-character)
		  (end-of-line))
	    (delete-next-character))
	(save-excursion (insert-character '.'))
	(delete-white-space)
	(delete-next-character)
	(Newline)
    )

    (C-newline-and-indent	; by SWT
				; Do newline-and-indent function for
				; Utah rlisp mode.  Uses C-newline and
				; indent-nested to do its work.
	(C-newline)
	(provide-prefix-argument prefix-argument (indent-nested))
    )
)

(defun
    (electric-rlisp-mode	; by SWT
	(load-comment)
	(use-syntax-table "rlisp")

	(autoload "rlisp-execute" "rlisp-proc.ml") ; Rlisp in a window.
	(local-bind-to-key "rlisp-execute" "\ee")  ; meta-e
	(local-bind-to-key "rlisp-execute" "\eOM") ; vt100 KPenter = meta-e
	(if (error-occured 			   ; ^C sends char to process.
		(local-bind-to-key "send-character" "\^c"))
	    (progn 			; May have to load process stuff first.
		(load "process.ml")
		(local-bind-to-key "send-character" "\^c")
	    )
	)
	(setq associated-process "rlisp")

	(local-bind-to-key "rlisp-paren" ')')
	(local-bind-to-key "rlisp-paren" ']')
	(local-bind-to-key "electric-<<" "\e{")		; M-{
	(local-bind-to-key "electric->>" '}')
	(local-bind-to-key "tab-to-tab-stop" "\e\^I")	; M-Tab
	(local-bind-to-key "indent-nested" '^I')	; Tab
	(local-bind-to-key "dedent-to-tab-stop" "\eI")	; M-I
	(local-bind-to-key "indent-to-tab-stop" "\ei")	; M-i
	(local-bind-to-key "indent-region" "\^X\t")	; ^XTab
	(local-bind-to-key "indent-under" "\^Xi")	; ^Xi
	(local-bind-to-key "C-newline" '^M')		; Return
	(local-bind-to-key "C-newline-and-indent" '^J')	; LineFeed
	(local-bind-to-key "comment" "\e;")		; M-; 
	(local-bind-to-key "global-comment" "\^X;")
	(local-bind-to-key "delete-comment" "\^Z;")	; ^Z;
	(local-bind-to-key "next-comment" "\en")	; M-n
	(local-bind-to-key "previous-comment" "\ep")	; M-p
	(local-bind-to-key "indent-new-comment" "\e\^J")	; M-linefeed
	(local-bind-to-key "up-rlisp-prog-block" "\e\^P"); M-^P (up-arrow)
	(local-bind-to-key "down-rlisp-prog-block" "\e\^N"); M-^N (down-arrow)
	(local-bind-to-key "backward-paren" "\e(")
	(local-bind-to-key "forward-paren" "\e)")
	(error-occured 	; Fixed sequences in function keys...
	    (if (= (getenv "TERM") "vt100")
		(vt100-rlisp-keys)
	    )
	)

	(setq mode-string "rlisp")
	(setq comment-column default-comment-column)
	(setq comment-begin "% ")
	(setq comment-end "")
	(setq comment-start "%")
	(setq comment-continuation "")
	(setq tab-stops "    :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :")
	(novalue)
    )
)
(use-syntax-table "rlisp")
(modify-syntax-entry "()   (")
(modify-syntax-entry ")(   )")
(modify-syntax-entry "(>   <")
(modify-syntax-entry ")<   >")
(modify-syntax-entry "(]   [")
(modify-syntax-entry ")[   ]")
(modify-syntax-entry """    """)
;(modify-syntax-entry "\\    !")
(modify-syntax-entry "w    _!")
(novalue)
