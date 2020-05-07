; local c mode procedures, try to duplicate the functions on the 20 as far
; as possible.
; Written Sun Sep 20 1981 by Spencer W. Thomas
; modified for Purdue CS Dept. Fri Feb  5 1982 by Christopher A. Kent
; modified even more Tue Mar  2 14:50:59 1982 by CAK
; updated Mon Jun 13 16:20:30 1983 by CAK
; modified again Wed Jul 13 10:37:56 1983 by CAK

(status-line "Loading decwrl-C")
;(extend-database-search-list "describe" "/usr/jtk/emacs/databases/purdue-c")

(declare-global paren-bounce-time)
(setq-default paren-bounce-time 5)
(setq-default fancy-function-headers 0)

(defun
    (make-c-standard-header	; a useful alias
	(make-C-standard-header))

    (make-C-standard-header author comment year filename ; by SWT&CAK
				; Insert a standard C program header at the
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
			       "/* $Header$ */\n\n"
			       "/* \n"
			       " * " filename " - " comment "\n"
			       " * \n"
			       " * Author:\t"
			       author
			       "\n * \t\tDigital Equipment Corporation\n"
			       " * \t\t\Western Research Laboratory\n"
			       " * Date:\t"))
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
				   " */"
				   "\n\n/* $Log$ */\n\n"
			       (if (!= (substr (current-file-name) -2 2) ".h")
				   "static char rcs_ident[] = \"$Header$\";\n"
				   ""
			       )
			   ))
	)
	(if (bobp) (end-of-file)); this only happens when file was empty
	(novalue)
    )
)

; Insert modification notice into standard C header
; Written 17 June 1982 by Elizabeth S. Cobb
; Modified from make-c-standard-header by SWT
(defun
    (modification-notice author comment year
				; Insert modification notice in the 
				; standard header.  Tries to get the
				; authors name from the environment
				; variable USERNAME.
	(if (error-occured (setq author (getenv "USERNAME")))
	    (setq author (get-tty-string "Author: ")))
	(save-excursion
	    (beginning-of-file)
	    (search-forward "*/")
	    (beginning-of-line)
	    (newline-and-backup)
	    (insert-string " * \n"
			   " * Modified by:\t" author "\n"
			   " * \tDate:\t")
	   (save-excursion (current-date-and-time))
	   (delete-next-word)
	   (delete-next-character)
	   (provide-prefix-argument 2 (forward-word))
	   (forward-character)
	   (set-mark)
	   (end-of-line)
	   (backward-word)
	   (erase-region)
	   (beginning-of-next-line)
	   (insert-string " * ")
	   (newline-and-backup)
	   (edit-global-comment)
	)
	(novalue)
    )
)

(defun
    (make-function fn fname decls has-args has-decls
	(setq fn (arg 1 ": make-function "))
	(save-excursion
	    (temp-use-buffer "Scratch")
	    (use-syntax-table "C")
	    (erase-buffer)
	    (insert-string fn)
	    (beginning-of-file)
	    (set-mark)
	    (if (setq has-args (! (error-occured (search-forward "("))))
		(&make-fn-do-arg)
		(setq fn (concat (setq fname fn) "()"))))
	(save-excursion
	    (insert-string "\n" fn "\n"
		   (if has-decls decls "") "{\n    \n}\n"))

	(save-excursion &start-mark &end-mark
	    (setq &start-mark (dot))
	    (insert-string
    "/*****************************************************************\n")
	    (save-excursion 
		(if (! fancy-function-headers)
		    (insert-string " * TAG( " fname " )\n * \n * \n */\n")
		    (progn
			  (insert-string " * TAG( " fname " )\n * \n * \n"
			      " * Inputs:\n * \t...\n"
			      " * Outputs:\n * \t...\n"
			      " * Assumptions:\n * \t...\n"
			      " * Algorithm:\n * \t...\n"
			      " */\n")
			  (message "Use ^X. to move to next ...")))
		(setq &end-mark (dot))
	    )
	    (provide-prefix-argument 2 (next-line))
	    (end-of-line)
	    (edit-global-comment)
	    			; Get rid of unused ellipses
	    (if fancy-function-headers
		(save-restriction
		      (goto-character &end-mark)
		      (set-mark)
		      (goto-character &start-mark)
		      (narrow-region)
		      (while (! (error-occured (re-search-forward
			"^ \\*[ \t]*\\.\\.\\.\\|^ \\* [A-z]*:\n \\*[ \t]*$")))
			     (if (= (preceding-char) '.')
				 (provide-prefix-argument 3
				     (delete-previous-character)))
			     (delete-white-space)
			     (insert-string "\t[None]"))
		)
	    )
	)
	(if (! has-args)
	    (re-search-forward (concat fname " *("))
	    has-decls
	    (re-search-forward "^{\n *")
	    (re-search-forward (concat fname " *(.*\n")))
	(novalue)
    )

    (&make-fn-do-arg
	(backward-character)
	(setq fname (region-to-string))
	(save-excursion
	    (set-mark)
	    (forward-paren)
	    (backward-character)
	    (narrow-region))
	(save-excursion
	    (setq has-decls (! (error-occured (search-forward ":")))))
	(setq decls "")
	(if has-decls
	    (while (! (error-occured (search-forward ":")))
		   (re-search-reverse "\\b\\w"); start of var
		   (if (looking-at "\\(\\w*\\)[ \t]*:[ \t]*\\([^,]*\\)")
		       (progn arg decl
			      (region-around-match 1)
			      (setq arg (region-to-string))
			      (region-around-match 2)
			      (save-restriction
				   (narrow-region)
				   (beginning-of-file)
				   (if (error-occured
					     (replace-string "%" arg))
				       (if (error-occured (re-search-forward
							     "\\*\\**"))
					   (progn
						 (end-of-file)
						 (insert-string " " arg))
					   (insert-string arg)))
				   (Mark-Whole-Buffer)
				   (setq decl (region-to-string))
				   (erase-region))
			      (delete-white-space)
			      (delete-previous-character)
;			      (delete-white-space)
			      (setq decls (concat decls decl ";\n"))
		       )
		       (search-forward ":")
		   )
	    )
	    (looking-at "( *\\'")
	    (setq has-decls 1)
		  
	)
	(end-of-file)
	(widen-region)
	(forward-character)
	(if (looking-at "[ \t]*:")
	    (save-excursion i
		(delete-white-space)
		(delete-next-character)
		(delete-white-space)
		(set-mark)
		(end-of-file)
		(setq i (region-to-string))
		(erase-region)
		(beginning-of-file)
		(insert-string i "\n")))
	(Mark-Whole-Buffer)
	(setq fn (region-to-string))
    )
)

