(if (! (is-bound rmail-default-log))
    (load "rmail.ml"))
(message "Loading the news system, please wait...")
(sit-for 0)

; Unix Emacs readnews facility.

; "rnews" is used for reading news.  Executing it places your news
; directory into a window and enters a special command interpretation loop.
; The commands that it understands are:
;  p	move to the previous message.
;  n	move to the next message.
; Mp	move to previous undeleted message
; Mn	move to next undeleted message
; \n	set current message pointer to location of mark
;  =	print # of current message and total # of messages
;  f	move forward in the current message.
;  b	move backward in the current message.
; ^D	delete the current message.
;  d	delete current message and move to next message
;  u	undelete the last deleted message.
;  a	append current message to a file
;  g	goto absolute message number
;  s	skip a number of messages
;  <	go to first message
;  >	go to last message
;  D	decrypt message body
;  T	top of message
;  t	top of message
; ^r	reverse search for string
; ^s	forward search for string
;  r	reply to the current message.
;  m	enter smail, to send mail.
;  a	append the current message to a file.
;  F	Post a followup to the current message.
;  P	Post a message.
;  e	erase or expunge deleted messages
;  q	quit out of rnews, removing all deleted messages

; "smail" is used for sending mail.  It places you in a buffer for
; constructing the message and locally defines a few commands:
;  ^X^S	send the mail -- if all went well the window will disappear,
;	otherwise a message indicating which addresses failed will appear
;	at the bottom of the acreen.  Unfortunatly, the way the mailers on
;	Unix work, the message will have been sent to those addresses which
;	succeded and not to the others, so you have to delete some
;	addresses and fix up the others before you resend the message.
;  ^Xt	positions you in the To: field of the message.
;  ^Xc	positions you in the Cc: field of the message, creating it if it
;	doesn't already exist.
; 		The abbrev facility is used for mail address expansion,
; 		the file /usr/local/lib/emacs/RMailAbbrevs should contain
; 		abbrev definitions to expand login names to their
;		proper mail address.  This gets used at CMU since we have
;		7 VAXen, 4 10's and countless 11's;  remembering where a
;		person usually logs in is nearly impossible.
;  ^Xs	positions you in the Subject: field of the message.
;  ^Xa	positions you to the end of the body of the message, ready to
; 	append more text.

(declare-global rnews-message-number)
(declare-global rnews-message-count)
(if (! (is-bound rnews-auto-top-of-message))
    (setq-default rnews-auto-top-of-message 0))

(defun
    (rnews nbx			; The top level mail reader
	(setq nbx (concat (getenv "HOME") "/Messages/Newsbox"))
	(message "Please wait while I read your news file...")
	(sit-for 0)
	(save-window-excursion
	    (pop-to-buffer "rnews-directory")
	    (setq mode-line-format
		(concat "     News from message file "
		    (substr nbx 1 -1)
		    "      %M   %[%p%]"))
	    (setq needs-checkpointing 0)
	    (setq mode-string "RNews")
	    (erase-buffer)
	    (set-mark)
	    (if (= prefix-argument-provided 0)
		(filter-region (concat "readnews -e >> " nbx)))
	    (read-file nbx)
	    (end-of-file)
	    (setq case-fold-search 0)
	    (if (error-occured (re-search-reverse "^[>N ]"))
		(beginning-of-file)
		(next-line)
	    )
	    (error-occured
		(re-replace-string "^" "N "))
	    (setq case-fold-search 1)
	    (rnews-position)
	    (rnews-count-messages)
	    (rnews-mark)
	    (sit-for 0)
	    (message "Type ^C to exit rnews; ? for help")
	    (recursive-edit)
	    (pop-to-buffer "rnews-directory")
	    (rnews-erase-messages)
	    (if buffer-is-modified (write-current-file))
	)
	(novalue)
    )
)

(defun
    (rnews-position
	(beginning-of-line)
	(if (! (looking-at "^>"))
	    (progn
		(beginning-of-file)
		(error-occured (re-search-forward "^>"))
		(beginning-of-line)
		(setq rnews-message-number (find-line))
	    )
	)
    )
)

