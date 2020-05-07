;  This autoloaded file implements the "t" command of mhe
(defun 
    (&mh-show msgn sm fn fl nelided
        (setq msgn (&mh-get-msgnum))
        (message  "Typing message " msgn) (sit-for 0)
        (if 
            (error-occured
                (pop-to-buffer (concat "+" mh-folder))
                (setq fn (&mh-get-fname))
                (setq fl mh-folder)
                (pop-to-buffer "show")
                (erase-buffer)
                (insert-file fn)
                (setq nelided 0)
                (if (!= (last-key-struck) 'T')
                    (setq nelided (&mh-clean-header)))
                (setq mode-line-format
                      (concat "{%b}     %[%p of +" fl "/" msgn
                              "%] (" nelided
                              " lines elided; 'T' to show) |%M"))
                (use-local-map "&mh-keymap")
                (setq mode-string "mhe")
                (setq buffer-is-modified 0)
                (sit-for 0)
                (&mh-set-cur)
            )
           (progn (delete-window)
                  (error-message "message " msgn " does not exist!")
           )
        )
    )

; This function removes unwanted header lines.
    (&mh-clean-header n
        (beginning-of-file)
        (set-mark)
        (setq n 0)
        (error-occured 
            (search-forward "\n\n")
            (backward-character)
            (narrow-region)
            (beginning-of-file)
            (while (! (eobp))
                   (if (looking-at "^Received: ")
                       (&mh-kill-header)
                       (looking-at "^Message-id: ")
                       (&mh-kill-header)
                       (looking-at "^Resent-")
                       (&mh-kill-header)
                       (looking-at "^Remailed-")
                       (&mh-kill-header)
                       (looking-at "^Via: ")
                       (&mh-kill-header)
                       (looking-at "^Mail-from: ")
                       (&mh-kill-header)
                       (next-line)
                   )
            )
            (beginning-of-file)
            (error-occured (replace-string ".ARPA" ""))
            (beginning-of-file)
            (error-occured 
                (re-search-forward "^From:")
                (&mh-kill-header)
                (beginning-of-file)
                (yank-from-killbuffer) (setq n (- n 1))
            )
            (error-occured 
                (re-search-forward "^To:")
                (&mh-kill-header)
                (beginning-of-file)
                (yank-from-killbuffer) (setq n (- n 1))
            )
            (widen-region)
        )
        n
    )

    (&mh-kill-header
        (beginning-of-line) (set-mark)
        (next-line)
        (while (| (= (following-char) ' ') (= (following-char) '\t'))
               (next-line) (beginning-of-line)
        )
        (delete-to-killbuffer)
        (setq n (+ n 1))
    )
)