(defun
    (make-includes ifile cont file argn
	 (save-excursion
	      (if (interactive)
		  (setq cont -1)
		  (progn
			(setq cont (nargs))
			(setq argn 1))
	      )
	      (beginning-of-file)
	      (if (& (error-occured
			   (re-search-forward "rcs_ident.*\n\n*"))
		     (error-occured
			 (re-search-forward "#[ \t]*include.*\n")))
		  (error-occured (re-search-forward "^[ \t]*\\*/[ \t]*\n*"))
	      )
	      (while (looking-at "#[ \t]*include")
		     (beginning-of-next-line))
	      (while (!= cont 0)
		     (setq ifile (arg argn ": include file "))
		     (setq argn (+ argn 1))
		     (if (!= ifile "")
			 (error-occured
			       (while 1
				      (save-excursion
					   (temp-use-buffer "Scratch")
					   (erase-buffer)
					   (insert-string ifile " ")
					   (beginning-of-file)
					   (set-mark)
					   (re-search-forward ". ")
					   (backward-character)
					   (setq file (region-to-string))
					   (re-search-forward " *")
					   (erase-region)
					   (set-mark)
					   (end-of-file)
					   (setq ifile (region-to-string)))
				      (insert-string
					     "#include \"" file "\"\n")))
			 (setq cont 1))
		     (setq cont (- cont 1))
	      )
	 )
	(novalue)
    )
)

