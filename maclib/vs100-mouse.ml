(defun
    (move-vs100-cursor savest b x y
	(setq savest stack-trace-on-error)
	(setq stack-trace-on-error 0)
	(setq b (- (get-tty-character) 32))
	(setq x (- (get-tty-character) 32))
	(setq y (- (get-tty-character) 32))
	(if
	   (error-occured (do-edit-action b x y))
	   (scroll-window b x y)
	)
	(backward-character)(forward-character)
	(setq stack-trace-on-error savest)
    )
)

(bind-to-key "move-vs100-cursor" "\e[M")
