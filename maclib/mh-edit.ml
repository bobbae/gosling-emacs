;  This autoloaded file implements the "e" command of mhe
(defun 
    (&mh-edit msgn fn fl
	(save-excursion
	    (&mh-pop-to-buffer (concat "+" mh-folder))
	    (&mh-save-killbuffer)
	    (delete-other-windows)
	    (error-occured
		(setq msgn (&mh-get-msgnum))
		(setq fn (&mh-get-fname))
		(setq fl mh-folder)
		(message "editing message " msgn)
		(setq mode-line-format mhml-edit-other)
		(&mh-pop-to-buffer "message")
		(read-file fn)
		(setq window-priority 5)
		(setq mode-line-format
		      (concat mhml-edit-1 fl "/" msgn mhml-edit-2))
		(local-bind-to-key "exit-emacs" "\\")
		(&mh-restore-killbuffer)
		(recursive-edit)
		(&mh-pop-to-buffer "message")
		(setq mode-line-format
		      (concat mhml-edit-done-1 fl "/" msgn mhml-edit-done-2))
		(unlink-file (concat (current-file-name) ".BAK"))
		(unlink-file (concat (current-file-name) ".CKP"))
	    )
	)
	(&mh-pop-to-buffer (concat "+" mh-folder))
	(setq mode-line-format mh-mode-line)
    )
)
