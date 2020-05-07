; $Header: RCS/utah-init.ml,v 1.3 83/05/31 11:13:42 thomas Exp $
; $Log:	RCS/utah-init.ml,v $
; Revision 1.3  83/05/31  11:13:42  thomas
; Fix the files-should-end-with-newline code in ^X^S.
; 
(progn mode-line
(declare-global &Small-Window-Size) (setq &Small-Window-Size 6)
;(setq mode-line-format "Loading Libraries") (sit-for 0)
(load "transpose")	(load "inc-s")
(load "buff")		(load "newcompile")
(load "tabs")			; Lots of goodies
(load "glob")			; filename/variable expansion package
(load "case-char")		; single-char case shifts.
(load "long-files")		; file name matching
(load "rmail")			; mail package
;(load "info")			; info package


(defun
    
    (Set &var			; by SWT
				; set + declare-global
	(setq &var (arg 1 ": Set "))
	(execute-mlisp-line (concat "(declare-global " &var ")"))
	(set &var (arg 2 (concat ": Set " &var " to ")))
    )
	
    (Not-modified    		; by SWT
	; Reset buffer-is-modified flag
	(setq buffer-is-modified 0)
	(message "Buffer not modified")
    )

    (insert-variable cmd
	(setq cmd (concat "(insert-string " (arg 1 ": insert-variable ") ")"))
	(execute-mlisp-line cmd)
    )
    
    (beginning-of-next-line	; definitely useful
	(next-line)
	(if (eobp) (insert-character '\n'))
	(beginning-of-line))

    (first-non-blank				 ; a useful function
	(beginning-of-line)
	(while (| (= (following-char) 32)	 ; space
		   (= (following-char) 9))	 ; tab
	    (forward-character)
	)
	(current-column)			 ; returned for convience
    )
    
    (buffer-stats				 ; whizzzz - Bang 
	(message (concat
		     (if (!= (buffer-size) 0)
			 (concat
			     "Dot: " (+ 0 (dot))
			     ", Buffer-size: " (buffer-size)
			     ", percent-of-file: "
			     (/ (* (dot) 100) (buffer-size)))
			 "EMPTY")
		     (if buffer-is-modified ", unsaved" "")))
    )
    
    (current-date-and-time			 ; useful if bound to a key
	(insert-string (current-time))
    )
    
    (skip-forward-matching char			 ; originally in electric-lisp
	(setq char (following-char))
	(forward-character)
	(while (!= (following-char) char)
	    (forward-character)
	)
	(forward-character)
    )    
    
    (skip-backward-matching char		 ; originally in electric-lisp
	(setq char (following-char))
	(backward-character)
	(while (!= (following-char) char)
	    (backward-character)
	)
    ) 
    
    (confirm sureness
	(setq sureness (get-tty-no-blanks-input (arg 1 ": confirm ") ""))
	(if (& (!= (substr sureness 1 1) "y")
	       (!= (substr sureness 1 1) "Y"))
	    (error-message "Aborted.")))
    
    (load-current-file
	(if (= (current-file-name) "")
	    (error-message "No file named for this buffer!")
	)
	(if buffer-is-modified
	    (confirm "Buffer is modified, are you sure?"))
	
	(progn (message (concat "loading " (current-file-name)))
	    (sit-for 0)			 ; cause re-display
	    (load (current-file-name))
	    (message (concat "loaded " (current-file-name)))
	)
    )
    
    (split-window-small foo
	(save-excursion
	    (split-current-window)
	    (error-occured
		(while 1 (shrink-window)))
	    (if (= prefix-argument 1)
		(setq foo (- &Small-Window-Size 1))
		(setq foo prefix-argument))
	    (error-occured
		(while (> foo 0)
		    (enlarge-window)
		    (setq foo (- foo 1))))
	    (progn)))
    
    
    (No-Exit
	(error-message
	    "Due to screw ups ^C and ESC-^C have been disabled."))
    
    ; Change the name of the current file and buffer.
    (set-visited-filename newname
	(if (& (interactive) match/recognize)
	    (setq newname (recognize "New file name: "))
	    (setq newname (Expand-file-name
			      (arg 1 ": set-visited-filename "))))
	(change-file-name newname)
	(if (!= newname "")
	    (progn pos
		  (while (!= (setq pos (string-index newname '/')) 0)
			 (setq newname
			       (substr newname (+ pos 1) (length newname))))
		  (if (!= (current-buffer-name) newname)
		      (if (error-occured (change-buffer-name newname))
			  (progn i
				 (setq newname (concat newname "<2>"))
				 (setq i 2)
				 (while (error-occured
					    (change-buffer-name newname))
					(setq i (+ i 1))
					(setq newname
					      (concat
						     (substr newname 1 -3)
						     "<" i ">"))
				 )
			  )
		      )
		  )
	    )
	)
	(novalue)
    )

    ; like write-current-file, but doesn't do it if it doesn't have to.
    (Write-current-file
	(if buffer-is-modified
	    (progn
		  (error-occured	; Check for newline at end of buffer.
		      (save-excursion
			  (end-of-file)
			  (if (& (!= (preceding-char) '\n')
				 (>= files-should-end-with-newline 0))
			      (progn
				    (if (= files-should-end-with-newline 0)
					(confirm
					  (concat (current-buffer-name)
						  " doesn't end with a newline"
						  ", should I add one?")))
				    (insert-character '\n'))
			  )
		      )
		  )
		  (write-current-file)
		  (message (concat "Written: "
				   (current-file-name))))
	    (message "No changes need be written."))
    )
    
    (split-window-buffer buf	; split the current window and ask for
				; a buffer to put in the new half
	(setq buf (get-tty-buffer "Buffer: " ""))
	(split-current-window)
	(use-old-buffer buf)
    )
	
    ; this allows revert-file to get you the last thing you executed!
    (execute-mini-buffer
	(write-current-file)
	(execute-mlisp-buffer))
    
    ;;; A Mini Buffer.
    (Mini-Buffer
	(split-window-small)
	(switch-to-buffer "mini")
	(write-named-file (concat "/tmp/minibuf_" (users-login-name)))
	(electric-mlisp-mode)
	(local-bind-to-key "execute-mini-buffer" "\e\e")
	(setq mode-line-format
 "%[Mini Buffer -- Dangerous and Experimental MLisp Code is Resident%]")
	(progn)
    )
    
    (Mark-Whole-Buffer
	(beginning-of-file) (set-mark) (end-of-file))
    
    (Copy-region-to-kill-buffer
	(copy-region-to-buffer "Kill buffer")
	(message "Region -> Kill buffer"))
    
    (Next-Page doit
	(if (< prefix-argument 0)
	    (provide-prefix-argument prefix-argument (next-page))
	    (prefix-argument-loop
		(save-excursion
		    (end-of-window)
		    (if (! (eobp))
			(setq doit 1)))
		(if doit
		    (next-page)
		    (end-of-window)))))
    

    (Newline
	(prefix-argument-loop
	    (insert-character ' ')
	    (delete-previous-character)
	    ;;; Cause expansion of abbrevs!
	    (if (!= (following-char) 10)
		(insert-character 10)
		(progn
		    (forward-character)
		    (if (! (looking-at "\n\n"))
			(progn
			    (insert-character 10)
			    (backward-character))))))
    )

    (join-lines			; by SWT
				; Joins the current line with the one above.
				; Leaves dot between the 'lines'.  Always
				; leaves a space.
	(beginning-of-line)
	(if prefix-argument-provided (next-line))
	(if (! (bobp))
	    (progn
		(delete-previous-character)
		(delete-white-space)
		(insert-character ' ')))
    )

    (same-window-visit-file &pop-up
	(setq &pop-up pop-up-windows)
	(error-occured
	    (setq pop-up-windows 0)
	    (visit-file (arg 1 "Visit file: "))
	)
	(setq pop-up-windows &pop-up)
    )
    
    (cd
	(glob-cd (arg 1 "Change to directory ")))

    (pwd cwd
	(setq cwd (working-directory))
	(message (concat
		     ": pwd => "
		     (if (= (substr cwd -1 1) "/")
			 (substr cwd 1 -1)
			 cwd)))
	(novalue))
    
    (Pop-level			; written by SWT
	; If in a recursive emacs, then exit, else
	; if at top level, do Pause
	(if (= (recursion-depth) 0)
	    (Pause)
	    (exit-emacs))
    )
    
    ; save screen layout for return by pop-level.
    (push-level
	(save-window-excursion (recursive-edit))
    )

    (Pause			; written by SWT
	; Pause emacs, printing working dir upon
	; restart.
	(progn stopped-time
	    (if (> (process-status "newtime") 0)
		(progn
		      
		    (stop-process "newtime")
		    
		    (setq stopped-time 1))
		(setq stopped-time 0))
	    (pause-emacs)
	    (if stopped-time
		(continue-process "newtime"))
	    (message (concat "Now connected to " (working-directory)))
	)
    )
    
    (grep string files com
	(progn
	    (setq string (arg 1 ": grep (string) '"))
	    (setq files (arg 2 (concat
				   (concat ": grep (string) '" string)
				   "' (files) ")))
	    (setq com  (concat "jagrep -n '"
			   (concat string
			       (concat "' " files))))
	    (message com)
	    (provide-prefix-argument 1 (new-compile-it com))
	)
    )

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
    
    (Doc foo char		; written by Spencer W. Thomas
	; Invokes various documentation functions
	(progn
	    (setq foo 1)
	    (message "Doc (? for help) ")
	    (while foo
		(setq char (get-tty-character))
		(setq foo 0)	; assume good char
		(if (= char '^G') (error-message "Aborted")

		    (c= char 'a')
		    (apropos (arg 1 "Apropos: "))

		    (c= char 'c')
		    (describe-command (get-tty-command "Describe command: "))

		    (c= char 'd')
		    (describe-variable
			(get-tty-variable "Describe variable: "))

		    (c= char 'v')
		    (variable-apropos
			(get-tty-no-blanks-input "Variable apropos: " ""))

		    (progn	; this is the none-of-the-above case
			(if (!= char '?')
			    (send-string-to-terminal "\^G"))
			(message "Apropos, Command, Describe-var or Var-apropos.  Doc (? for help): ")
			(setq foo 1)
		    )
		)
	    )
	    (progn)
	)
    )

    (extend-describe		; SWT
				; extend the database list for
				; describe-word-in-buffer.  Does filename
				; expansion.
	(extend-database-search-list "subr-names"
	    (expand-file-name (arg 1 ": extend-describe (file name) ")))
    )

    (Expand-file-name name	; SWT
				; do filename expansion, also looking up
				; environment variables and Emacs variables
				; if the name begins with a $.  Finally,
				; let glob handle it.
	(setq name (arg 1 ": Expand-file-name "))
	(error-occured
	    (while (= (substr name 1 1) "$")
		(progn i var
		    (setq i 2)
		    (while (& (<= i (length name))
			       (!= (substr name i 1) "/"))
			(setq i (+ i 1)))
		    (setq var (substr name 2 (- i 2)))
		    (setq name
			(concat
			    (if (! (error-occured (getenv var)))
				(getenv var)
				(execute-mlisp-line var))
			    (substr name i 1000))))
	    )
	)
	(glob name)
    )

    (revert-file dot
	(setq dot (+ 0 (dot)))
	(if buffer-is-modified
	    (confirm "File is modified, revert from disk? "))
	(read-file (current-file-name))
	(goto-character dot)
	(novalue)
    )

    (Transpose-characters
	(if (bolp)
	    (forward-character))
	(if (! (| (eolp) (eobp)))
	    (forward-character))
	(transpose-characters))

    (Transpose-word
	(if (bobp)
	    (forward-word))
	(if (! (eobp))
	    (forward-word))
	(transpose-word))
)

; Pour a balanced expression in a buffer into the Mlisp.
; With prefix arg, executes it at the meta-mark and resets meta-mark.
(defun
    (execute-mlisp-expr mark value
	(save-excursion
	    (setq mark (dot))
	    (set-mark)
	    (forward-paren)	; Go to end of expr.
	    (if prefix-argument-provided
		(setq mark meta-mark))
	    (copy-region-to-buffer "&temp-code&")
	    (temp-use-buffer "&temp-code&")
	    (beginning-of-file)
	    (insert-string
		"(progn\n"
		"    (pop-to-buffer mark)\n"
		"    (goto-character mark)\n"
		"    (error-occured\n"
		"	(setq value\n")
	    (end-of-file)
	    (insert-string
		"\n	))\n"
		"    (setq mark (dot))\n"
		")\n")
	    (setq value "No value.")
	    (execute-mlisp-buffer)
	    (if prefix-argument-provided
		(setq meta-mark mark))
	)
	(message value)
	(novalue)
    )
)

; Set meta-mark for execute-mlisp-expr.
; With prefix argument, goes to the meta-mark instead.
(defun
    (meta-mark
	(if prefix-argument-provided
	    (progn
		  (pop-to-buffer meta-mark)
		  (goto-character meta-mark)
	    )
	    (progn 
		   (setq meta-mark (dot))
		   (message "meta-mark at " meta-mark " " (+ 0 meta-mark))
	    )
	)
    )
)
(declare-global meta-mark)

(set "ask-about-buffer-names" 0)
(set "backup-before-writing" 1)
(set "checkpoint-frequency" 500)
(set "ctlchar" 1)
(set "default-case-fold-search" 1)
(set "help-on-comm" 0)
(set "quick-redisplay" 1)
(set "replace-case" 1)	; do fancy case substitution
(set "silently-kill-processes" 1)
(setq default-mode-line-format "%[ %M %b: %*   (%m)   %p %]")
(set "track-eol" 0)
(set "wrap-long-lines" 1)
(set "visible-bell" 1)
(autoload "buffer-menu" "buff-menu")
(autoload "calendar" "calendar")
(autoload "load-comment" "comment")
(autoload "compare-windows" "comp-wind")
(autoload "dabbrevs-help" "dabbrevs")
(autoload "dabbrevs-expand" "dabbrevs")
(autoload "dired" "dired")
(autoload "electric-lisp-mode" "electric-lisp")
(autoload "electric-mlisp-mode" "electric-lisp")
(autoload "flush-lines" "flush")
(autoload "keep-lines" "flush")
(autoload "Count-Lines-In-Region" "gotos")
(autoload "find-line" "gotos")
(autoload "goto-line" "gotos")
(autoload "goto-percentage-of-file" "gotos")
(autoload "inc-re-forward-top-level" "inc-rs")
(autoload "inc-re-reverse-top-level" "inc-rs")
(autoload "info" "info")
(autoload "*more*" "more")
(autoload "view-buffer" "more")
(autoload "Occurances" "occur")
(autoload "push-to-csh" "process")
(autoload "csh" "process")
(autoload "new-shell" "process")
(autoload "rnews" "rnews")
(autoload "scribe-mode" "scribe")
(autoload "squeeze-mlisp-file" "squeeze")
(autoload "goto-tag" "tags")
(autoload "visit-function" "tags")
(autoload "visit-tag-table" "tags")
(autoload "teach-emacs" "teach-emacs")
(autoload "time" "time")
(autoload "new-undo" "undo")
(autoload "utah-c-mode" "utah-c-mode")
(autoload "electric-rlisp-mode" "utah-rlisp")
(autoload "write-region-to-file" "writeregion")
(bind-to-key "dabbrevs-expand" "\e ")		; meta-space
;;;(bind-to-key "set-mark" "\e ")			; meta-space
(bind-to-key "Doc" 31)				 ; ^_
(bind-to-key "goto-tag" "\e.")			 ; M-.
(bind-to-key "expand-filespec" "\^z$")
(bind-to-key "push-level" "\e@")		 ; meta-@
(bind-to-key "meta-mark" "\e\^@")	; C-M-@ on Telerays.
(bind-to-key "push-to-csh" "\e#")		 ; meta-#
(bind-to-key "query-replace-string" "\e%")	 ; meta-%
(bind-to-key "re-query-replace-string" "\^Z%")   ; ^Z%
(bind-to-key "describe-key" "\e/")		 ; M-/
(bind-to-key "describe-command" "\^X/")		 ; ^X/
(bind-to-key "beginning-of-window" "\^x<")
(bind-to-key "print" "\e=")			 ; ESC-=
(bind-to-key "end-of-window" "\^x>")
(bind-to-key "delete-white-space" "\e\\")	 ; M-\
(bind-to-key "Not-modified" "\e~")		 ; M-~
(bind-to-key "join-lines" "\e^")		 ; M-^
(bind-to-key "enlarge-window" "\^X^")		 ; ^X^
(bind-to-key "execute-mlisp-expr" "\^^")	; C-` on Telerays.
(bind-to-key "delete-window" "\^X0")		 ; ^X0
(bind-to-key "split-window-buffer" "\^X4")
(bind-to-key "define-local-abbrev" "\^X\^A")	 ; ^X^A
(bind-to-key "backward-word" "\e\^B")		 ; M-^B
(bind-to-key "one-line-buffer-list" "\^XB")	 ; ^XB
(bind-to-key "buffer-menu" "\^X\^b")		 ; ^X^B
(bind-to-key "switch-to-buffer" "\^Xb")		 ; ^Xb
(bind-to-key "No-Exit" '^C')			 ; ^C
(bind-to-key "No-Exit" "\e\^C")			 ; ESC-^C
(bind-to-key "Pop-level" (+ 256 3))		 ; ^X^C
(bind-to-key "case-word-capitalize" "\ec")	 ; Meta-c
(bind-to-key "compare-windows" "\^xc")
(bind-to-key "case-char-lower" "\eL")		 ; Meta-Shift-l
(bind-to-key "case-char-upper" "\eU")		 ; Meta-Shift-u
(bind-to-key "case-char-upper" "\eC")		 ; Meta-Shift-c
(bind-to-key "current-date-and-time" "\e\")	 ; ESC-^D
(bind-to-key "forward-word" "\e\^F")		 ; M-^F
;(bind-to-key "visit-file" "\^X\^F")		 ; ^X^F
(bind-to-key "find-line" "\eG")		 	 ; ESC-G
(bind-to-key "goto-line" "\eg")			 ; ESC-g
(bind-to-key "backward-character" '^H')		 ; ^H
(bind-to-key "backward-word" "\e\^H")		 ; M-^H
(bind-to-key "Mark-Whole-Buffer" "\^Xh")	 ; ^Xh
(bind-to-key "indent-line" "\ei")		 ; ESC-i
(bind-to-key "dedent-line" "\eI")		 ; ESC-I
(bind-to-key "info" "\^XI")			 ; ^XI
(bind-to-key "delete-buffer" "\^Xk")
(bind-to-key "load-current-file" "\^XL")	 ; ^XL
(bind-to-key "load-current-file" "\^Xl")	 ; ^Xl
(bind-to-key "*more*" "\eM")			 ; ESC-M
(bind-to-key "smail" "\^Xm")			 ; ^Xm
(bind-to-key "Mini-Buffer" "\^XM")		 ; ^XM
(bind-to-key "Newline" '^M')			 ; ^M
(bind-to-key "first-non-blank" "\e\^M")	 ; meta-return
(bind-to-key "narrow-region" "\^xN")
(bind-to-key "Occurances" "\eO")		 ; ESC-O
(bind-to-key "Occurances" "\eo")		 ; ESC-o
(bind-to-key "next-window" "\^Xo")		 ; ^Xo
(bind-to-key "justify-paragraph" "\eq")
(bind-to-key "inc-reverse-top-level" '^R')	 ; ^R
(bind-to-key "inc-re-reverse-top-level" "\e\^R"))	 ; ESC-^R
;(bind-to-key "read-file" "\^X\^R")		 ; ^X^R
(bind-to-key "rmail" "\^Xr")			 ; ^Xr
(bind-to-key "buffer-stats" "\es")		 ; ESC-s
(bind-to-key "buffer-stats" "\eS")		 ; ESC-S
(bind-to-key "inc-forward-top-level" '^S')	 ; ^S
(bind-to-key "inc-re-forward-top-level" "\e\^S")	 ; M-^S
(bind-to-key "Write-current-file" "\^X\^S")	 ; ^X^S
(bind-to-key "Transpose-character" '^T')	 ; ^T
(bind-to-key "Transpose-word" "\et")		 ; ESC-t
(bind-to-key "transpose-word" "\eT")		 ; ESC-T
(bind-to-key "transpose-line" "\^X\^T")		 ; ^X^T
(bind-to-key "new-undo" "\^X\^U")		 ; ^X^U
(bind-to-key "view-buffer" "\^XV")		 ; ^XV
(bind-to-key "view-buffer" "\^Xv")		 ; ^Xv
;(bind-to-key "same-window-visit-file" "\^X\^v")  ; ^X^V
(bind-to-key "Next-Page" '^V')			 ; ^V
(bind-to-key "visit-function" "\^Z\^V")		 ; ^Z^V
(bind-to-key "Copy-region-to-kill-buffer" "\ew") ; M-w
(bind-to-key "copy-region-to-buffer" "\^Z\^W")   ; ^Z^W
(bind-to-key "widen-region" "\^xw")
(bind-to-key "widen-region" "\^xW")
(bind-to-key "Pop-level" "\e\^Z")		 ; M-^Z
(bind-to-key "Pause" "\^X\^Z")			 ; ^X^Z
(bind-to-key "Pop-level" "\^Z\^Z")		 ; ^Z^Z
(bind-to-key "scroll-one-line-up" "\eZ")
(bind-to-key "delete-previous-word" "\e\177")	; M-rubout
(auto-execute "scribe-mode" "*.mss")
(auto-execute "utah-c-mode" "*.c")
(auto-execute "utah-c-mode" "*.h")
(auto-execute "utah-c-mode" "*.y")
(auto-execute "utah-c-mode" "*.l")
(auto-execute "utah-c-mode" "*.str")
(auto-execute "text-mode" "/tmp/*")
(auto-execute "electric-mlisp-mode" "*.emacs_pro")
(auto-execute "electric-lisp-mode" "*.abbrevs")
(auto-execute "electric-mlisp-mode" "*.ml")
(auto-execute "electric-rlisp-mode" "*.sl")
(auto-execute "electric-rlisp-mode" "*.lap")
(auto-execute "electric-rlisp-mode" "*.build")
(auto-execute "electric-rlisp-mode" "*.r")
(auto-execute "electric-rlisp-mode" "*.red")
(auto-execute "electric-rlisp-mode" "*.sl")
(auto-execute "electric-rlisp-mode" "*.lap")
(auto-execute "electric-rlisp-mode" "*.build")
(quietly-read-abbrev-file "~/.abbrevs")

(save-excursion
    (temp-use-buffer "  Minibuf")
    (define-keymap "Minibuf-esc-map")
    (define-keymap "Minibuf-^X-map")
    (define-keymap "Minibuf-^Z-map")
    (use-local-map "Minibuf-local-NS-map")
    (local-bind-to-key "Minibuf-esc-map" "\e")
    (local-bind-to-key "Minibuf-^X-map" "\^X")
    (local-bind-to-key "Minibuf-^Z-map" "\^Z")
    (local-bind-to-key "exit-emacs" "\e\e"); double escape exits minibuf
    (local-bind-to-key "expand-mlisp-word" "\e$")
    (local-bind-to-key "expand-mlisp-variable" "\^X$")
    (local-bind-to-key "backward-paren" "\e(")
    (local-bind-to-key "forward-paren" "\e)")
    (use-local-map "Minibuf-local-map")
    (local-bind-to-key "Minibuf-esc-map" "\e")
    (local-bind-to-key "Minibuf-^X-map" "\^X")
    (local-bind-to-key "Minibuf-^Z-map" "\^Z")
    (use-syntax-table "Minibuf")
    (modify-syntax-entry "w    -_")
    (modify-syntax-entry "()   (")
    (modify-syntax-entry ")(   )")
    (modify-syntax-entry "w    ~")
)
;(setq mode-line-format "Loading Files") (sit-for 0)
(setq mode-line-format default-mode-line-format)
)

