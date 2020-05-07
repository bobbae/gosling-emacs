; comment.ml - Commenting functions
; Written by Spencer W. Thomas
; Tue Nov  3 1981
; 
; begin-global-comment
;   Enter a recursive edit to insert a global comment.
; 
; edit-global-comment
;   Enter a recursive edit to re-edit a global comment.
; 
(progn 
(setq mode-line-format "Loading block comments")
(declare-global &comment-continuation&)

(defun 
    (begin-global-comment old-fill old-mode old-return old-lf old-c-o old-right-margin
	(setq old-fill prefix-string); save old prefix-string
	(save-excursion		; set prefix from current line
	    (set-mark)
	    (beginning-of-line)
	    (setq &comment-continuation&
		(concat (region-to-string) " * ")))
	(insert-string comment-begin)
	(if (! (looking-at "$"))
	    (save-excursion (insert-string "\n")))
	(setq old-return (local-binding-of '^M'))
	(setq old-lf (local-binding-of '^J'))
	(setq old-c-o (local-binding-of '^O'))
	(setq old-right-margin right-margin)
	(setq old-mode mode-string)
	(error-occured 		; catch ^Gs and the such-like
	    (setq prefix-string &comment-continuation&)
	    (setq mode-string (concat mode-string " Global Comment"))
	    (setq right-margin 72)
	    (local-bind-to-key "comment-return" '^M')
	    (local-bind-to-key "comment-lf" '^J')
	    (local-bind-to-key "comment-c-o" '^O')
	    (recursive-edit))
	(local-rebind-to-key old-return "\^M")
	(local-rebind-to-key old-lf "\^J")
	(local-rebind-to-key old-c-o "\^O")
	(setq prefix-string old-fill)
	(setq mode-string old-mode)
	(setq right-margin old-right-margin)
	(save-excursion
	    (set-mark)
	    (beginning-of-line)
	    (if (= (region-to-string) &comment-continuation&)
		(progn
		    (exchange-dot-and-mark)
		    (provide-prefix-argument 3
			(delete-previous-character))))
	)
	(insert-string comment-end)
	(novalue)
    )
)
(defun
    (edit-global-comment old-return old-lf old-c-o old-right-margin old-mode
			 old-fill
	(save-excursion
	    (search-reverse comment-start)
	    (set-mark)
	    (beginning-of-line)
	    (setq &comment-continuation& (concat (region-to-string) " * "))
	)
	(setq old-return (local-binding-of '^M'))
	(setq old-lf (local-binding-of '^J'))
	(setq old-c-o (local-binding-of '^O'))
	(setq old-right-margin right-margin)
	(setq old-mode mode-string)
	(setq old-fill prefix-string)
	(error-occured 		; catch ^Gs and the such-like
	    (setq prefix-string &comment-continuation&)
	    (setq mode-string (concat mode-string " Global Comment"))
	    (setq right-margin 72)
	    (local-bind-to-key "comment-return" '^M')
	    (local-bind-to-key "comment-lf" '^J')
	    (local-bind-to-key "comment-c-o" '^O')
	    (recursive-edit))
	(local-rebind-to-key old-return "\^M")
	(local-rebind-to-key old-lf "\^J")
	(local-rebind-to-key old-c-o "\^O")
	(setq prefix-string old-fill)
	(setq mode-string old-mode)
	(setq right-margin old-right-margin)
    )
)
(defun
    (comment-return
	(prefix-argument-loop
	    (provide-prefix-argument 1 (newline))
	    (insert-string &comment-continuation&))
    )
    (comment-lf
	(comment-return)
	(tab-to-tab-stop)
    )
    (comment-c-o
	(save-excursion
	    (if (bolp)
		(prefix-argument-loop
		    (insert-string &comment-continuation&)
		    (provide-prefix-argument 1 (newline)))
		(comment-return)))
    )
)
(defun
    (local-rebind-to-key com old-binding key
	(setq old-binding (arg 1 ": local-rebind-to-key (old binding) "))
	(setq key (arg 2 (concat ": local-rebind-to-key (old binding) "
			     old-binding
			     " (key) ")))
	(if (= old-binding "nothing")
	    (remove-binding key)
	    (progn
		(if
		    (= (substr old-binding 1 1) "L")
		    (setq com (concat "(local-bind-to-key "
				  "\"" (substr old-binding 3 1000) "\" "
				  "\"" key "\"" ")"))
		    (= (substr old-binding 1 1) "G")
		    (setq com (concat "(remove-local-binding "
				  "\"" key "\"" ")"))
		    (setq com "(novalue)"))
;		(message com) (sit-for 20)
		(execute-mlisp-line com))
	)
    )
)
(setq mode-line-format default-mode-line-format)
)
