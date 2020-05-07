(declare-global last-line)
(declare-buffer-specific last-line)

(defun
    (pr-newline
	(end-of-line)
	(if (eobp)
	    (newline)
	    (progn com
		   (beginning-of-line)
		   (if (= (following-char) '$') (forward-character))
		   (if (= (following-char) ' ') (forward-character))
		   (set-mark)
		   (end-of-line)
		   (forward-character)
		   (setq com (region-to-string))
		   (end-of-file)
		   (set-mark)
		   (insert-string com)
	    )
	)
	(setq last-line (region-to-string))
	(region-to-process (active-process))
	(set-mark)
    )
)

(defun
    (shell
	(pop-to-buffer "shell")
	(setq needs-checkpointing 0)
	(if (< (process-status "shell") 0)
	    (start-process "sh" "shell"))
	(local-bind-to-key "pr-newline" '^m')
	(local-bind-to-key "send-eot" '')
	(local-bind-to-key "send-int-signal" '\177')
	(local-bind-to-key "send-quit-signal" '^\')
	(local-bind-to-key "grab-last-line" (+ 128 '='))
	(end-of-file)
	(novalue)
    )
)

(defun
    (new-shell name
	(setq name (arg 1 ": new-shell (buffer name) "))
	(pop-to-buffer name)
	(use-abbrev-table "shell")
	(use-syntax-table "shell")
	(setq abbrev-mode 1)
	(setq needs-checkpointing 0)
	(if (< (process-status name) 0)
	    (start-process "sh" name))
	(local-bind-to-key "pr-newline" '^m')
	(local-bind-to-key "send-eot" '')
	(local-bind-to-key "send-int-signal" '\177')
	(local-bind-to-key "send-quit-signal" '^\')
	(local-bind-to-key "grab-last-line" (+ 128 '='))
	(end-of-file)
	(novalue)
    )
)

(defun
    (send-eot
	(if (eobp)
	    (eot-process (active-process))
	    (delete-next-character)
	)
    )
)

(defun
    (send-int-signal
	(int-process (active-process))))

(defun
    (send-quit-signal
	(quit-process (active-process))))

(defun (lisp-kill-output
	   (end-of-file)
	   (beginning-of-line)
	   (set-mark)
	   (previous-line)
	   (re-search-reverse "^[0-9][0-9]*\.")
	   (next-line)
	   (erase-region)
	   (backward-character)
	   (insert-string "    [output flushed]")
	   (end-of-file)
	   (set-mark)
       ))

(defun
    (lisp
	(pop-to-buffer "lisp")
	(setq needs-checkpointing 0)
	(if (bobp)
	    (progn
		(electric-lisp-mode)
		(local-bind-to-key "lisp-kill-output" "\^X\^K")))
	(if (< (process-status "lisp") 0)
	    (start-process "cmulisp" "lisp"))
	(local-bind-to-key "pr-newline" '^m')
	(local-bind-to-key "send-eot" '')
	(local-bind-to-key "send-int-signal" '\177')
	(local-bind-to-key "send-quit-signal" '^\')
	(local-bind-to-key "grab-last-line" (+ 128 '='))
	(end-of-file)
	(novalue)
    )
)

(defun
    (grab-last-line
	(end-of-file)
	(set-mark)
	(insert-string last-line)
	(delete-previous-character)
    )
)

(defun (shell-cd
	   (if (= (- (dot) (mark)) 2)
	       (progn (cd (get-tty-string ": cd "))
		      (insert-string " " (working-directory))
		      (pr-newline)
		      0)
	       1)))

(save-excursion
    (temp-use-buffer "shell")
    (use-abbrev-table "shell")
    (setq abbrev-mode 1)
    (define-local-abbrev "~" (getenv "HOME"))
    (define-hooked-local-abbrev "cd" "cd" "shell-cd")
    (use-syntax-table "shell")
    (modify-syntax-entry "w    ~")
    (novalue))
