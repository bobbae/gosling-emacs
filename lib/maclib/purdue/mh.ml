; This file implements "mhe", the display-oriented front end to the MH mail
; system. Documentation is in file mh-doc.ml.
; 
; Brian K. Reid, Stanford, April 1982
;
; This is version 4 (September 1982); it uses fast-filter-region.
; 
; Heavy handed by Tim Korb, Purdue, November 1982
;                            again, January 1983
; 			     again, February 1983
; 			     again, April 1983
;			     again, May 1983
; 
(status-line "Loading mhi")

(declare-global
     mh-path			; "/usr/jtk/Mail"
     t-mh-directory		; set by &mh-parse-names
     t-mh-folder		; set by &mh-parse-names
     t-mh-buffer
)

(declare-buffer-specific
    mh-buffer			; "+inbox<2>"
    mh-folder			; "+inbox"
    mh-directory		; "/usr/jtk/Mail/inbox/"
    mh-direction		; 1 is up, -1 is down.
    mh-last-destination		; destination of last "move" command
)
(setq-default mh-direction 1)

; Visit folder. Like visit-file, but supplies default path name.
; 
(defun				; (mh "folder")
    (mh folder sb
	(if (= mh-path "")
	    (setq mh-folder (&mh-read-profile)))
	(setq sb (arg 1 (concat "Folder name (" mh-folder ")? ")))
	(if (!= sb "")
	    (setq mh-folder sb))
	(if (!= (substr mh-folder 1 1) "+")
	    (setq mh-folder (concat "+" mh-folder)))
	(error-occured
	    (visit-file (concat mh-path "/" (substr mh-folder 2 -1) "/" mh-folder))
	)
	(mh-mode)
	(if (= (buffer-size) 0)
	    (&mh-scan)
	)
    )
)

; mh-mode -- auto-execute when reading a mail box.
; 
(defun
    (mh-mode
	(if (= mh-path "")
	    (&mh-read-profile))
	(setq mh-buffer (current-buffer-name))
	(setq t-mh-buffer (current-buffer-name))
	(&mh-parse-names)
	(setq mh-folder t-mh-folder)
	(setq mh-directory t-mh-directory)
	(use-local-map "&mh-keymap")
	(setq mode-string "mh-mode")
	(&mh-position-to-current)
	(novalue)
    )
)

; &mh-parse-names -- get mh-folder and mh-directory from current file name.
; Sets temporary variables t-mh-folder and t-mh-directory, so the buffer
; specific stuff will work.
; If the header file name is "/usr/jtk/Mail/inbox/+inbox", t-mh-folder is
; set to "+inbox", t-mh-directory is set to "/usr/jtk/Mail/inbox".
; The folder name always starts with a "+".
;  
(defun
    (&mh-parse-names fn
	(setq fn (current-file-name))
	(save-excursion 
	    (temp-use-buffer "mh-temp")
	    (erase-buffer)
	    (insert-string fn)
	    (beginning-of-file)
	    (set-mark)
	    (search-forward "+")
	    (backward-character)
	    (setq t-mh-directory (region-to-string))
	    (set-mark)
	    (end-of-line)
	    (setq t-mh-folder (region-to-string))
	)
    )
)
	    
(defun
    (&mh-summary
	(message "next prev del ^refile !repeat undo type forw inc repl")
    )
)

(defun
    (mh-debug
	(message "(buffer,folder,directory) = (" mh-buffer "," mh-folder ","
	    mh-directory ")")
    )
)	

; Mark a message as being deleted.
; 
(defun 
    (&mh-rmm
	(save-excursion 
	    (temp-use-mh-buffer)
	    (beginning-of-line)
	    (goto-character (+ (dot) 3))
	    (if (| (= (following-char) ' ') (= (following-char) '+'))
		(progn
		    (delete-next-character)
		    (insert-string "D")
		)
	    )
	)
	(another-line)
    )
)

(load "purdue/mh-util.ml")
(load "purdue/mh-scan.ml")

(autoload "&mh-send" "purdue/mh-send.ml")
(autoload "&mh-comp" "purdue/mh-send.ml")
(autoload "&mh-repl" "purdue/mh-send.ml")
(autoload "&mh-forw" "purdue/mh-send.ml")
(autoload "mail-mode" "purdue/mh-send.ml")

(autoload "&mh-show" "purdue/mh-show.ml")
(autoload "&mh-inc" "purdue/mh-inc.ml")
(autoload "&mh-refile" "purdue/mh-refile.ml")
(autoload "&mh-rerefile" "purdue/mh-refile.ml")
(autoload "&mh-undo" "purdue/mh-undo.ml")
(autoload "&mh-extras" "purdue/mh-extras.ml")
(load "purdue/mh-keymap.ml")
(setq mode-line-format default-mode-line-format)
(novalue)
