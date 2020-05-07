(defun 
    (create-buffer-menu
	(push-back-string "?")
	(if (& (is-bound shift) shift)
	    (pop-to-buffer "Help")
	    (switch-to-buffer "Help"))
        (error-occured (call-interactively (use-old-buffer)))
	(switch-to-buffer "Buffer menu")
	(erase-buffer)
	(yank-buffer "Help")
	(beginning-of-file)
	(set-mark)(next-line)(beginning-of-line)(erase-region)
	(search-forward "  Minibuf")(region-around-match 0)(erase-region)
	(insert-string "         ")(exchange-dot-and-mark)
	(message "")
    )
    
    (goto-char-in-line gc-col gc-eol
	(beginning-of-line)
	(setq gc-col (max 0 (arg 1 "Column: ")))
	(setq gc-col (+ gc-col (dot)))
	(end-of-line)
	(goto-character (min (dot) gc-col))
    )
    
    (menu-select-from-buffer-list dotcol wordstart wordend
	(setq dotcol (dot))
	(beginning-of-line)
	(setq dotcol (- dotcol (dot)))
	(setq wordend (+ 24 (* 25 (/ dotcol 25))))
	(goto-char-in-line wordend)
	(while (& (!= (following-char) ' ') (! (eolp)))
	       (setq wordend (+ wordend 25))
	       (goto-char-in-line wordend)
	)
	(setq wordstart (- wordend 25))
	(goto-char-in-line wordstart)
	(while (& (!= (following-char) ' ') (! (bolp)))
	       (setq wordstart (- wordstart 25))
	       (goto-char-in-line wordstart))
	(if (! (bolp)) (forward-character))
	(set-mark)
	(goto-char-in-line wordend)
	(while (= (preceding-char) ' ') (backward-character))
	(if (< (dot) (mark)) (set-mark))
	(region-to-string)
    )
)

(defun 
    (menu-switch-to-buffer ms-buffername
	(setq ms-buffername (menu-select-from-buffer-list))
	(if (buffer-exists ms-buffername)
	    (switch-to-buffer ms-buffername)
	    (message (concat ms-buffername
			     " is not a valid buffer.")))
    )
    
)

(save-excursion 
    (temp-use-buffer "Buffer menu")
    (setq needs-checkpointing 0)
    (local-bind-to-key "menu-switch-to-buffer" " ")
    (setq mode-line-format 
	  "%[ %b   Click or type space with dot inside selection %]")
    (if (is-bound click-hook)    
	(setq click-hook
	      "(if (& up (! shift)) (menu-switch-to-buffer))"))
)

