; $Header: RCS/rmail.ml,v 1.5 83/05/18 13:41:16 thomas Exp $
(message "Loading the mail system, please wait...")
(setq-default rmail-pathalias 0)
(setq-default mail-headers-to-ignore
    "received|origin|via|message-id|status|remailed-to|remailed-date")
(setq-default &mail-headers-to-ignore "")
(sit-for 0)
; Unix Emacs RMail facility.  implements rmail (read mail) and
; smail (send mail).

; "rmail" is used for reading mail.  Executing it places your incoming
; mailbox into a window and enters a special command interpretation loop.
; The commands that it understands are:
;  p	move to the previous message.
;  n	move to the next message.
;  f	move forward in the current message.
;  b	move backward in the current message.
;  o	go to other window (usually current message window.)
;  d	delete the current message.
;  u	undelete the last deleted message.
;  r	reply to the current message.
;  q	quit out of RMail, appending all undeleted messages to mbox.

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

(defun
    (rmail mbx entry-name		; The top level mail reader
	(setq mbx (concat (getenv "HOME") "/Messages/"))
	(message "Please wait while I read your mail file...")
	(sit-for 0)
	(save-window-excursion
	    (pop-to-buffer "rmail-directory")
	    (setq mode-line-format
		(concat "     Mail from message file "
		    (substr mbx 1 -1)
		    "      %M   %[%p%]"))
	    (setq needs-checkpointing 0)
	    (if (! (is-bound  &IN_RMAIL&))
		(progn
		      (if buffer-is-modified (write-current-file))
		      (set-mark)
		      (if (! prefix-argument-provided)
			  (filter-region
			      (concat "/usr/local/lib/emacs/collectmail "
				      mbx
				      " $HOME/BlindBox /usr/spool/mail/$USER"))
		      )
		      (read-file (concat mbx "Directory"))
		      (beginning-of-file)
		      (if (! (eolp)) (insert-character '\n'))
		      (setq case-fold-search 1)
		      (setq mode-string "RMail")
		      (mail-ignore-headers mail-headers-to-ignore)
		      (position-on-dirent)
		      (pick-up-message)
		      (sit-for 0)
		      (message "Type ESC-^Z to exit rmail; ? for help")
		      (progn  &IN_RMAIL&
			      (recursive-edit))
		      (pop-to-buffer "rmail-directory")
		      (erase-messages)
		      (if buffer-is-modified (write-current-file))
		)
		(progn
		      (end-of-file)
		      (set-mark)
		      (filter-region
			  (concat "/usr/local/lib/emacs/collectmail - "
				  mbx
				  " $HOME/BlindBox /usr/spool/mail/$USER"))
		      (position-on-dirent)
		      (beginning-of-line)
		      (write-current-file)
		)
	    )
	)
	(novalue)
    )
)

(defun
    (mail-ignore-headers
	(setq mail-headers-to-ignore (arg 1 ": mail-ignore-headers "))
	(if (!= mail-headers-to-ignore "")
	    (save-excursion
		(temp-use-buffer "Scratch")
		(erase-buffer)
		(insert-string mail-headers-to-ignore)
		(beginning-of-file)
		(error-occured (replace-string "|" ":\\|^"))
		(insert-character '\^')
		(set-mark)
		(end-of-file)
		(insert-character ':')
		(setq &mail-headers-to-ignore (region-to-string))
	    )
	    (setq &mail-headers-to-ignore "")
	)
    )

    (position-on-dirent
	(pop-to-buffer "rmail-directory")
	(if (= (buffer-size) 0) (read-file (concat mbx "Directory")))
	(if (! (looking-at "^>[^0-9\n]*\\([0-9][0-9]*\\)"))
	    (progn
		(beginning-of-file)
		(if (error-occured (re-search-forward ""))
		    (progn
			(beginning-of-file)
			(if (error-occured (search-forward "^ N"))
			    (end-of-file))
			(rmail-mark)
			(if (! (looking-at "^>[^0-9\n]*\\([0-9][0-9]*\\)"))
			    (error-message "No messages"))))
	    ))
	(region-around-match 1)
	(setq entry-name (region-to-string))
	(beginning-of-line)
    )
)

