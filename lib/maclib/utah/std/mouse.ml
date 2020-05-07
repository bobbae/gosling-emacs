; Support for the mouse on the PERQ

(defun (mouse-set-dot but x y
	   (setq but (get-tty-character))
	   (setq x (- (get-tty-character) 33))
	   (setq y (- (get-tty-character) 33))
	   (move-dot-to-x-y x y)
	   (if (= but '0') (button-0)
	       (= but '1') (button-1)
	       (= but '2') (button-2)
	       (button-3))
       ))

(defun (mouse-set-mark
	   (set-mark)
	   (message "Mark set")))

(bind-to-key "mouse-set-dot" "\eM")
(define-string-macro "button-0" "\eA")
(define-string-macro "button-1" "\eB")
(define-string-macro "button-2" "\eC")
(define-string-macro "button-3" "\eD")
(bind-to-key "next-page" "\eA")
(bind-to-key "mouse-set-mark" "\eB")
(bind-to-key "previous-page" "\eC")
(bind-to-key "novalue" "\eD")
(send-string-to-terminal "\e\035\061")
