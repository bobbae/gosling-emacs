;****************************************************************
;* File: lauralee.ml                                            *
;* Last modified on Fri Apr 25 07:48:08 1986 by roberts         *
;*      modified on Sun Mar  9 11:31:46 1986 by msm             *
;* -----------------------------------------------------------  *
;*        lauralee -- the emacs counterpart of lorelei          *
;****************************************************************


(if (! (is-bound window-list)) (load "xtemmouse.ml"))
(if (! (is-bound mouse-sequence-number)) (load "xmacmouse.ml"))
(if (! (is-bound ff-first-time)) (load "filelist.ml"))

(if (! (is-bound ll-test-in-progress)) (load "ll-actions.ml"))
(if (! (is-bound ll-test-in-progress)) (load "ll-click.ml"))
(if (! (is-bound ll-test-in-progress)) (load "ll-cmdbuf.ml"))
(if (! (is-bound ll-test-in-progress)) (load "ll-sendmail.ml"))
(if (! (is-bound ll-test-in-progress)) (load "ll-window.ml"))
(if (! (is-bound ll-test-in-progress)) (load "ll-misc.ml"))

;****************************************************************
;* Global variables                                             *
;****************************************************************

(declare-global ll-source-folder)	    ;Currently open folder
(declare-global ll-target-folder)	    ;Target of filem operations
(declare-global ll-selected-folder)	    ;Folder selected in folders window
(declare-global ll-previous-buffer)	    ;Buffer obscured by display
(declare-global ll-draft-active)	    ;TRUE if draft unsent
(declare-global ll-reply-key)		    ;Folder/msg being replied to
(declare-global ll-has-mail)		    ;TRUE if user has new mail

(declare-buffer-specific ll-window-type)    ;Type of folder
(declare-buffer-specific ll-folder-name)    ;Name of folder
(declare-buffer-specific ll-message-number) ;Message number

(if (! (is-bound ll-cc-to-self)) (setq-default ll-cc-to-self 1))
(if (! (is-bound ll-auto-incorporate)) (setq-default ll-auto-incorporate 1))
(if (! (is-bound ll-init-flag)) (setq-default ll-init-flag 0))



;****************************************************************
;* (lauralee-shell)                                             *
;* (lauralee)                                                   *
;*                                                              *
;*     Main program entry.  Just creates the necessary          *
;* windows and returns.  The lauralee-shell entry is            *
;* used by the shell script and handles the command-line        *
;* arguments appropriately.                                     *
;****************************************************************

(defun
   (lauralee-shell i
      (setq i 3)
      (while (< i (argc)) (visit-file (argv i)) (setq i (+ 1 i)))
      (if (<= (argc) 3) (switch-to-buffer "ll-temp-buffer"))
      (lauralee)
   )
)

(defun
   (lauralee
      (message "")
      (ll-button-block
         (if (! ll-init-flag) (ll-once-only-initialization))
         (ll-create-folders-window)
         (sit-for 0)
         (if (= ll-source-folder "")
            (setq ll-source-folder ll-selected-folder)
         )
         (ll-create-inbox-window ll-source-folder)
         (if (& ll-draft-active (! (ll-draft-window-is-visible)))
            (ll-select-draft-window 3)
         )
      )
      (novalue)
   )
)



;****************************************************************
;* (ll-once-only-initialization)                                *
;*                                                              *
;*     Initialization of variables to be performed only         *
;* once at first startup time.                                  *
;****************************************************************

(defun
   (ll-once-only-initialization
      (if (! (file-exists "~/.mh_profile"))
         (error-message "You must have a .mh_profile file.  "
                         "Run any mh command and try again."
         )
      )
      (setq ll-selected-folder "inbox")
      (setq ll-previous-buffer "")
      (setq ll-draft-active 0)
      (setq-default ll-window-type "")
      (setq-default ll-folder-name "")
      (setq-default ll-message-number 0)
      (ll-mh-init-cmdbuf)
      (setq ll-init-flag 1)
      (defun  (exit-emacs-hook (ll-exit-emacs-hook)))
   )
)