(defun
    (pick-up-message
	(position-on-dirent)
	(save-excursion
	    (pop-to-buffer "current-message")
	    (set-rmail-mode-line-format)
	    (setq needs-checkpointing 0)
	    (read-file (concat mbx entry-name))
	    (beginning-of-file)
	    (setq case-fold-search 1)
	    (set-mark)
	    (if (! prefix-argument-provided)
	    (error-occured
		(save-restriction
		    (re-search-forward "^$")
		    (narrow-region)
		    (beginning-of-file)
		    (while (!= &mail-headers-to-ignore "")
			   (re-search-forward &mail-headers-to-ignore)
			   (beginning-of-line)
			   (mail-extend-field)
			   (forward-character)
			   (erase-region))
		    (error-occured (re-replace-string "\nvia:.*" ""))
		    (error-occured (re-replace-string "\nmail-from:.*" ""))
		    (error-occured (re-replace-string "\norigin:.*" ""))))
	    )
	    (setq buffer-is-modified 0)
	)
    )
)

(defun
    (erase-messages
	(save-excursion
	    (pop-to-buffer "rmail-directory")
	    (beginning-of-file)
	    (error-occured (re-replace-string "^.N" "  "))
	    (error-occured fn
		(while 1
		    (re-search-forward "^.D[^0-9\n]*\\([0-9]*\\)")
		    (region-around-match 1)
		    (unlink-file (concat mbx (region-to-string)))
		    (beginning-of-line)
		    (set-mark)
		    (end-of-line)
		    (forward-character)
		    (erase-region)
		)
	    )
	)
    )
)

(defun
    (rmail-com
	(argc)
	(rmail)
	(exit-emacs)
    )
)

(defun
    (smail-com i
	(declare-global exit-when-through)
	(pop-to-buffer "send-mail")
	(setq needs-checkpointing 0)
	(setq case-fold-search 1)
	(erase-buffer)
	(if (! (is-bound read-mail-abbrevs))
	    (progn (declare-global read-mail-abbrevs)
		(quietly-read-abbrev-file "/usr/local/lib/emacs/RMailAbbrevs")
	    )
	)
	(use-abbrev-table "RMail")
	(setq i 1)
	(newline)
	(while (> (argc) i)
	    (if (!= (substr (argv i) 1 1) "-")
		(progn
		    (insert-string (argv i))
		    (if (> (argc) i) (insert-character ','))
		)
	    )
	    (setq i (+ i 1))
	)
	(newline)
	(do-mail-setup)
	(exit-emacs)
    )
    
    (rmail-next-page
	(save-excursion
	    (pop-to-buffer "current-message")
	    (next-page)
	    (set-rmail-mode-line-format)
	))
    
    (rmail-previous-page
	(save-excursion
	    (pop-to-buffer "current-message")
	    (previous-page)
	    (set-rmail-mode-line-format)
	))

    (rmail-all-headers
	(provide-prefix-argument 1 (pick-up-message)))

    (rmail-top-of-message
	(save-excursion
	    (pop-to-buffer "current-message")
	    (beginning-of-file)
	    (set-rmail-mode-line-format)
	)
    )

    (rmail-pass-headers
	(save-excursion
	    (pop-to-buffer "current-message")
	    (beginning-of-file)
	    (if (error-occured (re-search-forward "^\n\n*"))
		(end-of-file))
	    (line-to-top-of-window)
	    (set-rmail-mode-line-format)
	)
    )
)

(defun
    (set-rmail-mode-line-format
	(save-excursion 
	    (end-of-file)
	    (setq mode-line-format
		(if (dot-is-visible)
		    "     Current message       %[%p %M%]"
		    "     Current message       %[%p %M%]   --More--")))
    ))
(defun
    (rmail-next-message
	(position-on-dirent)
	(delete-next-character)
	(insert-character ' ')
	(beginning-of-line)
	(next-line)
	(if (eobp) (progn (previous-line)
			  (message "You're at the last message already")))
	(delete-next-character)
	(insert-character '>')
	(backward-character)
	(pick-up-message)
    )
)

(defun
    (rmail-previous-message
	(position-on-dirent)
	(delete-next-character)
	(insert-character ' ')
	(beginning-of-line)
	(previous-line)
	(if (bobp) (progn (next-line)
			  (message "You're at the first message")))
	(delete-next-character)
	(insert-character '>')
	(backward-character)
	(pick-up-message)
    )
)

