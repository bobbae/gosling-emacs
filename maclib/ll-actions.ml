;****************************************************************
;* File: ll-actions.ml                                          *
;* Last modified on Wed Apr 16 16:20:45 1986 by roberts         *
;* -----------------------------------------------------------  *
;*     Actions on mail items for the lauralee system.           *
;****************************************************************

;****************************************************************
;* Global variables                                             *
;****************************************************************

(declare-global ll-selected-message)	;Currently selected message
(declare-global ll-message-state)	;Current message state

(setq ll-selected-message -1)



;****************************************************************
;* (ll-set-selected-message)                                    *
;*                                                              *
;*     Goes to the message selected by dot in the currently     *
;* selected source folder and sets ll-selected-message          *
;* accordingly.                                                 *
;****************************************************************

(defun
   (ll-set-selected-message
      (ll-select-inbox-window)
      (beginning-of-line)
      (set-mark)
      (goto-character (+ (dot) 3))
      (setq ll-message-state (following-char))
      (setq ll-selected-message (+ (region-to-string)))
      (beginning-of-line)
   )
)



;****************************************************************
;* (ll-selected-message-file)                                   *
;*                                                              *
;*     Returns the filename of the selected message.            *
;* This is done separately since it should eventually be        *
;* upgraded to understand the .mh_profile format.               *
;****************************************************************

(defun
   (ll-selected-message-file
      (concat "/udir/" (users-login-name)
              "/Mail/" ll-source-folder "/" ll-selected-message
      )
   )
)



;****************************************************************
;* (ll-open-message)                                            *
;*                                                              *
;*     Visits the file associated with the currently selected   *
;* message.                                                     *
;****************************************************************

(defun
   (ll-open-message
      (ll-set-selected-message)
      (ll-select-display-window)
      (if (& (!= (current-file-name) "") buffer-is-modified)
         (progn
            (message "Saving changes in message " ll-message-number " ...")
            (sit-for 0)
            (write-current-file)
         )
      )
      (read-file (ll-selected-message-file))
      (setq ll-folder-name ll-source-folder)
      (setq ll-message-number ll-selected-message)
      (error-occured
         (re-search-forward "^Date:\\|^To:\\|^From:")
         (beginning-of-line)
         (line-to-top-of-window)
      )
   )
)



;****************************************************************
;* (ll-change-state 'x')                                        *
;*                                                              *
;*      Changes the state of the current message to the         *
;* single character x, which should be one of ' ', 'D'          *
;* or '^' (following the mhe convention).                       *
;****************************************************************

(defun
   (ll-change-state
      (beginning-of-line)
      (goto-character (+ (dot) 3))
      (delete-next-character)
      (insert-character (arg 1))
      (beginning-of-line)
   )
)



;****************************************************************
;* (ll-toggle-message)                                          *
;*                                                              *
;*     Deletes the currently selected message unless it was     *
;* already marked, in which case the message is undeleted.      *
;****************************************************************

(defun
   (ll-toggle-message
      (ll-set-selected-message)
      (if
         (= ll-message-state ' ')
            (progn
               (ll-change-state 'D')
               (ll-mh-delete)
            )
         1
            (progn
               (ll-change-state ' ')
               (ll-mh-unmark)
            )
      )
   )
)



;****************************************************************
;* (ll-delete-message)                                          *
;*                                                              *
;*     Deletes the currently selected message.                  *
;****************************************************************

(defun
   (ll-delete-message
      (ll-set-selected-message)
      (if
         (= ll-message-state ' ')
            (progn
               (ll-change-state 'D')
               (ll-mh-delete)
            )
         (message "Message already deleted or filed")
      )
   )
)



;****************************************************************
;* (ll-unmark-message)                                          *
;*                                                              *
;*     Unmarks the currently selected message.  If the          *
;* current message is not marked, this function tries           *
;* to be clever and checks if the previous message is           *
;* deleted or filed.  If so, move to this message and           *
;* unmark it.  This makes the button function as an undo.       *
;****************************************************************

(defun
   (ll-unmark-message olddot
      (ll-set-selected-message)
      (if (!= ll-message-state ' ')
         (progn
            (ll-change-state ' ')
            (ll-mh-unmark)
         )
         (progn
            (setq olddot (dot))
            (previous-line)
            (beginning-of-line)
            (ll-set-selected-message)
            (if (!= ll-message-state ' ')
               (progn
                  (ll-change-state ' ')
                  (ll-mh-unmark)
               )
               (progn
                  (goto-character olddot)
                  (message "Message is not deleted or filed")
               )
            )
         )
      )
   )
)



;****************************************************************
;* (ll-file-message "folder" [link])                            *
;*                                                              *
;*     Files the currently selected message in the specified    *
;* folder, using link semantics if a non-zero third argument    *
;* is specified.  If the target folder is the same as the       *
;* current folder, this acts as an undelete operation.          *
;****************************************************************

