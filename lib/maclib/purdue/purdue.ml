; (extend-database-search-list "describe" "/usr/jtk/emacs/databases/describe")
(defun  
    (status-line
	(if (! (error-occured (setq status-line 1)))
	    (progn
		(setq mode-line-format (arg 1))
		(sit-for 0)
	    )
	)
    )
)
(declare-global &Small-Window-Size) (setq &Small-Window-Size 6)
(status-line "Loading Libraries")
(load "newcompile.ml")
(load "utah/transpose.ml")	
(load "utah/gotos.ml")
(load "utah/comment.ml")
(load "local/tabs.ml")		; Lots of goodies
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
    
    (beginning-of-next-line	; definitely useful
	(next-line)
	(beginning-of-line))
    (first-non-blank				 ; a useful function
	(beginning-of-line)
	(while (| (= (following-char) 32)	 ; space
		   (= (following-char) 9))	 ; tab
	    (forward-character)
	)
	(current-column)			 ; returned for convience
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
    
    
    (load-current-file
	(if (= (current-file-name) "")
	    (error-message "No file named for this buffer!"))
	(if buffer-is-modified (write-current-file))
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
	    "Due to screw ups ^C and M-^C have been disabled."))
    
    ; like write-current-file, but doesn't do it if it doesn't have to.
    (Write-current-file
	(if buffer-is-modified
	    (progn
		(write-current-file)
		(message (concat "Written: "
			     (current-file-name))))
	    (message "No changes need be written.")))
    
    
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
	(local-bind-to-key "execute-mini-buffer" (+ 128 ''))
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
	(if (! (bobp))
	    (progn
		(delete-previous-character)
		(delete-white-space)
		(insert-character ' ')))
    )
    (same-window-visit-file pop-up
	(setq pop-up pop-up-windows)
	(setq pop-up-windows 0)
	(visit-file (arg 1 "Visit file: "))
	(setq pop-up-windows pop-up)
    )
    
    (cd dir i			; written by Spencer W. Thomas
	; Change to directory, recognizing <cr>
	; and ~ as home.  Will also interpret a
	; leading ~ as home, and $var will cause
	; an attempted environment lookup
	; Sun Sep 20 1981 - added expand-file-name to emacs, use this
	; function to expand ~user type directories.  Since the filename
	; expansion requires a / after ~user, a / is appended to all
	; directory names before expansion.
	; Sun Nov  1 1981 - use Expand-file-name to do all $ and ~
	; expansion.  This also recognizes $emacs-var as well as
	; $environment-var.  If the change-directory fails, prepend a $ to
	; the directory name and try again.  [Almost simulates csh
	; semantics.]
	(progn
	    (setq dir (arg 1 "Change to directory "))
	    (if (| (= dir "")
		    (= dir "~"))
		(setq dir (getenv "HOME"))
	    )
	    (if (|  (= (substr dir 1 1) "~")
		    (= (substr dir 1 1) "$"))
		(setq dir (Expand-file-name (concat dir "/")))
	    )
	    (if (error-occured
		    (change-directory dir))
		(if (! (error-occured
			   (setq dir
			       (Expand-file-name (concat "$" dir "/")))))
		    (change-directory dir)
		    (error-message (concat "Can't change to directory " dir)))
	    )
	    (pwd)
	    (novalue)
	)
    )
    (pwd
	(message (concat "Connected to " (working-directory)))
    )
    
    (Pop-level			; written by SWT
	; If in a recursive emacs, then exit, else
	; if at top level, do Pause
	(if (= (recursion-depth) 0)
	    (Pause)
	    (exit-emacs))
    )
    
    (Pause			; written by SWT modified by CAK
	; Pause emacs, printing working dir upon
	; restart.
	(progn stopped-time
	    (if (= prefix-argument 1)
		(write-modified-files)
	    )
	    (if (> (process-status "newtime") 0)
		(progn
		      (stop-process "newtime")
		      (setq stopped-time 1)
		)
		(setq stopped-time 0)
	    )
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
	    (setq com  (concat "/a3/kent/emacs/grep -n '"
			   (concat string
			       (concat "' " files))))
	    (message com)
	    (sit-for 0)
;	    (execute-monitor-command com)
;	    (message "Done")	    
;	    (temp-use-buffer "Command execution")
;	    (Mark-Whole-Buffer)
;	    (parse-error-messages-in-region)
;	    (setq errors-parsed 1)
;	    (next-error)
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
		    (|  (= char 'a')
			(= char 'A'))
		    (apropos (arg 1 "Apropos: "))
		    (|  (= char 'k')
			(= char 'K'))
		    (progn
			(message "Use the describe-key command to describe a key (M-/)")
		    )
		    (|  (= char 'c')
			(= char 'C'))
		    (describe-command (get-tty-command "Describe command: "))
		    (|  (= char 'v')
			(= char 'V'))
		    (describe-variable (get-tty-variable "Describe variable: "))
		    (progn	; this is the none-of-the-above case
			(message "Type a (apropos), k (key), c (command) or v (variable).  Doc (? for help): ")
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
	; if the name begins with a $
	(setq name (arg 1 ": Expand-file-name "))
	(while (= (substr name 1 1) "$")
	    (progn i var
		(setq i 2)
		(while (& (<= i (length name))
			   (!= (substr name i 1) "/"))
		    (setq i (+ i 1)))
		(setq var (substr name 2 (- i 2)))
		(setq name
		    (concat
			(if (error-occured (getenv var))
			    (execute-mlisp-line var)
			    (getenv var))
			(substr name i 1000))))
	)
	(expand-file-name name)
    )
)
(autoload "new-undo" "undo.ml")
(autoload "buffer-menu" "utah/buff-menu.ml")
(autoload "centre-line" "centre-line.ml")
(autoload "compare-windows" "purdue/comp-wind.ml")
(autoload "csh" "local/process.ml")
(autoload "electric-lisp-mode" "utah/electric-lisp")
(autoload "electric-mlisp-mode" "utah/electric-lisp")
(autoload "info" "info.ml")
(autoload "*more*" "utah/more.ml")
(autoload "Occurances" "utah/occur.ml")
(autoload "one-line-buffer-list" "buff.ml")
(autoload "purdue-C-mode" "purdue/purdue-C")
(autoload "spell" "spell.ml")
(autoload "tail" "purdue/tail.ml")
(autoload "time" "time.ml")
(autoload "view-buffer" "local/more.ml")
(auto-execute "purdue-C-mode" "*.c")
(auto-execute "purdue-C-mode" "*.h")
(auto-execute "purdue-C-mode" "*.y")
(auto-execute "purdue-C-mode" "*.l")
(auto-execute "text-mode" "/tmp/*")
(auto-execute "text-mode" "*.mss")
(auto-execute "electric-mlisp-mode" "*.emacs_pro")
(auto-execute "electric-lisp-mode" "*.abbrevs")
(auto-execute "electric-mlisp-mode" "*.ml")
(bind-to-key "new-undo" "\^X\^U")		 ; ^X^U
(bind-to-key "set-mark" (+ 128 '\040'))		 ; meta-space
(bind-to-key "shell" (+ 128 '-'))		 ; meta-minus
(bind-to-key "csh" (+ 256 '-'))			 ; ^X-minus
(bind-to-key "Pause" '^_')			 ; ^_
(bind-to-key "Doc" (+ 256 31))			 ; ^X^_
(bind-to-key "query-replace-string" (+ 128 '%')) ; M-%
(bind-to-key "re-query-replace-string" "\030%")  ; ^X%
(bind-to-key "describe-key" (+ 128 '/'))	 ; M-/
(bind-to-key "describe-command" (+ 256 '/'))	 ; ^X/
(bind-to-key "print" (+ 128 '='))		 ; M-=
(bind-to-key "delete-white-space" (+ 128 92))	 ; M-\
(bind-to-key "Not-modified" (+ 128 '~'))	 ; M-~
(bind-to-key "join-lines" (+ 128 '^'))		 ; M-^
(bind-to-key "define-local-abbrev" (+ 256 1))	 ; ^X^A
(bind-to-key "backward-word" (+ 128 2))		 ; M-^B
(bind-to-key "one-line-buffer-list" (+ 256 'B')) ; ^XB
(bind-to-key "buffer-menu" (+ 256 '^b'))	 ; ^X^B
(bind-to-key "switch-to-buffer" (+ 256 'b'))	 ; ^Xb
(bind-to-key "Pop-level" (+ 256 3))		 ; ^X^C
(bind-to-key "case-word-capitalize" (+ 128 'c')) ; ESC-c
(bind-to-key "compare-windows" (+ 256 'c'))	 ; ^X-c
(bind-to-key "current-date-and-time" (+ 128 '')); ESC-^D
(bind-to-key "forward-word" (+ 128 6))		 ; M-^F
;(bind-to-key "visit-file" (+ 256 6))		 ; ^X^F
(bind-to-key "find-line" (+ 128 'G'))		 ; ESC-G
(bind-to-key "goto-line" (+ 128 'g'))		 ; ESC-g
(bind-to-key "Mark-Whole-Buffer" (+ 256 'h'))	 ; ^Xh
(bind-to-key "indent-line" "\033i")		 ; ESC-i
(bind-to-key "dedent-line" "\033I")		 ; ESC-I
(bind-to-key "info" (+ 256 'I'))		 ; ^XI
(bind-to-key "load-current-file" (+ 256 'l'))	 ; ^Xl
(bind-to-key "*more*" (+ 128 'M'))		 ; ESC-M
(bind-to-key "smail" "\030m")			 ; ^Xm
(bind-to-key "Mini-Buffer" "\030M")		 ; ^XM
(bind-to-key "Newline" 13)			 ; ^M
(bind-to-key "first-non-blank" (+ 128 13))	 ; meta-return
(bind-to-key "Occurances" (+ 128 'o'))		 ; ESC-o
(bind-to-key "next-window" (+ 256 'o'))		 ; ^Xo
(bind-to-key "re-search-reverse" (+ 128 '^R'))	 ; ESC-^R
(bind-to-key "read-file" (+ 256 18))		 ; ^X^R
(bind-to-key "rmail" "\030r")			 ; ^Xr
(bind-to-key "re-search-forward" "\033\023")	 ; M-^S
(bind-to-key "Write-current-file" (+ 256 19))	 ; ^X^S
(bind-to-key "transpose-word" (+ 128 'T'))	 ; ESC-T
(bind-to-key "transpose-word" (+ 128 't'))	 ; ESC-t
(bind-to-key "transpose-line" (+ 128 20))	 ; ESC-^T
(bind-to-key "view-buffer" (+ 256 'V'))		 ; ^XV
(bind-to-key "same-window-visit-file" (+ 256 'v')) ; ^Xv
(bind-to-key "Next-Page" 22)			 ; ^V
(bind-to-key "Copy-region-to-kill-buffer" (+ 128 'w'))	 ; M-w
(bind-to-key "delete-previous-word" '^W')	 ; ^W
(bind-to-key "Pop-level" (+ 128 26))		 ; M-^Z
(bind-to-key "scroll-one-line-up" "\033Z")	 ; M-Z
(quietly-read-abbrev-file ".abbrevs")
(setq mode-line-format default-mode-line-format)
