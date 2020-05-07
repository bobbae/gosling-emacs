;  This autoloaded file implements the "xl" (extended print) command of mhe
(defun 
    (&mh-xlprint msgn fn tray duplex
	(if (error-occured
		(setq msgn (&mh-get-msgnum))
		(setq fn (&mh-get-fname))
		(&mh-set-cur)
	    )
	    (error-message "message " msgn " does not exist!")
	    (error-occured
		(setq tray (get-response "Which paper tray? (0-9 or CR) "
			       "0123456789\000"
			       "0-9 to select a paper tray, RETURN for default: "))
		(setq duplex (get-response "Double sided? (1, 2, t or CR) "
				 "12t\000"
				 "1-single, 2-double, t-tumble, RETURN for default: "))
		(message  "Listing message " msgn) (sit-for 0)
		(save-window-excursion 
		    (temp-use-buffer "mh-temp")
		    (erase-buffer)
		    (insert-string "sh <<'endit' | lpr '-JMail Message " msgn "'\n")
		    (if (| (!= tray '\000') (!= duplex '\000'))
			(insert-string "echo '%!'\n")
		    )
		    (if (!= tray '\000')
			(progn
			      (insert-string "echo 'statusdict begin mark { ")
			      (insert-character tray)
			      (insert-string " setpapertray } stopped cleartomark end'\n")
			)
		    )
		    (if (= duplex '1')
			(insert-string "echo 'statusdict begin mark { false setduplexmode } stopped cleartomark end'\n")
		    )
		    (if (= duplex '2')
			(insert-string "echo 'statusdict begin mark { true setduplexmode } stopped cleartomark end'\n")
		    )
		    (if (= duplex 't')
			(insert-string "echo 'statusdict begin mark { true setduplexmode true settumble } stopped cleartomark end'\n")
		    )
		    (insert-string "awk 'BEGIN { go=0 } /^%!/ { go=1 } go == 0 { next } /^- -/ { print substr($0,3,length($0)-2) ; next } { print }' ")
		    (insert-string (concat "<" fn "\nendit\n"))
		    (beginning-of-file) (set-mark) (end-of-file)
		    (fast-filter-region "sh")

		    (message  "Listed message " msgn " on "
			(if (error-occured (getenv "PRINTER"))
			    "the system printer"
			    (getenv "PRINTER")
			)
		    )
		    (sit-for 2)
		)
	    )
	)
	(exit-emacs)
    )
)
