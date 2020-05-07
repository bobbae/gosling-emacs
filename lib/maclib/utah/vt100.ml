; function key bindings for vt100 for gemacs navigation, PSL, csh mode.

(send-string-to-terminal "\e=")		; Put it in numeric keypad mode.
(send-string-to-terminal "\e[?1h")	; Cursor keys in "application" mode.
(send-string-to-terminal "\e[?8h")	; Enable auto-repeat.

; PF keys.
(bind-to-key "ESC-prefix" "\eOP")		; PF1 = Meta Prefix (ESC).
; gemacs screws up and misses local bindings if PF1 instead of ESC. (!?)
(bind-to-key "self-insert" "\e\^i")		; M-tab
(bind-to-key "expand-mlisp-word" "\e$")		; M-$
(bind-to-key "expand-mlisp-variable" "\^x$")	; ^X-$

(bind-to-key "buffer-menu" "\eOQ")		; PF2 = ^X^B
(bind-to-key "use-old-buffer" "\eOR")		; PF3 = ^X^O

; Cursor motion keys, both arrows and "Plus" pattern centered on keypad key 5.
(bind-to-key "previous-line" "\eOA")		; UpArrow    = KP8 = ^P
(bind-to-key "previous-line" "\eOx")
(bind-to-key "next-line" "\eOB")		; DownArrow  = KP2 = ^N
(bind-to-key "next-line" "\eOr")
(bind-to-key "backward-character" "\eOD")	; LeftArrow  = KP4 = ^B
(bind-to-key "backward-character" "\eOt")
(bind-to-key "forward-character" "\eOC")	; RightArrow = KP6 = ^F
(bind-to-key "forward-character" "\eOv")

(bind-to-key "argument-prefix" "\eOu")		; KP5 = ^U

; Screen motion.
(bind-to-key "previous-window" "\eOw")		; KP7 = ^X-p
(bind-to-key "next-window" "\eOy")		; KP9 = ^X-n

(bind-to-key "previous-page" "\eOq")		; KP1 = M-v
(bind-to-key "next-page" "\eOs")		; KP3 = ^V

(bind-to-key "scroll-one-line-down" "\eOp")	; KP0 = M-z
(bind-to-key "scroll-one-line-up" "\eOn")	; KP. = M-Z

; Other keypad keys (for PSL interface.)
(defun

    ; Need a couple minor funtions first.
    (rlisp-star (insert-string "!*"))
    (no-echo-rlisp-execute
	(setq rlisp-input-echo 0) 	; turn off echo.
	(rlisp-execute)
    )

    (vt100-rlisp-keys			; Only done in Rlisp mode buffers.
	(local-bind-to-key "rlisp-execute" "\eOM")	; KP Enter = M-e
	(local-bind-to-key "no-echo-rlisp-execute" "\eOl")  ; KP, = ^U M-e
	
	; KP -  = rlisp break, etc. prefix.
	(local-bind-to-key "rlisp-break-chars" "\eOm")
    )
)

(autoload "rlisp-break" "rlisp-proc.ml")
(autoload "rlisp-char" "rlisp-proc.ml")
(autoload "rlisp-send" "rlisp-proc.ml")
; Define the rlisp break character dispatching map.
(progn 
    (define-keymap "rlisp-break-chars")
    (use-global-map "rlisp-break-chars")
    (bind-to-key "rlisp-break" "q")	; ^Z-b-q (Quit)
    (bind-to-key "rlisp-break" "i")	; ^Z-b-i (Interp trbck)
    (bind-to-key "rlisp-break" "t")	; ^Z-b-t (full Trbck)
    (bind-to-key "rlisp-break" "c")	; ^Z-b-c (Continue)
    (bind-to-key "rlisp-break" "m")	; ^Z-b-m (print errmsg)
    (bind-to-key "rlisp-break" "r")	; ^Z-b-r (Retry)
    
    (bind-to-key "rlisp-char" "y")	; ^Z-y (Yes)
    (bind-to-key "rlisp-char" "n")	; ^Z-n (No)
    (bind-to-key "rlisp-char" "0")	; ^Z-0 (arg counts.)
    (bind-to-key "rlisp-char" "1")	; ^Z-1
    (bind-to-key "rlisp-char" "2")	; ^Z-2
    (bind-to-key "rlisp-char" "3")	; ^Z-3
    (bind-to-key "rlisp-char" "4")	; ^Z-4
    (bind-to-key "rlisp-char" "5")	; ^Z-5
    (bind-to-key "rlisp-char" "6")	; ^Z-6
    (bind-to-key "rlisp-char" "7")	; ^Z-7
    (bind-to-key "rlisp-char" "8")	; ^Z-8
    (bind-to-key "rlisp-char" "9")	; ^Z-9
    
    (bind-to-key "rlisp-send" "s")	; ^Z-s (send line.)
    
    (use-global-map  "default-global-keymap")
)

; Enter key for shell windows...
(defun					; Only done in shell windows.
    (vt100-csh-keys
	(local-bind-to-key "pr-newline" "\eOM")
    )
)
