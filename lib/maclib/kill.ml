(declare-global kill-ring-size kill-ring-pos kill-buffer-name)
(setq kill-ring-size 10)
(setq kill-ring-pos -1)

(defun
    (perform-kill
	(if (!= (previous-command) -84)
	    (progn
		(setq kill-ring-pos (% (+ kill-ring-pos 1) kill-ring-size))
		(setq kill-buffer-name (concat "kill-buffer-" kill-ring-pos))
		(copy-region-to-buffer kill-buffer-name))
	    (if (< (dot) (mark))
		(prepend-region-to-buffer kill-buffer-name)
		(append-region-to-buffer kill-buffer-name)))
	(erase-region)
	(setq this-command -84)))

(defun
    (kill-next-word
	(save-excursion
	    (set-mark)
	    (provide-prefix-argument prefix-argument (forward-word))
	    (perform-kill)))
)

(defun    
    (kill-previous-word
	(save-excursion
	    (set-mark)
	    (provide-prefix-argument prefix-argument (backward-word))
	    (perform-kill)))
)

(defun    
    (kill-lines-ITS
	(save-excursion
	    (set-mark)
	    (if prefix-argument-provided
		(progn 
		    (beginning-of-line)
		    (provide-prefix-argument prefix-argument (next-line)))
		(if (eolp) (forward-character) (end-of-line)))
	    (perform-kill)))
)

(defun
    (yank-kill
	(if prefix-argument-provided
	    (yank-cycle)
	    (progn
		(set-mark)
		(yank-buffer kill-buffer-name))))
)

(defun
    (yank-cycle dot mark
	(setq kill-ring-pos (- kill-ring-pos 1))
	(if (< kill-ring-pos 0)
	    (setq kill-ring-pos (- kill-ring-size 1)))
	(setq kill-buffer-name (concat "kill-buffer-" kill-ring-pos))
	(if (< (dot) (mark)) (exchange-dot-and-mark))
	(setq dot (dot))
	(setq mark (mark))
	(set-mark)
	(yank-buffer kill-buffer-name)
	(save-excursion
	    (goto-character mark)
	    (set-mark)
	    (goto-character dot)
	    (delete-region-to-buffer kill-buffer-name)))
)

(bind-to-key "kill-next-word" "\ed")
(bind-to-key "kill-previous-word" "\eh")
(bind-to-key "kill-lines-ITS" "\^K")
(bind-to-key "yank-kill" "\^Y")
