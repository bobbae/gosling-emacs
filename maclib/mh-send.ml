;  This autoloaded file implements the "m" command of mhe. We call "comp" to
;  compose the message into buffer "draft", and then when we are ready to
;  send it we call "send" to do the evil deed.
(defun 
    (&mh-send actn #draft #draft-fn
	(setq #draft (if (= (recursion-depth) 1) "draft"
			 (concat "draft-" (recursion-depth))))
	(setq #draft-fn (concat mh-path "/draft"))
	(&mh-save-killbuffer)
	(message "Composing a message...") (sit-for 0)
	(error-occured (unlink-file #draft-fn))
	(temp-use-buffer #draft) (erase-buffer)
	(if (file-exists (concat mh-path "/components"))
	    (insert-file (concat mh-path "/components"))
	    (insert-file (concat mh-lib "/components"))
	)
	(write-named-file #draft-fn)
	(local-bind-to-key "exit-emacs" "\\")
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
		  (error-message (concat "Message not sent; its text remains in buffer '" #draft "'"))
	    )
	)
    )
)