(defun
    (rmail-delete-message
	(position-on-dirent)
	(forward-character)
	(delete-next-character)
	(insert-character 'D')
	(beginning-of-line)
    )

    (rmail-delete-message-next
	(rmail-delete-message)
	(rmail-next-message)
    )

    (rmail-delete-message-previous
	(rmail-delete-message)
	(rmail-previous-message)
    )
)

(defun
    (rmail-undelete-message
	(position-on-dirent)
	(forward-character)
	(delete-next-character)
	(insert-character ' ')
	(beginning-of-line)
    )
)

(autoload "&info" "info.ml")

(defun
    (rmail-help
	(&info "emacs" "rmail")))

(defun
    (rmail-reply
	(save-window-excursion
	    (rmail-setup-reply)
	    (do-mail-setup)
	)
	(position-on-dirent)
	(if (looking-at "^>[N ]")
	    (progn
		  (forward-character)
		  (delete-next-character)
		  (insert-character 'A')
		  (beginning-of-line)))
    )
)
(defun 
    (rmail-setup-reply subject dest excess
	(setq subject "")
	(setq dest "")
	(setq excess "")
	(pop-to-buffer "current-message")
	(setq case-fold-search 1)
	(beginning-of-file)
	(search-forward "\n\n")
	(set-mark)
	(beginning-of-file)
	(narrow-region)
	(error-occured
	    (re-search-forward "^Subject:[ \t]*\\(.*\\)")
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
				       "^from:[ \t]*\\(.*\\)"))
		    (re-search-forward "^from[ \t]*\\(.[^ \t]*\\)")
		)
	    )
	    (region-around-match 1)
	    (exchange-dot-and-mark)
	    (save-restriction
		(narrow-region)
		(if (looking-at ".*<\\(.*\\)>")
		    (region-around-match 1)))
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
		(error-occured 
		    (re-replace-string
			"  *at  *[^,\n]*\\| *@ *[^,\n]*\\| *([^)\n]*)\\| *<[^>\n]*>"
			""))
		(setq edest (region-to-string)))
	    (if (error-occured
		    (re-search-forward "^date:[ \t]*"))
		(re-search-forward "^from[ \t]*.[^ \t]*[ \t]*"))
	    (set-mark)
	    (end-of-line)
	    (setq excess (concat
				"In-Reply-To: "
				edest "'s message of "
				(region-to-string)
				"\n"))
	)
	(widen-region)
	(pop-to-buffer "send-mail")
	(setq case-fold-search 1)
	(erase-buffer)
	(insert-string subject)
	(newline)
	(insert-string dest)
	(newline)
	(insert-string excess)
	(error-occured
	    (beginning-of-file)
	    (search-forward "In-Reply-To: ")
;		(replace-string ":" "")
	)
    )
)

(defun
    (rmail-unmark
	(error-occured
	    (position-on-dirent)
	    (delete-next-character)
	    (insert-character ' ')
	    (beginning-of-line)))
    
    (rmail-mark
	(if (error-occured
		(beginning-of-line)
		(if (eobp)
		    (re-search-reverse "^.")
		    (progn
			(re-search-forward "^.")
			(beginning-of-line)))
		(delete-next-character)
		(insert-character '>')
		(beginning-of-line)
		(position-on-dirent)
		(pick-up-message)
	    )
	    (message "No messages"))
    )
)

(defun
    (rmail-search-forward
	(rmail-unmark)
	(error-occured (re-search-forward
			   (get-tty-string "Search forward: ")))
	(rmail-mark)
	
    )
)

(defun
    (rmail-search-reverse
	(rmail-unmark)
	(error-occured (re-search-reverse
			   (get-tty-string "Search reverse: ")))
	(rmail-mark)
    )
)

(defun
    (rmail-goto-message n
	(setq n (get-tty-string "Goto message: "))
	(rmail-unmark)
	(beginning-of-file)
	(provide-prefix-argument n (next-line))
	(rmail-mark)
    )
)

(defun
    (rmail-first-message
	(rmail-unmark)
	(beginning-of-file)
	(rmail-mark)
    )
)

