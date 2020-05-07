(declare-global is-neg)
(setq is-neg 0)

(defun (neg-arg
	       (setq is-neg 1)
	       (message "Arg: -")
	       (return-prefix-argument 0)
       ))

(defun (auto-arg-insert
	   (if prefix-argument-provided
	       (insert-string prefix-argument))
	   (self-insert)
       ))

(defun (n-digit n
	   (if (! prefix-argument-provided)
	       (setq is-neg 0))
	   (if is-neg
	       (setq n (- (* (if prefix-argument-provided prefix-argument 0)
			     10)
			  (% (last-key-struck) 16)))
	       (setq n (+ (* (if prefix-argument-provided prefix-argument 0)
			     10)
			  (% (last-key-struck) 16)))
	   )
	   (message (concat "Arg: " n))
	   (return-prefix-argument n)
       ))

(progn i
    (setq i ' ')
    (while (< i 0177)
	   (bind-to-key "auto-arg-insert" i)
	   (setq i (+ i 1)))
    (setq i '0')
    (while (<= i '9')
	   (bind-to-key "n-digit" i)
	   (setq i (+ i 1)))
    (bind-to-key "neg-arg" "-")
)
