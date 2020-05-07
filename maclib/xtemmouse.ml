; Last modified on Sun Feb 23 12:56:53 1986 by msm
; 
; xtemmouse.ml
; 
; hooks up the tem mouse support.  The real work is done by xmacmouse

(autoload "move-mouse-cursor" "xmacmouse.ml")
(autoload "split-window-at-dot" "split.ml")
(load "unipress.ml")

(defun (emacs-dsp-entry-hook (send-string-to-terminal "\e[?1000h")))
(defun (emacs-dsp-exit-hook (send-string-to-terminal "\e[?1000l")))
(emacs-dsp-entry-hook)

; Avoid mouse clicks interfering with incremental search
(setq-default search-exit-char '\r')

(bind-to-key "move-mouse-cursor" "\e[M")

(defun (start-thinking (novalue)))
(defun (stop-thinking (novalue)))

(autoload "get-tty-integer" "xmacmouse.ml")

(if (= (getenv "TERM") "xterm")
    (progn (defun (reset-display
		      (send-string-to-terminal "\e7\e[r\e[999;999H\e[6n\e8")
		  )
	   )
	   (defun (resize-display rs-x rs-y rs-ww
		      (push-back-character (last-key-struck))
		      (setq rs-y (get-tty-integer))
		      (get-tty-character)	; skip ';'
		      (setq rs-x (get-tty-integer))
		      (get-tty-character)	; skip 'R'
		      (if (& (= rs-x screen-width)
			     (= rs-y screen-height))
			  (redraw-display)
			  (progn
				(setq rs-ww (current-window))
				(memorize-windows)
				(if (!= rs-x screen-width)
				    (progn (setq screen-width rs-x)
					   (columns-on-screen rs-x)))
				(if (!= rs-y screen-height)
				    (progn (setq screen-height rs-y)
					   (lines-on-screen rs-y)))
				(restore-windows)
				(goto-window rs-ww)
			  )
		      )
		  )
	   )
	   (bind-to-key "resize-display" "\e[0")
	   (bind-to-key "resize-display" "\e[1")
	   (bind-to-key "resize-display" "\e[2")
	   (bind-to-key "resize-display" "\e[3")
	   (bind-to-key "resize-display" "\e[4")
	   (bind-to-key "resize-display" "\e[5")
	   (bind-to-key "resize-display" "\e[6")
	   (bind-to-key "resize-display" "\e[7")
	   (bind-to-key "resize-display" "\e[8")
	   (bind-to-key "resize-display" "\e[9")
	   (global-rebind "reset-display" "redraw-display")
    )
)

(declare-global window-list window-size-list length-of-window-list
    old-screen-height)

(defun (memorize-windows mw-n
	   (setq window-list "")
	   (setq window-size-list "")
	   (setq mw-n (number-of-windows))
	   (setq length-of-window-list (number-of-windows))
	   (setq old-screen-height screen-height)
	   (top-window)
	   (while (> mw-n 0)
		  (setq mw-n (- mw-n 1))
		  (setq window-list
			(cons (current-buffer-name) window-list))
		  (setq window-size-list
			(cons (window-height) window-size-list))
		  (next-window)
	   )
       )
)

(defun (cons (concat (arg 1) ":::" (arg 2))))

(defun (car car-string
	    (setq car-string (arg 1))
	    (substr car-string 1 (- (index car-string ":::" 1) 1))
       )
)

(defun (cdr cdr-string cdr-i
	    (setq cdr-string (arg 1))
	    (setq cdr-i (+ (index cdr-string ":::" 1) (length ":::")))
	    (substr cdr-string cdr-i (+ (- (length cdr-string) cdr-i) 1))
       )
)

(defun (restore-windows rw-bufht rw-desired-height rw-old-ht rw-new-ht
	   rw-old-w-height
	   (switch-to-buffer (car window-list))
	   (setq window-list (cdr window-list))
	   (setq rw-old-ht (- old-screen-height
			      (height-of-minibuf)
			      length-of-window-list))
	   (setq rw-new-ht (- screen-height
			      (height-of-minibuf)
			      length-of-window-list))
	   (delete-other-windows)
	   (while (!= window-list "")
		  (split-current-window)
		  (top-window)
		  (next-window)
		  (setq rw-old-w-height (car window-size-list))
		  (setq window-size-list (cdr window-size-list))
		  (setq rw-desired-height
			(/ (* rw-new-ht rw-old-w-height)
			   rw-old-ht))
		  (setq rw-new-ht (- rw-new-ht rw-desired-height))
		  (setq rw-old-ht (- rw-old-ht rw-old-w-height))
		  (error-occured
		      (dotimes (- rw-desired-height (window-height))
			  (enlarge-window)))
		  (previous-window)
		  (switch-to-buffer (car window-list))
		  (setq window-list (cdr window-list))
	   )
       )
)
		  