(defun
    (rnews-pickup rnews-file
	(beginning-of-line)
	(save-excursion
	    (provide-prefix-argument 2 (forward-character))
	    (set-mark)
	    (search-forward " ")
	    (backward-character)
	    (setq rnews-file (region-to-string))
	    (pop-to-buffer "current-message")
	    (setq needs-checkpointing 0)
	    (if (error-occured
		    (read-file (concat "/usr/spool/news/" rnews-file)))
		(progn
		    (erase-buffer)
		    (message (concat rnews-file " has expired"))
		)
	    )
	    (if rnews-auto-top-of-message
		(rnews-skip-header)
		(beginning-of-file))
	    (set-rnews-mode-line-format)
	    (setq case-fold-search 1)
	    (set-mark)
	)
    )
)

(defun
    (rnews-erase-messages
	(save-excursion
	    (pop-to-buffer "rnews-directory")
	    (beginning-of-line)
	    (if (looking-at "^.D")
		(rnews-previous-undeleted-message))
	    (beginning-of-file)
	    (error-occured
		(while 1
		    (re-search-forward "^.D")
		    (beginning-of-line)
		    (set-mark)
		    (end-of-line)
		    (forward-character)
		    (erase-region)
		)
	    )
	    (setq rnews-message-count 0)
	)
    )
)

(defun
    (rnews-com
	(argc)
	(rnews)
	(exit-emacs)
    )
)

(defun
    (rnews-next-page
	(save-excursion
	    (pop-to-buffer "current-message")
	    (next-page)
	    (beginning-of-window)
	    (set-rnews-mode-line-format)
	))
    (rnews-previous-page
	(save-excursion
	    (pop-to-buffer "current-message")
	    (previous-page)
	    (beginning-of-window)
	    (set-rnews-mode-line-format)
	))
    (set-rnews-mode-line-format
	(save-excursion foo
	    (if (= rnews-message-number 0)
		(rnews-count-messages))
	    (pop-to-buffer "current-message")
	    (setq foo (concat "     Message " rnews-message-number
			      "/" rnews-message-count))
	    (while (< (length foo) 25)
		   (setq foo (concat foo " ")))
	    (setq foo (concat foo "%[%p%]"))
	    (end-of-file)
	    (setq mode-line-format
		(if (dot-is-visible)
		    foo (concat foo "   --More--")))
    )))

(defun
    (rnews-next-message
	(rnews-position)
	(delete-next-character)
	(insert-character ' ')
	(beginning-of-line)
	(next-line)
	(if (eobp) (progn (previous-line)
			  (message "You're at the last message already")))
	(delete-next-character)
	(insert-character '>')
	(setq rnews-message-number (+ rnews-message-number 1))
	(rnews-pickup)
    )
)

(defun
    (rnews-previous-message
	(rnews-position)
	(delete-next-character)
	(insert-character ' ')
	(previous-line)
	(beginning-of-line)
	(delete-next-character)
	(insert-character '>')
	(setq rnews-message-number (- rnews-message-number 1))
	(if (= rnews-message-number 0)
	    (setq rnews-message-number 1))
	(rnews-pickup)
    )
)

