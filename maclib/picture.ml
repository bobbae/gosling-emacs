;
; declare variables
;

(declare-buffer-specific &picture-direction)
(declare-buffer-specific &picture-mode-format)

(setq-default &picture-direction 0)
(setq-default &pic-overwrite 1)

(if (! (is-bound word-mode-prompt))
    (progn (setq-default word-mode-prompt 0)
	   (declare-buffer-specific word-mode-prompt)
    ))

(if (! (is-bound &picture-chars))
    (progn (declare-global &picture-chars)
	   (setq &picture-chars "-!|_=+/\:*#")
    ))

; utility movement functions

(defun 
    (forward-column old new
	(prefix-argument-loop
	    (if (eolp) (insert-character ' ')
		(! (looking-at "\^I")) (forward-character)
		(progn
		      (setq old (current-column))
		      (forward-character)
		      (setq new (current-column))
		      (delete-previous-character)
		      (while (< (current-column) new)
			     (insert-character ' '))
		      (while (> (current-column) old)
			     (backward-character))
		      (forward-character))))))

(defun 
    (move-to-col zzcol tmp
	(beginning-of-line)
	(setq zzcol  (arg 1 ": move to column "))
	(provide-prefix-argument (- zzcol 1) (forward-column))))

;
; miscellaneous utility functions
;

(defun
    (toggle-overwrite
	(setq &pic-overwrite (- 1 &pic-overwrite))
	(message "Overwrite turned " (if &pic-overwrite "On." "Off."))))

(defun
    (toggle-tab
	(if (!= (local-binding-of "\^I") "&pic-tab-overwrite")
	    (progn
		  (local-bind-to-key "&pic-tab-overwrite" "\^I")
		  (message "Tab in overwrite mode.")
	    )
	    (progn
		  (local-bind-to-key "&pic-tab-table" "\^I")
		  (message "Tab in table mode.")))))

(defun                          ; direct cursor movement
    (right-picture-movement (&picture-movement 0))
    (up-picture-movement (&picture-movement 1))
    (down-picture-movement (&picture-movement 2))
    (left-picture-movement (&picture-movement 3))
    (nw-picture-movement (&picture-movement 4))
    (ne-picture-movement (&picture-movement 5))
    (sw-picture-movement (&picture-movement 6))
    (se-picture-movement (&picture-movement 7))
)

(defun
    (&picture-movement
        (setq &picture-direction (arg 1))
        (setq mode-line-format
              (concat
                      (if (= &picture-direction 1) "up"
			  (= &picture-direction 2) "down"
			  (= &picture-direction 3) "left"
			  (= &picture-direction 4) "nw"
			  (= &picture-direction 5) "ne"
			  (= &picture-direction 6) "sw"
			  (= &picture-direction 7) "se"
			  "right")
                      ">>" &picture-mode-format))
        (novalue)))

(defun
    (delete-line
	(save-excursion
	    (beginning-of-line)
	    (set-mark)
	    (provide-prefix-argument prefix-argument (next-line))
	    (if (! (eobp)) (beginning-of-line)) ; fix eol-tracking bug
	    (if (= (previous-command) -3113)
		(progn
		      (append-region-to-buffer "Kill buffer")
		      (erase-region))
		(delete-to-killbuffer))
	    (setq this-command -3113))))

(defun
    (get-word zztmp
	   (if word-mode-prompt (get-tty-string (arg 1))
	       (progn
		     (message (arg 1))
		     (setq zztmp (get-tty-character))
		     (if (| (= zztmp 7) (= zztmp 27))
			 (error-message "Aborted."))
		     (char-to-string zztmp)))))

; This routine deletes prefix-argument characters up to the eol by turning tabs
; to spaces and makeing sure that there are enough characters on the line.

(defun
    (&pic-del-eol-chars num
	(save-excursion (prefix-argument-loop (forward-column)))
	(prefix-argument-loop (delete-next-character))
    )
)

(defun
    (abort-picture-edit
	(error-occured (setq ep-write-files 0))
	(if (recursion-depth) (exit-emacs) (message "Huh?  Not editing!!"))))

