;  This autoloaded file implements the "r" command of mhe
(defun     
    (&mh-repl actn exfl fn annotate ft whoreply Roption
	#message #reply #reply-fn
	(if (= (last-key-struck) 'r')
	    (setq whoreply "sender")
	    (setq whoreply "sender and recipients")
	)
	(setq #message (if (= (recursion-depth) 1) "message"
			   (concat "message-" (recursion-depth))))
	(setq #reply (if (= (recursion-depth) 1) "reply"
			 (concat "reply-" (recursion-depth))))
	(setq #reply-fn (concat mh-path "/reply"))
	(progn
	    (&mh-save-killbuffer)
	    (temp-use-buffer (concat "+" mh-folder))
	    (setq fn (&mh-get-fname))
	    (setq annotate mh-annotate)
	    (setq ft mh-folder-title)

	    ; Get original message into a SCRATCH buffer -- no file name.
	    (error-occured (delete-buffer #message))
	    (temp-use-buffer #message)
	    (setq mode-string "mhe")
	    (setq needs-checkpointing 0)
	    (message  "Replying to " whoreply " of message " 
		(&mh-get-msgnum) "...")
	    (sit-for 0)
	    (temp-use-buffer #message)
	    (erase-buffer)
	    (if (error-occured (insert-file fn))
		(error-message "Message " fn " does not exist!"))
	    (beginning-of-file)

	    (message "One moment, please....")
	    (unlink-file #reply-fn)
	    (if mh-version-6-or-later
		(if (= whoreply "sender")
		    (setq Roption " -nocc all -cc me")
		    (setq Roption " -cc all"))
	        (if (= whoreply "sender")
		    (setq Roption " -nocceverybody")
		    (setq Roption " -cceverybody")))
	    (error-occured 
		(send-to-shell 
		    (concat mh-progs "/repl -build" 
			    Roption " +" ft " "
			    (&mh-get-msgnum))
		))
	    (show-shell-errors)
	)

	(temp-use-buffer #reply) (erase-buffer)
	(if (file-exists #reply-fn)
	    (read-file #reply-fn)
	    (error-message "Reply failed: cannot construct header"
		" (file " #reply-fn ")")
	)
	(local-bind-to-key "exit-emacs" "\\")
	(mail-mode)
	(beginning-of-file)
	(if (error-occured (re-search-forward "^---"))
	    (end-of-file)
	    (next-line)
	)
	(sit-for 0)

	; Edit and (perhaps) mail the message.
	(setq actn (&mh-compose #reply #message #reply-fn))

	; Set up the final window format.
	(&mh-pop-to-buffer (concat "+" mh-folder))
	(setq mode-line-format mh-mode-line)
	(delete-other-windows)
	(&mh-pop-to-buffer #reply)
	(&mh-pop-to-buffer (concat "+" mh-folder))

	; Other actions besides just sending the message.
	(if (= actn 'm')
	    (if annotate
		(error-occured
		    (temp-use-buffer "annotate")
		    (read-file fn)
		    (annotate "Replied")
		    (delete-buffer "annotate")
		)
	    )
	    (= actn 'q')
	    (progn
		  (error-message (concat "Message not sent; its text remains in buffer '" #reply "'"))
	    )
	)
    )
)
