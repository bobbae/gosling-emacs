;  This autoloaded file implements the "f" command of mhe
(defun 
    (&mh-forw actn exfl annotate fn #message #draft #draft-fn
	(setq #message (if (= (recursion-depth) 1) "message"
			   (concat "message-" (recursion-depth))))
	(setq #draft (if (= (recursion-depth) 1) "draft"
			 (concat "draft-" (recursion-depth))))
	(setq #draft-fn (concat mh-path "/draft"))
	
	(message  "Forwarding message " (&mh-get-msgnum) "...")
	(sit-for 0)

	(&mh-save-killbuffer)
	(temp-use-buffer (concat "+" mh-folder))
	(delete-other-windows)
	(setq annotate mh-annotate)
	(setq fn (&mh-get-fname))
	(unlink-file #draft-fn)
	(send-to-shell 
	    (concat mh-progs "/forw -build +" mh-folder " "
		    (&mh-get-msgnum))
	)
	(show-shell-errors)
	(temp-use-buffer #draft)
	(erase-buffer)
	(read-file #draft-fn)

	(local-bind-to-key "exit-emacs" "\\")
	(mail-mode) (header-line-position)
	
	; Edit and (perhaps) mail the message.
	(setq actn (&mh-compose #draft (concat "+" mh-folder) #draft-fn))
	
	; Set up the final window format.
	(&mh-pop-to-buffer (concat "+" mh-folder))
	(setq mode-line-format mh-mode-line)
	(delete-other-windows)
	(&mh-pop-to-buffer #draft)
	(&mh-pop-to-buffer (concat "+" mh-folder))

	; Other actions besides just sending the message.
	(if (= actn 'm')
	    (if annotate
		(error-occured
		    (temp-use-buffer "annotate")
		    (read-file fn)
		    (annotate "Replied" "Forwarded")
		    (delete-buffer "annotate")
		)
	    )
	    (= actn 'q')
	    (progn
		  (error-message (concat "Message not sent; its text remains in buffer '" #draft "'"))
	    )
	)
    )
)