(defun
   (ll-file-message &linkflag
      (setq ll-target-folder (arg 1))
      (setq &linkflag (if (< (nargs) 2) 0 (arg 2)))
      (ll-set-selected-message)
      (if
         (& (= ll-message-state ' ') (!= ll-target-folder ll-source-folder))
            (progn
               (ll-change-state '^')
               (if &linkflag (ll-mh-linkm) (ll-mh-filem))
            )
         (& (!= ll-message-state ' ') (= ll-target-folder ll-source-folder))
            (progn
               (ll-change-state ' ')
               (ll-mh-unmark)
            )
         (= ll-target-folder ll-source-folder)
            (message "Message is already in this folder")
         (message "Message is already filed")
      )
   )
)



;****************************************************************
;* (ll-print-message)                                           *
;*                                                              *
;*      Prints the currently selected message using enscript.   *
;* In the future, this should be enhanced to allow some         *
;* control over the printing, presumably by an environment      *
;* variable or init file.                                       *
;****************************************************************

(defun
   (ll-print-message printer msg
      (ll-set-selected-message)
      (setq printer
         (if shift
            (concat "-P" (get-tty-string "Printer: ") " ")
            ""
         )
      )
      (message (concat "Printing message " ll-selected-message " ..."))
      (ll-button-block
         (set-mark)
         (safe-fast-filter-region
            (concat "enscript " printer (ll-selected-message-file))
         )
         (if (> (dot) (mark))
            (progn
               (delete-previous-character)
               (setq msg (region-to-string))
               (erase-region)
            )
            (setq msg "")
         )
      )
      (message msg)
   )
)



;****************************************************************
;* (ll-check-if-displayed)                                      *
;*                                                              *
;*     Checks to see whether the message indicated by dot       *
;* in the inbox window is already displayed in the display      *
;* window.  This is used to adjust the behavior of the          *
;* show button so that successive clicks display successive     *
;* messages.                                                    *
;****************************************************************

(defun
   (ll-check-if-displayed
      (ll-set-selected-message)
      (ll-select-display-window)
      (&
         (= ll-window-type "display")
         (= ll-folder-name ll-source-folder)
         (= ll-message-number ll-selected-message)
      )
   )
)



;****************************************************************
;* (ll-check-for-page)                                          *
;*                                                              *
;*     Checks to see if dot has moved outside the visible       *
;* page in the inbox window.  If it has, readjust the           *
;* window so that there is plenty of room.                      *
;****************************************************************

(defun
   (ll-check-for-page nscroll
      (if (! (dot-is-visible)) (ll-select-inbox-window 1))
   )
)



;****************************************************************
;* (ll-advance)                                                 *
;*                                                              *
;*     Advances to the next unread message in the inbox         *
;* window.  If there is no such message, dot stays              *
;* where it is, and a message is generated.                     *
;****************************************************************

(defun
   (ll-advance found olddot
      (setq found 0)
      (ll-set-selected-message)
      (setq olddot (dot))
      (next-line)
      (while (& (! (eobp)) (! found))
         (ll-set-selected-message)
         (if (= ll-message-state ' ')
            (setq found 1)
            (next-line)
         )
      )
      (if (! found)
         (progn
            (message "No next message")
            (goto-character olddot)
         )
      )
      (ll-check-for-page)
   )
)



(defun
   (ll-bug-folder-name
      (ll-button-block
         (ll-create-inbox-window ll-source-folder)
      )
   )
)

(defun
   (ll-bug-show
      (ll-button-block
         (if (ll-check-if-displayed) (ll-advance))
         (ll-open-message)
         (ll-select-inbox-window)
      )
   )
)

(defun
   (ll-bug-delete
      (ll-delete-message)
      (ll-advance)
   )
)

(defun
   (ll-bug-file
      (ll-file-message ll-selected-folder shift)
      (ll-advance)
   )
)

(defun
   (ll-bug-unmark
      (ll-unmark-message)
   )
)

(defun
   (ll-bug-print
      (ll-print-message)
   )
)



(defun
   (ll-bug-reply/send
      (ll-button-block
         (if ll-draft-active
            (ll-bug-send)
            (ll-reply-to-message)
         )
      )
   )
)

(defun
   (ll-bug-forward/cancel
      (if ll-draft-active
         (ll-bug-cancel)
         (ll-button-block (ll-forward-message))
      )
   )
)

(defun
   (ll-bug-compose/novalue
      (ll-button-block
         (if (! ll-draft-active) (ll-compose-message))
      )
   )
)



(defun
   (ll-bug-send
      (goto-window #old-window)
      (if (! (ll-draft-window-is-visible))
         (progn
            (ll-select-draft-window 3)
            (message "Click again to send this message")
         )
         (ll-send-draft)
      )
   )
)



(defun
   (ll-bug-cancel
      (ll-delete-draft-window)
      (message "Current draft cancelled.  Hit CTRL-compose to restore.")
   )
)