(defun
    (rmail-last-message
	(rmail-unmark)
	(end-of-file)
	(rmail-mark)
    )
)

(defun
    (rmail-skip n
	(if (! prefix-argument-provided)
	    (setq n (get-tty-string "Skip messages: "))
	    (setq n prefix-argument))
	(rmail-unmark)
	(provide-prefix-argument n (next-line))
	(rmail-mark)
    )
)

(defun (rmail-but-mark
	   (save-excursion (rmail-unmark))
	   (rmail-mark)))

(defun (rmail-but-delete
	   (rmail-but-mark)
	   (rmail-delete-message)))

(defun
    (mail-insert
	(mail-append)
	(save-excursion
	    (insert-string "\n_________________________________\n")
	    (yank-buffer "current-message"))
	(re-replace-string "^From \\|^Date:" ">&"))

    (mail-noblind-exit
	(setq mail-append-blind 0)
	(exit-emacs))
)

(defun    
    (smail 	        ; initiate mail sending
	(save-window-excursion
	    (pop-to-buffer "send-mail")
	    (setq case-fold-search 1)
	    (erase-buffer)
	    (do-mail-setup)
	)
	(novalue)
    )
    
    ; set things up in a mail sending buffer.
    (do-mail-setup mail-do-send mail-append-blind
	(beginning-of-file)     ; makemail is a tiny little C program that
	(set-mark) 	        ; builds a prototype mail header from an
	(end-of-file) 	        ; input subject and destination.
	(setq mode-string "SMail")
	(setq mail-do-send 1)
	(setq mail-append-blind 1)
	(if (! (is-bound read-mail-abbrevs))
	    (progn (declare-global read-mail-abbrevs)
		(quietly-read-abbrev-file "/usr/local/lib/emacs/RMailAbbrevs")
	    )
	)
	(use-abbrev-table "RMail")
	(filter-region "/usr/local/lib/emacs/makemail")
	(beginning-of-file)
	(search-forward "hErE<!}")
	(delete-previous-word)
	(setq abbrev-mode (= (current-column) 5))
	(setq right-margin 72)
	(change-file-name "~/live.letter")
	(remove-all-local-bindings)
	(local-bind-to-key "rmail-help" "\^X?")
	(local-bind-to-key "mail-to" "\^Zt")
	(local-bind-to-key "mail-append" "\^Za")
	(local-bind-to-key "mail-bcc" "\^Zb")
	(local-bind-to-key "mail-cc" "\^Zc")
	(local-bind-to-key "mail-subject" "\^Zs")
	(local-bind-to-key "mail-fetch-field" "\^Zf")
	(local-bind-to-key "mail-insert" "\^Zi")
	(local-bind-to-key "mail-noblind-exit" "\^X\^C")
;	(local-bind-to-key "exit-emacs" "\^X\^F")
	(local-bind-to-key "mail-abort-send" "\^X\^A")
	(local-bind-to-key "justify-paragraph" "\ej")
	(message "Type ESC-^Z to send the message; ^X^A to abort; ^X? for help.")
	(while mail-do-send
	    (save-excursion
		(recursive-edit)
		(if mail-do-send
		    (progn
			(message "Sending...")
			(sit-for 0))))
	    (if mail-do-send (send-mail)))
    )
)

