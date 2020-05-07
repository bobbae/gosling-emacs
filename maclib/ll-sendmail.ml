;****************************************************************
;* File: ll-sendmail.ml                                         *
;* Last modified on Thu Apr 24 09:25:32 1986 by roberts         *
;* -----------------------------------------------------------  *
;*     Lauralee functions that pertain to sending mail and      *
;* handling the reply windows.                                  *
;****************************************************************



;****************************************************************
;* (ll-reply-to-message)                                        *
;*                                                              *
;*     Replies to the current message.  Today, this is done     *
;* by using the mh repl command to generate the header and      *
;* then post-processing the result to delete the cc line,       *
;* if appropriate.  Soon, this should all be done inside        *
;* the mail system.                                             *
;****************************************************************

(defun
   (ll-reply-to-message key
      (ll-set-selected-message)
      (ll-open-message)
      (setq key (concat ll-folder-name "/" ll-message-number))
      (ll-select-draft-window 4)
      (ll-init-draft)
      (setq ll-reply-key key)
      (set-mark)
      (message "Generating reply header ...")
      (sit-for 0)
      (safe-fast-filter-region
         (concat "repl -build +" ll-source-folder " "
                 ll-selected-message
         )
      )
      (error-occured (insert-file "~/Mail/reply"))
      (beginning-of-file)
      (ll-replace-cc-field)
      (end-of-file)
   )
)



;****************************************************************
;* (ll-replace-cc-field)                                        *
;*                                                              *
;*     Deletes the cc field in a repl message unless the        *
;* shift button was down when this function was invoked.        *
;****************************************************************

(defun
   (ll-replace-cc-field
      (if (! shift)
         (error-occured
            (beginning-of-file)
            (re-search-forward "^[Cc]c:")
            (set-mark)
            (beginning-of-line)
            (exchange-dot-and-mark)
            (re-search-forward "^[-A-Za-z]*:")
            (beginning-of-line)
            (erase-region)
            (ll-insert-cc-field)
         )
      )
      (beginning-of-file)
   )
)



;****************************************************************
;* (ll-forward-message)                                         *
;*                                                              *
;*     Forwards the current message.                            *
;****************************************************************

(defun
   (ll-forward-message old-cc-to-self
      (ll-set-selected-message)
      (ll-select-draft-window 3)
      (ll-init-draft)
      (insert-string "\n------- Forwarded Message\n\n")
      (insert-file (ll-selected-message-file))
      (end-of-file)
      (insert-string "\n------- End of Forwarded Message\n")
      (setq old-cc-to-self ll-cc-to-self)
      (setq ll-cc-to-self 0)
      (ll-insert-standard-header)
      (setq ll-cc-to-self old-cc-to-self)
   )
)



;****************************************************************
;* (ll-compose-message)                                         *
;*                                                              *
;*     Generates a new message header window.                   *
;****************************************************************

(defun
   (ll-compose-message
      (ll-select-draft-window 3)
      (if shift
         (ll-set-draft-active 1)
         (progn
            (ll-init-draft)
            (ll-insert-standard-header)
         )
      )
   )
)



;****************************************************************
;* (ll-init-draft)                                              *
;*                                                              *
;*    This function deletes the contents of the draft window    *
;* and binds it to "~/Mail/draft.ll".  Ordinarily, this will    *
;* neither be read or written unless the user explicitly        *
;* saves it.                                                    *
;****************************************************************

(defun
   (ll-init-draft
      (save-excursion
         (temp-use-buffer "Draft")
         (read-file "/dev/null")
         (change-file-name "~/Mail/draft.ll")
         (setq needs-checkpointing 1)
         (erase-buffer)
         (ll-set-draft-active 1)
         (setq ll-reply-key "")
         (setq buffer-is-modified 0)
      )
   )
)



;****************************************************************
;* (ll-insert-standard-header)                                  *
;*                                                              *
;*     Builds up a standard header line and inserts it at       *
;* the beginning of the message.                                *
;****************************************************************

(defun
   (ll-insert-standard-header
      (beginning-of-file)
      (insert-string "To: \n")
      (ll-insert-cc-field)
      (insert-string "Subject: \n")
      (insert-string "-------\n")
      (beginning-of-file)
      (end-of-line)
      (setq buffer-is-modified 0)
   )
)



;****************************************************************
;* (ll-insert-cc-field)                                         *
;*                                                              *
;*     Inserts the cc field.  The global variable               *
;* ll-cc-to-self controls whether the user is                   *
;* included by default.                                         *
;****************************************************************

(defun
   (ll-insert-cc-field
      (if ll-cc-to-self
         (progn
            (insert-string "cc: ")
            (insert-string (users-login-name))
            (insert-string "\n")
         )
      )
   )
)



