(declare-global ns-mywords-modified ns-mywords-exists ns-mywords-fn
	ns-mywords-base-fn ns-mywords-other-fn ns-lib)

(setq ns-lib "/usr/local/lib/emacs/maclib")
(setq ns-mywords-base-fn "ns-mywords")


(error-occured
    (setq ns-mywords-other-fn (expand-file-name "~/emacs/ns-mywords"))
)



(defun 
    (spell  		;  alias for ns-spell
	(if (= (file-exists ns-mywords-base-fn) 1)
	    ; 1=>r/w, 0 not exist, -1 => read only
	    (setq ns-mywords-fn (expand-file-name ns-mywords-base-fn))
	    ; ELSE
	    (setq ns-mywords-fn (expand-file-name ns-mywords-other-fn))
	)
	(ns-spell (current-file-name) ns-mywords-fn)
    )
)

(defun
    (ns-spell-mh-buffer tmp-fn
	(setq tmp-fn  (concat mh-path "/" (current-buffer-name)))
	(write-named-file tmp-fn)
	(ns-spell tmp-fn ns-mywords-other-fn)
    )
)
	      

(defun 
    (ns-spell  ns-myfile 
	(setq ns-myfile (arg 1 "file to spell check:"))
	(setq ns-mywords-fn (arg 2 "personal word list:"))
	(message (concat "Spellcheck of" ns-myfile
			 ", with "  ns-mywords-fn))
	(sit-for 0)
	(save-window-excursion
	    ;  sort requires that all lines end in \n
	    (end-of-file)
	    (if (!= (preceding-char) '\n')
		(insert-character '\n')
	    )
	    (write-named-file ns-myfile)

	    (compile-it
		(concat ns-lib "/ns-spell.csh "
			ns-myfile " " ns-mywords-fn)))
	(ns-spell-init)
	(error-occured (ns-correct-mistakes))
	(ns-spell-windup)
	(message "ns-spell Done!")
	(novalue)
    )
)

;  windup files after running new spell
(defun
    (ns-spell-windup
	(save-excursion 
	    (if ns-mywords-modified
		(if (error-occured
			(temp-use-buffer "ns-spell-mywords")
			(end-of-file)
			(if (!= (preceding-char) '\n')
			    (insert-character '\n')
			)
			(write-named-file ns-mywords-fn)
			(message (concat "writing " ns-mywords-fn))
			; (mylog "writing ns-mywords")
		    )
		    (message (concat "ns-spell: Cant write "
				     ns-mywords-fn))
		)
	    )
	)
	(novalue)
    )
) 


(defun
    (ns-spell-init  s-file-status
	(setq ns-mywords-modified 0)
	(setq ns-mywords-exists 0)
	(setq s-file-status (file-exists ns-mywords-fn))
	; 1=>r/w, 0 not exist, -1 => read only
	(save-excursion
	    (error-occured
		(pop-to-buffer "ns-spell-mywords")
		(erase-buffer)
		(if (| (= s-file-status 1) (= s-file-status -1))
		    (progn
			  (read-file ns-mywords-fn)
			  (setq ns-mywords-exists 1)
		    )
		)
	    )
	)
	(save-excursion		; Begin a start of Error log
	    (temp-use-buffer "Error log")
	    (beginning-of-file)
	)
	(novalue)
    )
)


(defun
    (ns-correct-mistakes word correction action c-continue tmp bufff
	(setq c-continue 1)
	(error-occured
	    (while  (& c-continue
		       (progn
			     (setq word (ns-get-word "Error log"))
			     (> (length word) 0)))
		    (beginning-of-file)
		    (error-occured (re-search-forward (concat  "\\b"
							  (quote word)
							  "\\b")))
		    (setq action (br-get-response
				     (concat "Spelling? >>> " 
					     (quote word) " <<< (i, r, a, q, or ?) :")
				     "iIrRaAqQeE"
				     "i: include in dict, r: replace, a: accept, q: quit, ?: this msg. :"))
		    
		    (if (| (= action '^G') (= action 'e') (= action 'q')) 
			(setq c-continue 0))
		    (if (= action 'i') ; include
			(ns-spell-add word)
		    )
		    (if (= action 'r') ;;; r => replace
			(ns-spell-query-replace word))
		    ; Fall through for "accept
	    )
	)
	(novalue)
    )
)

