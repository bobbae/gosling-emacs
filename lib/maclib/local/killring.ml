; This emacs macro file defines commands for killing and unkilling text.
; Commands to delete words, lines, and regions actually send the text to a
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

; There are usually ten buffers in the killring.  If you want more (or less)
; buffers in the ring (say 25), execute the following mlisp functions BEFORE
; you load this file:
; 	(setq-default nrings 25)

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
	    (prepend-region-to-buffer killbuffer)))
    (append-next-kill
	(setq this-command 11))
    (unkill				; leaves pointer to restored text
	(setq last-unkill-dot (dot))
	(yank-buffer killbuffer))
    (unkill-pop
	(if (= (previous-command) 25)	; yank?
	    (save-excursion
		(set-mark)
		(goto-character last-unkill-dot)
		(erase-region))
	)
	(setq last-unkill-dot (dot))
	(previous-killbuffer)
	(yank-buffer killbuffer)
	(setq this-command 25))
    (next-killbuffer
	(setq ringpos (+ ringpos 1))
	(if (>= ringpos nrings)
	    (setq ringpos 0))
	(setq killbuffer (concat "KB-" ringpos)))
    (previous-killbuffer
	(if (< ringpos 1)
	    (setq ringpos nrings))
	(setq ringpos (- ringpos 1))
	(setq killbuffer (concat "KB-" ringpos)))
    (line-step n
	(setq n prefix-argument)
	(if (< n 1)
	    (while (< n 1)		;step backwards
		(setq n (+ n 1))
		(if (bolp)
		    (backward-character)
		    (beginning-of-line))
	    )
	    (while (> n 0)		;step forward
		(setq n (- n 1))
		(if (eolp)
		    (forward-character)
		    (end-of-line))
	    )
	))
    (kill-lines
	(save-excursion
	    (set-mark)
	    (provide-prefix-argument prefix-argument (line-step))
	    (kill-region)
	))
    (copy-lines newdot
	(save-excursion			;don't clobber mark
	    (set-mark)
	    (provide-prefix-argument prefix-argument (line-step))
	    (copy-region) (setq newdot (dot)))
	(goto-character newdot))
    (kill-word
	(save-excursion
	    (set-mark)
	    (provide-prefix-argument prefix-argument (forward-word))
	    (kill-region)
	))
    (backward-kill-word
	(save-excursion
	    (set-mark)
	    (provide-prefix-argument prefix-argument (backward-word))
	    (kill-region)
	))
    )

(declare-global nrings)
(if (= nrings 0) (setq-default nrings 10))
(declare-global ringpos)
(declare-global killbuffer)
(declare-global last-unkill-dot)

(save-excursion
    (setq ringpos nrings)
    (while (> ringpos 0)
	(previous-killbuffer)
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