(defun
    (rnews-previous-undeleted-message
	(rnews-unmark)
	(previous-line)
	(beginning-of-line)
	(while (& (> (dot) 1) (looking-at "^.D"))
	       (previous-line)
	       (beginning-of-line))
	(setq rnews-message-number (find-line))
	(rnews-mark)
    )
    (rnews-next-undeleted-message
	(rnews-unmark)
	(next-line)
	(beginning-of-line)
	(while (& (! (eobp)) (looking-at "^.D"))
	       (next-line)
	       (beginning-of-line))
	(setq rnews-message-number (find-line))
	(rnews-mark)
    )
    (rnews-decrypt-message
	(save-window-excursion
	    (pop-to-buffer "current-message")
	    (if (= prefix-argument-provided 0)
		(progn
		      (setq case-fold-search 1)
		      (beginning-of-file)
		      (search-forward "\n\n")	; Skip to first blank line
		      (while (looking-at "^#")	; In case of notesfile header
			     (search-forward "\n\n"))
		)
		(provide-prefix-argument prefix-argument (next-line)))
	    (set-mark)
	    (end-of-file)
	    (filter-region "/usr/local/decrypt")
	    (exchange-dot-and-mark)
	    (line-to-top-of-window)
	)
    )
    (rnews-skip-header
	(save-excursion
	    (pop-to-buffer "current-message")
	    (setq case-fold-search 1)
	    (beginning-of-file)
	    (search-forward "\n\n")
	    (while (looking-at "^#")	; In case of notesfile header
		   (search-forward "\n\n"))
	    (line-to-top-of-window)
	)
    )
)

(defun
    (rnews-delete-message
	(rnews-position)
	(forward-character)
	(delete-next-character)
	(insert-character 'D')
	(beginning-of-line)
    )
)

(defun
    (rnews-undelete-message
	(rnews-position)
	(forward-character)
	(delete-next-character)
	(insert-character ' ')
	(beginning-of-line)
    )
)

(defun
    (rnews-delete-and-next-message
    	(rnews-delete-message)
	(rnews-next-message)
    )
)

(autoload "&info" "info.ml")

(defun
    (rnews-help
	(&info "emacs" "rnews")))

(defun
    (rnews-reply subject dest excess refs
	(setq subject "")
	(setq dest "")
	(setq excess "")
	(save-window-excursion
	    (pop-to-buffer "current-message")
	    (setq case-fold-search 1)
	    (beginning-of-file)
	    (search-forward "\n\n")
	    (set-mark)
	    (beginning-of-file)
	    (narrow-region)
	    (error-occured
		(re-search-forward "^Title:[ \t]*\\(.*\\)")
		(region-around-match 1)
		(setq subject (region-to-string))
		(if (!= (substr subject 1 3) "Re:")
		    (setq subject (concat "Re: " subject))
		)
	    )
	    (beginning-of-file)
	    (error-occured
		(if (error-occured (re-search-forward
				       "^reply-to:[ \t]*\\(.*\\)"))
		    (if (error-occured (re-search-forward
					   "^from:[ \t]*[^ \t!]*!\\(.*\\)"))
			(re-search-forward "^from[ \t]*\\(.[^ \t]*\\)")
		    )
		)
		(region-around-match 1)
		(setq dest (region-to-string))
	    )
	    (beginning-of-file)
	    (error-occured edest
		(save-excursion 
		    (temp-use-buffer "Scratch Stuff")
		    (setq needs-checkpointing 0)
		    (erase-buffer)
		    (insert-string dest)
		    (set-mark)
		    (beginning-of-file)
		    (if (! (error-occured
			(re-search-forward " (\\(.*\\))")))
			(progn
			    (region-around-match 1)
			    (setq dest (region-to-string))
			    (beginning-of-file)
			    (insert-string (concat dest "  <"))
			    (re-replace-string "  *(.*" ">")
			    (end-of-line)
			    (set-mark)
			    (beginning-of-line)
			    (setq dest (region-to-string))
			)
		    )
		    (error-occured 
			(re-replace-string
			    "  *at  *[^,\n]*\\| *@ *[^,\n]*\\| *([^)\n]*)\\| *<[^>\n]*>"
			    ""))
		    (error-occured
			(re-replace-string ".*!" ""))
		    (setq edest (region-to-string))
		)
		(if (error-occured
			(re-search-forward "^Posted:[ \t]*"))
		    (re-search-forward "^Received:[ \t]*.[^ \t]*[ \t]*"))
		(set-mark)
		(end-of-line)
		(setq excess (concat
				 "In-Reply-To: "
				 edest "'s message of "
				 (region-to-string)
				 "\n"))
		(beginning-of-file)
		(error-occured
		    (re-search-forward "^Article-I.D.:[ \t]*\\(.*\\)")
		    (region-around-match 1)
		    (setq refs (concat "References: " (region-to-string)))
		)
	    )
	    (widen-region)
	    (pop-to-buffer "send-mail")
	    (setq needs-checkpointing 0)
	    (setq case-fold-search 1)
	    (erase-buffer)
	    (insert-string subject)
	    (newline)
	    (insert-string dest)
	    (newline)
	    (insert-string excess)
	    (insert-string refs)
	    (newline)
	    (do-mail-setup)
	)
	(rnews-position)
	(if (looking-at "^>")
	    (progn
		(forward-character)
		(delete-next-character)
		(insert-character 'A')
		(beginning-of-line)))
    )
)

