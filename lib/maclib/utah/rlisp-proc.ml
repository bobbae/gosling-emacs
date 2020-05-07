 (if (! (is-bound rlisp-pgm))
    (progn
	  (declare-global rlisp-pgm)	 ; The name of the rlisp to start.
	  (setq rlisp-pgm "/usr/local/rlisp") 	; Default value.
    )
)
(defun 
    ; rlisp-execute - Similar to Emode Meta-E, feeds lines until end-of-cmd.
    ; prefix arg inhibits echo of input in rlisp buffer.
    (rlisp-execute
	cmd-wanted cmd-str pgm-dir pgm-name fix-file ; Local vars.
	(save-excursion (pop-to-buffer "rlisp")) ; Put it on the screen.

	(if (< (process-status "rlisp") 0)  	 ; Start rlisp if necessary.
	    (progn
		  (save-excursion
		      (temp-use-buffer "rlisp")	    ; Rlisp dialog window.

		      (electric-rlisp-mode)	    ; Rlisp mode first.
		      (new-shell "rlisp" rlisp-pgm) ; Overlaid w/ shell mode.

		      ; Fix bindings - <CR> feeds rlisp.
		      (local-bind-to-key "rlisp-pr-newline" "\r")
		      (error-occured 	; Fixed sequences in function keys...
			  (if (= (getenv "TERM") "vt100")
			      ; KP Enter key.
			      (local-bind-to-key "rlisp-pr-newline" "\eOM")
			  )
		      )

		      (use-syntax-table "rlisp")    ; Get paren matching back.
		      (insert-filter "rlisp" "rlisp-output")  ; Catch output.

		      (declare-global		;  Make sure vars are known.
			  rlisp-command rlisp-level
			  rlisp-input-buffer rlisp-input-echo)

		      (setq rlisp-command 0)	    ; No cmd seen yet.

		      ; Find out what kind of rlisp is running.
		      (setq cmd-str (concat "set x=" rlisp-pgm "; echo $x:"))
		      (setq pgm-dir (glob-command (concat cmd-str "h")))
		      (setq pgm-name (glob-command (concat cmd-str "t")))

		      ; Setup environment in the rlisp.
		      (string-to-process "rlisp" 
			  (if (!= pgm-name "shapedit")
			      (progn 		; Non-shapedit rlisp.
				  (setq cmd-wanted 1)
				  ; Insure proper toploop, for > prompts.
				  "rlisp();\n"
			      )
			      (progn 		; Shapedit.
				  (setq cmd-wanted 1)

				  ; Load updates to shapedit if file found.
				  (setq fix-file
					(concat pgm-dir "/shapedit-fix.r"))
				  (if (file-exists fix-file)
				      (progn
					  (setq cmd-wanted (+ cmd-wanted 1))
					  (concat "in \"" fix-file "\"$\n")
				      )
				      "\n"	; Null cmd if no fix file.
				  )
			      )
			  )
		      )

		      ; Hang until prompt number is known.
		      (while (!= rlisp-command cmd-wanted)
			     (await-process-input))
		  )
	    )
	)

	; Determine whether to echo, in top-level call.
	(if (interactive)
	    (setq rlisp-input-echo (! prefix-argument-provided))
	)

	(if (progn (beginning-of-line) (eobp))
	    (message "Ran out of input for rlisp.")

	    (progn			; Send line to rlisp.
		(set-mark)
		(next-line)

		(if (! (dot-is-visible))	; Page instead of scrolling.
		    (Next-Page)
		)

		(if (& (eobp) (!= (preceding-char) '\n'))
		    (insert-character '\n'))	; CR at eob.

		(setq rlisp-input-buffer (current-buffer-name))

		(if rlisp-input-echo	; Echo input, conditionally.
		    (append-region-to-buffer "rlisp")
		    (if (interactive)	; Else just CR intead of input.
			(rlisp-echo "\n"))
		)

		(pop-to-buffer "rlisp")	; Put point at end of dialog.
		(end-of-file)
		(pop-to-buffer rlisp-input-buffer)

		(region-to-process "rlisp")	; Send the input.
	    )
	)
    )

    ; Put a string at the end of the rlisp dialog buffer.
    (rlisp-echo
	(save-excursion
	      (temp-use-buffer "rlisp")
	      (end-of-file)
	      (insert-string (arg 1 "rlisp-echo string: "))
	)
    )

    ;  rlisp-output - filter output, keep executing as long as same prompt.
    (rlisp-output old-cmd old-lvl is-prompt prompt-string old-buffer
	(if rlisp-command	; Remember old command number.
	    (progn
		  (setq old-cmd rlisp-command)
		  (setq old-lvl rlisp-level)
	    )
	)

	(save-excursion 	; Process output, looking for prompts.
	    (temp-use-buffer "*rlisp-output*")
	    (erase-buffer)
	    (insert-string (process-output))
	    (beginning-of-file)
	    (while (! (eobp))
		(if (setq is-prompt (looking-at 
		     "\\([0-9][0-9]*\\) [a-z][a-z]*[ break]*\\(>>*\\) \\'")
		    )
		    (save-excursion	; Found prompt, grab number and level.
			(region-around-match 1)    ; Cmd number.
			(setq rlisp-command (region-to-string))
			(region-around-match 2)    ; Cmd level.
			(setq rlisp-level (length (region-to-string)))
		    )
		)

		; Handle the prompt or output string.
		(set-mark)
		(next-line)		; (May just go to end of prompt line.)
		(if is-prompt
		    (setq prompt-string	     ; Stash prompt. (Always at EOB.)
			  (region-to-string))
		    (append-region-to-buffer "rlisp")	; Else echo output.
		)
		(erase-region)
	    )
	)

 ;	(if is-prompt			; Debug msg.
 ;	    (progn (message "com: " rlisp-command ":"
 ;		       old-cmd "lvl: " rlisp-level ":" old-lvl) ))

	(if is-prompt		; Decide whether a prompt is extraneous.
	    (if (& (!= rlisp-input-buffer "")	; Somewhere to get more input?
		   (& (= rlisp-command old-cmd)	; Same cmd number
		      (= rlisp-level old-lvl))	; and level in prompt?
		)

		; Extraneous prompt for same cmd, just feed more input.
		(progn
		    (pop-to-buffer rlisp-input-buffer)
		    (rlisp-execute)
		)

		;  Necessary prompt, echo it.
		(progn 
		    (setq old-buffer (current-buffer-name))
		    (pop-to-buffer "rlisp")
		    (end-of-file)
		    (insert-string prompt-string)	; Show  prompt.
		    (set-mark)		; Mark after prompt for dialog here.
		    (pop-to-buffer old-buffer)
		)
	    )
	)

	(sit-for 0)		; Force redisplay.
    )

    ; Supplement for pr-newline - turn off continuing meta-e if command
    ; was entered from dialog buffer instead of an rlisp buffer.
    (rlisp-pr-newline
	(setq rlisp-input-buffer "")
	(pr-newline)
    )

    ; Send string to rlisp process and rlisp window.
    (rlisp-send
	(string-to-process "rlisp"
	    (rlisp-echo (concat (arg 1 "send line to rlisp: ") "\n"))
	)
    )

    ; Communicate with the rlisp break loop.
    (rlisp-break
	(rlisp-send (concat (char-to-string (last-key-struck)) ";"))
    )

    ; Communicate with a PSL "(Y or N)"  or "How many args", etc. prompt.
    (rlisp-char
	(rlisp-send (char-to-string (last-key-struck)))
    )
)

