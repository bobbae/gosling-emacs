;****************************************************************
;* File: ll-cmdbuf.ml                                           *
;* Last modified on Wed Apr 23 11:23:31 1986 by roberts         *
;* -----------------------------------------------------------  *
;*     The functions in this file are concerned with managing   *
;* the mh command buffer which specifies the actual operations  *
;* to be performed at process time.  As message operations      *
;* are indicated by the user, these operations are queued       *
;* for processing in the buffer &ll-mh-cmdbuf and are not       *
;* actually performed until ll-mh-process is invoked. In        *
;* addition to the command lines maintained in &ll-mh-cmdbuf,   *
;* this package is also responsible for maintaining a list      *
;* of the folders which have changed.  This data is in the      *
;* buffer &ll-changed-folders.                                  *
;*                                                              *
;*     Most entries in this package are called using global     *
;* variables to record the parameters.  In general, these       *
;* are                                                          *
;*                                                              *
;*      ll-selected-message                                     *
;*      ll-target-folder                                        *
;*      ll-source-folder                                        *
;****************************************************************

(declare-global ll-command-string)	;String to process the cmdbuf
(declare-global ll-cleanup-type)	;Cleanup operation desired

(setq ll-command-string "")

(defun (funny-execute-mlisp-buffer
	   (save-excursion 
	       (beginning-of-file)
	       (insert-string "(progn ")
	       (end-of-file)
	       (insert-string ")")
	   )
	   (execute-mlisp-buffer)
       )
)



;****************************************************************
;* (ll-mh-delete)                                               *
;*                                                              *
;*     Marks the currently selected message in the source       *
;* folder for deletion.                                         *
;****************************************************************

(defun
   (ll-mh-delete
      (save-excursion
         (temp-use-buffer "&ll-mh-cmdbuf")
         (beginning-of-file)
         (if (error-occured
               (re-search-forward (concat "^rmm +" ll-source-folder))
             )
             (progn
                 (end-of-file)
                 (insert-string (concat "rmm +" ll-source-folder "\n"))
                 (backward-character)
             )
         )
         (end-of-line)
         (insert-string (concat " " ll-selected-message))
      )
      (message "Message " ll-selected-message " deleted")
      (sit-for 0)
      (ll-mark-changed ll-source-folder)
   )
)



;****************************************************************
;* (ll-mh-filem)                                                *
;*                                                              *
;*     Queues the appropriate commands to move the currently    *
;* selected message in the source folder into the target        *
;* folder.                                                      *
;****************************************************************

(defun
   (ll-mh-filem
      (save-excursion
         (temp-use-buffer "&ll-mh-cmdbuf")
         (beginning-of-file)
         (if (error-occured
                 (re-search-forward
                    (concat "filem -src +" ll-source-folder
                            " +" ll-target-folder
                    )
                 )
             )
             (progn
                (end-of-file)
                (insert-string
                   (concat "filem -src +" ll-source-folder
                           " +" ll-target-folder "\n"
                   )
                )
                (backward-character)
             )
         )
         (end-of-line)
         (insert-string (concat " " ll-selected-message))
      )
      (message "Message " ll-selected-message
               " moved into folder " ll-target-folder
      )
      (sit-for 0)
      (ll-mark-changed ll-source-folder)
   )
)



;****************************************************************
;* (ll-mh-linkm)                                                *
;*                                                              *
;*     Queues the appropriate commands to link the currently    *
;* selected message in the source folder into the target        *
;* folder.                                                      *
;****************************************************************

(defun
   (ll-mh-linkm
      (save-excursion
         (temp-use-buffer "&ll-mh-cmdbuf")
         (beginning-of-file)
         (if (error-occured
                 (re-search-forward
                    (concat "filem -link -src +" ll-source-folder
                            " +" ll-target-folder
                    )
                 )
             )
             (progn
                (end-of-file)
                (insert-string
                   (concat "filem -link -src +" ll-source-folder
                           " +" ll-target-folder "\n"
                   )
                )
                (backward-character)
             )
         )
         (end-of-line)
         (insert-string (concat " " ll-selected-message))
      )
      (message "Message " ll-selected-message
               " linked into folder " ll-target-folder
      )
      (sit-for 0)
      (ll-mark-changed ll-source-folder)
      (ll-mark-changed ll-target-folder)
   )
)



;****************************************************************
;* (ll-mh-unmark)                                               *
;*                                                              *
;*     Removes any queue entries pertaining to the              *
;* selected message.                                            *
;****************************************************************