; Handle adding new word to private dictionary
(defun
    (ns-spell-add  add-word
	(setq add-word (arg 1 "word to add to mywords:"))
	(save-excursion
	    (error-occured
		(temp-use-buffer "ns-spell-mywords")
		(end-of-file)
		(insert-string add-word)
		(newline)
		(setq ns-mywords-modified 1)
	    )
	)
	(novalue)
    )
)
	    
	


;;; query for correct spelling, replace current word, ask about others
(defun
    (ns-spell-query-replace wword re-word action wcontinue correction
	(setq wword (arg 1 "word to query-replace: "))
	(setq re-word 	(concat  "\\b" (quote wword) "\\b"))
	(error-occured
	    (setq correction (get-tty-string (concat "Correction: " 
						     (quote wword)
						     " => ")))
	    (ns-fix-word correction)
	    (setq wcontinue 1)
	    (while (& (re-search-forward re-word) (= wcontinue 1)) 
		   (setq action (br-get-response
				    (concat "replace with " correction
					    " ? (r, n, q, ?)")
				    "rRnNqQeE"
				    "r: replace, n: no replacement, q: quit, ?: this msg."))
		   
		   (if (= action 'r')
		       (ns-fix-word correction))
		   (if (= action 'n')
		       (no-value)) ;;; do nothing
		   (if (|  (= action '^G') (= action 'e') (= action 'q')) 
		       (setq wcontinue 0))
	    )
	)	  
    )
)
			
;;; call with dot set to a match on a word to be changed
(defun
    (ns-fix-word fcorrection
	(setq fcorrection (arg 1 "word to fix:"))
	(delete-previous-word) ;;; fix without further questions
	(insert-string (quote fcorrection))
	(novalue)
    )
)

; stuff to pull next "word" out of file without  being destructive
;  returns "" when a word cant be found
(defun
    (ns-get-word  ns-get-word-buffer sgw-word
	(setq ns-get-word-buffer (arg 1 "ns-get-word-buffer:"))
	(save-excursion
	    (temp-use-buffer ns-get-word-buffer)
	    ;; note file may include a blank line
	    (forward-word)
	    (if (eobp) 		;  test end of buffer
		(setq sgw-word "") ; ;  end of useful file
		; ELSE
		(progn     
		    (backward-word)
		    (set-mark)
		    (forward-word) ; avoid problem with blank lines
		    (setq sgw-word (region-to-string))
		    ; (mylog "word to fix is: " sgw-word)
		)
	    )
	    (novalue)
	)
	sgw-word) 			;  return word found
)


	

; This functions query the user for various things, and error-check the
; responses. "get-response" reads a 1-letter response code in the minibuffer.
; from mh-e.ml by Brian Reid.
; (br-get-response InitialPrompt StringOfValidResponseChars AdditionalPrompt)
; the initial response is matched against the valid response chars.
; If the response is "?" or not in the valid response, the AdditionalPrompt,
; with more explanation is used.
; The resulting char is always lower case. 
; Eg:
 ;;; (get-response
 ;;;  Ready to send. Action? (m, d, q, e, or ?) "
 ;;;    "mMdDqQeE\" 
 ;;;   "m: mail it, d: delayed mail, q: quit, e: resume editing, ?: this msg.")
    
(defun     
    (br-get-response pr chr ok s c 
	(setq ok 0)
	(setq pr (arg 1))
	(while (! ok)
	       (message pr)
	       (setq chr (get-tty-character))
	       (setq s (arg 2))
	       (while (> (length s) 0)
		      (if (= chr (string-to-char (substr s 1 1)))
			  (progn (setq ok 1) (setq s ""))
			  (setq s (substr s 2 -1))
		      )
	       )
	       (if (= ok 0)
		   (progn (if (!= chr '?')
			      (setq pr (concat "Illegal response '"
					       (char-to-string chr)
					       "'. " (arg 1)))
			      (setq pr (arg 3))
			  )
		   )
	       )
	)
	(if (& (>= chr 'A') (<= chr 'Z'))
	    (+ chr (- 'a' 'A'))
	    chr
	)
    )
)
    
    
    
