(if (! (is-bound vt100-prefix-sign))
    (progn
	(declare-global vt100-prefix-sign)
	(setq vt100-prefix-sign 1)
        (send-string-to-terminal "=")
        (defun
	    (vt100-keypad
		0
	    )
	    (vt100-exit-emacs
	        (send-string-to-terminal ">")
		(exit-emacs)
	        (send-string-to-terminal "=")
	    )
	    (vt100-pause-emacs
	        (send-string-to-terminal ">")
		(pause-emacs)
	        (send-string-to-terminal "=")
	    )
	    (vt100-minus
		(setq vt100-prefix-sign (- 0 vt100-prefix-sign))
	    )
	    (vt100-auto-arg vt100-value
		(setq vt100-value
		    (+ (if prefix-argument-provided
			    (progn
				(if (< prefix-argument 0)
				    (setq vt100-prefix-sign -1))
				(* prefix-argument 10))
			    0)
			(* vt100-prefix-sign (- (last-key-struck) 'p'))
		    ))
		(setq vt100-prefix-sign 1)
	        (message vt100-value)
	        (return-prefix-argument vt100-value)
	    )
        )
	(bind-to-key "forward-character" "[C")	;Right Arrow
	(bind-to-key "backward-character" "[D")	;Left Arrow
	(bind-to-key "next-line" "[B")		;Down Arrow
	(bind-to-key "previous-line" "[A")		;Up Arrow

	(bind-to-key "describe-command" "OP")		;PF1
	(bind-to-key "describe-variable" "OQ")	;PF2
	(bind-to-key "apropos" "OR")			;PF3
	(bind-to-key "describe-key" "OS")		;PF4

; alternate keypad codes
	(bind-to-key "vt100-minus" "Om")		;-(minus)
        (bind-to-key "vt100-auto-arg" "Op")		;0
        (bind-to-key "vt100-auto-arg" "Oq")		;1
        (bind-to-key "vt100-auto-arg" "Or")		;2
        (bind-to-key "vt100-auto-arg" "Os")		;3
        (bind-to-key "vt100-auto-arg" "Ot")		;4
        (bind-to-key "vt100-auto-arg" "Ou")		;5
        (bind-to-key "vt100-auto-arg" "Ov")		;6
        (bind-to-key "vt100-auto-arg" "Ow")		;7
        (bind-to-key "vt100-auto-arg" "Ox")		;8
        (bind-to-key "vt100-auto-arg" "Oy")		;9
	(bind-to-key "execute-extended-command" "OM")	;ENTER
	(bind-to-key "set-mark" "On")			;.(period)
    )
)
