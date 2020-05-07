;****************************************************************
;* File: ll-window.ml                                           *
;* Last modified on Fri Apr 18 12:16:02 1986 by roberts         *
;* -----------------------------------------------------------  *
;*     This package has the responsibility for maintaining the  *
;* window arrangement required by lauralee.  The rules are      *
;*                                                              *
;*  #1 ("folders")  The top window displays the list of         *
;*                  folders and is adjusted so that then        *
;*                  bottom bar is flush against the last        *
;*                  line of the window.  The bar contains       *
;*                  only the identifying tag.                   *
;*                                                              *
;*  #2 ("inbox")    This window contains the message list       *
;*                  for the currently selected folder.          *
;*                  The menu bar is buggable and contains       *
;*                  the standard operations.                    *
;*                                                              *
;*  #3 ("display")  The display window may be any emacs         *
;*                  window, but will be used as the window      *
;*                  in which messages are displayed.            *
;*                                                              *
;*  #3/4 ("draft")  For replies or new messages, a "draft"      *
;*                  window is used for message generation.      *
;*                  This will usually be window #3 for new      *
;*                  messages and #4 for replies.                *
;*                                                              *
;*  last ("help")   Help window, always at bottom of screen.    *
;****************************************************************

(declare-global ll-buffer-draft-replaced)

(defun (ignore-key (nothing)))

(defun (no-typing nt-i
	   (setq nt-i 127)
	   (while (>= nt-i ' ')
		  (local-bind-to-key "ignore-key" (char-to-string nt-i))
		  (setq nt-i (- nt-i 1))
	   )
	   (local-bind-to-key "ignore-key" (char-to-string 8))
	   (local-bind-to-key "ignore-key" (char-to-string 9))
	   (local-bind-to-key "ignore-key" (char-to-string 10))
	   (local-bind-to-key "ignore-key" (char-to-string 13))
       )
)
	   



;****************************************************************
;* (ll-select-folders-window [adjflag])                         *
;*                                                              *
;*     Selects the folders window and adjusts its size.         *
;* An error is signalled if the "Mail folders" buffer           *
;* does not exist.                                              *
;****************************************************************

(defun
   (ll-select-folders-window &adjflag height nlines
      (setq &adjflag (if (< (nargs) 1) 0 (arg 1)))
      (if (= (number-of-windows) 1) (split-current-window))
      (goto-window 1)
      (if (| (!= ll-window-type "folders") &adjflag)
         (progn
            (switch-to-buffer "Mail folders")
	    (no-typing)
            (setq ll-window-type "folders")
            (setq pad-mode-line 1)
            (set-mark)
            (setq nlines (line-number))
            (end-of-file)
            (setq height (min 8 (line-number)))
            (provide-prefix-argument (- height (window-height))
               (enlarge-window)
            )
            (beginning-of-line)
            (setq nlines (- (line-number) nlines))
            (setq nlines
               (max (/ height 2) (- (- height nlines) 1))
            )
            (goto-character (mark))
            (line-to-top-of-window)
            (provide-prefix-argument nlines (scroll-one-line-down))
            (exchange-dot-and-mark)
         )
      )
   )
)



;****************************************************************
;* (ll-select-inbox-window [adjflag])                           *
;*                                                              *
;*     Selects the inbox window and make sure that it is        *
;* associated with the buffer given by ll-source-folder.        *
;* If the adjflag parameter is given and is nonzero, this       *
;* also adjusts the message display so that there is only       *
;* one blank line at the bottom if possible.  The size of       *
;* the window is chosen to be 1/3 of the space remaining        *
;* on the screen after the folders window.                      *
;****************************************************************

(defun
   (ll-select-inbox-window adjflag inbox-height nlines
      (setq adjflag (if (< (nargs) 1) 0 (arg 1)))
      (goto-window 1)
      (if (!= ll-window-type "folders") (ll-select-folders-window))
      (setq inbox-height (/ (- screen-height (window-height)) 3))
      (goto-window 2)
      (if (= (number-of-windows) 2) (split-current-window))
      (goto-window 2)
      (if (| (!= ll-window-type "inbox") (!= ll-source-folder ll-folder-name))
         (progn
            (switch-to-buffer (concat "+" ll-source-folder))
	    (no-typing)
            (setq pad-mode-line 1)
            (provide-prefix-argument (- inbox-height (window-height))
                (enlarge-window)
            )
            (setq split-height-threshhold (+ inbox-height 1))
         )
         (setq inbox-height (window-height))
      )
      (if adjflag
         (progn
            (set-mark)
            (setq nlines (line-number))
            (end-of-file)
            (beginning-of-line)
            (setq nlines (- (line-number) nlines))
            (setq nlines
               (max (/ inbox-height 2) (- (- inbox-height nlines) 2))
            )
            (goto-character (mark))
            (line-to-top-of-window)
            (provide-prefix-argument nlines (scroll-one-line-down))
            (exchange-dot-and-mark)
         )
      )
   )
)



;****************************************************************
;* (ll-select-display-window)                                   *
;*                                                              *
;*      Selects the third window on the screen.  If there       *
;* is another window on the screen, it is deleted unless it     *
;* is marked as an active draft window.                         *
;****************************************************************

