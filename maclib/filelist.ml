(declare-global fm-directory-stack fm-last-belongs 
    fm-last-current-dir fm-first-time)
(setq fm-directory-stack "")
(setq fm-last-belongs 0)
(setq fm-first-time 1)
(declare-buffer-specific fm-last-modtime)
(setq-default fm-last-modtime 0)

(defun (new-working-directory cwd
          (setq cwd (working-directory))
	  (if (= cwd "") "/" cwd)
       )
)

(save-excursion 
    (temp-use-buffer "Get file")
    (setq needs-checkpointing 0)
    (setq mode-line-format 
	  "%[ %b  Click in path to chdir, in filename to open %]")
    (if (is-bound click-hook)
	(setq click-hook
	      "(if (& up (! shift)) (menu-open-file))"))
)

;****************************************************************
;* (only-directories)                                           *
;*                                                              *
;*     Passed to the fm-ls routine to ensure that only          *
;* directories are listed in the folders window                 *
;****************************************************************

(defun
   (only-directories
      (save-excursion
         (end-of-line)
         (if (= (preceding-char) '/')
            (progn (delete-previous-character) 0)
            1
         )
      )
   )
)

(defun (no-comma-files
	   (| (looking-at ",") (looking-at "\\.,"))))

(defun (fm-create-HFS new-name new-name-nl
	   (if (& (is-bound shift) shift)
	       (pop-to-buffer "Get file")
	       (switch-to-buffer "Get file"))
	   (setq new-name-nl (expand-file-name (new-working-directory)))
	   (if (!= (substr new-name-nl -1 1) "/")
	       (setq new-name-nl (concat new-name-nl "/")))
	   (setq fm-last-current-dir new-name-nl)
	   (setq new-name (concat new-name-nl "\n"))
	   (setq tab-size (fm-ls new-name-nl "no-comma-files"))
	   (erase-buffer)
	   (insert-string fm-directory-stack)
	   (if (! fm-last-belongs)
	       (progn (end-of-file)(set-mark)(previous-line)
		      (beginning-of-line)(erase-region)))
	   (beginning-of-file)
	   (setq fm-last-belongs
		 (! (error-occured 
			(re-search-forward 
			    (concat "^" new-name)))))
	   (if fm-last-belongs
	       (progn (region-around-match 0)(erase-region)))
	   (setq fm-last-belongs (| fm-last-belongs fm-first-time))
	   (setq fm-first-time 0)
	   (end-of-file)
	   (insert-string new-name)
	   (beginning-of-file)(set-mark)(end-of-file)
	   (setq fm-directory-stack (region-to-string))
	   (previous-line)(end-of-line)
	   (set-mark)(push-mark)(insert-string "   ")
	   (beginning-of-line)
	   (while (! (bobp))
		  (delete-previous-character)
		  (insert-string "   ")
		  (beginning-of-line))
	   (insert-string "   ")
	   (while (! (error-occured (search-forward "/   ")))
		  (if (>= (current-column) (- (window-width) 3))
		      (progn (search-reverse "/")
			     (search-reverse "   /")
			     (if (!= 1 (current-column))
				 (insert-string "   \n"))
			     (search-forward "/   "))))
	   (pop-mark)(exchange-dot-and-mark)
	   (save-excursion (end-of-file)(yank-buffer new-name-nl))
       )
)

(defun 
    (fm-ls prev-buffer-name fm-tabs fm-edit-type
	   (setq fm-edit-type (arg 2))
	   (setq prev-buffer-name (current-buffer-name))
	   (switch-to-buffer (arg 1)) 
	   (if (!= fm-last-modtime (file-modtime (new-working-directory)))
	       (progn max-file-name num-per-line counter
		      (setq fm-last-modtime 
			    (file-modtime (new-working-directory)))
		      (setq needs-checkpointing 0)
		      (erase-buffer)(set-mark)
		      (save-excursion 
			  (error-occured 
			      (rename-buffer "Kill buffer" "fm-ls-killbuffer"))
			  (fast-filter-region "/bin/ls -AF1")
			  (error-occured (delete-buffer "Kill buffer"))
			  (error-occured 
			      (rename-buffer 
				  "fm-ls-killbuffer" "Kill buffer")))
		      (setq max-file-name 0)
		      (beginning-of-file)
		      (while (! (eobp))
			     (set-mark)(next-line)(beginning-of-line)
			     (exchange-dot-and-mark)
			     (if 
			        (|
				   (& (= fm-edit-type "no-comma-files")
				      (no-comma-files))
				   (& (= fm-edit-type "only-directories")
				      (only-directories))
			 	) (erase-region)
			     )
			     (exchange-dot-and-mark)
			     (setq max-file-name 
				   (max max-file-name (- (dot) (mark)))))
		      (setq max-file-name (+ 1 max-file-name))
		      (setq num-per-line (/ (window-width) max-file-name))
		      (beginning-of-file) (end-of-line)
		      (setq counter num-per-line)
		      (while (! (eobp))
			     (setq counter (- counter 1 ))
			     (if (<= counter 0)
				 (progn (setq counter num-per-line)
					(forward-character))
				 (progn (delete-next-character)
					(insert-character '	'))
			     )
			     (end-of-line)
		      )
		      (setq tab-size max-file-name)
	       ))
	   (setq fm-tabs tab-size)	       
	   (switch-to-buffer prev-buffer-name)
	   fm-tabs
    )
)

(defun 
    (HFS-select HFS-fnam
	(save-excursion
	    (set-mark)(push-mark)(beginning-of-line)(set-mark)
	    (end-of-line)(narrow-region)(pop-mark)
	    (beginning-of-line)
	    (if (= (following-char) ' ')
		(progn (exchange-dot-and-mark)(set-mark)
		       (if (error-occured (search-reverse "   /"))
			   (beginning-of-line))
		       (forward-character)(forward-character)
		       (forward-character)(exchange-dot-and-mark)
		       (error-occured 
			   (search-forward "/"))
		       (setq HFS-fnam (region-to-string)))
		(progn (exchange-dot-and-mark)
		       (if (error-occured 
			       (search-reverse "\t"))
			   (beginning-of-line)
			   (forward-character))
		       (set-mark)
		       (if (error-occured 
			       (search-forward "\t"))
			   (end-of-line)
			   (backward-character))
		       (setq HFS-fnam (concat fm-last-current-dir
					      (region-to-string)))
		)
	    )
	    (widen-region)
	    (setq HFS-fnam (expand-file-name HFS-fnam))
	    (if (= HFS-fnam "") (setq HFS-fnam "/"))
	    (if (& (! (file-exists HFS-fnam)) 
		   (file-exists (substr HFS-fnam 1 -1)))
		(setq HFS-fnam (substr HFS-fnam 1 -1)))
	    HFS-fnam
	)
    )
)


(defun 
    (menu-open-file mof-fnam
	(setq mof-fnam (HFS-select))
	(if (error-occured (change-directory mof-fnam))
	    (progn mof-readonly mof-popup
		   (setq mof-readonly (file-exists mof-fnam))
		   (setq mof-popup pop-up-windows)
		   (setq pop-up-windows 0)
		   (if (!= mof-readonly 0)
		       (progn 
			   (visit-file mof-fnam)
			   (setq fm-last-belongs 1)
		       )
		       (message (concat "Can't open " mof-fnam))
		   )
		   (setq pop-up-windows mof-popup)
	    )
	    (fm-create-HFS)
	)
    )
)

