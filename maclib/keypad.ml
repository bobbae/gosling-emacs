; Enable driving EMACS from the VT100 keypad
; Also changes scrolling slightly, and implements ESC-t
; Andrew Birrell, Thu Apr 12 14:13:06 1984

; set keypad into "application mode" ....
(send-string-to-terminal "\e=")

; redefine ESC-[ to ESC-{ to allow access to VT100 escapes
(bind-to-key "forward-paragraph" "\e{")
(bind-to-key "backward-paragraph" "\e}")

; cursor keys ( up, down, left, right ) ....
(bind-to-key "previous-line" "\e[A")
(bind-to-key "next-line" "\e[B")
(bind-to-key "backward-character" "\e[D")
(bind-to-key "forward-character" "\e[C")

; First row of keypad:  deleting characters and words
; PF1 = back-char; 2 = fwd-char; 3 = back-word; 4 = fwd-word ....
(bind-to-key "delete-previous-character" "\eOP")
(bind-to-key "delete-next-character" "\eOQ")
(bind-to-key "delete-previous-word" "\eOR")
(bind-to-key "delete-next-word" "\eOS")

; Second row of keypad: replica of cursor keys
; "7" = up; "8" = down; "9" = left; "-" = right ....
(bind-to-key "previous-line" "\eOw")
(bind-to-key "next-line" "\eOx")
(bind-to-key "forward-character" "\eOm")
(bind-to-key "backward-character" "\eOy")

; Third row of keypad: cut-and-paste operations
; "4" = set-mark; "5" = cut; "6" = copy; "," = paste ....
(bind-to-key "set-mark" "\eOt")
(bind-to-key "delete-to-killbuffer" "\eOu")
(defun
   (delete-and-replace
      (delete-to-killbuffer)
      (yank-from-killbuffer)
      (message "Copied to kill-buffer")
   )
)
(bind-to-key "delete-and-replace" "\eOv")
(bind-to-key "yank-from-killbuffer" "\eOl")

; Remainder of keypad: miscellaneous
; "1" = start-of-line; "2" = end-of-line; "3" = scroll-up; "ENTER" = undo
; "0" = exit-emacs; "." = scroll-down
(bind-to-key "beginning-of-line" "\eOq")
(bind-to-key "end-of-line" "\eOr")
(bind-to-key "scroll-one-line-up" "\eOs")
(bind-to-key "undo" "\eOM")
(bind-to-key "exit-emacs" "\eOp")
(bind-to-key "scroll-one-line-down" "\eOn")

; scroll only one line when I type RETURN at bottom of a window ....
(setq scroll-step 1)

; ESC-t = insert the current time ....
(defun
  (insert-time
     ( insert-string (current-time)
     )
  )
)
(bind-to-key "insert-time" "\et")

;  End of keypad and stuff.
