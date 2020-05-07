(if (! (is-bound geom-screen))
    (progn
	  (declare-global geom-screen)	; The favorite screen device to use.
	  (setq geom-screen "mps2")	; Default value.
    )
)
(defun
    (grab-screen
	   (string-to-process "rlisp"
	       (rlisp-echo
		   (concat "<<grab " geom-screen "; "
			   "pickScreen " geom-screen " >>$\n")))
    )
    (drop-screen
	   (string-to-process "rlisp"
	       (rlisp-echo (concat "drop " geom-screen ";\n")))
    )
    (grefresh
	(string-to-process "rlisp" (rlisp-echo "grefresh();\n"))
    )    
)

(bind-to-key "grab-screen" "\^zg")	; ^Z-G
(bind-to-key "drop-screen" "\^zd")	; ^Z-D
(bind-to-key "grefresh" "\^zG")		; ^Z-g
