(defun (exit-emacs-hook (novalue)))

(defun (new-exit-emacs (exit-emacs-hook) (exit-emacs)))
(defun (new-write-file-exit (write-modified-files) (new-exit-emacs)))

(defun (global-rebind new-function old-function default-binding 
	   (setq new-function (arg 1 ": new function: "))
	   (setq old-function (arg 2 ": old function: "))
	   (if (= (nargs) 3)
	       (setq default-binding (arg 3))
	       (setq default-binding 0)
	   )
	   (save-window-excursion did-bind
	       (setq did-bind 0)
	       (temp-use-buffer "Help")
	       (describe-bindings)
	       (beginning-of-file)
	       (set-mark)
	       (next-line)
	       (next-line)
	       (next-line)
	       (erase-region)
	       (end-of-file)
	       (set-mark)
	       (error-occured 
		   (search-reverse "Local Bindings")
		   (beginning-of-line)
		   (previous-line)
		   (erase-region)
	       )
	       (beginning-of-file)
	       (while (! (error-occured 
			     (search-forward (concat " " old-function))))
		      (if (eolp)
			  (save-excursion
			      (beginning-of-line)
			      (set-mark)
			      (search-forward " ")
			      (backward-character)
			      (bind-to-key new-function (region-to-control-string))
			      (setq did-bind 1)
			  )
		      )
	       )
	       (if (& default-binding (! did-bind))
		   (bind-to-key new-function default-binding)
	       )
	   )
       )
)

(defun (region-to-control-string return-string
	   (setq return-string "")
	   (save-restriction 
	       (narrow-region)
	       (beginning-of-file)
	       (while (! (eobp))
		      (if (= (following-char) '^')
			  (progn 
				 (forward-character)
				 (setq return-string
				       (concat return-string 
					       (char-to-string
						   (- (following-char) 64))))
			  )
			  (looking-at "ESC")
			  (setq return-string (concat return-string "\e"))
			  (setq return-string (concat return-string 
						      (char-to-string 
							  (following-char))))
		      )
		      (if (error-occured (search-forward "-"))
			  (end-of-file)
		      )
	       )
	       return-string
	   )
       )
)

(global-rebind "new-exit-emacs" "exit-emacs")
(global-rebind "new-write-file-exit" "write-file-exit")

(defun (line-to-bottom-of-window 
	   (push-mark)(set-mark)(line-to-top-of-window)
	   (provide-prefix-argument (- (window-height) 1) (scroll-one-line-down))
	   (exchange-dot-and-mark)(pop-mark)
       )
)

(defun (line-number ln-dot
	   (setq ln-dot (+ (dot)))
	   (save-excursion ln-n
	       (setq ln-n 1)
	       (beginning-of-file)
	       (end-of-line)
	       (while (& (! (eobp)) (< (+ (dot)) ln-dot))
		      (next-line)(end-of-line)
		      (setq ln-n (+ 1 ln-n))
	       )
	       ln-n
	   )
       )
)
	       
(defun (goto-line 
	   (beginning-of-file)
	   (provide-prefix-argument (- (arg 1) 1) (next-line))
       )
)

(declare-buffer-specific mark1 mark2 mark3)
(setq-default mark1 -1)
(setq-default mark2 -1)
(setq-default mark3 -1)

(defun (push-mark
	   (setq mark3 mark2)
	   (setq mark2 mark1)
	   (setq mark1 (if (error-occured (mark)) -1 (mark)))
       )
)

(defun (pop-mark
	   (if (>= mark1 0) 
	       (progn 
		      (exchange-dot-and-mark)
		      (goto-character mark1)
		      (exchange-dot-and-mark)
		      (setq mark1 mark2)
		      (setq mark2 mark3)
	       )
	   )
       )
)

(defun (buffer-exists
	   (save-window-excursion 
	       (! (error-occured (use-old-buffer (arg 1))))
	   )
       )
)

(defun (abs abs-arg
	    (setq abs-arg (arg 1))
	    (if (< abs-arg 0)
		(- 0 abs-arg)
		abs-arg
	    )
       )
)

(defun (max max-arg1 max-arg2
	    (setq max-arg1 (arg 1))
	    (setq max-arg2 (arg 2))
	    (if (> max-arg1 max-arg2)
		max-arg1
		max-arg2
	    )
       )
)

(defun (min min-arg1 min-arg2
	    (setq min-arg1 (arg 1))
	    (setq min-arg2 (arg 2))
	    (if (< min-arg1 min-arg2)
		min-arg1
		min-arg2
	    )
       )
)


(defun (push-back-string pbs-n pbs-s
	   (setq pbs-s (arg 1 ": push-back-string "))
	   (setq pbs-n (length pbs-s))
	   (while (> pbs-n 0)
		  (push-back-character (string-to-char (substr pbs-s pbs-n 1)))
		  (setq pbs-n (- pbs-n 1))
	   )
       )
)

(defun (is-top-window
	   (= (current-window) 1)
       )
)

(defun (top-window
	   (while (! (is-top-window))
		  (next-window)
	   )
	   (novalue)
       )
)

(defun (goto-window gw-n
	   (setq gw-n (arg 1 ": goto-window "))
	   (top-window)
	   (while (> gw-n 1)
		  (next-window)
		  (if (is-top-window)
		      (progn 
			     (previous-window)
			     (setq gw-n 1)
		      )
		      (setq gw-n (- gw-n 1))
		  )
	   )
	   (novalue)
       )
)

(defun (number-of-windows now-n
	   (save-window-excursion 
	       (setq now-n 1)
	       (goto-window 2)
	       (while (! (is-top-window))
		      (setq now-n (+ now-n 1))
		      (next-window)
	       )
	   )
	   now-n
       )
)

(defun (path-of dir-name epath po-done po-colon file-name
	   (setq file-name (arg 1 ": path-of "))
	   (setq epath (concat ".:" (getenv "EPATH") ":"))
	   (setq po-done 0)
	   (while (& (= po-done 0) (!= epath ""))
		  (setq po-colon (index epath ":" 1))
		  (setq dir-name (substr epath 1 (- po-colon 1)))
		  (setq dir-name (concat dir-name "/" file-name))
		  (setq epath (substr epath (+ po-colon 1)
				      (- (length epath) po-colon)))
		  (setq po-done (file-exists dir-name))
	   )
	   (if (= po-done 0)
	       (error-message ": path-of " file-name " not found")
	       dir-name
	   )
       )
)
		  

		      
