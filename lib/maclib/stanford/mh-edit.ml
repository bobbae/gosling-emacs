;  This autoloaded file implements the "e" command of mhe
(defun 
    (&mh-edit msgn fn fl
	(save-excursion
	    (pop-to-buffer (concat "+" mh-folder))
	    (&mh-save-killbuffer)
	    (delete-other-windows)
	    (error-occured
		(setq msgn (&mh-get-msgnum))
		(setq fn (&mh-get-fname))
		(setq fl mh-folder)
		(message "editing message " msgn)
		(setq mode-line-format "{%b}	%[^X^F writes and exits to top level%]  %M")
		(pop-to-buffer "message")
		(read-file fn)
		(setq mode-line-format
		      (concat "{%b}	%[%p of +" fl "/" msgn
			      "%] ^X^C exits to top level |%M"))
		(local-bind-to-key "exit-emacs" "\\")
		(&mh-restore-killbuffer)
		(recursive-edit)
		(pop-to-buffer "message")
		(setq mode-line-format
		      (concat "{%b}	%[%p of +" fl "/" msgn "%] |%M"))
	    )
	)
	(pop-to-buffer (concat "+" mh-folder))
	(setq mode-line-format mh-mode-line)
    )
)
