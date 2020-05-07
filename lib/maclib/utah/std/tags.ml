; twenex-like tags package		J. Gosling, November 81
;
; A tag file is a sequence of lines of the following forms:

; ^_filename
; ^Atagline^Bposition

; A tagline/position pair refers to the preceeding file

(declare-global last-search-tag)

(defun (to-tag-buffer
	   (temp-use-buffer "*TAG*")
	   (if (& (= (buffer-size) 0) (= (current-file-name) ""))
	       (progn
		   (if (error-occured (read-file ".tags"))
		       (progn
			   (write-named-file ".tags")
			   (message "New tag file")))
		   (beginning-of-file)))
       ))

(defun (visit-tag-table tagfn
	   (setq tagfn (arg 1 ": visit-tag-table "))
	   (save-excursion
	       (temp-use-buffer "*TAG*")
	       (read-file tagfn))
       ))

(defun (goto-tag fn str pos restart
	   (setq restart 0)
	   (if (save-excursion
		   (to-tag-buffer)
		   (= (buffer-size) 0))
	       (visit-tag-table (get-tty-string ": visit-tag-table ")))
	   (if (! prefix-argument-provided)
	       (progn
		   (setq last-search-tag
		       (concat "\^A[^\^B]*" (quote (arg 1 ": goto-tag "))))
		   (setq restart 1)))
	   (save-excursion
	       (to-tag-buffer)
	       (if restart (beginning-of-file))
	       (re-search-forward last-search-tag)
	       (beginning-of-line)
	       (re-search-forward "\^A\\([^\^B]*\\)\^B\\(.*\\)")
	       (region-around-match 1)
	       (setq str (region-to-string))
	       (region-around-match 2)
	       (setq pos (- (region-to-string) 300))
	       (save-excursion
		   (re-search-reverse "\^_\\(.*\\)")
		   (region-around-match 1)
		   (setq fn (region-to-string)))
	   )
	   (visit-file fn)
	   (goto-character pos)
	   (if (error-occured (search-forward str))
	       (search-reverse ""))
	   (beginning-of-line)
	   (line-to-top-of-window)
       ))

(defun (goto-tag-word fn str pos restart
	   (setq restart 0)
	   (if (save-excursion
		   (to-tag-buffer)
		   (= (buffer-size) 0))
	       (visit-tag-table (get-tty-string ": visit-tag-table ")))
	   (if (! prefix-argument-provided)
	       (progn
		   (setq last-search-tag
		       (concat "\^A[^\^B]*" "\\b"
			       (quote (arg 1 ": goto-tag-word ")) "\\b"))
		   (setq restart 1)))
	   (save-excursion
	       (to-tag-buffer)
	       (if restart (beginning-of-file))
	       (re-search-forward last-search-tag)
	       (beginning-of-line)
	       (re-search-forward "\^A\\([^\^B]*\\)\^B\\(.*\\)")
	       (region-around-match 1)
	       (setq str (region-to-string))
	       (region-around-match 2)
	       (setq pos (- (region-to-string) 300))
	       (save-excursion
		   (re-search-reverse "\^_\\(.*\\)")
		   (region-around-match 1)
		   (setq fn (region-to-string)))
	   )
	   (visit-file fn)
	   (goto-character pos)
	   (if (error-occured (search-forward str))
	       (search-reverse ""))
	   (beginning-of-line)
	   (line-to-top-of-window)
       ))

(defun (find-pos-str
	   (beginning-of-line)
	   (setq pos (+ (dot) 0))
	   (set-mark)
	   (end-of-line)
	   (setq str (region-to-string))))

(defun (store-pos-str
	       (insert-character '^A')
	       (insert-string str)
	       (insert-character '^B')
	       (insert-string pos)
	       (newline)))

