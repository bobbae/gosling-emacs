(progn 				; make execute buffer happy
(declare-global last-line)
(if (! (is-bound csh-two-window))
    (setq-default csh-two-window 1))
(declare-global &csh-prompt)
(declare-buffer-specific associated-process)

(defun
    (pr-newline
	(end-of-line)
	(if (| prefix-argument-provided
	       (& (eobp) (= associated-process (current-buffer-name))))
	    (progn
		(if (eobp) (newline) (forward-character))
		(setq last-line (region-to-string))
		(region-to-process associated-process)
		(if (!= associated-process (current-buffer-name))
		    (progn buffer
			(setq buffer (current-buffer-name))
			(pop-to-buffer associated-process)
			(end-of-file)
			(insert-string last-line)
			(set-mark)
			(pop-to-buffer buffer)))
		(set-mark)
		    
	    )
	    (progn com
		(beginning-of-line)
		(if (= (current-buffer-name) "c-shell")
		    (if (|  (looking-at "\\([0-9]* [^ >#]*[>#]\\)")
			    (looking-at &csh-prompt))
			(region-around-match 1))
		    (if (= associated-process (current-buffer-name))
			(if (= (following-char) '$') (forward-character))))
		(if (& (= associated-process (current-buffer-name))
		       (= (following-char) ' '))
		    (forward-character))
		(save-excursion
		    (set-mark)
		    (end-of-line)
		    (if (eobp)
			(insert-character '\n')
			(forward-character))
		    (setq com (region-to-string)))
		(if (= associated-process (current-buffer-name))
		    (progn
			(end-of-file)
			(set-mark)
			(insert-string com)
			(setq last-line (region-to-string))
			(region-to-process associated-process)
			(set-mark))
		    (progn buffer
			(setq buffer (current-buffer-name))
			(pop-to-buffer associated-process)
			(end-of-file)
			(set-mark)
			(insert-string com)
			(setq last-line com)
			(string-to-process associated-process com)
			(set-mark)
			(pop-to-buffer buffer)
			(next-line)
		    ))
	    )
	)
    )
)

(defun
    (scroll-up-process-window
	(save-excursion
	    (pop-to-buffer associated-process)
	    (scroll-one-line-up)
	)
    )
    (scroll-down-process-window
	(save-excursion
	    (pop-to-buffer associated-process)
	    (scroll-one-line-down)
	)
    )
)

(defun
    (csh (c-shell))

    (c-shell
	(pop-to-buffer "c-shell")
	(setq associated-process "c-shell")
	(if (& (eobp) (bobp))
	    (insert-string "Started csh\n"))
	(setq needs-checkpointing 0)
	(if (< (process-status "c-shell") 0)
	    (progn
		(start-process "exec stdcsh" "c-shell")
;		(string-to-process "c-shell" "unalias cd; unalias pwd\^J")
;		(string-to-process "c-shell"
;		    "set path = (`printenv PATH | sed 's/:/ /g'`)\^J")
	    )
	    (change-current-process "c-shell"))
	(if csh-two-window
		(setq mode-line-format
		    "%[ %M  C Shell Output  %p %]")
		(setq mode-line-format
		    "%[ %M  C Shell   %p %]"))
	(local-bind-to-key "pr-newline" '^m')
	(local-bind-to-key "send-eot" '')
	(local-bind-to-key "send-character" '^C')
	(local-bind-to-key "send-int-signal" "\e\^C")
	(local-bind-to-key "send-quit-signal" '\034')
	(local-bind-to-key "grab-last-line" "\^X!")
	(setq abbrev-mode 1)
	(use-abbrev-table "shell")
	(use-syntax-table "shell")
	(end-of-file)
	(if csh-two-window
	    (progn
		(pop-to-buffer "c-shell-input")
		(setq associated-process "c-shell")
		(setq needs-checkpointing 0)
		(setq mode-line-format
		    "%[ %M  C Shell Input   %p %]")
		(local-bind-to-key "pr-newline" '^m')
		(local-bind-to-key "send-eot" '')
		(local-bind-to-key "send-character" '^C')
		(local-bind-to-key "send-int-signal" "\e\^C")
		(local-bind-to-key "send-quit-signal" '\034')
		(local-bind-to-key "grab-last-line" "\^X!")
		(local-bind-to-key "scroll-up-process-window" "\^[Z")
		(local-bind-to-key "scroll-down-process-window" "\^[z")
		(setq abbrev-mode 1)
		(use-abbrev-table "shell")
		(use-syntax-table "shell")
		(if (& (eobp) (bobp))
		    (set-mark))
	    ))
	(novalue)
    )
)

(defun
    (new-shell name shell
	(setq name (arg 1 ": new-shell (buffer name) "))
	(if (| (> (nargs) 1) (interactive))
	    (setq shell (arg 2 (concat ": new-shell (buffer name) " name
				   " (command) ")))
	    (setq shell "sh"))
	(pop-to-buffer name)
	(setq associated-process name)
	(use-abbrev-table "shell")
	(use-syntax-table "shell")
	(setq abbrev-mode 1)
	(setq needs-checkpointing 0)
	(if (< (process-status name) 0)
	    (start-process shell name))
	(local-bind-to-key "pr-newline" '^m')
	(local-bind-to-key "send-character" '^C')
	(local-bind-to-key "send-eot" '')
	(local-bind-to-key "send-int-signal" "\e\^C")
	(local-bind-to-key "send-quit-signal" '\034')
	(local-bind-to-key "grab-last-line" "\^X!")
	(end-of-file)
	(if (& (eobp) (bobp))
	    (set-mark))
	(novalue)
    )
)

(defun
    (shell
	(new-shell "shell")
	(novalue)
    )
)

(defun
    (send-character char
	(string-to-process associated-process
	    (char-to-string (get-tty-character)))
    )
)

(defun
    (send-eot
	(if (eobp)
	    (string-to-process associated-process "\^D"); eot-process is broken
;	    (eot-process associated-process)
	    (delete-next-character)
	)
    )
)

(defun
    (send-int-signal
	(int-process associated-process)))

(defun
    (send-quit-signal
	(quit-process associated-process)))

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
	(new-shell "lisp" "lisp")
	(if (bobp)
	    (progn
		(electric-lisp-mode)
		(local-bind-to-key "lisp-kill-output" "\^X\^K")))
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

(defun
    (push-to-csh
	(save-window-excursion
	    (c-shell)
	    (if prefix-argument-provided
		(progn
		      (pop-to-buffer "c-shell")
		      (end-of-file)
		)
	    )
	    (recursive-edit)
	)
    )
)

(defun
    (csh-prompt str
	(setq str (arg 1 ": csh-prompt (string) "))
	(if (!= str "")
	    (setq &csh-prompt (concat "\\(" (quote str) "\\)"))
	    (setq &csh-prompt "\\=.\\<"); doesnt match anything
	)
    )
)

(csh-prompt "")
(save-excursion
    (temp-use-buffer "shell")
    (use-abbrev-table "shell")
    (setq abbrev-mode 1)
;;; (define-local-abbrev "~" (getenv "HOME"))
    (use-syntax-table "shell")
    (modify-syntax-entry "w    ~")
    (modify-syntax-entry "w    -")
    (modify-syntax-entry "w    _")
    (modify-syntax-entry "w    .")
    (novalue))
)
