(progn 				; make execute buffer happy
(declare-global last-line)
(declare-global csh-two-window)
(declare-global &csh-prompt)

(defun
    (pr-newline
	(end-of-line)
	(if (eobp)
	    (progn
		(newline)
		(setq last-line (region-to-string))
		(region-to-process (active-process))
		(if (!= (active-process) (current-buffer-name))
		    (progn buffer
			(setq buffer (current-buffer-name))
			(pop-to-buffer (active-process))
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
		    (if (= (following-char) '$') (forward-character)))
		(if (= (following-char) ' ') (forward-character))
		(save-excursion
		    (set-mark)
		    (end-of-line)
		    (forward-character)
		    (setq com (region-to-string)))
		(if (= (active-process) (current-buffer-name))
		    (progn
			(end-of-file)
			(set-mark)
			(insert-string com)
			(setq last-line (region-to-string))
			(region-to-process (active-process))
			(set-mark))
		    (progn buffer
			(setq buffer (current-buffer-name))
			(pop-to-buffer (active-process))
			(end-of-file)
			(set-mark)
			(insert-string com)
			(setq last-line com)
			(string-to-process (active-process) com)
			(set-mark)
			(pop-to-buffer buffer)
			(next-line)
		    ))
	    )
	)
    )
)

(defun
    (scroll-up-other-window
	(next-window)
	(scroll-one-line-up)
	(previous-window)
    )
    (scroll-down-other-window
	(next-window)
	(scroll-one-line-down)
	(previous-window)
    )
)

(setq csh-two-window 0)

(defun
    (csh (c-shell))

    (c-shell
	(pop-to-buffer "c-shell")
	(if (& (eobp) (bobp))
	    (insert-string "Started csh\n"))
	(setq needs-checkpointing 0)
	(if (< (process-status "c-shell") 0)
	    (progn
		(start-process "oldcsh" "c-shell")
		(string-to-process "c-shell" "unalias cd; unalias pwd\^J")
		(string-to-process "c-shell"
		    "set path = (`printenv PATH | sed 's/:/ /g'`)\^J"))
	    (change-current-process "c-shell"))
	(if csh-two-window
		(setq mode-line-format
		    "%[-------- %M  C Shell Output  %p --------%]")
		(setq mode-line-format
		    "%[-------- %M  C Shell   %p --------%]"))
	(local-bind-to-key "pr-newline" '^m')
	(local-bind-to-key "send-eot" '')
	(local-bind-to-key "send-int-signal" '\177')
	(local-bind-to-key "send-quit-signal" '^\')
	(local-bind-to-key "grab-last-line" "\^X!")
	(end-of-file)
	(if csh-two-window
	    (progn
		(pop-to-buffer "c-shell-input")
		(setq mode-line-format
		    "%[-------- %M  C Shell Input   %p --------%]")
		(local-bind-to-key "pr-newline" '^m')
		(local-bind-to-key "send-eot" '')
		(local-bind-to-key "send-int-signal" '\177')
		(local-bind-to-key "send-quit-signal" '^\')
		(local-bind-to-key "grab-last-line" "\^X!")
		(local-bind-to-key "scroll-up-other-window" "\^[Z")
		(local-bind-to-key "scroll-down-other-window" "\^[z")
		(if (& (eobp) (bobp))
		    (set-mark))
	    ))
	(novalue)
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
	    (start-process "lisp" "lisp"))
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
)
