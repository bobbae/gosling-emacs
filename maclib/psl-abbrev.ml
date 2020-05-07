(defun 
    ( lp
	(insert-string "lisp procedure ")
    )

    ( bs
	(set-mark)
	(insert-string "begin scalar ...;") (Newline)
	(insert-string "    ...") (Newline)
	(insert-string "end;") (Newline)
	(exchange-dot-and-mark)
    )

    ( ds
	(set-mark)
	(insert-string "% ...") (Newline)
	(insert-string "defstruct(   ...( !:prefix ),") (Newline)
	(insert-string "    ...( !:Type ... ),") (Newline)
	(exchange-dot-and-mark)
    )

    ( fl
	(set-mark)
	(insert-string "fluid '(") (Newline)
	(insert-string "    ...") (Newline)
	(insert-string ");") (Newline)
	(exchange-dot-and-mark)
    )

    ( next-ellipsis		; For filling in templates.
	(if (! (error-occured (search-forward "...")))
	    (provide-prefix-argument 3 (delete-previous-character)))
    )
)

(bind-to-key "next-ellipsis" "\^x.")
