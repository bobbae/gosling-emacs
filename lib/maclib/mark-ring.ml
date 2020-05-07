(declare-global mark-number top-mark mark-ring-size
    Mark-0 Mark-1 Mark-2 Mark-3 Mark-4 Mark-5 Mark-6 Mark-7 Mark-8 Mark-9)
(setq mark-number 0)
(setq top-mark "Mark-0")
(setq mark-ring-size 10)

(defun
    (mark-cycle-ring
	(setq top-mark
	    (concat "Mark-"
		(setq mark-number
		    (% (+ mark-number (arg 1)) mark-ring-size)))))
    
    (mark-push
	(error-occured
	    (execute-mlisp-line
		(concat "(setq " (mark-cycle-ring 1) " (mark))")))
	(set-mark))
    
    (mark-pop n
	(setq n (execute-mlisp-line top-mark))
	(if n
	    (progn
		(pop-to-buffer n)
		(goto-character n)
		(exchange-dot-and-mark)
		(mark-cycle-ring -1))
	    (goto-character (mark))))
    
    (mark-set/pop
	(if prefix-argument-provided
	    (mark-pop)
	    (mark-push)))
)
