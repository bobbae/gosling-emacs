(load "utah.ml")

(load "time.ml")
(time)

; Jump the window the minimum amount when falling off the screen bottom.
(setq scroll-step 1)

; Make a 2-line minibuffer at the bottom of the screen, so it can scroll.
(save-excursion
    (pop-to-buffer "  Minibuf")
    (enlarge-window)
)

; M-# descends to c-shell under gemacs, C-M-z (pop-level) returns.
(bind-to-key "push-to-csh" "\e#")

; M-@ saves screen layout for return by pop-level.
(defun
    (push-level
	 (save-window-excursion (recursive-edit))
    )
)
(bind-to-key "push-level" "\e@")

(defun
    (teach-emacs
	(visit-file "/usr/local/lib/emacs/maclib/TEACH-EMACS")
	(delete-other-windows)
    )
)