(defun (add-tag
	   (save-excursion pos str fn
	       (find-pop-str)
	       (setq fn (current-file-name))
	       (to-tag-buffer)
	       (beginning-of-file)
	       (if (error-occured (re-search-forward
				      (concat "\^_" fn "[^\^_]*")))
		   (progn
		       (beginning-of-file)
		       (insert-character '^_')
		       (insert-string fn)
		       (newline)))
	       (store-pos-str)
	       (beginning-of-file))
       ))

(defun (add-tag* pos str
	   (find-pos-str)
	   (save-excursion
	       (temp-use-buffer "*TAG*")
	       (store-pos-str))))

(defun (add-all-tags pattern fn ntags
	   (setq pattern (arg 1 ": add-all-tags (pattern) "))
	   (setq fn (current-file-name))
	   (save-excursion
	       (to-tag-buffer)
	       (beginning-of-file)
	       (if (error-occured (search-forward (concat "\^_" fn "\n")))
		   (progn
		       (beginning-of-file)
		       (insert-character '^_')
		       (insert-string fn)
		       (newline))
		   (progn
			 (set-mark)
			 (while (= (following-char) '^A')
				(next-line))
			 (erase-region))
	       )
	   )
	   (setq ntags 0)
	   (save-excursion
	       (error-occured
		   (beginning-of-file)
		   (while 1
		       (re-search-forward pattern)
		       (add-tag*)
		       (setq ntags (+ ntags 1)))))
	   ntags
       )
)

(defun (add-typed-tags ext pattern
	   (setq ext (substr (current-file-name) -2 2))
	   (add-all-tags
	       (if
		   (= ext ".l") "^(def"
		   (= ext ".c") "^[A-z].*(.*)\\|^[/* \t]*TAGS*[ \t]*("
		   (= ext ".h") "#[ \t]*define\\|^[/* \t]*TAGS*[ \t]*("
		   (= ext "ml") "^(defun[ \t\n]*("
		   (= ext "ss") "@section\\|@chapter\\|@subsection"
		   (= ext ".p") "function\\|procedure"
		   (= ext ".r") (concat "^[^%\n]*procedure" "\\|"
					"^[^%\n]*defstruct" "\\|"
					"^[^%\n]*protocol"  "\\|"
					"^[^%\n]*defmacro")
		   (error (concat "Can't tag " (current-file-name)))
	       )
	   )
       ))

(defun (tag-file fn nfns
	   (setq fn (arg 1 ": tag-file (filename) "))
;	   (message (concat "Tagging " fn))
	   (save-window-excursion
	       (if (! (error-occured (visit-file fn)))
		   (setq nfns (add-typed-tags))
		   (setq nfns 0)))
	   (message "Tagged " fn ", found " nfns " Functions")
	   (sit-for 0)
       ))

(defun (recompute-all-tags
	   (save-window-excursion
	       (to-tag-buffer)
	       (beginning-of-file)
	       (error-occured
		   (while 1
		       (re-search-forward "\^_\\(.*\\)")
		       (region-around-match 1)
		       (tag-file (region-to-string)))
	       )
	       (if (= (current-file-name) "")
		   (write-named-file ".tags")
		   (write-current-file))))
)

(defun (make-tag-table fns
	   (setq fns (arg 1 ": make-tag-table (from filenames) "))
	   (save-window-excursion
	       (temp-use-buffer "*TEMP*")
	       (erase-buffer)
	       (set-mark)
	       (filter-region (concat "ls " fns))
	       (beginning-of-file)
	       (while (! (eobp))
		      (set-mark)
		      (end-of-line)
		      (tag-file (region-to-string))
		      (next-line)
		      (beginning-of-line))
	       (delete-buffer "*TEMP*")
	       (temp-use-buffer "*TAG*")
	       (if (= (current-file-name) "")
		   (write-named-file ".tags")
		   (write-current-file)))
	   (novalue)
       ))

(defun (visit-function func
	   (save-window-excursion
	       (forward-character)
	       (backward-word)
	       (set-mark)
	       (forward-word)
	       (setq func (region-to-string))
	       (goto-tag-word func)
	       (message "Type C-M-Z to go back")	;should check binding
	       (recursive-edit)
	   )
       ))
