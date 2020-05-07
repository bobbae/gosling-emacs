;							 -*-mlisp-*-
;
; This file contains alternate definitions for the delete/yank commands.
; They offer the advantage of a kill ring (holding 9 saves), with
; appending of consecutive kills to a single element of the ring.  (also,
; yank-from-kill-ring leaves the mark at the beginning of the yank,
; facilitating un-yanking if desired.)
;
; The key assignments follow the defaults (see the end of the file), except
; that the function yank-next-from-kill-ring, which has no default
; counterpart, is bound to M-Y.  Use it as follows to go around the ring:
; type C-Y to get back the last thing you killed.  If you don't like it,
; travel back in time by typing M-Y repeatedly, replacing the un-kill with
; its predecessor on the ring.  Eventually you get back where you started.
;
; The rules for appending/prepending successive kills follow those for teco
; emacs: successive line or word deletions in the same direction get stuck
; together.  Character deletions preceded by kills of larger units also get
; tacked on.
;
; The lack of arrays or other indirection, plus the problem of knowing whether
; the last thing you did was a kill, combine to place this among the
; grisliest pieces of code ever written.     A. Witkin 2/81
;
; This was modified by SWT Wed Sep 23 1981 to use the (previous-command)
; function and this-command variable to determine if this invocation
; was immediately preceded by a kill command.  The function
; (previous-command) returns the value of the variable this-command
; had after the execution of the most recently executed command.  This is
; usually the value of the key which invoked the command.  The kill
; functions set this to a 'unique' value.
;
; &kr0 - &kr8 are, I regret to say, our kill-ring.
; &kr-flag, if != 0,  signals that we're in a recursive kill. [Now only used
; to remember direction of the previous kill].
; &kr-dir if >0 says we're going forward, <0, backward.
; &kr-ptr "points" to the current "element."
;
(declare-global &kr-ptr &kr0 &kr1 &kr2 &kr3 &kr4 &kr5
		&kr6 &kr7 &kr8 &kr-flag &kr-dir &kr-me-too)

(progn i			; otherwise you get a "0"
       (while (< i 9)
	      (set (concat "&kr" i) "")
	      (setq i (+ 1 i))))  

(defun 

(Delete-next-character string
   (setq string (char-to-string (following-char))); save it
   (delete-next-character)	; kill it
   (if (&Was-kill) (forward-maybe))); maybe append if in a successive kill.


(Delete-previous-character string
   (setq string (char-to-string (preceding-char)))
   (delete-previous-character)
   (if (&Was-kill) (backward-maybe)))

(Delete-next-word string
  (set-mark)
  (forward-word)
  (setq string (region-to-string))
  (delete-to-killbuffer)
  (forward-maybe))

(Delete-previous-word string
  (set-mark)
  (backward-word)
  (setq string (region-to-string))
  (delete-to-killbuffer)
  (backward-maybe))

(Kill-to-end-of-line string
  (set-mark)
  (if (= (following-char) 10)	; if at eol, gobble newline char.
      (forward-character)
      (end-of-line))
  (setq string (region-to-string))
  (delete-to-killbuffer)
  (forward-maybe))

(region-to-kill-ring		; put on ring w/o killing
  (setq &kr-ptr (% (+ 1 &kr-ptr) 9)); increment ptr mod 9
  (set (concat "&kr" &kr-ptr) (region-to-string)))

(delete-region-to-kill-ring
  (region-to-kill-ring)
  (delete-to-killbuffer))

(yank-from-kill-ring s
  (set-mark)
  (execute-mlisp-line (concat "(insert-string &kr" &kr-ptr ")"))); boo, hiss!

(yank-next-from-kill-ring s k
   (setq s (region-to-string))
   (execute-mlisp-line (concat  "(setq k &kr" &kr-ptr ")"))
   (if (!= s k)
       (error-message "")
       (progn (delete-to-killbuffer)
	      (set-mark)
	      (setq &kr-ptr (- &kr-ptr 1))
	      (if (< &kr-ptr 0) (setq &kr-ptr 8))
	      (execute-mlisp-line
		(concat "(insert-string &kr" &kr-ptr ")")))))


(forward-maybe			; set dir to forward, call work function,
  (setq &kr-dir 1) 		; reset dir, and return
  (maybe-append-to-kill-ring)
  (setq &kr-dir 0))

(backward-maybe			; set dir to forward, call work function,
  (setq &kr-dir -1) 		; reset dir, and return
  (maybe-append-to-kill-ring)
  (setq &kr-dir 0))

; This is the guy who figures out whether to append or prepend, rather than
; incrementing ptr.
(maybe-append-to-kill-ring s
  (if (!= (&Was-kill) &kr-dir)	; -> shouldn't append or prepend'
      (progn (setq &kr-ptr (% (+ 1 &kr-ptr) 9)); increment
	     (set (concat "&kr" &kr-ptr) string));save
      (if (> &kr-dir 0)		; if forward...
	  (execute-mlisp-line	; append
	    (concat
	      "(set (concat ""&kr"" &kr-ptr) (concat &kr"
						     &kr-ptr " string))"))
	  (execute-mlisp-line	; else prepend
	    (concat
	      "(set (concat ""&kr"" &kr-ptr) (concat string &kr"
						     &kr-ptr "))" ))))
    (setq this-command 1802071148); = 'k'<<24+'i'<<16+'l'<<8+'l'
    (setq &kr-flag &kr-dir)	; also remember the direction
)

(&Was-kill			; check to see if previous command was a
				; kill
    (if (= (previous-command) 1802071148); see above
	&kr-flag		; if was kill, return direction of kill
	0			; else return 0
    )
)
); Immer muss Man den Verben zu end lassen.

; bind some keys
(bind-to-key "Delete-next-character" '')
(bind-to-key "Delete-previous-character" '')
(bind-to-key "Delete-next-word" (+ 128 'd'))
(bind-to-key "Delete-previous-word" (+ 128 ''))
(bind-to-key "Kill-to-end-of-line" '')
(bind-to-key "region-to-kill-ring" (+ 128 'w'))
(bind-to-key "delete-region-to-kill-ring" '')
(bind-to-key "yank-from-kill-ring" '')
(bind-to-key "yank-next-from-kill-ring" (+ 128 'y'))
