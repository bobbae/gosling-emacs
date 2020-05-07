; Modula-2 editing support package for emacs
;
; author: Mick Jordan
; amended: Peter Robinson
; thoroughly modified and extended: Benli Pierce
; documented and prepared for distribution: Benli Pierce

; --------------------------------------------------------------

; The main facilities of the modula-2 mode are:
;     * A number of functions for automatically inserting correctly
;       formatted statement templates.  Most modula-2 structures
;       of any complexity have such a function.
;     * Local key bindings for these functions
;     * Automatic time-stamping of files
;     * Four-space tabbing
;     * Automatic indentation (bound to <cr>)
;     * Automatic addition of identifiers to export lists
;     * Automatic variable declarations

; Rather than try to document all of the features of each function,
; I will simply refer the user to the end of this file where the
; key bindings are defined, and then to the function definitions 
; themselves.  I believe everything is reasonably self-explanatory.
; 
; It will probably be easier to see what the functions do by trying
; them on a test file rather than by reading the code.


; Note on style:
;     I realize that my particular indentation style will not appeal
;     to everyone who uses this package.  However, rather than try to
;     parameterize the package for every possible alternative formatting
;     style that anyone might use I simply used one that seemed
;     reasonable, with the notion that anyone who isn't happy with
;     it is welcome to modify the code to suit their pleasure.  I
;     think they will find it a fairly simple exercise.


;                                          -- Benjamin C. Pierce, Feb. 1984

; --------------------------------------------------------------
; .emacs_pro additions:

;            ; Emacs Modula-2 mode minimal profile file
;            ; 
;             
;            (load "modula2")
;            (auto-execute "modula-2" "*.def")
;            (auto-execute "modula-2" "*.mod")
;            (remove-binding "\^Q")
;            (setq lowercase-modula-keywords 1)
;            (setq redundant-modula-comments 1)
;            (declare-global 
;                modula-site-name
;                modula-copyright-notice
;                programmers-full-name)
;            (setq modula-site-name "DEC Western Research Lab")
;            (setq modula-copyright-notice "Copyright (c) Digital Equipment")
;            (setq programmers-full-name "Benjamin C. Pierce")

; Parameters:
;    lowercase-modula-keywords -- some people prefer to have all of 
;           their modula-2 keywords in UPPERCASE.  These people should
;           set this variable to 0.
;    redundant-modula-comments -- some people like to have the END
;           statement that closes each block marked with a comment
;           telling what kind of block it is.  These people should
;           set this variable to 1.  Those who would rather just
;           use indentation cues should set it to 0.
;    modula-site-name -- if defined, this will be inserted in the
;           header for each modula-2 file.  If undefined, that line
;           of the header will simply be left out.
;    modula-copyright-notice -- ditto
;    programmers-full-name -- used to fill in the Author field of
;           the file header.  Set it to the name you like to appear
;           in code that you write.
;    modula-max-col -- used in routines that do formatting to determine
;           how long lines can be.  Default: 70

; --------------------------------------------------------------
; First, all the modula-2 mode procedures

