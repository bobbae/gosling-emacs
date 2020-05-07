; $Header: /c/cak/lib/mlisp/RCS/macmouse.ml,v 1.5 85/11/05 14:01:44 cak Rel $
; 
; Macintosh mouse routines for use with John Bruner's uw program.
; 	Chris Kent, Purdue University Fri Oct 25 1985
; 	Copyright 1985 by Christopher A. Kent. All rights reserved.
; 	Permission to copy is given provided that the copy is not
; 	sold and this copyright notice is included.
;
; Seriously hacked by msm and luca
; Last modified on Fri Apr  4 00:14:54 1986 by hania
;      modified on Tue Mar 25 17:36:54 1986 by msm
;      modified on Sun Mar 23 18:38:36 1986 by roberts
; 
; Cursor positioning is achieved by clicking in a buffer with the left button.
; 
; Regions are selected using the left button by:
;	1. dragging the mouse (clicking selects a null region).
; 	2. clicking at the beginning of the intended region and
;	   cntl-clicking at the end. Cntl-clicks can also be used at any
; 	   time to change the end-point of a region.
; 
; For the more emacs-oriented: unmodified left button-down sets mark, unmodified
; or cntl'ed left button-up or -down sets dot.
; 
; Pressing the middle button in a window pops up an edit menu in the mode
; line of the window containing the mouse cursor:
;	undo: undo the last change
;       ..more: keep undoing
; 	cut: cut the current region to the internal cutbuffer
; 	paste: the cutbuffer replaces the current region
; 	copy: copy the current region to the cutbuffer
; 	clear: erase the current region
;
; Pressing the left button in the minibuffer (bottom line) pulls down
; a file menu:
;	new: creates a new file
;	open: presents a menu of files in the current-directory, and the
;		path to the root.  Clicking on an ordinary file opens it.
;		Clicking a subdirectory, or a prefix of the path name
;		brings up a menu with that directory at its head, after
;		chdir'ing to it.
;       close: writes a file and deletes its buffer
;	save: writes a file
;	..as: writes a file of a given name
;	split: splits a window into two windows at the line with the text cursor
;	buffers: presents a menu of available buffers to display
;       pp: calls the modula2 prettyprinter
;	mail: invokes lauralee
;       make: executes the local Makefile
;	shell: opens a shell window
;	exit: saves all files and exits
;	abort: exit without saving files
; 
;   open and buffers use the current window by default; holding the cntl
;   key down while making the menu selection causes them to pop up in
;   whatever mysterious way Emacs chooses;  the only guarantee is that
;   it will not be the current window.
;
; Pressing the left button in the last mode line pulls down a search menu:
;	find: wrap-around search for a string (prompts for a search-string)
;	..next: wrap-around search again for the search-string
;	change: change the current selection (prompts for a replace-string)
;       ..again: replace the current selection with the replace-string
;       ..next: same as "(change)..again" followed by "(find)..again"
;	grep: regular-expression search over several files; the results
;	  appear in the Error-log buffer.  The middle button menu for
;	  for the window displaying the Error-log buffer will now contain
;	  a "next" entry, which can be used to scan through the files
;	  containing the patterns found by grep (similarly to scanning through
;	  the files containing errors when using make).
;       goto: goto a line number
; 
; Scrolling is achieved by clicking the right button:
;	the window containing the mouse cursor is scrolled.  If the mouse
;	is moved up or down,
;	the line pointed at is moved to the top or bottom of the window;
;	be careful with wrapped lines.  If the mouse is moved sideways the
;	line pointed at is moved to the middle.  If the mouse button is simply
;	clicked, then the window is scrolled up or
;	down by a fraction of a screenful; the
;	amount is determined by the distance from
;	the top or bottom of the window.
; 	cntl-click goes to an absolute position in the file; on the top line
;	it goes to top of file; on the status line it goes to bottom of file.
;	cntl-drag moves the line initially pointed at to the indicated
;	position.
; 
; Pressing the left button on the mode line between windows and moving the mouse
;	up or down drags the mode line, causing
;	the two windows adjacent to the bar to change size.  Moving up to or
;	past another mode line closes the dragged-through window(s).
; 

