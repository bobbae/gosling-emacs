;****************************************************************
;* File: ll-test.ml                                             *
;* Last modified on Wed Apr 23 09:57:37 1986 by roberts         *
;* -----------------------------------------------------------  *
;*     Test program during the development cycle.               *
;****************************************************************

(defun
   (ll-import ll-test-in-progress oldbuf thisbuf pattern
      (setq ll-test-in-progress 1)
      (setq oldbuf (current-buffer-name))
      (find-file "lauralee.ml")
      (beginning-of-file)
      (sit-for 0)
      (funny-execute-mlisp-buffer)
      (setq pattern "(if (! (is-bound ll-test-in-progress)) (load ")
      (while (! (error-occured (search-forward pattern)))
         (forward-character)
         (set-mark)
         (search-forward ")")
         (backward-character)
         (backward-character)
         (setq thisbuf (region-to-string))
         (find-file thisbuf)
         (beginning-of-file)
         (sit-for 0)
         (funny-execute-mlisp-buffer)
         (switch-to-buffer "lauralee.ml")
      )
      (switch-to-buffer oldbuf)
      (novalue)
   )
)


(defun
   (ll-export ll-test-in-progress oldbuf thisbuf pattern
      (setq ll-test-in-progress 1)
      (setq oldbuf (current-buffer-name))
      (find-file "lauralee.ml")
      (beginning-of-file)
      (sit-for 0)
      (funny-execute-mlisp-buffer)
      (if buffer-is-modified (ll-fixup-buffer))
      (setq pattern "(if (! (is-bound ll-test-in-progress)) (load ")
      (while (! (error-occured (search-forward pattern)))
         (forward-character)
         (set-mark)
         (search-forward ")")
         (backward-character)
         (backward-character)
         (setq thisbuf (region-to-string))
         (find-file thisbuf)
         (beginning-of-file)
         (sit-for 0)
         (funny-execute-mlisp-buffer)
         (if buffer-is-modified (ll-fixup-buffer))
         (switch-to-buffer "lauralee.ml")
      )
      (write-modified-files)
      (switch-to-buffer oldbuf)
      (novalue)
   )
)

(defun
   (ll-fixup-buffer
      (trim-trailing-space)
      (expand-leading-tabs)
      (end-of-file)
      (while (= (preceding-char) '\n') (delete-previous-character))
      (insert-character '\n')
      (beginning-of-file)
   )
)

(defun
   (ll-test
      (if (buffer-exists "lauralee.ml") (ll-export) (ll-import))
   )
)

(bind-to-key "ll-test" "\e`")