;****************************************************************
;* (ll-create-folders-window [adjflag])                         *
;*                                                              *
;*     The window at the top of the screen is the folders       *
;* window and contains a list of all folders in the users       *
;* Mail directory.  This function creates the folders           *
;* window and fills it with the relevant data.  If adjflag      *
;* is specified, this forces a window redraw.                   *
;****************************************************************

(defun
   (ll-create-folders-window adjflag adjflag old-dir
      (setq adjflag (if (< (nargs) 1) 0 (arg 1)))
      (save-excursion
         (temp-use-buffer "Mail folders")
         (setq needs-checkpointing 0)
         (setq buffer-is-modified 0)
      )
      (setq old-dir (working-directory))
      (change-directory "~/Mail")
      (fm-ls "Mail folders" "only-directories")
      (change-directory old-dir)
      (save-excursion
         (temp-use-buffer "Mail folders")
         (end-of-file)
         (if buffer-is-modified (delete-previous-character))
      )
      (ll-select-folders-window adjflag)
      (set-mode-line
         (concat
            " Mail folders: "
            (if ll-auto-incorporate "" "inc ")
            "open commit new remove | help "
         )
      )
      (setq #edit-menu mode-line-format)
      (setq #edit-actions
         (concat
            "ll-folders-novalue;"
            "ll-folders-novalue;"
            "ll-folders-novalue;"
            (if ll-auto-incorporate "" "ll-folders-bug-inc;")
            "ll-folders-bug-open;"
            "ll-folders-bug-commit;"
            "ll-folders-bug-new;"
            "ll-folders-bug-remove;"
            "ll-folders-novalue;"
            "ll-folders-bug-help;"
         )
      )
      (setq click-hook
         "(if (ll-record-transition) (ll-folders-up) (ll-folders-down))"
      )
      (if (= ll-selected-folder "") (setq ll-selected-folder "inbox"))
      (ll-set-selected-folder ll-selected-folder)
   )
)



;****************************************************************
;* (ll-create-inbox-window "folder")                            *
;*                                                              *
;*     The second window is always the "inbox" window and       *
;* contains the message list for the currently selected         *
;* folder.  This function creates a window for the indicated    *
;* folder, overlaying the previous contents of the second       *
;* window.                                                      *
;****************************************************************

(defun
   (ll-create-inbox-window &folder new
      (setq &folder (arg 1 "Folder name: "))
      (setq ll-source-folder &folder)
      (setq new (! (buffer-exists (concat "+" &folder))))
      (if new (ll-record-new-folder ll-source-folder))
      (ll-select-inbox-window)
      (setq needs-checkpointing 0)
      (setq ll-folder-name &folder)
      (setq ll-window-type "inbox")
      (ll-set-inbox-mode-line)
      (setq #edit-actions
         (concat
            "novalue;"
            "ll-bug-folder-name;"
            "ll-bug-show;"
            "ll-bug-delete;"
            "ll-bug-file;"
            "ll-bug-unmark;"
            "ll-bug-print;"
            "novalue;"
            "ll-bug-reply/send;"
            "ll-bug-forward/cancel;"
            "ll-bug-compose/novalue;"
         )
      )
      (setq click-hook
         "(if (ll-record-transition) (ll-inbox-up) (ll-inbox-down))"
      )
      (ll-init-folder)
      (ll-select-inbox-window 1)
   )
)



;****************************************************************
;* (ll-set-inbox-mode-line)                                     *
;*                                                              *
;*     Sets the mode line for the inbox.  Even though this      *
;* is a button menu, certain characters are volatile, such      *
;* as the name of the folder and the second group of buttons.   *
;****************************************************************

(defun
   (ll-set-inbox-mode-line
      (set-mode-line
         (concat " [" (substr ll-source-folder 1 9)
                 (if (> (length ll-source-folder) 9) "$" "")
                 "] show delete file unmark print | "
                 (if ll-draft-active
                     "send cancel"
                     "reply forward compose"
                 )
                 " "
         )
      )
      (setq #edit-menu mode-line-format)
   )
)


;****************************************************************
;* (ll-init-folder)                                             *
;*                                                              *
;*     Initializes (if necessary) an inbox-type window.         *
;* If this buffer is new, this is always required.  The only    *
;* other case which requires special treatment is to read in    *
;* new mail into an inbox which is already open.                *
;****************************************************************

(defun
   (ll-init-folder olddot oldbuf
      (setq ll-has-mail (& (= ll-source-folder "inbox") (new-mail-exists)))
      (if
         (= ll-auto-incorporate 0) (setq ll-has-mail 0)
         (= ll-auto-incorporate -1) (setq ll-auto-incorporate 0)
      )
      (if
         new (ll-read-folder)
         ll-has-mail
            (progn
               (message "Incorporating new mail ...")
               (sit-for 0)
               (end-of-file)
               (if (! (bobp)) (insert-character '\n'))
               (setq olddot (dot))
               (ll-scan-folder "-iatw")
               (end-of-file)
               (delete-previous-character)
               (goto-character olddot)
            )
      )
      (save-excursion
         (beginning-of-file)
         (while (! (error-occured (re-search-forward "^....-")))
            (delete-previous-character)
            (insert-character 'R')
         )
      )
   )
)



;****************************************************************
;* (ll-read-folder)                                             *
;*                                                              *
;*    Reads in the header file for the source folder if         *
;* no changes have occured in the folder recently.  The        *
;* test is made by checking the date on the folder              *
;* directory against the date on the .inodecache file.          *
;* If the latter is newer, no work is required.                 *
;****************************************************************

(defun
   (ll-read-folder maildir folderdate cachedate cur
      (erase-buffer)
      (setq maildir (concat "~/Mail/" ll-source-folder))
      (setq folderdate (file-modtime maildir))
      (setq cachedate 
	    (if (file-exists (concat maildir "/.inodecache"))
		(file-modtime (concat maildir "/.inodecache"))
		0
	    )
      )
      (if
         ll-has-mail
            (progn
               (message
                  (concat "Scanning +" ll-source-folder
                          " [incorporating new mail] ..."
                  )
               )
               (sit-for 0)
               (ll-scan-folder "-itw")
            )
         (< cachedate folderdate)
            (progn
               (message (concat "Scanning +" ll-source-folder " ..."))
               (sit-for 0)
               (ll-scan-folder "-tw")
            )
         1
            (progn
               (message "Reading +" ll-source-folder " ...")
               (sit-for 0)
               (insert-file (concat maildir "/+" ll-source-folder))
            )
      )
      (end-of-file)
      (delete-previous-character)
      (if (& ll-has-mail (file-exists (concat maildir "/cur")))
         (progn
            (set-mark)
            (insert-file (concat maildir "/cur"))
            (end-of-file)
            (setq cur (substr (concat "   " (region-to-string)) -4 3))
            (erase-region)
            (if (error-occured (re-search-reverse (concat "^" cur)))
               (end-of-file)
            )
         )
      )
      (beginning-of-line)
   )
)



;****************************************************************
;* (ll-scan-folder ["switches"])                                *
;*                                                              *
;*     If a scan is necessary because the directory has         *
;* changed, the llscan program is invoked by this routine.      *
;* If provided, the switches argument is passed to the          *
;* llscan program.                                              *
;****************************************************************

(defun
   (ll-scan-folder cmdline
      (if (= (nargs) 0)
         (setq cmdline (concat "llscan +" ll-source-folder))
         (setq cmdline (concat "llscan " (arg 1) " +" ll-source-folder))
      )
      (if (buffer-exists (concat "+" ll-source-folder "/.inodecache"))
         (save-excursion
            (temp-use-buffer (concat "+" ll-source-folder "/.inodecache"))
            (if buffer-is-modified (write-current-file))
         )
      )
      (set-mark)
      (safe-fast-filter-region cmdline)
      (save-excursion
         (temp-use-buffer (concat "+" ll-source-folder "/.inodecache"))
         (setq needs-checkpointing 0)
         (read-file (concat "~/Mail/" ll-source-folder "/.inodecache"))
      )
   )
)



;****************************************************************
;* (ll-folders-down)                                            *
;* (ll-folders-up)                                              *
;*                                                              *
;*     When clicking in the folders window, the down transition *
;* must set dot to the beginning of the current folder name,    *
;* but not select that folder.  On the up transition, three     *
;* cases apply:                                                 *
;*                                                              *
;*     CLICK  -> select the folder                              *
;*     DOUBLE -> open the folder                                *
;*     DRAG   -> if dragging from inbox window, file the        *
;*               current message, otherwise select folder       *
;****************************************************************

(defun
   (ll-folders-down folder
      (setq folder (ll-get-folder-name))
   )
)

(defun
   (ll-folders-up folder
      (setq folder (ll-get-folder-name))
      (if (= ll-opcode "DRAG")
         (progn
            (goto-window ll-drag-window)
            (goto-character ll-drag-dot)
            (if (!= ll-window-type "inbox") (setq ll-opcode "CLICK"))
         )
      )
      (if
         (= ll-opcode "DRAG")
            (ll-file-message folder shift)
         (= ll-opcode "DOUBLE")
            (ll-button-block
               (ll-create-inbox-window ll-selected-folder)
            )
         (= ll-opcode "CLICK")
            (progn
               (ll-set-selected-folder folder)
               (goto-window ll-old-window)
               (goto-character ll-old-dot)
               (ll-record-uptime)
            )
      )
   )
)



;****************************************************************
;* (ll-inbox-down)                                              *
;* (ll-inbox-up)                                                *
;*                                                              *
;*     For the current folder in the inbox window, the down     *
;* transition simply moves to the beginning of the line to      *
;* rigidize cursor positioning.  On the up transition,          *
;* CLICK operations are normally ignored unless the shift       *
;* or control keys are down, in which case this abbreviates     *
;* a common operation (see the code).  DOUBLE clicks open       *
;* the currently selected message.                              *
;****************************************************************

(defun
   (ll-inbox-down
      (beginning-of-line)
   )
)

(defun
   (ll-inbox-up
      (beginning-of-line)
      (if
         (& (= ll-opcode "DOUBLE") (! command) (! shift))
            (ll-button-block
               (ll-open-message)
               (ll-select-inbox-window)
            )
         (= ll-opcode "CLICK")
            (if
              command (ll-file-message shift)
              shift (ll-toggle-message)
            )
      )
   )
)



;****************************************************************
;* (ll-get-folder-name)                                         *
;*                                                              *
;*     Returns the name of the folder that dot is touching in   *
;* the folders window (which must be the current window).  As   *
;* a side effect, dot is moved to the beginning of the folder   *
;* name.                                                        *
;****************************************************************

(defun
   (ll-get-folder-name folder startdot
      (if (error-occured (re-search-reverse "[\t\n]"))
          (beginning-of-file)
          (forward-character)
      )
      (setq startdot (dot))
      (if (= (following-char) '>') (forward-character))
      (set-mark)
      (if (error-occured (re-search-forward "[\t\n]"))
          (end-of-file)
          (backward-character)
      )
      (setq folder (region-to-string))
      (goto-character startdot)
      folder
   )
)



;****************************************************************
;* (ll-set-selected-folder "folder")                            *
;*                                                              *
;*     Marks the indicated folder as the currently selected     *
;* one which will then be used for filing.  On the display,     *
;* the current folder is marked with a greater than sign.       *
;****************************************************************

(defun
   (ll-set-selected-folder &folder newdot
      (setq &folder (arg 1 "Select folder: "))
      (setq ll-selected-folder &folder)
      (save-excursion
         (temp-use-buffer "Mail folders")
         (beginning-of-file)
         (setq newdot -1)
         (while (! (eobp))
            (if (= (following-char) '>') (delete-next-character))
            (set-mark)
            (if (error-occured (re-search-forward "[\t\n]"))
               (end-of-file)
               (backward-character)
            )
            (if (= &folder (region-to-string)) (setq newdot (+ (mark))))
            (if (= (following-char) '\t') (forward-character))
            (if (= (following-char) '\n') (forward-character))
         )
         (if (!= newdot -1)
            (progn
               (goto-character newdot)
               (insert-character '>')
               (setq ll-selected-folder &folder)
            )
         )
      )
   )
)



;****************************************************************
;* (ll-folders-bug-inc)                                         *
;*                                                              *
;*     Called when the inc button is pressed in the folders     *
;* window.  Selects the inbox folder and opens it.              *
;****************************************************************


(defun
   (ll-folders-bug-inc
      (ll-button-block
         (goto-window #old-window)
         (ll-set-selected-folder "inbox")
         (setq ll-auto-incorporate -1)
         (if shift (ll-force-rescan ll-selected-folder))
         (ll-create-inbox-window ll-selected-folder)
      )
      (if (! ll-has-mail)
         (message "No new mail to incorporate")
      )
   )
)



;****************************************************************
;* (ll-folders-bug-open)                                        *
;*                                                              *
;*     Called when the open button is pressed in the folders    *
;* window.  Simply opens an inbox window on the selected        *
;* folder.                                                      *
;****************************************************************

(defun
   (ll-folders-bug-open
      (ll-button-block
         (goto-window #old-window)
         (if shift (ll-force-rescan ll-selected-folder))
         (ll-create-inbox-window ll-selected-folder)
      )
   )
)



;****************************************************************
;* (ll-folders-bug-open)                                        *
;*                                                              *
;*     Called when the open button is pressed in the folders    *
;* window.  Simply opens an inbox window on the selected        *
;* folder.                                                      *
;****************************************************************

(defun
   (ll-folders-bug-open
      (ll-button-block
         (goto-window #old-window)
         (if shift (ll-force-rescan ll-selected-folder))
         (ll-create-inbox-window ll-selected-folder)
      )
   )
)



;****************************************************************
;* (ll-folders-bug-commit)                                      *
;*                                                              *
;*     Called when the commit button is pressed.  All of the    *
;* work is done by ll-process.                                  *
;****************************************************************

(defun
   (ll-folders-bug-commit
      (goto-window #old-window)
      (if
         ll-draft-active
            (progn
               (if (! (ll-draft-window-is-visible))
                  (ll-select-draft-window 3)
               )
               (message "Before you commit changes, you must either "
                        "send or cancel this message."
               )
            )
         (ll-mh-commands-pending)
            (ll-button-block
               (message "Committing changes to folders ...")
               (sit-for 0)
               (setq ll-reply-key "")
               (temp-use-buffer "Display")
               (if (& (!= (current-file-name) "") buffer-is-modified)
                  (progn
                     (message "Saving changes in message ...")
                     (sit-for 0)
                     (write-current-file)
                     (message "")
                  )
               )
               (ll-select-display-window)
               (switch-to-buffer
                  (if (= ll-previous-buffer "")
                     "ll-temp-buffer"
                     ll-previous-buffer
                  )
               )
               (delete-buffer "Display")
               (setq ll-previous-buffer "")
               (sit-for 0)
               (ll-select-inbox-window)
               (switch-to-buffer "ll-temp-buffer")
               (ll-process)
               (ll-create-inbox-window ll-source-folder)
            )
         (message "You haven't made any changes.")
      )
   )
)



;****************************************************************
;* (ll-folders-bug-new)                                         *
;*                                                              *
;*     Called when the new button is pressed in the folders     *
;* window.  Asks the user for a new buffer name and creates     *
;* a new directory.  The folders window is redrawn and the      *
;* new folder is selected, but not opened.                      *
;****************************************************************

(defun
   (ll-folders-bug-new folder dirname
      (setq folder (get-tty-string "Folder name: "))
      (ll-button-block
         (setq dirname (concat "/udir/" (users-login-name) "/Mail/" folder))
         (if (error-occured
		 (execute-monitor-command
		     (concat "mkdir " dirname)
		 )
	     )
            (progn
		  (message "couldn't create directory " dirname)
		  (sit-for 30)
	    )
            (progn
               (message "Creating +" folder " ...")
               (sit-for 0)
               (ll-create-folders-window 1)
               (ll-set-selected-folder folder)
            )
         )
      )
      (goto-window #old-window)
   )
)



;****************************************************************
;* (ll-folders-bug-remove)                                      *
;*                                                              *
;*     Called when the remove button is pressed in the          *
;* folders window.  This button must be clicked twice           *
;* to remove the directory and uses the this-command/           *
;* previous-command mechanism to ensure this.  The              *
;* documentation of this "feature" calls for a                  *
;* magic number; -42 is chosen here (with thanks                *
;* to Douglas Adams).                                           *
;****************************************************************

(defun
   (ll-folders-bug-remove msg
      (setq msg "")
      (if (& shift (= (previous-command) -42))
         (ll-button-block
            (save-excursion
               (temp-use-buffer "ll-temp-buffer")
               (setq needs-checkpointing 0)
               (message "Removing folder +" ll-selected-folder " ...")
               (sit-for 0)
               (set-mark)
               (safe-fast-filter-region
                  (concat "rm -rf /udir/" (users-login-name)
                          "/Mail/" ll-selected-folder
                  )
               )
               (if (> (dot) (mark))
                  (progn
                     (delete-previous-character)
                     (setq msg (region-to-string))
                     (erase-region)
                  )
                  (setq msg "")
               )
               (ll-create-folders-window 1)
               (ll-set-selected-folder ll-source-folder)
            )
         )
         (progn
            (setq msg
               (concat "Click CTRL-remove to confirm deletion of folder "
                       ll-selected-folder
               )
            )
            (setq this-command -42)
         )
      )
      (goto-window #old-window)
      (message msg)
   )
)



;****************************************************************
;* (ll-folders-bug-help)                                        *
;*                                                              *
;*    Brings up (or cancels) a help menu.                       *
;****************************************************************

(defun
   (ll-folders-bug-help
      (if (& (ll-help-window-is-visible) (! shift))
         (ll-delete-help-window)
         (ll-button-block
            (ll-select-help-window)
            (if shift
               (error-occured
                  (re-search-forward "^----*$")
                  (next-line)
                  (beginning-of-line)
                  (line-to-top-of-window)
               )
            )
         )
      )
      (ll-select-inbox-window)
   )
)



;****************************************************************
;* (ll-folders-novalue)                                         *
;*                                                              *
;*     Called when a non-button is pressed in the folders       *
;* menu line.  This is necessary to ensure that dot does        *
;* not lodge in the folders window.                             *
;****************************************************************

(defun
   (ll-folders-novalue
      (goto-window #old-window)
      (novalue)
   )
)



;****************************************************************
;* (ll-force-rescan "folder")                                   *
;*                                                              *
;*     Forces a rescan of the selected folder.  Fails           *
;* if there are active modifications in the command             *
;* buffer.                                                      *
;****************************************************************

(defun
   (ll-force-rescan &folder
      (setq &folder (arg 1))
      (if (ll-mh-commands-pending)
         (error-message "You have changes which are not committed.")
      )
      (message "Forcing rescan of +" &folder " ...")
      (sit-for 0)
      (unlink-file
         (concat "/udir/" (users-login-name) "/Mail/" &folder "/.inodecache")
      )
      (ll-select-inbox-window)
      (switch-to-buffer "ll-temp-buffer")
      (error-occured (delete-buffer (concat "+" &folder)))
   )
)



;****************************************************************
;* (ll-exit-emacs-hook)                                         *
;*                                                              *
;*     Makes sure user doesn't exit from emacs without          *
;* flushing the caches and commiting changes.  Again            *
;* we need a magic number so that doing this twice              *
;* in a row works: "'17!' exclaimed the Humbug,                 *
;* who always managed to be first with the wrong                *
;* answer." -- Norton Juster, The Phantom Tollbooth.            *
;****************************************************************

(defun
   (ll-exit-emacs-hook
      (if
         (= (previous-command) -17)
            (novalue)
         ll-draft-active
            (progn
               (ll-select-draft-window 3)
               (setq this-command -17)
               (error-message "This draft has not been sent or cancelled.")
            )
         (ll-mh-commands-pending)
            (progn
               (save-excursion (ll-select-folders-window))
               (setq this-command -17)
               (error-message "You have changes which are not committed.")
            )
      )
   )
)