(defun
    (clean-picture
	(save-excursion
		 (beginning-of-file)
		 (error-occured (re-replace-string "[ \t][ \t]*$" ""))
		 (novalue))))

;
; rectangular region commands
;

(defun
    (copy-rectangle zzchr zzbufzz
	(setq zzchr (if (interactive) (get-word "copy to rectangle? ")
			(arg 1)
			))
	(setq zzbufzz (concat "Rect:" zzchr))
	(save-excursion (temp-use-buffer zzbufzz) (erase-buffer))
	(&pic-copy-or-kill 0 (quote zzbufzz))))

(defun (&pic-kill-rect (&pic-copy-or-kill 1 "Rect:Kill Buff")))
(defun (&pic-yank-killed-rect (yank-rectangle "Kill Buff")))

(defun
    (&pic-copy-or-kill dotp markp zstartcol endcol dot-st zstartline
			endline temp zzbuf deflg zzlen
	(save-excursion
	   (setq deflg (arg 1))
	   (setq zzbuf (arg 2))
	   (save-excursion
	       (temp-use-buffer zzbuf)
	       (erase-buffer)
	   )
	   (setq dot-st (setq dotp (dot)))
           (setq markp (mark))
           (setq zstartcol (current-column))
           (beginning-of-line)
           (setq zstartline (dot))
           (goto-character markp)
           (setq endcol (current-column))
           (beginning-of-line)
           (setq endline (dot))
           (if (< endline zstartline)
               (progn
                     (setq temp zstartline)
                     (setq zstartline endline)
                     (setq endline temp)
		     (setq dot-st markp)
               )
           )
           (if (< endcol zstartcol)
               (progn
                     (setq temp zstartcol)
                     (setq zstartcol endcol)
                     (setq endcol temp)))
	   (setq zzlen (- endcol zstartcol))
           (goto-character dotp)
	   (message (if deflg "Deleting" "Copying") " rectangle ...")
	   (sit-for 0)
	   (if (= zzlen 0) (error-message "No rectangle."))
	   (goto-character zstartline)
	   (while (& (<= (dot) endline) (! (eobp)))
		  (end-of-line)
		  (setq temp (current-column))
		  (beginning-of-line)
		  (move-to-col temp)
		  (beginning-of-line)
		  (provide-prefix-argument (- zstartcol 1) (forward-character))
	          (set-mark)
		  (provide-prefix-argument (- endcol zstartcol)
					   (forward-column))
		  (newline)
		  (append-region-to-buffer zzbuf)
		  (if deflg
		      (progn
			    (erase-region)
			    (if (& &pic-overwrite (! (eolp)))
				(provide-prefix-argument zzlen
				    (insert-character ' ')))
		      )
		      (delete-previous-character))
		  (end-of-line)
		  (if (! (eobp)) (forward-character)))
	   (if deflg (goto-character dot-st) (goto-character dotp))
	   (if (! deflg) (message (concat "copied to rectangle " zzchr))
	       (message "rectangle killed")))))


(defun
    (yank-rectangle col markfrom markto zzchr zzbuf zzline origbuf zzlen
	(save-window-excursion
           (setq zzchr (if (interactive) (get-word "yank rectangle? ")
	        	   (arg 1)
	               ))
	   (setq origbuf (current-buffer-name))
   	   (setq zzbuf (concat "Rect:" zzchr))
	   (setq col (current-column))
	   (temp-use-buffer zzbuf)
	   (beginning-of-file)
	   (set-mark)
	   (end-of-line)
	   (setq zzlen (- (dot) (mark)))
	   (beginning-of-file)
	   (while (! (eobp))
		  (set-mark)
		  (end-of-line)
		  (setq zzline (region-to-string))
		  (forward-character)
		  (temp-use-buffer origbuf)
		  (insert-string zzline)
		  (if &pic-overwrite
		      (provide-prefix-argument zzlen (&pic-del-eol-chars))
		  )
		  (end-of-line)
		  (if (eobp) (newline) (next-line))
		  (move-to-col col)
		  (temp-use-buffer zzbuf)))))

