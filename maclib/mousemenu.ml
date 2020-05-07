;
; Routines for mousable menus.  Menus consist of two strings: the presented
; menu string and the action string.  Each menu item must be terminated by
; exactly one space, and the actions must be terminated by semi-colons.  The
; actions are MockLisp fragments--MockLisp code without the outermost
; parens.  Thus, an arrow-key simulation might have menu string
; "^ v <- -> ", and action string 
; "previous-line; next-line; if (! (bobp)) (backward-character); 
;  if (! (eobp)) (forward-character); "
; 
; The menu is invoked by (mouse-menu text actions popup).  This procedure
; awaits the next key- or mouse-sequence, checks to see if it is an 
; up-transition in the menu-line, and pushes it back if it was not a
; mouse action.  If popup is non-zero, the menu is displayed in the
; current window's status line; otherwise, it is displayed in the Minibuf.
; 
; One procedure must be supplied by the environment:
;   next-action-is-mouse, which returns a boolean if the next action
; was indeed a mouse button change;  if it was, it decodes the mouse.
; mouse decoding computes x, y, up, down, shift, option, command & lock.
; 
; Last modified on Fri Feb 14 09:33:21 1986 by msm
; 
(defun
    (nth-substr nsn nsi nsstr nsleft nsdelim
	(setq nsn (arg 1 "Index: ")) (setq nsstr (arg 2 "String: "))
	(setq nsi 1) (setq nsleft 1) (setq nsdelim (arg 3 "Delimiter: "))
	(while (< nsi nsn)
	       (setq nsleft (+ (index nsstr nsdelim nsleft) 1))
	       (if (= nsleft 1) (error-message "Not enough fields"))
	       (setq nsi (+ nsi 1)))
	(substr nsstr nsleft (- (index nsstr nsdelim nsleft) nsleft))
    )
)

(defun
    (which-word wwposn wwi wwstr wwright
	(setq wwi 0) (setq wwright 0)
	(setq wwposn (arg 1 "Index: ")) (setq wwstr (arg 2 "String: "))
	(while (< wwright wwposn)
	       (setq wwright (index wwstr " " (+ wwright 1)))
	       (if (= wwright 0) (error-message "Not enough fields"))
	       (setq wwi (+ wwi 1)))
	wwi
    )
)

(defun 
    (eval-menu wwp wwm wwa wwd
	(setq wwp (arg 1 "Position: "))(setq wwm (arg 2 "Menu: "))
	(setq wwa (arg 3 "Actions: "))(setq wwd (arg 4 "Delimiter: "))
	(if (> wwp (length wwm)) (novalue)
	    (= (substr wwm wwp 1) " ") (novalue)
	    (execute-mlisp-line 
		(concat "(" 
			(nth-substr (which-word wwp wwm) wwa wwd)
			")"
		)))
    )
)
(autoload "top-line-of" "split.ml")
(defun 
    (mouse-menu mmm mma mmpopup sline stext 
		x y up down shift option lock command
	(setq mmm (arg 1))
	(setq mma (arg 2))
	(setq mmpopup (arg 3))
	(if mmpopup 
	    (progn 
		   (setq sline (+ (top-line-of (current-window))
				  (window-height)))
		   (setq stext mode-line-format)
		   (setq mode-line-format mmm))
	    (progn
		  (setq sline (+ 1 (- screen-height (height-of-minibuf))))
		  (message mmm)
	    )
	)
	(push-back-character (get-tty-character))
	(if mmpopup
	    (setq mode-line-format stext)
	    (message ""))
	(if (& (next-action-is-mouse) up (= y sline))
	    (eval-menu x mmm mma ";"))
	(novalue)
    )
)