(bind-to-key "rlisp-send" "\^zs")	; ^Z-s (Send line to Rlisp)
(bind-to-key "rlisp-break" "\^zbq")	; ^Z-b-q (Quit)
(bind-to-key "rlisp-break" "\^zba")	; ^Z-b-a (Abort to toploop)
(bind-to-key "rlisp-break" "\^zbi")	; ^Z-b-i (Interpretive traceback)
(bind-to-key "rlisp-break" "\^zbt")	; ^Z-b-t (full Traceback)
(bind-to-key "rlisp-break" "\^zbc")	; ^Z-b-c (Continue)
(bind-to-key "rlisp-break" "\^zbm")	; ^Z-b-m (print errorform Message)
(bind-to-key "rlisp-break" "\^zbr")	; ^Z-b-r (Retry)
(bind-to-key "rlisp-char" "\^zy")	; ^Z-y (Yes)
(bind-to-key "rlisp-char" "\^zn")	; ^Z-n (No)
(bind-to-key "rlisp-char" "\^z0")	; ^Z-0 (arg counts for tr,untr.)
(bind-to-key "rlisp-char" "\^z1")	; ^Z-1
(bind-to-key "rlisp-char" "\^z2")	; ^Z-2
(bind-to-key "rlisp-char" "\^z3")	; ^Z-3
(bind-to-key "rlisp-char" "\^z4")	; ^Z-4
(bind-to-key "rlisp-char" "\^z5")	; ^Z-5
(bind-to-key "rlisp-char" "\^z6")	; ^Z-6
(bind-to-key "rlisp-char" "\^z7")	; ^Z-7
(bind-to-key "rlisp-char" "\^z8")	; ^Z-8
(bind-to-key "rlisp-char" "\^z9")	; ^Z-9