(defun
    (up-brace			; by SWT
				; moves up one level of block nesting.
				; if there was a mark stack, this should set
				; the mark, but since there isnt, it
				; doesnt
	(backward-balanced-paren-line)
	(while (& (! (bobp)) (!= (following-char) '{'))
	    (backward-balanced-paren-line))
    )
    (down-brace			; by SWT
				; like up-brace, but looks for close-brace
	(up-brace)
	(if (bobp)
	    (end-of-file)
	    (forward-paren))
    )
)
(defun
    (c-paren			; from CMU
				; Inserts a paren-type character, then
				; finds the matching paren, goes to it if
				; its on the screen, otherwise it just
				; shows it at the bottom of the screen.
	(insert-character (last-key-struck))
	(save-excursion
	    (backward-paren)
	    (if (dot-is-visible)
		(sit-for paren-bounce-time)
		(progn
		    (beginning-of-line)
		    (set-mark)
		    (end-of-line)
		    (message (region-to-string)))
	    )
	)
    )
    (c-indent old-dot old-size	; from CMU
				; Tries to find the bounds of the current C
				; function and filters it through indent.
				; A function must end with a } at the
				; beginning of a line for this to work.
        (setq old-dot (dot))
	(setq old-size (buffer-size))
	(save-excursion
	    (previous-line)
	    (re-search-forward "^}")
	    (set-mark)
	    (backward-paren)
	    (beginning-of-line)
	    (exchange-dot-and-mark)
	    (end-of-line)
	    (forward-character)
	    (filter-region "/usr/jtk/emacs/indent/indent -st")
	    (save-restriction
		(narrow-region)
		(goto-character (+ old-begin
				   (/ (* (buffer-size) old-dot) old-size)))
		(setq old-dot (dot)))
	)
	(goto-character (/ (* (buffer-size) old-dot) old-size))
	(novalue)
    )
    (electric-{			; from CMU, Modified by SWT
		    		; Insert a matching {} pair, properly
				; indented and indent one level between
				; them.  Intended to be bound to M-{
				; If not at end of line, and the preceding
				; line ends in a { then indent everything
				; between the { and the matching }.
		(if (eolp)
		    (progn col
			(setq col (current-column))
			(insert-character '{')
			(if (= col 1)
			    (C-newline)
			    (C-newline-and-indent))
			(insert-character '}')
			(if (eobp)
			    (progn
				(insert-string "\n")
				(previous-line)))
			(previous-line)
			(end-of-line)
			(if (= col 1)
			    (C-newline)
			    (C-newline-and-indent))
			(indent-to-tab-stop)
		    )
		    (save-excursion Mark
			(up-brace)
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
    (electric-}			; by SWT
				; Insert a }, show the matching { and adjust
				; the indentation to match
	(insert-character '}')
	(if (& (eolp)
	       (save-excursion
		   (set-mark)
		   (first-non-blank)
		   (= (dot) (- (mark) 1))))
	    (save-excursion col
		(backward-paren)
		(save-excursion
		    (first-non-blank)
		    (setq col (current-column)))
		(forward-paren)
		(backward-character)
		(delete-white-space)
		(to-col col)))
	(delete-previous-character)
	(c-paren)
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
				; Do newline function for Utah C mode.  If
				; dot is just before the end of a comment,
				; then do end-of-line before inserting the
				; newline.
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
				; Utah C mode.  Uses C-newline and
				; indent-nested to do its work.
	(C-newline)
	(provide-prefix-argument prefix-argument (indent-nested))
    )
)

(defun
    (decwrl-C-mode			; by CAK
	(load-comment)
	(use-syntax-table "C")
	(local-bind-to-key "c-paren" ')')
	(local-bind-to-key "c-paren" ']')
	(local-bind-to-key "electric-{" "\e{")		; M-{
	(local-bind-to-key "electric-}" '}')
	(local-bind-to-key "indent-nested" "\e\^I")	; M-Tab
	(local-bind-to-key "do-a-tab" '^I')		; Tab
	(local-bind-to-key "dedent-to-tab-stop" "\eI")	; M-I
	(local-bind-to-key "indent-to-tab-stop" "\ei")	; M-i
	(local-bind-to-key "indent-region" "\^X\t")	; ^XTab
	(local-bind-to-key "indent-under" "\^Xi")	; ^Xi
	(local-bind-to-key "C-newline" '^M')		; Return
	(local-bind-to-key "C-newline-and-indent" '^J')	; LineFeed
	(local-bind-to-key "comment" "\e;")		; M-; 
	(local-bind-to-key "global-comment" "\^X;")	; ^X-; 
	(if (! (error-occured (setq Z-prefix 1)))
	    (local-bind-to-key "delete-comment" "\^Z;") ; ^Z-; 
	)
	(local-bind-to-key "next-comment" "\en")	; M-n
	(local-bind-to-key "previous-comment" "\ep")	; M-p
	(local-bind-to-key "indent-new-comment" "\e\^J")	; M-linefeed
	(local-bind-to-key "up-brace" "\e\^P")		; M-^P (up-arrow)
	(local-bind-to-key "down-brace" "\e\^N")	; M-^N (down-arrow)
	(local-bind-to-key "backward-paren" "\e(")
	(local-bind-to-key "forward-paren" "\e)")
	(local-bind-to-key "c-indent" "\ej")			; M-j
	(setq mode-string "C")
	(setq comment-column 41)
	(setq comment-begin "/* ")
	(setq comment-end " */")
	(setq comment-start "/*")
	(setq comment-continuation " * ")
	(setq tab-stops "        :       :       :       :       :       :       :       :       :       :")
	(error-occured (_decwrl-C-mode-hook))
	(novalue)
    )
)
(use-syntax-table "C")
(modify-syntax-entry "()   (")
(modify-syntax-entry ")(   )")
(modify-syntax-entry "(}   {")
(modify-syntax-entry "){   }")
(modify-syntax-entry "(]   [")
(modify-syntax-entry ")[   ]")
(modify-syntax-entry """    '")
(modify-syntax-entry """    """)
(modify-syntax-entry "\\    \\")
(modify-syntax-entry "w    _")
(setq mode-line-format default-mode-line-format)
(novalue)
