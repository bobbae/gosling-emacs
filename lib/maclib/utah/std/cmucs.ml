; cmucs.ml:  rearrange the character set.
; mostly compatible with <agin.emacs>cmucs at CMU-20C

; There are five flavors of commands:  ^x is the usual, esc-x is the super,
;  and ^Z ^x is a super-duper.  ^X ^x commands usually deal with files and
;  windows.  ^X x commands are rare.  There are no useful commands that use
;  capital letters or esc-control.
; see /usr/agin/emacs/cmucs.chart for command assignments

; Modifications to functions have been made in the following areas:
; Killing: more like tops-20, but no ring of killed stuff
; Searching:  character searches and zap to character
; Case shifts, transpose word and char behave differently at end of line
;   than at beginning.
; Word moves and end-of-word moves are independent of direction of motion.

(defun
    (get-search-character
		newchar
	(setq newchar (get-tty-character))
	(if (& (!= newchar 18) (!= newchar 19))	; ^S or ^R repeat last search
	    (setq csearch-default (char-to-string newchar)))
	csearch-default)
    (character-search
	(search-forward (get-search-character)))
    (reverse-character-search
	(search-reverse (get-search-character)))
    (zap-to-character
	(set-mark)
	(character-search)
	(backward-character)
	(kill-region))
    (zap-thru-character
	(set-mark)
	(character-search)
	(kill-region))
    (set-fixed-mark
	(if prefix-argument-provided
	    (setq fixed-mark (dot))
	    (set-mark)))
    (goto-fixed-mark
	(if prefix-argument-provided
	    (goto-character fixed-mark)
	    (exchange-dot-and-mark)))
    (forward-word-beginning
	(forward-character)
	(backward-word)
	(forward-word)
	(provide-prefix-argument prefix-argument (forward-word))
	(backward-word))
    (backward-word-end
	(backward-character)
	(forward-word)
	(backward-word)
	(provide-prefix-argument prefix-argument (backward-word))
	(forward-word))
    (kill-region
	(if (= (previous-command) 11)
	    (progn
		(c-append-region)
		(erase-region))
	    (delete-region-to-buffer "KB"))
	(setq this-command 11))
    (copy-region
	(if (= (previous-command) 11)
	    (c-append-region)
	    (copy-region-to-buffer "KB"))
	(setq this-command 11))
    (c-append-region
	(if (>= (dot) (mark))
	    (append-region-to-buffer "KB")
	    (progn
		(exchange-dot-and-mark)
		(yank-buffer "KB")
		(copy-region-to-buffer "KB"))))
    (append-next-kill
	(setq this-command 11))
    (unkill				; leaves region around restored text
	(set-mark)
	(yank-buffer "KB"))
    (kill-word
	(set-mark)
	(provide-prefix-argument prefix-argument (forward-word-beginning))
	(kill-region))
    (kill-to-word-end
	(set-mark)
	(provide-prefix-argument prefix-argument (forward-word))
	(kill-region))
    (backward-kill-word
	(set-mark)
	(provide-prefix-argument prefix-argument (backward-word))
	(kill-region))
    (backward-kill-to-word-end
	(set-mark)
	(provide-prefix-argument prefix-argument (backward-word-end))
	(kill-region))
    (kill-lines		; to append to killbuffer, set dot before killing
	(set-mark)
	(if (bolp)
	    (progn			; beginning of line--kill whole lines
		(beginning-of-line)	; flush target column
		(provide-prefix-argument prefix-argument (next-line)))
	    (if (eolp)
		(forward-character)	; end of line--kill crlf
	        (end-of-line)))		; else--kill to end of line
	(kill-region))
    (copy-lines
	(set-mark)
	(provide-prefix-argument prefix-argument (next-line))
	(beginning-of-line)
	(copy-region))
    (scroll-smart
	(if prefix-argument-provided
	    (provide-prefix-argument prefix-argument (scroll-one-line-up))
	    (next-page)))
    (unscroll-smart
	(if prefix-argument-provided
	    (provide-prefix-argument prefix-argument (scroll-one-line-down))
	    (previous-page)))
    )

(declare-global &Default-Transpose-Magic)
(setq-default &Default-Transpose-Magic 1)
(autoload "transpose-line" "transpose.ml")
(autoload "transpose-word" "transpose.ml")