(defun
    (rnews-followup newsgroups title refs
	(setq newsgroups "")
	(setq title "")
	(setq refs "")
	(save-window-excursion
	    (pop-to-buffer "current-message")
	    (beginning-of-file)
	    (search-forward "\n\n")
	    (set-mark)
	    (beginning-of-file)
	    (narrow-region)
	    (error-occured
		(re-search-forward "^Newsgroups:[ \t]*\\(.*\\)")
		(region-around-match 1)
		(setq newsgroups (region-to-string))
	    )
	    (save-excursion
		(temp-use-buffer "Scratch Stuff")
		(setq needs-checkpointing 0)
		(erase-buffer)
		(insert-string newsgroups)
		(beginning-of-file)
		(error-occured
		    (replace-string "general" "followup"))
		(set-mark)
		(end-of-file)
		(setq newsgroups (region-to-string))
	    )
	    (beginning-of-file)
	    (error-occured
		(re-search-forward "^Title:[ \t]*\\(.*\\)")
		(region-around-match 1)
		(setq title (region-to-string))
		(if (!= (substr title 1 3) "Re:")
		    (setq title (concat "Re: " title))
		)
	    )
	    (beginning-of-file)
	    (error-occured
		(re-search-forward "^Article-I.D.:[ \t]*\\(.*\\)")
		(region-around-match 1)
		(setq refs (region-to-string))
	    )
	    (beginning-of-file)
	    (widen-region)
	    (pop-to-buffer "send-mail")
	    (setq needs-checkpointing 0)
	    (setq case-fold-search 1)
	    (erase-buffer)
	    (insert-string (concat "Newsgroups: " newsgroups))
	    (newline)
	    (insert-string (concat "Title: " title))
	    (newline)
	    (insert-string (concat "References: " refs))
	    (newline)
	    (newline)
	    (rnews-do-post)
	)
	(rnews-position)
	(if (looking-at "^>")
	    (progn
		(forward-character)
		(delete-next-character)
		(insert-character 'F')
		(beginning-of-line)))
    )

    (rnews-post
	(save-window-excursion
	    (pop-to-buffer "send-mail")
	    (setq needs-checkpointing 0)
	    (setq case-fold-search 1)
	    (erase-buffer)
	    (insert-string "Newsgroups: \nTitle: \n\n")
	    (beginning-of-file)
	    (end-of-line)
	    (rnews-do-post)
	)
    )

    (rnews-do-post rnews-do-send
	(setq rnews-do-send 1)
	(setq right-margin 72)
	(local-bind-to-key "exit-emacs" "\^X\^S")
	(local-bind-to-key "rnews-abort-send" "\^X\^A")
	(local-bind-to-key "justify-paragraph" "\ej")
	(recursive-edit)
	(if (= rnews-do-send 1)
	    (rnews-call-inews))
    )

    (rnews-call-inews newsgroups title refs
	(save-excursion
	    (setq newsgroups "")
	    (setq title "")
	    (setq refs "")
	    (beginning-of-file)
	    (search-forward "\n\n")
	    (set-mark)
	    (beginning-of-file)
	    (narrow-region)
	    (error-occured
		(re-search-forward "^Newsgroups:[ \t]*\\(.*\\)")
		(region-around-match 1)
		(setq newsgroups (region-to-string))
	    )
	    (if (= (length newsgroups) 0)
		(setq newsgroups (get-tty-string "Newsgroups [general]: ")))
	    (if (= (length newsgroups) 0)
		(setq newsgroups "general"))
	    (beginning-of-file)
	    (error-occured
		(re-search-forward "^Title:[ \t]*\\(.*\\)")
		(region-around-match 1)
		(setq title (region-to-string))
	    )
	    (if (= (length title) 0)
		(setq title (get-tty-string "Title: ")))
	    (beginning-of-file)
	    (error-occured
		(re-search-forward "^References:[ \t]*\\(.*\\)")
		(region-around-match 1)
		(setq refs (concat " -F " (region-to-string)))
	    )
	    (widen-region)
	    (beginning-of-file)
	    (search-forward "\n\n")
	    (set-mark)
	    (end-of-file)
	    (copy-region-to-buffer "Delivery-errors")
	    )
	(message "Sending...")
	(sit-for 0)
	(save-window-excursion
	    (switch-to-buffer "Delivery-errors")
	    (beginning-of-file)
	    (set-mark)
	    (end-of-file)
	    (filter-region
		(concat "inews" refs " -n " newsgroups " -t '" title "'"))
	    (beginning-of-file)
	    (set-mark)
	    (error-occured (re-replace-string "\n\n* *" "; "))
	    (end-of-line)
	    (message (region-to-string))
	)
    )

    (rnews-abort-send
	(if (!= "y" (substr (get-tty-string
				"Do you really want to abort the message? ")
			    1 1))
	    (error-message "Turkey!"))
	(setq rnews-do-send 0)
	(exit-emacs)
    )
)

