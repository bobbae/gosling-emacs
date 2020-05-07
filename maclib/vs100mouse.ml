(defun
    (move-vs100-cursor savest b x y
        (setq savest stack-trace-on-error)
	(setq stack-trace-on-error 0)
	(setq b (- (get-tty-character) 32))
	(setq x (- (get-tty-character) 32))
	(setq y (- (get-tty-character) 32))
	(if
	    (error-occured
	        (move-dot-to-x-y x y)
		(do-edit-action b)
	    )
	    (scroll-window b x y)
	)
	(setq stack-trace-on-error savest)
    )


    (scroll-window 
        (move-dot-to-x-y 1 (- (arg 3) 1))
        (if (= (arg 1) 0) (next-page))
        (if (= (arg 1) 1)
	   (goto-percent (/ (* (arg 2) 100) 80))
	)
        (if (= (arg 1) 2) (previous-page))
    ) 

    (do-edit-action
        (if (= (arg 1) 0) (set-mark))
        (if (= (arg 1) 1) (yank-from-killbuffer))
        (if (= (arg 1) 2)
	    (progn
	        (if (> (mark) (dot)) (exchange-dot-and-mark))
	        (if (! (eobp)) (forward-character))
	        (delete-to-killbuffer)
	    )
	)
   )
    (goto-percent
       (goto-character (/ (* (buffer-size) (arg 1)) 100))
   )
)
 
(if (| (= (getenv "TERM") "vs100") (= (getenv "TERM") "tsim"))
    (defun
	  (emacs-dsp-entry-hook (send-string-to-terminal "\e("))
	  (emacs-dsp-exit-hook (send-string-to-terminal "\e)"))
    )
    (defun
	  (emacs-dsp-entry-hook (send-string-to-terminal "\e[?9h"))
	  (emacs-dsp-exit-hook (send-string-to-terminal "\e[?9l"))
    )
)

(bind-to-key "move-vs100-cursor" "\e[M")
(emacs-dsp-entry-hook)