(autoload "lower-smart" "smarts.ml")
(autoload "upper-smart" "smarts.ml")
(autoload "capitalize-smart" "smarts.ml")
(autoload "transpose-smart" "smarts.ml")
(autoload "transpose-word-smart" "smarts.ml")

(autoload "display-line-number" "misc.ml")
(autoload "goto-line" "misc.ml")
(autoload "write-file-push" "misc.ml")
(autoload "dec-shell" "misc.ml")
(autoload "beginning-of-next-line" "misc.ml")
(autoload "set-bounds" "misc.ml")
(autoload "insert-date" "misc.ml")
(autoload "match-begin" "misc.ml")

(autoload "centre-line" "centre-line.ml")

(autoload "srccom" "srccom.ml")

(declare-global fixed-mark)
(declare-buffer-specific fixed-mark)
(declare-global csearch-default)

(save-excursion
    (switch-to-buffer "KB")
    (setq needs-checkpointing 0) )

(bind-to-key "shrink-window" "\^X<")
(bind-to-key "enlarge-window" "\^X>")
(bind-to-key "display-line-number" "\e=")
(bind-to-key "switch-to-buffer" "\^X\^B")
(bind-to-key "centre-line" "\ec")
(bind-to-key "kill-word" "\ed")
(bind-to-key "insert-date" "\^Xd")
(bind-to-key "delete-window" "\^X\^D")
(bind-to-key "forward-word-beginning" "\ef")
(bind-to-key "goto-fixed-mark" "\eg")
(bind-to-key "justify-paragraph" "\ej")
(bind-to-key "kill-lines" "\^K")
(bind-to-key "copy-lines" "\ek")
(bind-to-key "delete-buffer" "\^X\^K")
(bind-to-key "list-buffers" "\^X\^L")
(bind-to-key "lower-smart" "\el")
(bind-to-key "beginning-of-next-line" "\e\^M")	; esc return
(bind-to-key "set-fixed-mark" "\em")
(bind-to-key "next-window" "\^X\^O")
(bind-to-key "reverse-character-search" "\^R")
(bind-to-key "reverse-incremental-search" "\er")
(bind-to-key "character-search" "\^S")
(bind-to-key "incremental-search" "\es")
(bind-to-key "transpose-smart" "\^T")
(bind-to-key "transpose-word-smart" "\et")
(bind-to-key "upper-smart" "\eu")
(bind-to-key "scroll-smart" "\^V")
(bind-to-key "unscroll-smart" "\ev")
(bind-to-key "kill-region" "\^W")
(bind-to-key "copy-region" "\ew")
(bind-to-key "unkill" "\^Y")
(bind-to-key "zap-to-character" "\ez")
(bind-to-key "write-file-push" "\^X\^Z")
(bind-to-key "backward-kill-word" "\e\177")	 	; esc rubout

(define-keymap "z-commands")
(use-global-map "z-commands")
(bind-to-key "start-remembering" "(")
(bind-to-key "stop-remembering" ")")
(bind-to-key "srccom" "=")
(bind-to-key "match-begin" "]")
(bind-to-key "append-next-kill" "\^A")
(bind-to-key "backward-word-end" "\^B")
(bind-to-key "exit-emacs" "\^C")
(bind-to-key "kill-to-word-end" "\^D")
(bind-to-key "execute-keyboard-macro" "\^E")
(bind-to-key "forward-word" "\^F")
(bind-to-key "set-bounds" "\^H")
(bind-to-key "delete-region-to-buffer" "\^K")
(bind-to-key "goto-line" "\^L")
(bind-to-key "prepend-region-to-buffer" "\^P")
(bind-to-key "re-query-replace" "\^Q")
(bind-to-key "re-search-reverse" "\^R")
(bind-to-key "re-search-forward" "\^S")
(bind-to-key "transpose-line" "\^T")
(bind-to-key "capitalize-smart" "\^U")
(bind-to-key "page-next-window" "\^V")
(bind-to-key "copy-region-to-buffer" "\^W")
(bind-to-key "yank-buffer" "\^Y")
(bind-to-key "zap-thru-character" "\^Z")
(bind-to-key "backward-kill-to-word-end" "\177")	; ^Z rubout
(use-global-map "default-global-keymap")
(bind-to-key "z-commands" "\^Z")
