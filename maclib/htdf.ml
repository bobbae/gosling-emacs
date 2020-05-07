(load "newcompile.ml")

(declare-global htdf-n-value 0)

(defun (currently-in-def-file
	   (save-excursion 
	       (pop-to-buffer "Error-log")
	       (search-forward ", line")
	       (search-forward ",")
	       (backward-character)
	       (= (char-to-string (preceding-char)) "n")
	   )
       )
)


(defun (calculate-htdf-n-value i ch
	   (save-excursion
	       (beginning-of-file)
	       (search-forward "TION MODULE")
	       (next-line)
	       (next-line)
	       (beginning-of-line)
	       (forward-character)
	       (forward-character)
	       (setq i 1)
	       (while (| (= (setq ch (char-to-string (following-char))) "f")
			 (= ch "i"))
		      (next-line)
		      (beginning-of-line)
		      (forward-character)
		      (forward-character)
		      (setq i (+ i 1))
		      (setq ch (char-to-string (following-char))))
	       (if (= ch "e")
		   (progn (next-line)
			  (next-line)
			  (if (= "*" (setq ch (char-to-string (following-char))))
			      (setq i (+ i 4))
			      (setq i (+ i 1)))
		   ))
	       (setq htdf-n-value i)
	   )
       )
)
		   

(defun (htdf-next-error 
	   (new-next-error)
	   (if (currently-in-def-file)
	       (progn (if (= htdf-n-value 0)
			  (calculate-htdf-n-value))
		      (provide-prefix-argument htdf-n-value (next-line))
	       ))
       ))
    
(defun (htdf-compile-it
	   (if prefix-argument-provided
	       (provide-prefix-argument prefix-argument 
		   (new-compile-it (arg 1 ": compile-it using command: ")))
	       (new-compile-it))
	   (setq htdf-n-value 0)
       ))
	       
(bind-to-key "htdf-compile-it" "\^X\^E")
(bind-to-key "htdf-next-error" "\^X\^N")
