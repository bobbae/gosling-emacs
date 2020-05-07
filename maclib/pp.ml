(declare-global pp-margin)
(setq pp-margin 79)

(declare-global &which-pp)
(setq &which-pp "/usr/local/bin/pp.mod2")

(declare-global &pp-modunit)
(setq &pp-modunit "\002")

(declare-global &pp-defunit)
(setq &pp-defunit "\005")

(declare-global &pp-endunit)
(setq &pp-endunit "\001")

(declare-global &pp-in-progress)

(declare-global &pp-running)
(setq &pp-running 0)

(declare-global &pp-unit-boundary)
(setq &pp-unit-boundary
         (concat "^[ \t]*\n[Cc][Oo][Nn][Ss][Tt]\\|" 
	 "^[ \t]*\n[Tt][Yy][Pp][Ee]\\|"
	 "^[ \t]*\n[Vv][Aa][Rr]\\|"
	 "^[ \t]*\n[Pp][Rr][Oo][Cc][Ee][Dd][Uu][Rr][Ee]\\|"
	 "^[ \t]*\n[Ee][Xx][Cc][Ee][Pp][Tt][Ii][Oo][Nn]\\|"
	 "^[ \t]*\n[Mm][Oo][Dd][Uu][Ll][Ee]\\|"
	 "^[ \t]*\n[Bb][Ee][Gg][Ii][Nn]"
       )
)

(defun
   (&pp-startup
      (message "pp: starting up ...")
      (save-excursion 
         (execute-monitor-command 
           "echo $USER : pp.ml >> /udir/hania/pp/emacsppuselog")
         (temp-use-buffer "&pp")
         (erase-buffer)
         (setq needs-checkpointing 0)
         (start-filtered-process 
	    (concat &which-pp " " pp-margin " " 1 
              " | /usr/local/bin/emacsppbuffer")
	    "&pp" "&pp-filter")
         (setq &pp-in-progress 1)
         (string-to-process "&pp" (concat &pp-modunit &pp-endunit "\n"))
         (while &pp-in-progress (await-process-input))
         (setq &pp-running 1)
      )
      (message " ")
      (novalue)
    )
)

(defun (pp-unit start
        (find-format-unit)
	(setq start (dot))
        (pp-region)
	(set-mark)
	(goto-character start)
	(exchange-dot-and-mark)
       )
)

(defun
   (pp-region pp-type
      (if (! &pp-running) (&pp-startup))
      (save-excursion
	 (beginning-of-file)
	 (if (! (error-occured (search-forward &pp-endunit)))
	     (error-message "pp: file mustn't contain ^A"))
         (temp-use-buffer "&pp-output")
         (erase-buffer)
         (setq needs-checkpointing 0)
      )
      (if
         (= (extension (current-file-name)) ".mod")
            (setq pp-type &pp-modunit)
         (= (extension (current-file-name)) ".def")
            (setq pp-type &pp-defunit)
         (error-message "pretty-print only .mod or .def files")
      )
      (message "pp: working ...")
      (sit-for 0)
      (setq &pp-in-progress 1)
      (string-to-process "&pp" pp-type)
      (region-to-process "&pp")
      (string-to-process "&pp" &pp-endunit)
      (string-to-process "&pp" "\n")
      (while &pp-in-progress (await-process-input))
      (delete-to-killbuffer)
      (yank-buffer "&pp-output")
      (if (! (error-occured (search-reverse "(* SYNTAX ERROR *)")))
	  (progn
	   (set-mark)
	   (error-occured 
	    (progn
              (backward-character)
              (if (bolp) (set-mark))))
	   (search-forward "(* SYNTAX ERROR *)")
	   (erase-region)
           (if (looking-at " ") (delete-next-character))
	   (message "pp: can't finish")
          )
      (message "pp: done")
      )
      (novalue)
      )
)

(if (error-occured (index "ab" "a" 1))
(defun
    (index i string subst start-from len sublen
        (setq string (arg 1 "String: "))
	(setq subst (arg 2 "Locate: "))
        (setq i (arg 3 "Start from: "))
	(setq sublen (length subst))
	(setq len (+ 1 (- (length string) sublen)))
	(while (& (<= i len) (!= subst (substr string i sublen)))
	    (setq i (+ i 1)))
	(if (= subst (substr string i sublen)) i
	    0)
    )
))

(defun
   (extension filename result ldot tdot
      (setq filename (arg 1 "Filename: "))
      (setq ldot 0)
      (while (setq tdot (index filename "." (+ ldot 1)))
          (setq ldot tdot)
      )
      (if ldot
         (setq result (substr filename ldot 100))
         (setq result "")
      )
      result
   )
)

(defun
   (&pp-filter str
;      (if (= (sending-process) "&pp")
         (save-excursion
            (setq str (process-output))
            (temp-use-buffer "&pp-output")
            (end-of-file)
            (insert-string str)
            (if (! (error-occured (search-reverse &pp-endunit)))
               (progn
                  (set-mark)
                  (end-of-file)
                  (delete-to-killbuffer)
                  (beginning-of-file)
                  (while (& (eolp) (! (eobp)))
			 (delete-next-character))
                  (setq &pp-in-progress 0)
               )
            )
         )
;         (message "pp: bad sending process " (sending-process))
;      )
   )
)

(defun
  (find-format-unit
    (if (error-occured (re-search-reverse &pp-unit-boundary))
       (beginning-of-file)
    )
    (set-mark)
    (if (bobp)
        (progn 
          (end-of-file) 
	  (if (bolp) (error-occured (backward-character))))
	(progn
           (next-line)
           (beginning-of-line)
           (set-mark)
           (if (error-occured (re-search-forward &pp-unit-boundary))
	      (progn 
	        (end-of-file) 
		(if (bolp) (error-occured (backward-character))))
              (progn (previous-line) (previous-line) (end-of-line))
           )
        )
     )
     (exchange-dot-and-mark)
  )
)