(defun
    (mail-abort-send
	(if (!= "y" (substr (get-tty-string
				"Do you really want to abort the message? ")
			    1 1))
	    (error-message "Turkey!"))
	(setq mail-do-send 0)
	(exit-emacs))
    
    (mail-to 		        ; move to the "To:" field
	(abbrev-expand)
	(setq abbrev-mode 1)
	(mail-position-on-field "to")
	(setq left-margin 10)
    )
    
    (mail-subject 	        ; move to the "Subject:" field
	(abbrev-expand)
	(setq abbrev-mode 0)
	(mail-position-on-field "subject")
	(setq left-margin 10)
    )
    
    (mail-fetch-field		; fetch a field from the current message
	field-name field-contents
	(setq field-name (get-tty-string ": field name "))
	(save-excursion
	    (temp-use-buffer "current-message")
	    (beginning-of-file)
	    (setq case-fold-search 1)
	    (re-search-forward (concat "^" field-name "[^\n: ]*:[ \t]*"))
	    (mail-extend-field)
	    (setq field-contents (region-to-string))
	)
	(insert-string field-contents)
    )
    
    (mail-append 	        ; move to the body
	(abbrev-expand)
	(setq abbrev-mode 0)
	(end-of-file)
	(setq left-margin 1)
    )
    
    (mail-cc 		        ; move to the "cc:" field.
	(abbrev-expand)
	(setq abbrev-mode 1)
	(if (= (provide-prefix-argument 1 (mail-position-on-field "cc")) -1)
	    (progn
		  (mail-position-on-field "to")
		  (insert-string "\nCc: "))
	)
	(setq left-margin 10)
    )

    (mail-bcc
	(abbrev-expand)
	(setq abbrev-mode 1)
	(if (= (provide-prefix-argument 1 (mail-position-on-field "bcc")) -1)
	    (progn
		  (mail-position-on-field "to")
		  (insert-string "\nBcc: "))
	)
	(setq left-margin 10)
    )

    (mail-position-on-field field
	(save-restriction
	    (beginning-of-file)
	    (set-mark)
	    (if (error-occured (search-forward "\n\n"))
		(end-of-file)
		(backward-character))
	    (narrow-region)
	    (beginning-of-file)
	    (setq field (arg 1 ": mail-position-on-field "))
	    (if (error-occured (re-search-forward (concat "^" field ":")))
		(if prefix-argument-provided
		    -1
		    (progn
			  (end-of-file)
			  (backward-character)
			  (set-mark)
			  (insert-string "\n" field ": ")
			  (case-region-capitalize)
			  (set-mark)
			  0
		    )
		)
		(progn
		      (mail-extend-field)
		      0
		)
	    )
	)
    )

    (mail-extend-field
	(set-mark)
	(while (progn (end-of-line)
		      (looking-at "\n[ \t]"))
	       (forward-character))
    )

    (send-mail addresses		; finally send the mail
	(abbrev-expand)
	(beginning-of-file)
	(if (error-occured (re-search-forward "^$"))
	    (end-of-file))
	(set-mark)
	(beginning-of-file)
	(narrow-region)
	(setq addresses "")
;	(error-occured
;	    (re-search-forward "^to:[ \t]*")
;	    (mail-extend-field)
;	    (setq addresses (region-to-string)))
;	(beginning-of-file)
;	(error-occured
;	    (re-search-forward "^cc:[ \t]*")
;	    (mail-extend-field)
;	    (setq addresses (concat addresses ","
;				    (region-to-string))))
	(widen-region)
;	(message "sending...")
;	(save-excursion
;	    (temp-use-buffer "Scratch Stuff")
;	    (setq needs-checkpointing 0)
;	    (erase-buffer)
;	    (insert-string addresses)
;	    (beginning-of-file)
;	    (error-occured (re-replace-string "[\t\n]" " "))
;	    (error-occured (re-replace-string " *([^(]*)" ""))
;	    (error-occured (re-replace-string "[^,]*<\\([^>,]*\\)>" "\\1"))
;	    (error-occured (re-replace-string "  *at  *" "@"))
;	    (error-occured (re-replace-string "  *" "."))
;	    (error-occured (re-replace-string "\\.*,\\.*" " "))
;	    (error-occured (replace-string "!" "\\!"))
;	    (error-occured (re-replace-string "^  *\\|[ .][ .]*$" ""))
;	    (set-mark)
;	    (end-of-file)
;	    (setq addresses (region-to-string))
;	)
;	(message "Sending to " addresses " ...")(sit-for 0)

	(end-of-file)
	(if (! (bolp)) (newline))
	(if mail-append-blind
	    (progn
		  (mail-position-on-field "bcc")
		  (insert-string ", " (users-login-name))
	    ))
	(beginning-of-file)
	(set-mark)
	(end-of-file)
    	(filter-region "/usr/lib/sendmail -i -t")

	(if (= (buffer-size) 0)
	    (progn
		  (setq mail-do-send 0)
		  (message (concat "Mail sent"))
		  (setq buffer-is-modified 0)
	    )
	    (progn T
		  (beginning-of-file)
		  (set-mark)
		  (end-of-file)
		  (copy-region-to-buffer "Delivery-errors")
		  (beginning-of-file)
		  (error-occured (re-replace-string "\n\n* *" "; "))
		  (end-of-line)
		  (setq T (region-to-string))
		  (erase-buffer)
		  (yank-from-killbuffer)
		  (beginning-of-file)
		  (error-occured 
		      (re-search-forward "^to:[^>\n]*"))
		  (save-excursion
		      (pop-to-buffer "  Minibuf")
		      (previous-window)
		      (if (> (window-height) 4)
			  (progn
				(split-current-window)
				(while (> (window-height) 2)
				       (shrink-window))
				(switch-to-buffer "Delivery-errors"))
			  (pop-to-buffer "Delivery-errors"))
		      (beginning-of-file))
		  (message T))
	)
    )
    
    (abbrev-expand
	(insert-character ' ')
	(delete-previous-character)
    )
)

