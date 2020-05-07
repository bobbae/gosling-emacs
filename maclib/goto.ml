(defun

    ;***************************************************************
    ; goto-line
    ; - moves cursor to beginning of indicated line.
    ; - line number is taken from prefix if provided,
    ;   is prompted for otherwise.
    ; - first line of file is line 1
    (goto-line line
	(if prefix-argument-provided
	    (setq line prefix-argument)
	    (setq line (arg 1 ": goto-line "))
	)
	(beginning-of-file)
	(if (> line 1)
	    (provide-prefix-argument
		(- line 1)
		(next-line)
	    )
	)
	(beginning-of-line)
	(novalue)
    )

    ;***************************************************************
    ; goto-percent
    ; - moves cursor past indicated percentage of the buffer.
    ; - percentage is taken from prefix if provided,
    ;   is prompted for otherwise.
    ; - (goto-percent n) goes to the character closest to the
    ;   beginning of the buffer that is reported as n% in the
    ;   status line.  This is 2 characters further into the
    ;   buffer than you'd expect.  As a result, (goto-percent 0)
    ;   goes to character 1 in the file, since I didn't feel like
    ;   fixing that special case.
    ; - (goto-percent 100) goes to the end of the buffer.
    ; - remember that the position of the first character
    ;   in the buffer is 1.
    (goto-percent percent
	(if prefix-argument-provided
	    (setq percent prefix-argument)
	    (setq percent (arg 1 ": goto-percent "))
	)
	(goto-character (+ (/ (* (buffer-size) percent) 100) 2))
	(novalue)
    )
)
