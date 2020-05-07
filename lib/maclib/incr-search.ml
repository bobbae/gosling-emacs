; Incremental search -- see teco emacs for documentation.  Believed to 
; behave identically, except for <DEL> which simply clobbers chars
; off search string w/o moving dot.  A. Witkin 1/81
;
; Modified: Jerry Agin at CMU-750R	Fri Apr 30 1982
; 	- fixed case fold lossage
; 	- added search-exit-char
; Modified: Jeffrey Mogul @ Stanford	6 November 1981
;	- original version tried to reverse by re-defuning things.  This
;	  tended to fail quite often.  The direction of search is now
;	  tested explicitly.
;	- accepts <tab> as a "normal-character"

(declare-global I-search-string "")
(if (error-occured (& search-exit-char))
    (progn (declare-global search-exit-char)
	   (setq search-exit-char '\033')))

(defun

(&inc-initial
   (if (& (= (length string) 0)(> (length I-search-string) 0))
      (setq string I-search-string)))

(&inc-message
   (message
      (concat
	 (concat
	    (if failing "Failing " "") (if is-forward "" "Reverse "))
	 (concat "I-search: " string))))

(&inc-normal-char
   (if is-forward
      (&inc-forward-normal-char)
      (&inc-reverse-normal-char)))

(&inc-search
   (if is-forward
      (&inc-forward-search)
      (&inc-reverse-search)))

(&inc-forward-search
   (if 
      (error-occured (search-forward string))
      (setq failing (+ 1 failing))
      (setq failing 0))
   (&inc-message))

(&inc-reverse-search
   (if
      (error-occured (search-reverse string))
      (setq failing (+ 1 failing))
      (setq failing 0))
   (&inc-message))

(&inc-forward-normal-char
   (progn
      (setq string (concat string next))
      (if (| (= nextc (following-char))
	     (& (>= nextc 'A')
		(= (^ nextc (following-char)) '\040')))
	 (progn (forward-character) (&inc-message))
	 (&inc-forward-search))))

(&inc-reverse-normal-char
   (setq string (concat string next))
   (if 
      (save-excursion 
	 (goto-character (+ (dot) (length string)))
	 (| (= nextc (preceding-char))
	    (& (>= nextc 'A')
	       (= (^ nextc (preceding-char)) '\040'))))
      (&inc-message)
      (&inc-reverse-search)))

(&inc-CG
   (if (= nextc '^G') 
      (if failing
	 (progn
	    (setq string (substr string 1 (- (length string) failing)))
	    (setq failing 0)
	    (&inc-message))
	 (progn (setq ok 0)(goto-character start)))))

(&inc-CS 
   (if (= nextc '^S')
      (progn
	 (&inc-initial)
	 (if (! is-forward)
	    (progn
	       (setq is-forward 1) (setq turning-point (dot))
;	       (defun
;		  (&inc-search (&inc-forward-search))
;		  (&inc-normal-char (&inc-forward-normal-char)))
		))
	 (if failing (setq failing (- failing 1)))
	 (&inc-forward-search))))

(&inc-CR
   (if (= nextc '^R')
      (progn
	 (&inc-initial)
	 (if is-forward
	    (progn
	       (setq is-forward 0) (setq turning-point (dot))
;	       (defun
;		  (&inc-search (&inc-reverse-search))
;		  (&inc-normal-char (&inc-reverse-normal-char)))
		))
	 (if failing (setq failing (- failing 1)))
	 (&inc-reverse-search)))) 

(&inc-DEL (if (= nextc '\0177')
	     (progn
		(setq string (substr string 1 (- (length string) 1)))
		(if failing (setq failing (- failing 1)))
		(&inc-message))))

   (&inc-CQ (if (= nextc '^Q')
	       (progn
		  (setq next
		     (char-to-string (setq nextc (get-tty-character))))
		  (if (&inc-meta-char) (setq next (concat "" next)))
		  (&inc-normal-char)
		  (setq nextc '^Q'))))

   (&inc-ALT (if (= nextc search-exit-char) (setq ok 0)))

   (&inc-special-char
      (|
	 (= nextc '^G')(= nextc search-exit-char)
	 (= nextc '^S')(= nextc '^R')
	 (= nextc '^Q')(= nextc '\0177')))

   (&inc-funny-char
      (| (& (!= nextc '^I') (< nextc ' ')) (> nextc '~')))

(&inc-meta-char
   (> nextc 127))

(incremental-search
   string start ok start turning-point is-forward failing history push-back
   (setq push-back -1)
;   (defun
;     (&inc-normal-char (&inc-forward-normal-char))
;     (&inc-search (&inc-forward-search)))
   (setq string "") (setq turning-point (setq start (dot))) 
   (setq ok 1) (setq is-forward 1)(setq failing 0)(setq history "")
   (&inc-message)
   (while ok (&inc-process-char))
   (setq I-search-string string)
   (if (>= push-back 0) (push-back-character push-back))
)

(reverse-incremental-search
   string ok start turning-point is-forward failing history push-back
   (setq push-back -1)
;  (defun 
;     (&inc-normal-char (&inc-reverse-normal-char))
;     (&inc-search (&inc-reverse-search)))
   (setq string "") (setq turning-point (setq start (dot))) 
   (setq ok 1) (setq is-forward 0)(setq failing 0)(setq history "")
   (&inc-message)
   (while ok (&inc-process-char))
   (setq I-search-string string)
   (if (>= push-back 0) (push-back-character push-back))
)

(&inc-process-char next nextc
   (setq next (char-to-string (setq nextc (get-tty-character))))
   (if 
      (&inc-funny-char)
      (if
	 (&inc-special-char)
	 (progn (&inc-CS)(&inc-CR)(&inc-CG)(&inc-DEL)(&inc-CQ)(&inc-ALT))
	 (progn
	    (setq push-back nextc)
	    (setq ok 0)))
      (&inc-normal-char))
   (setq I-search-string "")))