(defun 
    (m2-module name
	(progn 
	       (if (= (current-file-extension) ".def")
		   (insert-string (cap-maybe "DEFINITION MODULE "))
		   (insert-string (cap-maybe "IMPLEMENTATION MODULE "))
	       ))
	(insert-string (current-file-root))
	(insert-string (cap-maybe ";\n\n\n\nEND "))
	(insert-string (current-file-root))
	(insert-string ".\n")
	(previous-line)
	(previous-line)
	(previous-line)
    )

    (m2-header
	(insert-string "(*\n    Title: \t")
	(insert-string (get-tty-string "Title: "))
	(insert-string "\n    LastEdit:\t""")
	(insert-string (current-time))
	(insert-string """")
	(if (! (is-bound programmers-full-name))
	    (progn
		  (declare-global programmers-full-name)
		  (setq programmers-full-name
			(get-tty-string "Author: "))))
	(insert-string "\n    Author: \t")
	(insert-string programmers-full-name)
	(insert-string "\n")
	(if (is-bound modula-site-name)
	    (insert-string (concat
				  "\t\t"
				  modula-site-name
				  "\n")))
	(if (is-bound modula-copyright-notice)
	    (insert-string (concat
				  "\t\t"
				  modula-copyright-notice
				  "\n")))
	(insert-string "*)\n")
    )
)

(defun 
    (m2-procedure name args
	(insert-string (cap-maybe "PROCEDURE "))
	(setq name (get-tty-string "Name: " ))
	(insert-string name)
	(insert-character ';')
	(m2-newline)
	(insert-string (cap-maybe "BEGIN"))
	(m2-newline)
	(insert-string (cap-maybe "END "))
	(insert-string name)
	(insert-character ';')
	(previous-line)
	(end-of-line)
	(m2-newline)
	(m2-tab)
	(previous-line)
	(previous-line)
	(end-of-line)
	(backward-character)
    )
)


(defun     
    (m2-case
	    (insert-string (cap-maybe "CASE "))
	    (insert-string (get-tty-string ": "))
	    (insert-string (cap-maybe " OF"))
	    (m2-newline)
	    (m2-newline)
	    (insert-string (cap-maybe "END"))
	    (redundant-comment " (* CASE *)")
	    (insert-string ";")
	    (previous-line)
	    (end-of-line)
	    (m2-tab)
    )
)

(defun 
    (m2-for
	   (insert-string (cap-maybe "FOR "))
	   (insert-string (get-tty-string ": "))
	   (insert-string (cap-maybe " DO"))
	   (m2-newline)
	   (m2-newline)
	   (insert-string (cap-maybe "END"))
	   (redundant-comment " (* FOR *)")
	   (insert-string ";")
	   (previous-line)
	   (end-of-line)
	   (m2-tab)
    )
)
    
(defun     
    (m2-if
	  (insert-string (cap-maybe "IF "))
	  (insert-string (get-tty-string ": "))
	  (insert-string (cap-maybe " THEN"))
	  (m2-newline)
	  (m2-newline)
	  (insert-string (cap-maybe "END"))
	  (redundant-comment " (* IF *)")
	  (insert-string ";")
	  (previous-line)
	  (end-of-line)
	  (m2-tab)
    )
    
    (m2-else
	    (provide-prefix-argument 4 (delete-previous-character))
	    (insert-string (cap-maybe "ELSE"))
	    (m2-newline)
	    (m2-tab)
    )
    
    (m2-loop
	    (insert-string (cap-maybe "LOOP"))
	    (m2-newline)
	    (m2-newline)
	    (insert-string (cap-maybe "END"))
	    (redundant-comment "(* LOOP *)")
	    (insert-string ";")
	    (previous-line)
	    (end-of-line)
	    (m2-tab)
    )
)

(defun 
    (m2-begin  cc
	(setq cc (current-column))
	(insert-string (cap-maybe "BEGIN"))
	(insert-string "\n")
	(while (> cc 1)
	       (insert-character ' ')
	       (setq cc (- cc 1))
	)
	(m2-newline)
	(insert-string (cap-maybe "END;"))
	(previous-line)
	(end-of-line)
	(m2-tab)
    )
    
    (m2-until
	(insert-string (cap-maybe "REPEAT"))
	(m2-newline)
	(m2-newline)
	(insert-string (cap-maybe "UNTIL "))
	(insert-string (get-tty-string ": "))
	(insert-character ';')
	(previous-line)
	(end-of-line)
	(m2-tab)
    )

    (m2-while
	(insert-string (cap-maybe "WHILE "))
	(insert-string (get-tty-string ": "))
	(insert-string (cap-maybe " DO"))
	(m2-newline)
	(m2-newline)
	(insert-string (cap-maybe "END"))
	(redundant-comment " (* WHILE *)")
	(insert-string ";")
	(previous-line)
	(end-of-line)
	(m2-tab)
    )
)
    
(defun     
    (m2-with
	    (insert-string (cap-maybe "WITH "))
	    (insert-string (get-tty-string ": "))
	    (insert-string (cap-maybe " DO"))
	    (m2-newline)
	    (m2-newline)
	    (insert-string (cap-maybe "END"))
	    (redundant-comment " (* WITH *)")
	    (insert-string ";")
	    (previous-line)
	    (end-of-line)
	    (m2-tab)
    )
)

(defun     
    (m2-var
	   (insert-string (cap-maybe "VAR"))
	   (m2-newline)
	   (m2-tab)
    )

    (m2-record  cc
	(setq cc (current-column))
	(insert-string (cap-maybe "RECORD"))
	(insert-string "\n")
	(while (> cc 1)
	       (insert-character ' ')
	       (setq cc (- cc 1))
	)
	(m2-newline)
	(insert-string (cap-maybe "END"))
	(redundant-comment " (* RECORD *)")
	(insert-string ";")
	(previous-line)
	(end-of-line)
	(m2-tab)
    )
)    

(defun     
    (m2-export
	(insert-string (cap-maybe "EXPORT QUALIFIED;"))
	(backward-character)
    )
    
    (m2-import
	(insert-string (cap-maybe "FROM "))
	(insert-string (get-tty-string "Module: "))
	(insert-string (cap-maybe " IMPORT;"))
	(backward-character)
    )
)

(defun 
    (m2-auto-export  prevword ident
	(if (!= (current-file-extension) ".def")
	    (error-message "not in .def file"))
	
	(save-excursion
	    ; find current token
	    (setq ident (this-word))
	    ; now add it to the exports
	    (find-export)
	    (if (error-occured (search-forward ";"))
		(error-message "EXPORT not terminated"))
	    (backward-word)
	    (set-mark)
	    (forward-word)
	    (setq prevword (region-to-string))
	    (setq prevword (upcase prevword))
	    (if (& (!= prevword "EXPORT")
		   (!= prevword "QUALIFIED"))
		(insert-string ","))
	    (if (> (+ (current-column) (length ident)) modula-max-col)
		(insert-string "\n    ")
		(insert-string " "))
	    (insert-string ident)
	)
	(message "EXPORT " ident)
	(sit-for 2)
    )
)

(defun 
    (m2-auto-var    ident type
	(if prefix-argument-provided
	    (setq ident (arg 1 "VAR ")))
	(if (= ident "")
	    (setq ident (this-word)))
	(setq type (arg 2 (concat "VAR " ident ": ")))
	(save-excursion
	    (if (error-occured (re-search-reverse "^begin"))
		(error-message "Can't find enclosing begin"))
	    (beginning-of-line)
	    (set-mark)
	    (if (error-occured (re-search-reverse "^end\\|^procedure"))
		(error-message "Can't find procedure header"))
	    (if (= (this-word) "end")
		(progn 				 ; global var
		    (beginning-of-file)
		    (if (error-occured
			    (re-search-forward "^var\\|^procedure"))
			(error-message "Can't find global vars"))
		    (if (= (this-word) "procedure")
			(progn
			      (beginning-of-line)
			      (insert-string "var \n\n")
			      (previous-line)
			      (previous-line))
			(progn 
			       (forward-character)
			       (insert-string "\n    ")
			       (previous-line)
			       (beginning-of-line)))
		)
		(progn				 ; local var
		    (narrow-region)
		    (if (error-occured (re-search-forward "^var"))
			(progn
			      (end-of-file)
			      (insert-string "var \n")
			      (previous-line))
			(progn 
			       (forward-character)
			       (insert-string "\n    ")
			       (previous-line)))
		    (beginning-of-line)
		    (widen-region)
		))
	    (end-of-line)
	    (insert-string ident ": " type ";")
	)
    ))

; ------------------------------------------------------------------
; Modula-2 mode-specific support functions

(defun
    (redundant-comment
	(if redundant-modula-comments
	    (insert-string (cap-maybe (arg 1))))
    )
)

(defun 
    (cap-maybe
	(if lowercase-modula-keywords
	    (save-excursion
		(temp-use-buffer "temp")
		(erase-buffer)
		(insert-string (arg 1))
		(end-of-file)
		(set-mark)
		(beginning-of-file)
		(case-region-lower)
		(region-to-string))
	    (arg 1)
	)
    )
)

(defun 
    (m2-newline cc
	(newline-and-indent)
	(setq cc (current-column))
	(delete-white-space)
	(while (> cc 1)
	       (insert-character ' ')
	       (setq cc (- cc 1))
	)
    )
    
    (m2-tab cc
	    (insert-character ' ')
	    (setq cc (current-column))
	    (while (!= (% cc 4) 1)
		   (insert-character ' ')
		   (setq cc (+ cc 1))
	    )
    )
)

(defun 
    (find-export 
	(beginning-of-file)
	(if (error-occured (search-forward "export"))
	    (if (error-occured (search-forward "EXPORT"))
		(error-message "Cannot find EXPORT statement")
	    )
	)
    )
)


; ------------------------------------------------------------------
; Miscellaneous support functions

(defun     
    (upcase
	   (save-excursion
	       (temp-use-buffer "temp")
	       (erase-buffer)
	       (insert-string (arg 1))
	       (beginning-of-file)
	       (set-mark)
	       (end-of-file)
	       (case-region-upper)
	       (region-to-string)
	       
	   )
    )
)

(defun     
    (current-file-extension   current-file
	(setq current-file (current-file-name))
	(save-excursion
	    (temp-use-buffer "temp")
	    (erase-buffer)
	    (insert-string current-file)
	    ; find extension
	    (search-reverse ".")
	    (set-mark)
	    (end-of-file)
	    (region-to-string)
	)	
    )
)

(defun  
    (current-file-root   current-file
	(setq current-file (current-file-name))
	(save-excursion
	    (temp-use-buffer "temp")
	    (erase-buffer)
	    (insert-string current-file)
	    ; find root
	    (end-of-file)
	    (search-reverse "/")
	    (forward-character)
	    (set-mark)
	    (if (! (error-occured 
		       (search-forward ".")))
		(backward-character))
	    (region-to-string)
	)	
    )
)

(defun
    (this-word
	(save-excursion
	    (error-occured (forward-character))
	    (backward-word)
	    (set-mark)
	    (forward-word)
	    (region-to-string)
	)
    )
)

(defun     
    (better-delete
	; before deleting
	(if (=  (preceding-char) 9)
	    (progn num-blanks
		   (delete-previous-character)
		   (setq num-blanks
			 (- 8
			    (% (- (current-column) 1)
			       8)))
		   (while (> num-blanks 0)
			  (insert-string " ")
			  (setq num-blanks (- num-blanks 1)))
	    ))
	(delete-previous-character)
    )
)    



; ------------------------------------------------------------------

(defun     
    (modula-2
	; set up syntax table
	(use-syntax-table "text-mode")
	(modify-syntax-entry "()   (")
	(modify-syntax-entry ")(   )")
	(modify-syntax-entry "(]   [")
	
	; set up key bindings
	(remove-all-local-bindings)
	(local-bind-to-key "better-delete" '')
	(local-bind-to-key "m2-newline" "\015")
	(local-bind-to-key "m2-tab" "\^i")
	
	(local-bind-to-key "m2-auto-export" "\^Qa")
	(local-bind-to-key "m2-auto-export" "\^Q\^A")
	(error-occured 			; these aren't used some places
		(local-bind-to-key "m2-auto-import" "\^Qq")
		(local-bind-to-key "m2-auto-import" "\^Q\^Q"))
	(local-bind-to-key "m2-auto-var" "\^Q\^V")
	(local-bind-to-key "m2-begin" "\^Qb")
	(local-bind-to-key "m2-case" "\^Qc")
	(local-bind-to-key "m2-else" "\^Qe")
	(local-bind-to-key "m2-for" "\^Qf")
	(local-bind-to-key "m2-header" "\^Qh")
	(local-bind-to-key "m2-if" "\^Qi")
	(local-bind-to-key "m2-loop" "\^Ql")
	(local-bind-to-key "m2-module" "\^Qm")
	(local-bind-to-key "m2-procedure" "\^Qp")
	(local-bind-to-key "m2-with" "\^Qd")
	(local-bind-to-key "m2-record" "\^Qr")
	(local-bind-to-key "m2-until" "\^Qu")
	(local-bind-to-key "m2-var" "\^Qv")
	(local-bind-to-key "m2-while" "\^Qw")
	(local-bind-to-key "m2-export" "\^Qx")
	(local-bind-to-key "m2-import" "\^Qy")
	
	(setq mode-string "Modula-2")

	
	; Now see if the file has a modification date we should set...
	(if (! buffer-is-modified)
	    (save-excursion
		(error-occured
		    (end-of-window)
		    (search-reverse "LastEdit:")
		    (search-forward "\"")
		    (set-mark)
		    (search-forward "\"")
		    (backward-character)
		    (erase-region)
		    (insert-string (current-time))
		    (insert-string "   (")
		    (insert-string (users-login-name))
		    (insert-string ")")
		    (setq buffer-is-modified 0)
		)
	    )
	)
    )
)

(declare-global lowercase-modula-keywords)
(declare-global redundant-modula-comments)
(declare-global modula-max-col)

(setq modula-max-col 70)

(novalue)