(declare-global rmail-default-log)
(setq rmail-default-log "~/TextMessage")

(defun
    (rmail-append file
	(setq file (get-tty-string (concat ": append-message-to-file ["
				       rmail-default-log "]  ")))
	(if (= file "") (setq file rmail-default-log))
	(save-excursion 
	    (temp-use-buffer "current-message")
	    (append-to-file file))
	(setq rmail-default-log file)
    )
    
    (rmail-shell
	(save-window-excursion
	    (shell)
	    (message "Type ESC-^Z to resume mail reading")
	    (recursive-edit))
    )
)

(defun (rmail-query-exit
	   (if (!= "y" (substr (get-tty-string
			   "Do you really want to abort mail reading? ")
			       1 1))
	       (error-message "Turkey!"))
	   (exit-emacs)
       )
)

(save-excursion i
    (temp-use-buffer "rmail-directory")
    (define-keymap "rmail-commands")
    (define-keymap "rmail-esc-commands")
    (define-keymap "rmail-^x-commands")
    (define-keymap "rmail-^z-commands")

    (use-local-map "rmail-esc-commands")
    (setq i 0)
    (while (< i 128)
	(local-bind-to-key "illegal-operation" i)
	(setq i (+ i 1)))

    (use-local-map "rmail-^x-commands")
    (setq i 0)
    (while (< i 128)
	(local-bind-to-key "illegal-operation" i)
	(setq i (+ i 1)))

    (use-local-map "rmail-^z-commands")
    (setq i 0)
    (while (< i 128)
	(local-bind-to-key "illegal-operation" i)
	(setq i (+ i 1)))

    (use-local-map "rmail-commands")
    (setq i 0)
    (while (< i 128)
	(local-bind-to-key "illegal-operation" i)
	(setq i (+ i 1)))
    (local-bind-to-key "rmail-esc-commands" "\e")
    (local-bind-to-key "rmail-^x-commands" '^x')
    (local-bind-to-key "rmail-^z-commands" '^z')
    				; innocuous commands which we want to keep
    (remove-local-binding '^a')
    (remove-local-binding '^b')
    (remove-local-binding '^e')
    (remove-local-binding '^f')
    (remove-local-binding '^l')
    (remove-local-binding '^n')
    (remove-local-binding '^p')
    (remove-local-binding '^r')
    (remove-local-binding '^s')
    (remove-local-binding '^u')
    (remove-local-binding '^v')
    (remove-local-binding "\^X\^B")
    (remove-local-binding "\^X\^F")
    (remove-local-binding "\^X\^O")
    (remove-local-binding "\^X\^S")
    (remove-local-binding "\^X\^V")
    (remove-local-binding "\^X\^X")
    (remove-local-binding "\^X\^Z")
    (remove-local-binding "\^X(")
    (remove-local-binding "\^X)")
    (remove-local-binding "\^X/")
    (remove-local-binding "\^X0")
    (remove-local-binding "\^X1")
    (remove-local-binding "\^X2")
    (remove-local-binding "\^X4")
    (remove-local-binding "\^X<")
    (remove-local-binding "\^X>")
    (remove-local-binding "\^XB")
    (remove-local-binding "\^XI")
    (remove-local-binding "\^XM")
    (remove-local-binding "\^X^")
    (remove-local-binding "\^Xb")
    (remove-local-binding "\^Xd")
    (remove-local-binding "\^Xe")
    (remove-local-binding "\^Xk")
    (remove-local-binding "\^Xm")
    (remove-local-binding "\^Xn")
    (remove-local-binding "\^Xo")
    (remove-local-binding "\^Xp")
    (remove-local-binding "\^Xr")
    (remove-local-binding "\^Xv")
    (remove-local-binding "\^Z\^Z")
    (remove-local-binding "\e\^@")
    (remove-local-binding "\e\^B")
    (remove-local-binding "\e\^F")
    (remove-local-binding "\e\^H")
    (remove-local-binding "\e\^R")
    (remove-local-binding "\e\^S")
    (remove-local-binding "\e\^V")
    (remove-local-binding "\e\^Z")
    (remove-local-binding "\e\e")
    (remove-local-binding "\e!")
    (remove-local-binding "\e#")
    (remove-local-binding "\e%")
    (remove-local-binding "\e-")
    (remove-local-binding "\e/")
    (remove-local-binding "\e0")
    (remove-local-binding "\e1")
    (remove-local-binding "\e2")
    (remove-local-binding "\e3")
    (remove-local-binding "\e4")
    (remove-local-binding "\e5")
    (remove-local-binding "\e6")
    (remove-local-binding "\e7")
    (remove-local-binding "\e8")
    (remove-local-binding "\e9")
    (remove-local-binding "\e<")
    (remove-local-binding "\e=")
    (remove-local-binding "\e>")
    (remove-local-binding "\e?")
    (remove-local-binding "\e@")
    (remove-local-binding "\eG")
    (remove-local-binding "\eM")
    (remove-local-binding "\eZ")
    (remove-local-binding "\eb")
    (remove-local-binding "\ef")
    (remove-local-binding "\eg")
    (remove-local-binding "\eo")
    (remove-local-binding "\es")
    (remove-local-binding "\ev")
    (remove-local-binding "\ex")
    (remove-local-binding "\ez")
    (remove-local-binding '^_')
    (local-bind-to-key "meta-digit" "1")
    (local-bind-to-key "meta-digit" "2")
    (local-bind-to-key "meta-digit" "3")
    (local-bind-to-key "meta-digit" "4")
    (local-bind-to-key "meta-digit" "5")
    (local-bind-to-key "meta-digit" "6")
    (local-bind-to-key "meta-digit" "7")
    (local-bind-to-key "meta-digit" "8")
    (local-bind-to-key "meta-digit" "9")
    (local-bind-to-key "meta-digit" "0")
    (local-bind-to-key "meta-minus" "-")
    (local-bind-to-key "rmail-previous-page" '^H')
    (local-bind-to-key "rmail-next-page" ' ')
    (local-bind-to-key "rmail-top-of-message" '^m')
    (local-bind-to-key "rmail-top-of-message" '^j')
    (local-bind-to-key "rmail-pass-headers" 't')
    (local-bind-to-key "rmail-all-headers" 'T')
    (local-bind-to-key "rmail-next-message" 'n')
    (local-bind-to-key "rmail-previous-message" 'p')
    (local-bind-to-key "next-window" 'o')
    (local-bind-to-key "rmail-delete-message-next" 'd')
    (local-bind-to-key "rmail-delete-message-previous" 'D')
    (local-bind-to-key "rmail-delete-message" '^d')
    (local-bind-to-key "rmail-undelete-message" 'u')
    (local-bind-to-key "rmail-query-exit" "\^G")
    (local-bind-to-key "rmail-help" '?')
    (local-bind-to-key "Pop-level" 'q')
    (local-bind-to-key "rmail-reply" 'r')
    (local-bind-to-key "smail" 'm')
    (local-bind-to-key "rmail-goto-message" 'g')
    (local-bind-to-key "rmail-first-message" '<')
    (local-bind-to-key "rmail-last-message" '>')
    (local-bind-to-key "rmail-but-mark" '.')
    (local-bind-to-key "rmail-skip" 's')
    (local-bind-to-key "rmail-append" 'a')
    (local-bind-to-key "execute-extended-command" ':')
    (local-bind-to-key "rmail" "i"); incorporate new messages
)
