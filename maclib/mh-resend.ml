;  This autoloaded file implements the "y" command of mhe
;  If an argument is provided, it will be used as the buffer to send.
(defun 
    (&mh-resend actn rebuffer #draft #draft-fn
	(setq #draft (if (= (recursion-depth) 1) "redraft"
			 (concat "redraft-" (recursion-depth))))
	(setq #draft-fn (concat mh-path "/redraft"))
	(&mh-save-killbuffer)
	(error-occured (delete-buffer #draft))
	(unlink-file #draft-fn)
	(if (> (nargs) 0)
	    (setq rebuffer (arg 1))
	    (setq rebuffer (get-tty-buffer 
			       "Buffer to be re-sent (type ? for list)--"))
	)
	(temp-use-buffer #draft)
	(erase-buffer)
	(yank-buffer rebuffer)
	(write-named-file #draft-fn)
	(local-bind-to-key "exit-emacs" "\\")
	(beginning-of-file)
	(mail-mode) (header-line-position)
	(sit-for 0)

	; Edit and (perhaps) mail the message.
	(setq actn (&mh-compose #draft (concat "+" mh-folder) #draft-fn))

	; Set up the final window format.
	(&mh-pop-to-buffer (concat "+" mh-folder))
	(setq mode-line-format mh-mode-line)
	(delete-other-windows)
	(&mh-pop-to-buffer #draft)
	(&mh-pop-to-buffer (concat "+" mh-folder))

	; Other actions besides just sending the message.
	(if (= actn 'q')
	    (progn 
		   (error-message "Message not sent; its text remains in buffer 'redraft'")
	    )
	)
    )
)
