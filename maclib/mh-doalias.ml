(declare-global alias-file)
(declare-global ns-spellcheck-mail)
(setq  ns-spellcheck-mail 0) 	; set to 1 in .emacs_pro to enable spell
				; checking of mail rjs  3/23/93

(error-occured
    (setq alias-file (expand-file-name "~/.alias"))
    (setq alias-file (getenv "MH_ALIASES"))
)

(defun
    (mh-compose-hook
	(if (file-exists alias-file)
	    (progn 
		   (message (concat
				   "Looking for local aliases in your "
				   (current-buffer-name)
				   " ..."))
		   (sit-for 0)
		   (beginning-of-file)
		   (set-mark)
		   (if (error-occured (re-search-forward "^-"))
		       (end-of-file)
		       (beginning-of-line)
		   )
		   (fast-filter-region "doalias")
		   (exchange-dot-and-mark)
		   
		   (if
		      (looking-at "Couldn't")
		      (progn (erase-region)
			     (yank-from-killbuffer)
			     (message "Couldn't execute doalias, sorry.")
			     (sit-for 25)
		      )
		      
		      (! (error-occured (re-search-forward "^Alias-")))
		      (progn 
			     (set-mark)
			     (end-of-line)
			     (message (region-to-string))
			     (push-back-character 'e')
			     (sit-for 25)
		      )
		   )
	    )
	    
	)
	(if (!= ns-spellcheck-mail 0)
	    (ns-spell-mh-buffer)
	)
    )
)
