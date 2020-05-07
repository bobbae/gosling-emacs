; This emacs macro file defines commands for killing and unkilling text.
; Commands to delete words. lines, and regions actually send the text to a
; ring of killbuffers, where they can be yanked back.  Multiple killing 
; commands in succession will concatenate text to the same buffer, so a
; single unkill can bring it all back.  The unkill-pop command can cycle
; the kill ring to retrieve previously-killed stuff.

; The following keys are redefined:
; 	^W	kill-region
; 	ESC-w	copy-region
; 	^K	kill-lines
; 	ESC-k	copy-lines
; 	ESC-d	kill-word
; 	ESC-h	backward-kill-word
; 	ESC-del	backward-kill-word
; 	ESC-a	append next kill (pretend previous command was ^K)
; 	^Y	unkill
; 	ESC-y	unkill-pop (kill the region, back up one on the kill ring,
;				; and unkill)

; Options:

; There are usually four buffers in the killring.  If you want more buffers
; in the ring (say 8), execute the following mlisp functions BEFORE you load
; this file:
; 	(setq-default nrings 8)

; The ^K function will behave pretty much the same as the old
; delete-to-end-of-line did, unless you want something better.  The improved
; version bases its behavior on the horizontal position of the cursor at the
; time the command is issued.  If the cursor is at the beginning of the line,
; the command will assume you want to kill the entire line, including the
; return at the end.  If you're at the end of the line, then it will remove
; the return separating this line from the next.  Otherwise, it will kill
; just to the end of the line.  To get this function, execute the following
; mlisp functions AFTER you load this file:
;	(setq-default &kill-lines-magic 1)

(defun
    (kill-region
	(if (= (previous-command) 11)
	    (progn
		(c-append-region)
		(erase-region))
	    (progn
		(next-killbuffer)
		(delete-region-to-buffer killbuffer)))
	(setq this-command 11))
    (copy-region
	(if (= (previous-command) 11)
	    (c-append-region)
	    (progn
		(next-killbuffer)
		(copy-region-to-buffer killbuffer)))
	(setq this-command 11))
    (c-append-region
	(if (>= (dot) (mark))
	    (append-region-to-buffer killbuffer)
	    (progn
		(exchange-dot-and-mark)
		(yank-buffer killbuffer)
		(copy-region-to-buffer killbuffer))))
    (append-next-kill
	(setq this-command 11))
    (unkill				; leaves region around restored text
	(set-mark)
	(yank-buffer killbuffer))
    (unkill-pop
	(delete-region-to-buffer killbuffer)
	(previous-killbuffer)
	(set-mark)
	(yank-buffer killbuffer))
    (set-up-killbuffer
	(setq killbuffer (concat "KB-" ringpos)))
    (next-killbuffer
	(setq ringpos (+ ringpos 1))
	(if (> ringpos nrings)
	    (setq ringpos (- ringpos nrings)))
	(set-up-killbuffer))
    (previous-killbuffer
	(setq ringpos (- ringpos 1))
	(if (< ringpos 1)
	    (setq ringpos (+ ringpos nrings)))
	(set-up-killbuffer))
    (forward-lines
	(if (& &kill-lines-magic (bolp))
	    (progn			; beginning of line--kill whole lines
		(beginning-of-line)	; flush target column
		(provide-prefix-argument prefix-argument (next-line)))
	    (if (eolp)
		(forward-character)	; end of line--kill crlf
	        (end-of-line))))	; else--kill to end of line
    (kill-lines		; to append to killbuffer, set dot before killing
	(set-mark)
	(provide-prefix-argument prefix-argument (forward-lines))
	(kill-region))
    (copy-lines
	(set-mark)
	(provide-prefix-argument prefix-argument (forward-lines))
	(copy-region))
    (kill-word
	(set-mark)
	(provide-prefix-argument prefix-argument (forward-word))
	(kill-region))
    (backward-kill-word
	(set-mark)
	(provide-prefix-argument prefix-argument (backward-word))
	(kill-region))
    )

(declare-global nrings)
(if (= nrings 0) (setq-default nrings 4))
(declare-global ringpos)
(declare-global killbuffer)
(declare-global &kill-lines-magic)
(setq-default &kill-lines-magic 0)

(save-excursion
    (setq ringpos (+ nrings 1))
    (while (> ringpos 1)
	(setq ringpos (- ringpos 1))
	(set-up-killbuffer)
	(switch-to-buffer killbuffer)
	(setq needs-checkpointing 0)))

(bind-to-key "kill-region" "\^W")
(bind-to-key "copy-region" "\ew")
(bind-to-key "kill-lines" "\^K")
(bind-to-key "copy-lines" "\ek")
(bind-to-key "kill-word" "\ed")
(bind-to-key "backward-kill-word" "\eh")
(bind-to-key "backward-kill-word" "\e\177")	 	; esc rubout
(bind-to-key "append-next-kill" "\ea")
(bind-to-key "unkill" "\^Y")
(bind-to-key "unkill-pop" "\ey")
