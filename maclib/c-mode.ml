(defun
    (begin-C-comment
	(move-to-comment-column)
	(setq left-margin (current-column))
	(setq right-margin 78)
	(setq prefix-string "   ")
	(insert-string "/* ")
    )
)
(defun
    (end-C-comment
	(setq right-margin 1000)
	(if (!= (preceding-char) ' ') (insert-string " "))
	(insert-string "*/")
    )
)

(defun
    (c-mode
	(setq right-margin 1000)
	(setq prefix-string "   ")
	(setq mode-string "C")
	(remove-all-local-bindings)
	(local-bind-to-key "begin-C-comment" (+ 128 '`'))
	(local-bind-to-key "end-C-comment" (+ 128 '''))
	(local-bind-to-key "indent-C-procedure" (+ 128 'j'))
	(novalue)
    )
)
