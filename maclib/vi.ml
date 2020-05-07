; A simple emulator for "vi".  It's very incomplete.

(defun
    (insert-before
	(use-global-map "vi-insertion-mode"))
    
    (insert-after
	(forward-character)
	(use-global-map "vi-insertion-mode"))
    
    (exit-insertion
	(use-global-map "vi-command-mode"))
    
    (replace-one
	(insert-character (get-tty-character))
	(delete-next-character))
    
    (next-skip
	(beginning-of-line)
	(next-line)
	(skip-white-space))
    
    (prev-skip
	(beginning-of-line)
	(previous-line)
	(skip-white-space))
    
    (skip-white-space
	(while (& (! (eolp)) (| (= (following-char) ' ') (= (following-char) '^i')))
	    (forward-character)))
    
    (vi
	(use-global-map "vi-command-mode"))
)

; setup vi mode tables
(define-keymap "vi-command-mode")
(define-keymap "vi-insertion-mode")
(use-global-map "vi-insertion-mode")
(bind-to-key "execute-extended-command" '^X')
(progn i
    (setq i ' ')
    (while (< i 0177)
	(bind-to-key "self-insert" i)
	(setq i (+ i 1))))
(bind-to-key "self-insert" '\011')
(bind-to-key "newline" '\015')
(bind-to-key "self-insert" '\012')
(bind-to-key "delete-previous-character" '\010')
(bind-to-key "delete-previous-character" '\177')
(bind-to-key "exit-insertion" '\033')

(use-global-map "vi-command-mode")
(bind-to-key "execute-extended-command" '^X')
(bind-to-key "next-line" '^n')
(bind-to-key "previous-line" '^p')
(bind-to-key "forward-word" 'w')
(bind-to-key "backward-word" 'b')
(bind-to-key "search-forward" '/')
(bind-to-key "search-reverse" '?')
(bind-to-key "beginning-of-line" '0')
(bind-to-key "end-of-line" '$')
(bind-to-key "forward-character" ' ')
(bind-to-key "backward-character" '^h')
(bind-to-key "backward-character" 'h')
(bind-to-key "insert-after" 'a')
(bind-to-key "insert-before" 'i')
(bind-to-key "replace-one" 'r')
(bind-to-key "next-skip" '+')
(bind-to-key "next-skip" '^m')
(bind-to-key "prev-skip" '-')
(use-global-map "default-global-keymap")