;
; Utility key binding functions
;

(defun
    (&pic-backward-character curloc
	(prefix-argument-loop
	    (if (bolp) (error-message "")
		(progn
		      (setq curloc (current-column))
		      (backward-character)
		      (if (looking-at "\^I")
			  (progn
				(delete-next-character)
				(while (< (current-column)
					  curloc)
				       (insert-character ' ')
				       )
				(backward-character)))))))

    (&pic-forward-character
	(prefix-argument-loop (if (eolp) (insert-character ' ')
				  (forward-column))))

    (&pic-next-line col
	(setq col (current-column))
	(prefix-argument-loop
	    (save-excursion (end-of-line) (if (eobp) (newline)))
	    (next-line))
	(if (!= col (current-column)) (move-to-col col))
    )

    (&pic-previous-line col
	(setq col (current-column))
	(prefix-argument-loop (previous-line))
	(if (!= col (current-column)) (move-to-col col)))

    (&pic-delete-next-character
	(prefix-argument-loop
	    (if (eolp) (error-message ""))
	    (forward-column)
	    (delete-previous-character)
	    (insert-character ' ')))


    (&pic-tab-overwrite col
	(insert-character '^I')
	(setq col (current-column))
	(delete-previous-character)
	(while (& (! (eolp)) (< (current-column) col))
	       (if (!= (following-char) '^I')
		   (progn
			 (delete-next-character)
			 (insert-character ' '))
		   (progn
			 (forward-column)
			 (delete-previous-character)
			 (insert-character ' '))))
	(if (< (current-column) col)
	    (provide-prefix-argument (- col (current-column))
		(insert-character ' '))))

    (&pic-tab-table           ; handle TAB
	(if (save-excursion (beginning-of-line) (bobp))
	    (error-message "No previous line."))
	(prefix-argument-loop
	    (&pic-previous-line)
	    (forward-column)
	    (while (& (! (eolp))
		      (! (looking-at (concat "[ \t"
					     (quote &picture-chars)
					     "]"))))
		   (forward-column))
	    (while (& (! (eolp))
		      (looking-at (concat "[ \t" (quote &picture-chars) "]")))
		   (forward-column))
	    (&pic-next-line)))

    (&pic-open
	(prefix-argument-loop
	    (end-of-line)
	    (newline)))

    (&pic-open-top
	(prefix-argument-loop
	    (beginning-of-line)
	    (newline-and-backup)))

    (&pic-open-and-dup line loc
	    (end-of-line)
	    (newline)
	    (previous-line)
	    (set-mark)
	    (next-line)
	    (setq line (region-to-string))
	    (insert-string line)
	    (delete-previous-character)
	    (beginning-of-line)
	    (while (! (eolp))
		   (if (looking-at (concat "[ " (quote &picture-chars) "]"))
		       (forward-column)
		       (&pic-delete-next-character)))
	    (beginning-of-line)
	    (set-mark)
	    (next-line)
	    (setq line (region-to-string))
	    (erase-region)
	    (setq loc (dot))
	    (prefix-argument-loop (insert-string line))
	    (goto-character loc)
	    (&pic-tab-table)
	    (if (eolp) (beginning-of-line))
    )
)

(defun
    (self-replace
        (prefix-argument-loop
            (if (! (eolp))
		(progn
		      (&pic-delete-next-character)
		      (backward-character)
		      (delete-next-character)))
            (insert-character (last-key-struck))
	    (backward-character)
	    (&pic-move)))

    (&pic-move
	(if (! &picture-direction)
	    (forward-character)
	    (= &picture-direction 1)
	    (&pic-previous-line)
	    (= &picture-direction 2)
	    (&pic-next-line)
	    (= &picture-direction 3)
	    (&pic-backward-character)
	    (= &picture-direction 4)	; nw
	    (progn
		  (if (!= (dot) (save-excursion (previous-line) (dot)))
		      (progn (&pic-previous-line) (&pic-backward-character))))
	    (= &picture-direction 5)	; ne
	    (progn
		  (if (!= (dot) (save-excursion (previous-line) (dot)))
		      (progn (&pic-previous-line) (forward-column))))
	    (= &picture-direction 6)	; sw
	    (progn (&pic-backward-character) (&pic-next-line))
	    (= &picture-direction 7)	; se
	    (progn (&pic-next-line) (forward-column))
	)
    )

    (&picture-digit
        (if prefix-argument-provided
	    (provide-prefix-argument prefix-argument (digit))
            (self-replace))))

