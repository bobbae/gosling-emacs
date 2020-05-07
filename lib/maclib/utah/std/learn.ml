; Package for the emacs tutorial
(defun (learn
	     (save-window-excursion 
		 (delete-other-windows)
		 (switch-to-buffer "emacs-tutorial")
		 (erase-buffer)
		 (insert-file "/usr/local/lib/emacs/databases/tutorial.txt")
		 (setq needs-checkpointing 0)
		 (recursive-edit)
	     )
       ))