(autoload "mouse-menu" "mousemenu.ml")
(autoload "split-window-at-dot" "split.ml")
(autoload "slow-move-dot-to-x-y" "split.ml")
(autoload "which-window-has-y" "split.ml")
(autoload "create-buffer-menu" "bufferlist.ml")
(autoload "fm-create-HFS" "filelist.ml")
(autoload "lauralee" "lauralee.ml")
(autoload "grep" "grep.ml")
(autoload "new-next-error" "newcompile.ml")
(autoload "new-compile-it" "newcompile.ml")

(if (! (is-bound click-hook)) (setq-default click-hook "(nothing)"))
(declare-buffer-specific click-hook)

(if (! (is-bound shift-edit-menu)) (setq-default shift-edit-menu 0))
(declare-global shift-edit-menu)

(declare-global #exit-flag)
(setq #exit-flag 0)

(declare-global #file-menu)
(declare-global #file-actions)

(declare-global #old-dot #old-window)

(setq #file-menu 
    (concat
	    "new open close save ..as | split buffers | "
	    "pp mail make shell | exit abort "
    )
)

(setq #file-actions
    (concat
	    "visit-file (get-tty-string \"Create file: \");"	; new
	    "fm-create-HFS;"					; open
	    "write-and-delete-file;"				; close
	    "write-file-as-needed;"				; save
	    "write-named-file (get-tty-string \"File: \");"	; ..as
	    "nothing;"						; |
	    "split-window-at-dot;"				; split
	    "create-buffer-menu;"				; buffers
	    "nothing;"						; |
	    "pp-unit;"						; pp
	    "lauralee;"						; mail
	    "new-compile-it;"					; make
	    "shell;"						; shell
	    "nothing;"						; |
	    "progn (write-modified-files) (setq #exit-flag 1);"	; exit
	    "setq #exit-flag 1;"				; abort
    )
)

(defun 
    (write-file-as-needed
	(if buffer-is-modified (write-current-file))
    )

    (write-and-delete-file
	(if 
	    (= (current-file-name) "")
	    (progn (switch-to-buffer "main")
		   (delete-window))
	    (error-occured 
		(write-file-as-needed)
		(delete-buffer (current-buffer-name)))
	    (message (concat "Can't write " (current-buffer-name))))
    )
)

(declare-global #find-menu)
(declare-global #find-actions)
(setq #find-menu "find ..next | change ..again ..next | grep goto ")
(setq #find-actions
    (concat
	    "wrap-search;"					; find
	    "wrap-search-again;"				; ..next
	    "nothing;"						; |
	    "change;"						; change
	    "change-again;"					; ..again
	    "change-again-and-next;"				; ..next
	    "nothing;"						; |
	    "call-interactively (grep);"			; grep
	    "goto-line (get-tty-string \"Line: \");"		; goto
    )
)

(declare-global glob-replace-string glob-search-string)
(setq glob-search-string "")
(setq glob-replace-string "")

(defun 
    (wrap-search s-string
	(setq s-string (get-tty-string
           (concat "Find (" glob-search-string "): ")))
        (if (!= s-string "") (setq glob-search-string s-string))
	(wrap-search-again)
    )
)

(defun
    (wrap-search-again-utility
	    (if (error-occured (search-forward glob-search-string))
			(if (error-occured
				(save-excursion
				    (beginning-of-file)
				    (search-forward glob-search-string)
				)
			    )
			    (error-message (concat 
				glob-search-string " not found."))
			    (progn
				    (beginning-of-file)
				    (search-forward glob-search-string)
			    )
			)
	    )
    )

    (wrap-search-again
	(wrap-search-again-utility)
	(region-around-match 0)
    )
)

(defun
   (change c-string
      (setq c-string (get-tty-string
         (concat "Change to (" glob-replace-string "): ")))
      (if (!= c-string "") (setq glob-replace-string c-string))
      (change-again)
   )

   (change-again
      (erase-region) (insert-string glob-replace-string)
   )

   (change-again-and-next
      (change-again)
      (wrap-search-again)
   )      
)

(declare-buffer-specific #edit-menu)
(declare-buffer-specific #edit-actions)
(setq-default #edit-menu "undo ..more | cut paste copy clear ")
(setq-default #edit-actions
    (concat
	"undo;"							; undo
	"undo-more;"						; ..more
	"nothing;"						; |
	"delete-to-killbuffer;"					; cut
	"yank-from-killbuffer;"					; paste
	"copy-region-to-buffer \"Kill buffer\";"		; copy
	"erase-region;"						; clear
    )
)
(save-excursion defl
    (temp-use-buffer "Error-log")
    (setq defl #edit-menu)
    (setq #edit-menu (concat defl "| next "))
    (setq defl #edit-actions)
    (setq #edit-actions 
	  (concat defl "nothing;new-next-error;"))
    (temp-use-buffer "shell")
    (setq defl #edit-menu)
    (setq #edit-menu (concat defl "| interrupt quit eof "))
    (setq defl #edit-actions)
    (setq #edit-actions 
	  (concat defl 
		  "nothing;"
		  "send-int-signal;"
		  "send-quit-signal;"
		  "send-eot;"
		  )))

(declare-global
    glob-search-string
    init-scroll-pos-y
    init-scroll-pos-x
    dragging-bar
    which-bar
    bar-start
    mouse-sequence-number
)

(setq dragging-bar 0)

(defun
    (dotimes dtn
	(setq dtn (arg 1))
	(while (> dtn 0)
	       (setq dtn (- dtn 1))
	       (arg 2)
	)
    )
)

(defun
    (next-ch-is-digit gtch
	(setq gtch (get-tty-character))
	(push-back-character gtch)
	(& (>= gtch '0') (<= gtch '9'))
    )

    (get-tty-integer gtint
	(setq gtint 0)
	(while (next-ch-is-digit)
	       (setq gtint (* gtint 10))
	       (setq gtint (+ gtint (- (get-tty-character) '0'))))
	gtint
    )
)

(declare-global real-x-value last-was-right)
(setq last-was-right 0)

(defun 
    (decode-mac-mouse b		; x y command shift lock option down up
				; must be declared by any caller
	(setq y (- (get-tty-character) 32))
	(setq x (- (get-tty-character) 32))
	(setq real-x-value x)
	(setq b (- (get-tty-character) 32)) ; buttons and modifiers
	(setq command (% b 2))(setq b (/ b 2))	; command key
	(setq shift (% b 2))(setq b (/ b 2))	; shift 
	(setq lock (% b 2))(setq b (/ b 2))	; caps-lock
	(setq option (% b 2))(setq b (/ b 2))	; option
	(setq down (% b 2))(setq b (/ b 2))	; mouse down
	(setq up (% b 2))	
    )

    (decode-tem-mouse b left middle right
	(setq y (get-tty-integer))
	(get-tty-character)	; eat ';'
	(setq x (get-tty-integer))
	(get-tty-character)	; eat ';'
	(setq b (get-tty-integer))
	(get-tty-character)	; eat 'M'
	(setq shift (% b 2))(/= b 2)	; shift key
	(setq command (% b 2))(/= b 2)	; control 
	(setq option (% b 2))(/= b 2)	; option
	(setq lock (% b 2))(/= b 2)	; caps-lock
	(setq left (% b 2))(/= b 2)	; left-button down
	(setq middle (% b 2))(/= b 2)
	(setq right (% b 2))
	(setq down (| left middle right))
	(setq up (! down))
	(setq real-x-value x)
	(if (| right last-was-right) (setq x (+ screen-width 1)))
	(setq last-was-right right)
	(if (& middle (<= y (- screen-height (height-of-minibuf)))) 
	    (setq option 1))
	(if (& left (> y (- screen-height (height-of-minibuf)))) (setq y (+ 1 y)))
    )

    (decode-xtem-mouse b left middle right
    	(setq b (- (get-tty-character) ' '))
	(setq x (- (get-tty-character) ' '))
	(setq y (- (get-tty-character) ' '))
	(setq shift (>= b 16))		; control key
	(setq command 0)		; don't do it
	(setq option 0)			; don't do it
	(setq lock 0)			; don't do it
	(setq b (bit& b 15))
	(setq left (= b 0))		; left-button down
	(setq middle (= b 1))
	(setq right (= b 2))
	(setq down (| left middle right))
	(setq up (! down))
	(setq real-x-value x)
	(if (| right last-was-right) (setq x (+ screen-width 1)))
	(setq last-was-right right)
	(if (& middle (<= y (- screen-height (height-of-minibuf)))) 
	    (setq option (+ 1 option)))
	(if (& left (> y (- screen-height (height-of-minibuf)))) (setq y (+ 1 y)))
    )
)

(defun
    (demand-sequence bsstr bsch bsi bslen bssb
	(setq bsstr (arg 1 "Demand: "))(setq bsi 1)(setq bslen (length bsstr))
	(setq bsch (char-to-string (get-tty-character)))
	(setq bssb (substr bsstr bsi 1))
	(while (& (< bsi bslen) (= bsch bssb))
	       (setq bsch (char-to-string (get-tty-character)))
	       (setq bsi (+ bsi 1))
	       (setq bssb (substr bsstr bsi 1)))
	(if (| (< bsi bslen) (!= bsch bssb))
	    (setq accepted-string 
		  (concat accepted-string (substr bsstr 1 (- bsi 1)) bsch)))
	(& (= bsi bslen) (= bsch bssb))
    )
)

(defun 
    (next-action-is-mac-mouse answer accepted-string
	(setq accepted-string "")
	(setq answer (demand-sequence "\em"))
	(if answer (decode-mac-mouse) (push-back-string accepted-string))
	answer
    )
    (next-action-is-tem-mouse answer accepted-string nach
	(setq accepted-string "")
	(setq answer (& (demand-sequence "\e[") (next-ch-is-digit)))
	(if answer (decode-tem-mouse) (push-back-string accepted-string))
	answer
    )
    (next-action-is-xtem-mouse answer accepted-string nach
        (setq accepted-string "")
	(setq answer (demand-sequence "\e[M"))
	(if answer (decode-xtem-mouse) (push-back-string accepted-string))
	answer
    )
)

(defun
    (move-mouse-cursor savest x y up down lock shift option command mbuf-line
	(setq savest stack-trace-on-error)
	(setq stack-trace-on-error 0)
	(setq #old-dot (dot))
	(setq #old-window (current-window))
	(decode-mouse)
	(setq mouse-sequence-number (+ 1 mouse-sequence-number))
	(setq mbuf-line (+ 1 (- screen-height (height-of-minibuf))))
	(if dragging-bar
	    (move-the-bar)
	    (> x screen-width)		; scrolling time
	    (#mouse-scroll-region)
	    (| (& option (= shift shift-edit-menu))
	       (= y mbuf-line))  ; edit-menu
	    (edit-menu-select)
	    (> y mbuf-line)		; file-menu
	    (file-menu-select)
	    (= y (- mbuf-line 1))	; find-menu
	    (find-menu-select)
	    (> y 0)			; move dot
	    (#mouse-set-dot-possibly-mark x y (& down (! shift)))
	)
	(setq stack-trace-on-error savest)
    )
    
    (move-the-bar mtb-dot-win
	(if (& up (<= x screen-width) (< y mbuf-line) (>= y 1))
	    (progn
		  (setq mtb-dot-win (current-window))
		  (goto-window which-bar) 
		  (if (< y bar-start)
		      (while (& (> which-bar 0) 
				(< y bar-start)
				(if (< (- bar-start y) (window-height ))
				    (progn 
					   (dotimes (- bar-start y)
					       (shrink-window))
					   0)
				    1
				)
			     )
			     (if (= which-bar mtb-dot-win)
				 (setq mtb-dot-win -1)
				 (< which-bar mtb-dot-win)
				 (setq mtb-dot-win (- mtb-dot-win 1)))
			     (delete-window)
			     (setq which-bar (- which-bar 1))
			     (goto-window which-bar))
		      (> y bar-start)
		      (while (& (< which-bar (number-of-windows))
				(> y bar-start)
				(| (progn nxt-ht
					  (next-window)
					  (setq nxt-ht (window-height))
					  (previous-window)
					  (<= nxt-ht (- y bar-start)))
				   (error-occured 
				       (dotimes (- y bar-start)
					   (enlarge-window)))))
			     (if (= (+ which-bar 1) mtb-dot-win)
				 (setq mtb-dot-win -1)
				 (< which-bar mtb-dot-win)
				 (setq mtb-dot-win (- mtb-dot-win 1)))
			     (next-window)
			     (setq bar-start (+ bar-start 1 (window-height)))
			     (delete-window)
			     (goto-window which-bar))))
	)
	(if (!= mtb-dot-win -1)
	    (goto-window mtb-dot-win))
	(setq dragging-bar 0)
    )
    
    (#mouse-set-dot-possibly-mark xxx yyy set-the-mark end-case which-window
     (setq xxx (arg 1 "X position: "))
     (setq yyy (arg 2 "Y position: "))
     (setq set-the-mark (arg 3 "Set mark? "))
     (if (error-occured (move-dot-to-x-y xxx yyy))
         (if (esr#check#bug xxx yyy)
            (progn (setq set-the-mark 0)
		(setq option 1)
		(edit-menu-select))
	    (progn (setq set-the-mark 0)
		(setq which-bar (which-window-has-y yyy))
		(setq bar-start yyy)
		(setq dragging-bar down)))
	 (execute-mlisp-line click-hook))
     (if set-the-mark (set-mark))
    )

    (esr#check#bug &x &y oldwin trim-edit trim-mode
	(setq &x (arg 1))
	(setq &y (arg 2))
        (setq oldwin (current-window))
        (goto-window (which-window-has-y &y))
        (setq trim-edit (esr#trim#trailing #edit-menu))
        (setq trim-mode (esr#trim#trailing mode-line-format))
        (goto-window oldwin)
        (& (= trim-edit trim-mode) (<= &x (length trim-mode)))
    )

    (esr#trim#trailing &str ic
	(setq &str (arg 1))
	(setq ic (length &str))
        (while (& (> ic 0) (= (substr &str ic 1) " ")) (setq ic (- ic 1)))
        (substr &str 1 ic)
    )

    (file-menu-select
	(mouse-menu #file-menu #file-actions 0)
	(if #exit-flag (progn (setq #exit-flag 0) (new-exit-emacs)))
    )
    
    (edit-menu-select opt
	(setq opt option)
	(if (< y mbuf-line)
	    (goto-window (which-window-has-y y)))
	(mouse-menu #edit-menu #edit-actions opt)
    )
    
    (find-menu-select
	(mouse-menu #find-menu #find-actions 0)
    )
    
    (#mouse-scroll-region	 ; out of range actions:
     (if (= down 1)
	 (progn (setq init-scroll-pos-y y)
		(setq init-scroll-pos-x real-x-value))
     )
     (if (= up 1)
	 (do-scroll)
     )
    )
    
    (do-scroll ds-prev-window ds-top-line ds-bot-line ds-temp
	(setq ds-prev-window (current-window))
	(progn (goto-window (which-window-has-y init-scroll-pos-y))
	       (setq ds-top-line (top-line-of (current-window)))
	       (setq ds-bot-line (+ ds-top-line (window-height)))
	       (setq ds-temp (line-in-window-of-y init-scroll-pos-y))
	       (if (= 0 ds-temp) (end-of-window)
		   (progn (beginning-of-window)
			  (provide-prefix-argument 
			      (- ds-temp 1) (next-line))))
	)
	(if shift
	    (do-absolute-scroll)
	    (do-relative-scroll)
	)
	(goto-window ds-prev-window)
    )
    
    (do-absolute-scroll
	(sit-for 0)
	(if (= y init-scroll-pos-y)
	    (goto-percent (/ (* (- y ds-top-line) 100) 
			     (- ds-bot-line ds-top-line)))
	    (provide-prefix-argument 
		(- y init-scroll-pos-y)
		(scroll-one-line-down))
	)
    )
    
    (do-relative-scroll amount scrl-bar-ht
	(if
	   (& (= y init-scroll-pos-y)
	      (= real-x-value init-scroll-pos-x))
	   (progn
		 (setq amount (max 1 (- (window-height) 1)))
		 (setq scrl-bar-ht (- ds-bot-line ds-top-line))
		 (setq amount (* amount (- (+ ds-bot-line ds-top-line) 
			       (+ y y))))
		 (if (< amount 0)
		     (dotimes (/ (- (- scrl-bar-ht 1)
				    amount) 
				 scrl-bar-ht)
			 (scroll-one-line-up))
		     (> amount 0)
		     (dotimes (/ (+ (- scrl-bar-ht 1) 
				    amount) 
				 scrl-bar-ht)
			 (scroll-one-line-down))
		     (scroll-one-line-up)
		 )
	   )
	   (> (abs (- real-x-value init-scroll-pos-x)) 
	      (abs (- y init-scroll-pos-y)))
	   (progn (push-mark)(set-mark)(line-to-top-of-window)
		  (provide-prefix-argument 
		      (/ (window-height) 2)
		      (scroll-one-line-down))(exchange-dot-and-mark)
		  (pop-mark))
	   (< y init-scroll-pos-y) 
	   (line-to-top-of-window)
	   ;	   else
	   (progn 
		  (push-mark)
		  (set-mark)
		  (line-to-bottom-of-window)
		  (exchange-dot-and-mark)
		  (pop-mark)
	   )
	)
    )
    
    (goto-percent
	(goto-character (+ 1 (/ (* (buffer-size) (arg 1)) 100)))
    )
)

(if (error-occured (terminal-type))
    (defun (terminal-type (getenv "TERM"))))

(if (= (terminal-type) "adm31")
    (defun (next-action-is-mouse (next-action-is-mac-mouse))
	   (decode-mouse (decode-mac-mouse))
	   (move-mac-cursor (move-mouse-cursor)))
    (= (terminal-type) "ety")
    (defun (next-action-is-mouse (next-action-is-tem-mouse))
	   (decode-mouse (decode-tem-mouse)))
    (defun (next-action-is-mouse (next-action-is-xtem-mouse))
	   (decode-mouse (decode-xtem-mouse)))
)

(defun
    (height-of-minibuf curr-win hofmin
	(setq curr-win (current-window))		    
	(pop-to-buffer "  Minibuf")
	(erase-buffer)
	(setq hofmin (window-height))
	(goto-window curr-win)
	hofmin
    )
)

(declare-global screen-height screen-width)

(setq which-bar 1)(setq screen-height 0)
(save-excursion 
    (top-window)
    (while (<= which-bar (number-of-windows))
	   (setq screen-height (+ screen-height (window-height) 1))
	   (setq which-bar (+ 1 which-bar))
	   (next-window))
)
(setq screen-height (+ screen-height (height-of-minibuf)))
(setq screen-width (window-width))
(if (& (= screen-width 79)
       (= (terminal-type) "adm31"))
    (setq screen-width (+ 1 screen-width))) 
        			; adm31's scroll bar really should be just
				; outside the screen.  This makes it work,
				; sort of.

(defun 
    (ignore-mouse-and-last-key x y up down lock shift option command 
	(push-back-character (last-key-struck))
	(if (! (next-action-is-mouse))
	    (get-tty-character)
	)
    )
)

(save-excursion 
    (temp-use-buffer "  Minibuf")
    (use-local-map "Minibuf-local-NS-map")
    (local-bind-to-key "ignore-mouse-and-last-key" "\e")
    (use-local-map "Minibuf-local-map")
    (local-bind-to-key "ignore-mouse-and-last-key" "\e")
)

; Let mouse-clicks end incremental search and succeed.
(setq-default search-exit-char '\r')
