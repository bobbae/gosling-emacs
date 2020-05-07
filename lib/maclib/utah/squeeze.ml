	;;;; LastEditDate="Tue Oct 19 11:36:46 1982"
	;;;;
	;;;; Squeeze.ml
	;;;; Written by Tony Hansen.
	;;;;
	;;;; Take an mlisp file and remove all extraneous stuff
	;;;; from it, then writes the file out.
	;;;;
	;;;; I think that this is as close as we will get to a
	;;;; compiler for mlisp functions.
	;;;;
	;;;; By convention, this file name should be the file's
	;;;; name without the .ml extension, and you will get that
	;;;; if you just type return.
	;;;;
	;;;; It is assumed that dot starts in the file you want
	;;;; squeezed down.
	;;;; 
	;;;; SWT Mon Jan 17 1983 - added "Squeeze-com" function for
	;;;; invocation from command line in a background emacs.
	;;;; Capitalized to prevent name conflict.
(defun 
    (Squeeze-com file i
	(setq i 0)
	(while (< i (argc))
	       (if (!= (substr (argv i) 1 1) "-")
		   		; There is a potential bug here - no files
				; starting with a dash will be processed.
				; However, anybody who starts a file with a
				; dash deserves what s/he gets.
		   (progn
			 (setq file (argv i))
			 (error-occured
			     (visit-file file)
			     (squeeze-mlisp-file "")
			     (delete-buffer (current-buffer-name))))
	       )
	       (setq i (+ i 1))
	)
	(exit-emacs)
    )
)

(defun
    (squeeze-mlisp-file 
	filename					; current file name
	sfilename					; squeezed file name
	default-sfilename				; default squeezed fn
	bufname						; current buffer name
	sbufname					; squeeze buffer name
	fc						; following char
	watch						; watch it being done
	
	(setq filename (current-file-name))		; fill in values
	(setq bufname (current-buffer-name))		; ....
	(if prefix-argument-provided			; ....
	    (setq watch 1)				; ....
	    (setq watch 0))				; ....
	
	(save-restriction old-mod-flag			; get squeezed file name
	    (setq old-mod-flag buffer-is-modified)	; ....
	    (set-mark)					; ....
	    (narrow-region)				; ....
	    (insert-string filename)			; ....
	    (error-occured (search-reverse "/"))	; .... find basename
	    (if (error-occured (search-forward "."))	; .... any suffix?
		(setq default-sfilename "No default")	; ....
		(progn (end-of-line)			; .... remove suffix
		       (search-reverse ".")		; ....
		       (setq default-sfilename		; ....
			     (region-to-string))))	; ....
	    (erase-buffer)				; .... clean up
	    (setq buffer-is-modified old-mod-flag))	; ....
	(setq sfilename					; .... ask user
	      (arg 1					; ....
		  (concat "File to write out to ["	; ....
			  default-sfilename "]? ")))	; ....
	(if (& (= sfilename "")				; .... give default
	       (= default-sfilename "No default"))	; ....
	    (setq sfilename "/dev/null")		; ....
	    (setq sfilename default-sfilename))		; ....
	
	(save-window-excursion
	    (error-occured				; visit squeezed file
		(visit-file sfilename))
	    (setq sbufname				; save buffer name
		  (current-buffer-name))
	    (erase-buffer)				; erase old contents
	    (yank-buffer bufname)			; get .ml version
	    (beginning-of-file)

	    (while (! (eobp))
		   (if watch (sit-for 0))		; let us watch
		   (delete-white-space)			; leading spaces
		   (while (! (eolp))
			  (setq fc (following-char))
			  (if (= fc '(')		; skip left paren
			      (forward-character)
			      (= fc ')')		; skip right paren
			      (progn (if (= (preceding-char) '^J')
					 (delete-previous-character))
				     (forward-character))
			      (= fc '"')		; quoted string
			      (progn (delete-white-space)
				     (if (! (bolp))
					 (insert-character ' '))
				     (forward-to-double-quote))
			      (= fc '\'')		; quoted char
			      (progn (delete-white-space)
				     (if (! (bolp))
					 (insert-character ' '))
				     (forward-to-single-quote))
			      (| (= fc ' ')		; white space
				 (= fc '^I'))
			      (progn (delete-white-space)
				     (if (! (bolp))
					 (insert-character ' ')))
			      (= fc ';')		; comment
			      (kill-to-end-of-line)
			      ;else			; everything else
			      (skip-mlisp-word))
		   )
		   (delete-white-space)			; trailing spaces
		   (if (= (current-column) 1)		; on blank line?
		       (error-occured (delete-next-character))
		       (error-occured (forward-character))))
	    (if (!= (preceding-char) '^J')		; add nl at file end
		(newline))
	    (beginning-of-file)
	    (write-named-file sfilename))		; write out result
	(delete-buffer sbufname)			; cleanup
	(message filename " >>> " sfilename "!")
	(novalue)
    )
    
    ; skip over quoted string
    (forward-to-double-quote quote in-string nextchar
	(setq quote '"')				; which quote?
	(setq in-string 1)
	(forward-character)				; skip quote
	(while in-string
	       (setq nextchar (following-char))		; look at next char
	       (if (error-occured			; move over char
		       (forward-character))
		   (error-message "End of buffer found within string!"))
	       (if (= nextchar quote)			; end of string?
		   (if (= (following-char) quote)	; ... another quote?
		       (forward-character)		; ... skip it too
		       (setq in-string 0))		; ... nope, the end
		   (= nextchar 92)			; backslash
		   (forward-character)			; ... skip next char
		   (= nextchar '^J')			; newline
		   (error-message "Newline found within string!")
	       )))

    (forward-to-single-quote nextchar
	(forward-character)				; skip quote
	(setq nextchar (following-char))
	(if (error-occured (forward-character))		; skip next char
	    (error-message
		"End of buffer found in character constant!"))
	(if (= nextchar 92)				; backslash
	    (if (& (>= (following-char) '0')
		   (<= (following-char) '9'))
		(while (& (>= (following-char) '0')	; skip number
			  (<= (following-char) '9'))
		       (forward-character))
		(if (error-occured (forward-character))	; skip next char
		    (error-message
			"End of buffer found in character constant!")))
	    (= nextchar '^')				; control char?
	    (if (!= (following-char) '\'')		; skip next char
		(if (error-occured (forward-character))
		    (error-message
			"End of buffer found in character constant!"))
	    ))
	(if (!= (following-char) '\'')			; skip other quote
	    (error-message
		"Improper character constant!")
	    (forward-character)))

    ; skip over mlisp word
    (skip-mlisp-word
	(if (error-occured				; find next white
		(re-search-forward "[ \t\n()]"))	; ... space or parens
	    (end-of-line)				; oops, none there
	    (backward-character)))			; back up
)

