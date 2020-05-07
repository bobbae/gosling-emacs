;  Stuff to do with mode lines in mhe
;	July 17, 1986	Glenn Trewitt
; 		Created.

(declare-global
    mh-mode-line		; restore the mode line to this
    mhml-blank				; empty mode line
    ;  Mode lines during message composition.
    mhml-comp-1 mhml-comp-2		; -- for msg during composition.
    mhml-comp-done-1 mhml-comp-done-2	; -- for msg after composition.
    mhml-comp-other			; -- for other window.
    ;  Mode lines during message editing.  (already in folder)
    mhml-edit-1 mhml-edit-2		; -- for msg during edit.
    mhml-edit-done-1 mhml-edit-done-2	; -- for msg after edit.
    mhml-edit-other			; -- for other window.
    ;  Mode line during message display.
    mhml-show-1 mhml-show-2a mhml-show-2b
)

(setq mh-mode-line "{%b} %[%] (npd^!u tTel mfrRyiq gbx ? ^X^C)\t\t    %M")
(setq mhml-blank "\t\t\t\t\t\t\t    %M")

(setq mhml-comp-1	"{%b} %[%p of ")
(setq mhml-comp-2			 "%] \t(^X^C exits)	    %M")
(setq mhml-comp-done-1	"{%b}  %[%p of ")
(setq mhml-comp-done-2			 "%]  \t		    %M")
(setq mhml-comp-other	"{%b}\t\t%[^X^C exits to top level%]	    %M")

(setq mhml-edit-1	"{%b} %[%p of +")
(setq mhml-edit-2			 "%]   \t(^X^C exits)	    %M")
(setq mhml-edit-done-1	"{%b}  %[%p of +")
(setq mhml-edit-done-2			 "%]    \t\t\t    %M")
(setq mhml-edit-other	"{%b}\t%[^X^F writes and exits to top level%]\t    %M")

(setq mhml-show-1	"{%b}  %[%p of +")
(setq mhml-show-2a			 " lines elided; 'T' to show)  %M")
(setq mhml-show-2b			 "%] \t\t\t\t    %M")


;  Convert a full path name to an abbreviated one by replacing the portion of
;  the name that is the user's home directory with "~".
;  e.g. (strip-home "/usr/joe/foo") => "~/foo"
; 	(strip-home "host:/usr/joe/foo") => "host:~/foo"
(defun
    (strip-home path home i len
	(setq path (arg 1))
	(setq home (getenv "HOME"))
	(setq i 1)
	(setq len (length home))
	(while (<= i (- (length path) len -1))
	       (if (= home (substr path i len))
		   (progn 
			  (setq path (concat
					    (substr path 1 (- i 1))
					    "~"
					    (substr path (+ i len)
						    (- (length path) i -1))
				     )
			  )
			  (setq i (length path))
		   )
		   (setq i (+ i 1))
	       )
	)
	path
    )

)