(defun
   (ll-select-display-window
      (goto-window 1)
      (if (!= ll-window-type "folders") (ll-select-folders-window))
      (goto-window 2)
      (if (!= ll-folder-name ll-source-folder) (ll-select-inbox-window))
      (goto-window 3)
      (if (& (!= ll-window-type "display") (!= ll-window-type "draft"))
         (setq ll-previous-buffer (current-buffer-name))
      )
      (if (& (ll-draft-window-is-visible) ll-draft-active)
         (switch-to-buffer "Draft")
      )
      (while (> (number-of-windows) 3)
         (goto-window 4)
         (delete-window)
      )
      (if (& (= ll-window-type "draft") ll-draft-active)
         (split-current-window)
      )
      (goto-window 3)
      (switch-to-buffer "Display")
      (setq ll-window-type "display")
      (setq needs-checkpointing 0)
   )
)



;****************************************************************
;* (ll-select-draft-window window)                              *
;*                                                              *
;*     This selects the composition/reply window, which         *
;* will live either in window #3 or #4, depending on            *
;* whether this is a new message or a reply, respectively.      *
;****************************************************************

(defun
   (ll-select-draft-window &window old-active
      (setq &window (arg 1))
      (setq old-active ll-draft-active)
      (setq ll-draft-active 0)
      (ll-select-display-window)
      (if (!= ll-window-type "draft")
         (setq ll-buffer-draft-replaced (current-buffer-name))
      )
      (if (= &window 4) (split-current-window))
      (switch-to-buffer "Draft")
      (setq ll-window-type "draft")
      (setq ll-draft-active old-active)
   )
)



;****************************************************************
;* (ll-select-help-window)                                      *
;*                                                              *
;*     Selects a help window at the bottom of the screen        *
;* and reads in the help file.  The height of the window        *
;* is adjusted so that the first page fits exactly in the       *
;* window, using a "-------" line as a sentinel.                *
;****************************************************************

(defun
   (ll-select-help-window helppath
      (ll-select-display-window)
      (if (= (number-of-windows) 3)
         (progn
            (goto-window 3)
            (split-current-window)
         )
      )
      (goto-window 4)
      (switch-to-buffer "Lauralee Help")
      (setq ll-window-type "help")
      (setq needs-checkpointing 0)
      (if (= (current-file-name) "")
         (progn
            (if (error-occured (setq helppath (path-of "lauralee.help")))
               (insert-string "No help file available!\n")
               (progn (read-file helppath) (no-typing))
            )
         )
      )
      (beginning-of-file)
      (if (error-occured (re-search-forward "^----*$")) (end-of-file))
      (provide-prefix-argument (- (- (line-number) (window-height)) 1)
          (enlarge-window)
      )
      (beginning-of-file)
   )
)



;****************************************************************
;* (ll-draft-window-is-visible)                                 *
;*                                                              *
;*     Returns true if the draft window is visible on the       *
;* display.                                                     *
;****************************************************************

(defun
   (ll-draft-window-is-visible oldwin iwin draft-found
      (setq oldwin (current-window))
      (setq draft-found 0)
      (setq iwin 1)
      (while (& (! draft-found) (<= iwin (number-of-windows)))
         (goto-window iwin)
         (if (= ll-window-type "draft") (setq draft-found 1))
         (setq iwin (+ 1 iwin))
      )
      (goto-window oldwin)
      draft-found
   )
)



;****************************************************************
;* (ll-help-window-is-visible)                                  *
;*                                                              *
;*     Returns true if the help window is visible on the        *
;* display.                                                     *
;****************************************************************

(defun
   (ll-help-window-is-visible oldwin iwin help-found
      (setq oldwin (current-window))
      (goto-window (number-of-windows))
      (setq help-found (= ll-window-type "help"))
      (goto-window oldwin)
      help-found
   )
)



;****************************************************************
;* (ll-delete-draft-window)                                     *
;*                                                              *
;*     Deletes the draft window from the screen, replacing      *
;* it either with the contents of window 3 or the buffer        *
;* which the draft window replaced when it was created          *
;* (if it still exists).                                        *
;****************************************************************

(defun
   (ll-delete-draft-window
      (save-excursion
         (temp-use-buffer "Draft")
         (setq buffer-is-modified 0)
      )
      (ll-set-draft-active 0)
      (ll-select-display-window)
      (if (& (= ll-window-type "draft")
             (buffer-exists ll-buffer-draft-replaced))
         (switch-to-buffer ll-buffer-draft-replaced)
      )
   )
)



;****************************************************************
;* (ll-delete-help-window)                                      *
;*                                                              *
;*     Deletes the help window from the screen, giving its      *
;* space to window 3 or the active draft.                       *
;****************************************************************

(defun
   (ll-delete-help-window
      (if (ll-help-window-is-visible)
         (save-excursion
            (goto-window (number-of-windows))
            (delete-window)
            (if (& ll-draft-active (! (ll-draft-window-is-visible)))
               (ll-select-draft-window 4)
            )
         )
      )
   )
)



;****************************************************************
;* (ll-set-draft-active [0/1])                                  *
;*                                                              *
;*     Performs the same action as (setq ll-draft-active ...)   *
;* but also sets the mode line to reflect the changed in        *
;* setting.                                                     *
;****************************************************************

(defun
   (ll-set-draft-active
      (save-excursion
         (temp-use-buffer "Draft")
         (setq ll-draft-active (arg 1))
         (if (! ll-draft-active) (setq buffer-is-modified 0))
         (temp-use-buffer (concat "+" ll-source-folder))
         (ll-set-inbox-mode-line)
      )
   )
)