(defun
   (ll-mh-unmark
      (save-excursion
         (temp-use-buffer "&ll-mh-cmdbuf")
         (beginning-of-file)
         (error-occured
            (re-search-forward (concat "\\b" ll-selected-message "\\b"))
            (delete-previous-word)
            (delete-previous-character)
         )
         (beginning-of-line)
         (if (| (looking-at "rmm +[^ ]*$")
                (looking-at "filem -src +[^ ]* +[^ ]*$")
                (looking-at "filem -link -src +[^ ]* +[^ ]*$"))
            (progn
               (set-mark)
               (next-line)
               (beginning-of-line)
               (erase-region)
            )
         )
      )
      (message "Message " ll-selected-message
               " restored to folder " ll-source-folder
      )
      (sit-for 0)
   )
)



;****************************************************************
;* (ll-mark-changed "folder")                                   *
;*                                                              *
;*     Whenever a folder is changed by the above commands,      *
;* this fact is noted by a call to this function which          *
;* adds the specified folder name to a list maintained          *
;* in the buffer &ll-changed-folders.  This list is             *
;* mildly conservative in that calls to ll-mh-unmark            *
;* can remove all changes without this fact being noted.        *
;****************************************************************

(defun
   (ll-mark-changed &folder
      (setq &folder (arg 1))
      (save-excursion
         (temp-use-buffer "&ll-changed-folders")
         (beginning-of-file)
         (if (error-occured (search-forward (concat &folder "\n")))
            (insert-string (concat &folder "\n"))
         )
      )
   )
)

;****************************************************************
;* (if (ll-folder-has-changed "folder") ... )                   *
;*                                                              *
;*     Returns TRUE if the specified folder has changed.        *
;****************************************************************

(defun
   (ll-folder-has-changed &folder flag
      (setq &folder (arg 1))
      (save-excursion
         (temp-use-buffer "&ll-changed-folders")
         (beginning-of-file)
         (setq result
            (error-occured (search-forward (concat &folder "\n")))
         )
      )
      (! flag)
   )
)



;****************************************************************
;* (ll-record-new-folder "folder")                              *
;*                                                              *
;*     Whenever a folder is read in for the first time,         *
;* it must be recorded using ll-record-new-folder.  At          *
;* process time, all open folders are deleted by executing      *
;* the buffer created by this command.                          *
;****************************************************************

(defun
   (ll-record-new-folder &folder
      (setq &folder (arg 1))
      (save-excursion
         (temp-use-buffer "&open-folder-list")
         (setq needs-checkpointing 0)
         (insert-string "(ll-folder-cleanup ")
         (insert-character '"')
         (insert-string &folder)
         (insert-character '"')
         (insert-string ")\n")
      )
   )
)



;****************************************************************
;* (ll-folder-cleanup "folder")                                 *
;*                                                              *
;*     This is called from the process command on each          *
;* folder that has been recorded by ll-record-new-folder.       *
;* The operation performed is specified by ll-cleanup-type.     *
;****************************************************************

(defun
   (ll-folder-cleanup &folder
      (setq &folder (arg 1))
      (if
         (= ll-cleanup-type "CACHE")
            (save-excursion
               (error-occured
                  (temp-use-buffer (concat "+" &folder "/.inodecache"))
                  (if buffer-is-modified (write-current-file))
               )
            )
         (= ll-cleanup-type "DELETE")
            (error-occured
                (delete-buffer (concat "+" &folder))
                (delete-buffer (concat "+" &folder "/.inodecache"))
            )
      )
   )
)



;****************************************************************
;* (ll-mh-process)                                              *
;*                                                              *
;*     Filters the current contents of &ll-mh-cmdbuf through    *
;* a shell to process all of the queued operations.  At the     *
;* conclusion of the operation, the buffers &ll-mh-cmdbuf and   *
;* &ll-changed-folders are both reset to their initial empty    *
;* state,  Thus, the client must save and delete any buffers    *
;* corresponding to open messages before this call is made.     *
;****************************************************************