;
; setting up mode
;

(defun
    (set-picture-mode zztmp
      (save-window-excursion
	(switch-to-buffer "xyzzypic")
	(define-keymap "empty")
	(define-keymap "kpicture map")
	(use-local-map "kpicture map")
	(setq zztmp 32)		; printing characters
	(while (< zztmp 126)
	       (local-bind-to-key "self-replace" zztmp)
	       (setq zztmp (+ zztmp 1)))
	(setq zztmp '0')
	(while (<= zztmp '9')
	       (local-bind-to-key "&picture-digit" zztmp)
	       (setq zztmp (+ zztmp 1)))
	(local-bind-to-key "up-picture-movement" "\^[-")
	(local-bind-to-key "down-picture-movement" "\^[=")
	(local-bind-to-key "left-picture-movement" "\^[`")
	(local-bind-to-key "right-picture-movement" "\^[\^H")
	(local-bind-to-key "&pic-backward-character" "\^B")
	(local-bind-to-key "&pic-delete-next-character" "\^D")
	(local-bind-to-key "&pic-delete-next-character" "\177") ; del
	(local-bind-to-key "&pic-forward-character" "\^F")
	(local-bind-to-key "&pic-move" "\^[\^I")
	(local-bind-to-key "&pic-backward-character" "\^H")
	(local-bind-to-key "&pic-tab-overwrite" "\^I")
	(local-bind-to-key "&pic-open-and-dup" "\^J")
	(local-bind-to-key "&pic-open" "\^M")
	(local-bind-to-key "&pic-next-line" "\^N")
	(local-bind-to-key "&pic-open-top" "\^O")
	(local-bind-to-key "&pic-previous-line" "\^P")
	(local-bind-to-key "&pic-kill-rect" "\^W")
	(local-bind-to-key "&pic-yank-killed-rect" "\^Y")
	(local-bind-to-key "copy-rectangle" "\^Xc")
	(local-bind-to-key "yank-rectangle" "\^Xy")
	(local-bind-to-key "delete-line" "\^K")
	(delete-buffer "xyzzypic"))))

(defun
    (edit-picture ep-write-files bufname
	(if (error-occured (mark)) (picture-mode)
	    (progn (save-window-excursion
		       (setq ep-write-files 1)
		       (setq bufname (concat "Pict:" (current-buffer-name)))
		       (copy-region-to-buffer bufname)
		       (switch-to-buffer bufname)
		       (setq buffer-is-modified 0)
		       (picture-mode)
		       (local-bind-to-key "abort-picture-edit" "\^Xa")
		       (message "^C to finish editing picture, ^Xa to abort.")
		       (save-excursion (recursive-edit))
		       (if (! buffer-is-modified) (setq ep-write-files 0)
			   (clean-picture)))
		   (if ep-write-files
		       (progn
			     (erase-region)
			     (yank-buffer bufname)))
		   (delete-buffer bufname)
		   (novalue)))))

(defun
    (picture-mode old-bufmod
	(use-local-map "kpicture map")
	(setq &picture-mode-format mode-line-format)
	(&picture-movement 0)
	(setq old-bufmod buffer-is-modified)
	(save-excursion (clean-picture))
	(setq buffer-is-modified old-bufmod)
	(setq mode-string "--Picture--")
	(novalue)))

(defun
    (off-picture-mode
	(use-local-map "empty")
	(setq mode-string "normal")))

(if (error-occured (function-type "kpicture map")) (set-picture-mode))

(novalue)