(defun
    (rnews-unmark
	(error-occured
	    (rnews-position)
	    (delete-next-character)
	    (insert-character ' ')
	    (beginning-of-line)))
    
    (rnews-mark
	(if (error-occured
		(beginning-of-line)
		(if (eobp)
		    (re-search-reverse "^.")
		    (progn
			(re-search-forward "^.")
			(beginning-of-line)))
		(delete-next-character)
		(insert-character '>')
		(rnews-position)
		(rnews-pickup)
	    )
	    (message "No messages"))
    )
)

(defun
    (rnews-search-forward
	(rnews-unmark)
	(error-occured (re-search-forward
			   (get-tty-string "Search forward: ")))
	(rnews-mark)
	
    )
)

(defun
    (rnews-search-reverse
	(rnews-unmark)
	(error-occured (re-search-reverse
			   (get-tty-string "Search reverse: ")))
	(rnews-mark)
    )
)

(defun
    (rnews-goto-message n
	(setq n (get-tty-string "Goto message: "))
	(rnews-unmark)
	(beginning-of-file)
	(provide-prefix-argument (- n 1) (next-line))
	(rnews-mark)
    )
)

(defun
    (rnews-first-message
	(rnews-unmark)
	(beginning-of-file)
	(setq rnews-message-number 1)
	(rnews-mark)
    )
)

(defun
    (rnews-last-message
	(rnews-unmark)
	(end-of-file)
	(setq rnews-message-number rnews-message-count)
	(rnews-mark)
    )
)

(defun
    (rnews-skip n
	(setq n (get-tty-string "Skip messages: "))
	(rnews-unmark)
	(provide-prefix-argument n (next-line))
	(setq rnews-message-number (+ rnews-message-number n))
	(rnews-mark)
    )
)

(defun
    (rnews-this-message save-dot
	(setq save-dot (dot))
	(rnews-unmark)
	(goto-character save-dot)
	(rnews-mark)
    )
)

(declare-global rnews-newsdir)
(declare-global rnews-default-log)