(defun
   (ll-process
      (save-excursion
         (setq ll-cleanup-type "CACHE")
         (temp-use-buffer "&open-folder-list")
         (error-occured (funny-execute-mlisp-buffer))
         (switch-to-buffer "&ll-mh-cmdbuf")
         (beginning-of-file)
         (ll-break-long-lines)
         (end-of-file)
         (set-mark)
         (yank-buffer "&ll-changed-folders")
         (exchange-dot-and-mark)
         (error-occured
            (re-replace-string "^.*$" "folder -pack +& ; llscan +&")
         )
         (beginning-of-file)
         (set-mark)
         (end-of-file)
         (safe-fast-filter-region (ll-generate-command-string))
         (erase-buffer)
         (temp-use-buffer "&ll-changed-folders")
         (erase-buffer)
         (setq ll-cleanup-type "DELETE")
         (temp-use-buffer "&open-folder-list")
         (error-occured (funny-execute-mlisp-buffer))
         (erase-buffer)
      )
   )
)



;****************************************************************
;* (ll-break-long-lines)                                        *
;*                                                              *
;*     The major subtlety in the command processing arises      *
;* from the need to circumvent a bug in mh that places a        *
;* limit of 50 on the number of arguments to a single           *
;* command.  This is accomplished by breaking any line          *
;* longer than 65 characters into two operations.  Thus,        *
;*                                                              *
;*      rmm +folder 1 2 3 4 5 ... 40 41 42                      *
;*                                                              *
;* would be turned into                                         *
;*                                                              *
;*      rmm +folder 1 2 3 4 5 ...                               *
;*      rmm +folder ... 40 41 42                                *
;****************************************************************

(defun
   (ll-break-long-lines olddot
      (beginning-of-file)
      (while (! (eobp))
         (setq olddot (dot))
         (next-line)
         (beginning-of-line)
         (if (> (- (dot) olddot) 65)
            (ll-split-previous-line)
         )
      )
   )
)

;****************************************************************
;* (ll-split-previous-line)                                     *
;*                                                              *
;*     Principal subroutine of the above operation.  This       *
;* operation removes any arguments past character position      *
;* 60 from the previous line and duplicates the command         *
;* operation on the following line with all remaining           *
;* arguments.  Note that this routine leaves dot at             *
;* the begining of the new line.  This is necessary             *
;* to ensure that multiple splits are handled correctly.        *
;****************************************************************

(defun
   (ll-split-previous-line ll-header
      (goto-character (+ olddot 60))
      (search-forward " ")
      (delete-previous-character)
      (insert-character '\n')
      (previous-line)
      (beginning-of-line)
      (set-mark)
      (re-search-forward " [^-+]")
      (backward-character)
      (setq ll-header (region-to-string))
      (next-line)
      (beginning-of-line)
      (insert-string ll-header)
      (beginning-of-line)
   )
)



;****************************************************************
;* (ll-generate-command-string)                                 *
;*                                                              *
;*      Generates a command string through which to filter      *
;* the collection of message commands.  The two possible        *
;* command strings are:                                         *
;*                                                              *
;*     Firefly:    /proj/topaz/bin/msh [homeserver] sh          *
;*     785:        /bin/sh                                      *
;****************************************************************

(defun
   (ll-generate-command-string logname cmdstr
      (if (= ll-command-string "")
         (save-excursion
            (setq ll-command-string "/bin/sh")
            (if (& 0 (! (file-exists "/dev/kmem")))
               (error-occured
                  (temp-use-buffer "ll-temp-buffer")
                  (setq needs-checkpointing 0)
                  (read-file "/etc/homes")
                  (setq logname (users-login-name))
                  (search-forward (concat logname ":" logname "@"))
                  (set-mark)
                  (end-of-line)
                  (setq ll-command-string
                     (concat "/proj/topaz/bin/msh " (region-to-string) " sh")
                  )
                  (delete-buffer "&ll-temp")
               )
            )
         )
      )
      ll-command-string
   )
)



;****************************************************************
;* (ll-mh-init-cmdbuf)                                          *
;*                                                              *
;*     Initializes the buffers referenced in this package.      *
;* Should be called once during system initialization.          *
;****************************************************************

(defun
   (ll-mh-init-cmdbuf
      (save-excursion
         (temp-use-buffer "&ll-mh-cmdbuf")
         (setq needs-checkpointing 0)
         (erase-buffer)
         (temp-use-buffer "&ll-changed-folders")
         (setq needs-checkpointing 0)
         (erase-buffer)
      )
   )
)



;****************************************************************
;* (ll-mh-commands-pending)                                     *
;*                                                              *
;*      Returns TRUE if there are any commands that need        *
;* processing.                                                  *
;****************************************************************

(defun
   (ll-mh-commands-pending empty
      (save-excursion
         (temp-use-buffer "&ll-mh-cmdbuf")
         (setq empty (& (bobp) (eobp)))
      )
      (! empty)
   )
)