;****************************************************************
;* (ll-send-draft)                                              *
;*                                                              *
;*      Sends the current draft.  Assumes an active             *
;* draft exists, since this is checked at a higher              *
;* level of the system.                                         *
;****************************************************************

(defun
   (ll-send-draft oldactive
      (save-excursion
         (ll-select-inbox-window)
         (setq oldactive ll-draft-active)
         (setq ll-draft-active 0)
         (ll-set-inbox-mode-line)
         (message "Sending mail ...")
         (sit-for 0)
         (setq ll-draft-active oldactive)
         (temp-use-buffer "&sendmail")
         (setq needs-checkpointing 0)
         (erase-buffer)
         (yank-buffer "Draft")
         (ll-process-draft)
         (beginning-of-file)
         (set-mark)
         (end-of-file)
         (fast-filter-region "/usr/lib/sendmail -t")
         (message "Done")
      )
      (if (!= ll-reply-key "")
         (save-excursion (ll-mark-replied))
      )
      (if (= ll-window-type "draft")
         (ll-delete-draft-window)
         (save-excursion (ll-delete-draft-window))
      )
   )
)



;****************************************************************
;* (ll-process-draft)                                           *
;*                                                              *
;*     Processes a message prior to sending.  This currently    *
;* only deletes the "-------" marker, but should eventually     *
;* also expand personal aliases.                                *
;****************************************************************

(defun
   (ll-process-draft
      (beginning-of-file)
      (if (! (error-occured (re-search-forward "^----*$")))
         (progn
            (beginning-of-line)
            (set-mark)
            (end-of-line)
            (erase-region)
         )
      )
   )
)



;****************************************************************
;* (ll-mark-replied)                                            *
;*                                                              *
;*     Marks the buffer associated with ll-reply-key            *
;* as being "replied-to".  This requires:                       *
;*                                                              *
;*    (1)  Adding an "R" to position 5 in the                   *
;*         corresponding inbox line and cache.                  *
;*    (2)  Adding a "Replied:" field at the top of              *
;*         the message.                                         *
;****************************************************************

(defun
   (ll-mark-replied folder msg slashpos pattern oldsrc oldmsg noteflag
      (setq slashpos (index ll-reply-key "/" 1))
      (if (= slashpos 0) (error-message "Illegal reply folder"))
      (setq folder (substr ll-reply-key 1 (- slashpos 1)))
      (setq msg (+ (substr ll-reply-key (+ slashpos 1) 100)))
      (temp-use-buffer (concat "+" folder))
      (ll-find-reply-and-mark 0)
      (temp-use-buffer "Display")
      (setq noteflag 1)
      (if (!= ll-reply-key (concat ll-folder-name "/" ll-message-number))
         (progn
            (temp-use-buffer "Reply")
            (setq needs-checkpointing 0)
            (setq noteflag (! (error-occured (read-file
               (concat "/udir/" (users-login-name) "/Mail/" folder "/" msg)
            ))))
         )
      )
      (if noteflag (ll-annotate-message))
      (if (= (current-buffer-name) "Reply") (delete-buffer "Reply"))
      (temp-use-buffer (concat "+" ll-source-folder "/.inodecache"))
      (ll-find-reply-and-mark 1)
      (setq ll-reply-key "")
   )
)



;****************************************************************
;* (ll-annotate-message)                                        *
;*                                                              *
;*     Mark the message in this buffer as "replied to"          *
;* and write it out.                                            *
;****************************************************************

(defun
   (ll-annotate-message olddot oldbuf oldpop
      (setq olddot (dot))
      (beginning-of-file)
      (insert-string "Replied: <<")
      (set-mark)
      (insert-string (current-time))
      (insert-string ">>\n")
      (goto-character olddot)
      (write-current-file)
   )
)



;****************************************************************
;* (ll-find-reply-and-mark cacheflag)                           *
;*                                                              *
;*      Finds the message being replied to (inherits msg        *
;* from parent) and marks it with an 'R'.  Used for both        *
;* the cache and the displayed inbox window.  The behavior      *
;* is determined by the argument (0 = inbox, 1 = cache).        *
;****************************************************************

(defun
   (ll-find-reply-and-mark &cacheflag olddot
      (setq &cacheflag (arg 1))
      (setq olddot (dot))
      (beginning-of-file)
      (setq pattern
         (if &cacheflag
            (concat "^......:" (substr (concat "   " msg) -3 3))
            (concat "^" (substr (concat "   " msg) -3 3))
         )
      )
      (if (! (error-occured (re-search-forward pattern)))
         (progn
            (forward-character)
            (delete-next-character)
            (insert-character (if &cacheflag '-' 'R'))
         )
      )
      (goto-character olddot)
   )
)