(save-excursion rnews-newsbox
    (if (error-occured (setq rnews-newsbox (getenv "NEWSBOX")))
	(setq rnews-newsbox "~"))
    (if (| (! (file-exists rnews-newsbox)) (is-text-file rnews-newsbox))
	(progn
	    (setq rnews-newsdir "~")
	    (setq rnews-default-log rnews-newsbox))
	(progn
	    (setq rnews-newsdir rnews-newsbox)
	    (setq rnews-default-log (concat rnews-newsdir "/Newsbox"))))
)

(defun
    (rnews-append file
	(setq file (get-tty-string (concat ": append-message-to-file ["
				       rnews-default-log "]  ")))
	(if (= file "")
	    (setq file rnews-default-log))
	(if (! (| (= "/" (substr file 1 1))
		  (= "$" (substr file 1 1))
		  (= "~" (substr file 1 1))))
	    (setq file (concat rnews-newsdir "/" file)))
	(save-excursion
	    (temp-use-buffer "current-message")
	    (append-to-file file)
	)
	(setq rnews-default-log file)
	(message (concat "Appended to " rnews-default-log))
	(sit-for 0)
    )
)

(defun
    (rnews-count-messages
	(pop-to-buffer "rnews-directory")
	(rnews-position)
	(setq rnews-message-number (find-line))
	(end-of-file)
	(setq rnews-message-count (- (find-line) 1))
	(rnews-position)
    )
)

(save-excursion i
    (temp-use-buffer "rnews-directory")
    (setq i ' ')
    (while (< i 128)
	(local-bind-to-key "illegal-operation" i)
	(setq i (+ i 1)))
    (local-bind-to-key "rnews-next-page" ' ')
    (local-bind-to-key "rnews-next-page" 'f')
    (local-bind-to-key "rnews-next-page" '^f')
    (local-bind-to-key "rnews-next-page" '^v')
    (local-bind-to-key "rnews-previous-page" 'b')
    (local-bind-to-key "rnews-previous-page" '^b')
    (local-bind-to-key "rnews-previous-page" '^H')
    (local-bind-to-key "rnews-previous-page" "\e\^V")
    (local-bind-to-key "rnews-next-message" 'n')
    (local-bind-to-key "next-line" '^N')
    (local-bind-to-key "rnews-next-undeleted-message" "\eN")
    (local-bind-to-key "rnews-next-undeleted-message" "\en")
    (local-bind-to-key "rnews-previous-message" 'p')
    (local-bind-to-key "previous-line" '^P')
    (local-bind-to-key "rnews-previous-undeleted-message" "\eP")
    (local-bind-to-key "rnews-previous-undeleted-message" "\ep")
    (local-bind-to-key "rnews-delete-message" '^D')
    (local-bind-to-key "rnews-delete-and-next-message" 'd')
    (local-bind-to-key "next-window" 'o')
    (local-bind-to-key "rnews-undelete-message" 'u')
    (local-bind-to-key "rnews-help" '?')
    (local-bind-to-key "exit-emacs" 'q')
    (local-bind-to-key "rnews-reply" 'r')
    (local-bind-to-key "rnews-followup" 'F')
    (local-bind-to-key "rnews-post" 'P')
    (local-bind-to-key "smail" 'm')
    (local-bind-to-key "rnews-search-forward" '^s')
    (local-bind-to-key "rnews-search-reverse" '^r')
    (local-bind-to-key "rnews-goto-message" 'g')
    (local-bind-to-key "rnews-first-message" '<')
    (local-bind-to-key "rnews-last-message" '>')
    (local-bind-to-key "rnews-skip" 's')
    (local-bind-to-key "rnews-append" 'a')
    (local-bind-to-key "rmail-shell" '!')
    (local-bind-to-key "rnews-decrypt-message" "D")
    (local-bind-to-key "rnews-skip-header" 't')
    (local-bind-to-key "rnews-skip-header" 'T')
    (local-bind-to-key "rnews-erase-messages" 'e')
    (local-bind-to-key "execute-extended-command" ':')
    (local-bind-to-key "execute-extended-command" "\ex")
    (local-bind-to-key "rnews-this-message" '\r')
    (local-bind-to-key "redraw-display" '^L')
)
