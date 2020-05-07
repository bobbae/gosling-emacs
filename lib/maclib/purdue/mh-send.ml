; Compose a message.
; 
(defun 
    (&mh-comp re 
	(message "Composing a draft...") (sit-for 0)
	(&mh-get-draft)
	(set-mark)
	(unlink-file (concat mh-path "/draft"))
	(fast-filter-region (concat "comp -build"))
	(if (= (buffer-size) 0)
	    (insert-file (concat mh-path "/draft")))
	(mail-mode)
	(beginning-of-file)
	(end-of-line)
    )
)

;  Forward a message.
; 
(defun 
    (&mh-forw mn
	(temp-use-mh-buffer)
	(setq mn (&mh-get-msgnum))
	(message "Forwarding message " mn "...") (sit-for 0)
	(&mh-get-draft)
	(set-mark)
	(unlink-file (concat mh-path "/draft"))
	(fast-filter-region (concat "forw -build " mh-folder " " (&mh-get-msgnum)))
	(if (= (buffer-size) 0)
	    (insert-file (concat mh-path "/draft")))
	(mail-mode)
	(beginning-of-file)
	(end-of-line)
    )
)

;  Reply to a message.
;
(defun     
    (&mh-repl mn
	(temp-use-mh-buffer)
	(setq mn (&mh-get-msgnum))
	(&mh-show)
	(message "Replying to message " mn "...") (sit-for 0)
	(&mh-get-draft)
	(set-mark)
	(unlink-file (concat mh-path "/reply"))
	(fast-filter-region (concat "repl -build " mh-folder " " mn))
	(if (= (buffer-size) 0)
	    (insert-file (concat mh-path "/reply")))
	(mail-mode)
	(end-of-file)
    )
)

; Get a buffer and file for a draft message
; 
(declare-global draft-number)
(defun
    (&mh-get-draft
	(if (= mh-path "")
	    (setq mh-folder (&mh-read-profile)))
	(setq draft-number (+ draft-number 1))
	(error-occured (visit-file (concat mh-path "/draft_" draft-number)))
	(erase-buffer)
    )
)

; Send the current file as a message.
; 
(defun
    (&mh-send
	(message "Sending...") (sit-for 0)
	(end-of-file)
	(insert-string "\n----------\n")
	(write-current-file)
	(set-mark)
	(fast-filter-region (concat "send -noverbose " (current-file-name)))
	(beginning-of-file)
	(insert-string "Message-sent: " (current-time) "\n")
	(setq buffer-is-modified 0)
	(message "")(sit-for 0)
	(novalue)
    )
)

; Include the current message into the message being composed.
; 
(defun
    (&mh-include fn
	(save-excursion
	    (temp-use-mh-buffer)
	    (setq fn (&mh-get-fname))
	)
	(insert-file fn)
    )
)

(defun
    (mail-mode
	(text-mode)
	(set "right-margin" 72)
	(local-bind-to-key "&mh-include" "\^X\^Y")
	(local-bind-to-key "&mh-send" "\^Xs")
	(message "Use ^Xs to send message.")
    )
)

