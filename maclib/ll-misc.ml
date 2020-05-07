;****************************************************************
;* File: ll-misc.ml                                             *
;* Last modified on Sat Apr 19 10:30:25 1986 by roberts         *
;* -----------------------------------------------------------  *
;*     Utility functions which don't seem to have any other     *
;* place to go.                                                 *
;****************************************************************

;****************************************************************
;* (set-mode-line "mode-line-format")                           *
;*                                                              *
;*    Sets the mode line format to the indicated string.  The   *
;* only difference between this and the standard setq is that   *
;* this version pads the mode line with spaces on the right     *
;* if the global pad-mode-line is set.                          *
;*                                                              *
;* NOTE:                                                        *
;*                                                              *
;*     This function is obsolete as of version 2.7 emacs,       *
;* since that version automatically pads mode lines.  For       *
;* a while, I'll keep this here to ensure that lauralee         *
;* will run even with older emacs versions.                     *
;****************************************************************

(declare-buffer-specific pad-mode-line)

(defun
   (set-mode-line
      (setq mode-line-format
         (concat (arg 1)
            (if pad-mode-line "                                        " "")
            (if pad-mode-line "                                        " "")
         )
      )
      (novalue)
   )
)



;****************************************************************
;* (new-mail-exists)                                            *
;*                                                              *
;*     True iff mail exists in the inbox.                       *
;****************************************************************

(defun
   (new-mail-exists
      (if (is-bound mailboxfilename)
         (file-exists mailboxfilename)
         (file-exists (concat "/usr/spool/mail/" (users-login-name)))
      )
   )
)



;****************************************************************
;* (safe-fast-filter-region "command")                          *
;*                                                              *
;*     Performs a fast-filter-region without destroying         *
;* the contents of the kill buffer.                             *
;****************************************************************

(defun
   (safe-fast-filter-region &command
      (setq &command (arg 1 "fast-filter-region through command: "))
      (error-occured (rename-buffer "Kill buffer" "&killbuffer"))
      (fast-filter-region &command)
      (error-occured (delete-buffer "Kill buffer"))
      (error-occured (rename-buffer "&killbuffer" "Kill buffer"))
   )
)
