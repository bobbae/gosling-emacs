(progn
;;; Pretty Brain Damaged at this point!
(defun
    (electric-pascal-mode
	(use-abbrev-table "Pascal")
	(use-syntax-table "Pascal")
	(Do-Pascal-Bindings)
	(setq mode-string "philips' pascal"))

    (Make-Pascal-Abbrevs
	(use-abbrev-table "Pascal")
	(define-local-abbrev "and" "AND")
	(define-local-abbrev "array" "ARRAY")
	(define-local-abbrev "begin" "BEGIN")
	(define-local-abbrev "boolean" "BOOLEAN")
	(define-local-abbrev "logical" "BOOLEAN")
	(define-local-abbrev "cand" "CAND")
	(define-local-abbrev "case" "CASE")
	(define-local-abbrev "chr" "CHR")
	(define-local-abbrev "const" "CONST")
	(define-local-abbrev "cor" "COR")
	(define-local-abbrev "div" "DIV")
	(define-local-abbrev "do" "DO")
	(define-local-abbrev "downto" "DOWNTO")
	(define-local-abbrev "else" "ELSE")
	(define-local-abbrev "end" "END")
	(define-local-abbrev "exit" "EXIT")
	(define-local-abbrev "exports" "EXPORTS")
	(define-local-abbrev "false" "FALSE")
	(define-local-abbrev "file" "FILE")
	(define-local-abbrev "for" "FOR")
	(define-local-abbrev "forward" "FORWARD")
	(define-local-abbrev "from" "FROM")
	(define-local-abbrev "fun" "FUNCTION")
	(define-local-abbrev "function" "FUNCTION")
	(define-local-abbrev "get" "GET")
	(define-local-abbrev "goto" "GOTO")
	(define-local-abbrev "if" "IF")
	(define-local-abbrev "imports" "IMPORTS")
	(define-local-abbrev "in" "IN")
	(define-local-abbrev "input" "INPUT")
	(define-local-abbrev "integer" "INTEGER")
	(define-local-abbrev "label" "LABEL")
	(define-local-abbrev "long" "LONG")
	(define-local-abbrev "mod" "MOD")
	(define-local-abbrev "module" "MODULE")
	(define-local-abbrev "new" "NEW")
	(define-local-abbrev "nil" "NIL")
	(define-local-abbrev "null" "NIL")
	(define-local-abbrev "not" "NOT")
	(define-local-abbrev "of" "OF")
	(define-local-abbrev "or" "OR")
	(define-local-abbrev "ord" "ORD")
	(define-local-abbrev "otherwise" "OTHERWISE")
	(define-local-abbrev "output" "OUTPUT")
	(define-local-abbrev "packed" "PACKED")
	(define-local-abbrev "private" "PRIVATE")
	(define-local-abbrev "proc" "PROCEDURE")
	(define-local-abbrev "procedure" "PROCEDURE")
	(define-local-abbrev "program" "PROGRAM")
	(define-local-abbrev "put" "PUT")
	(define-local-abbrev "read" "READ")
	(define-local-abbrev "readln" "READLN")
	(define-local-abbrev "real" "REAL")
	(define-local-abbrev "record" "RECORD")
	(define-local-abbrev "repeat" "REPEAT")
	(define-local-abbrev "reset" "RESET")
	(define-local-abbrev "rewrite" "REWRITE")
	(define-local-abbrev "set" "SET")
	(define-local-abbrev "string" "STRING")
	(define-local-abbrev "text" "TEXT")
	(define-local-abbrev "then" "THEN")
	(define-local-abbrev "to" "TO")
	(define-local-abbrev "true" "TRUE")
	(define-local-abbrev "type" "TYPE")
	(define-local-abbrev "until" "UNTIL")
	(define-local-abbrev "var" "VAR")
	(define-local-abbrev "while" "WHILE")
	(define-local-abbrev "with" "WITH")
	(define-local-abbrev "write" "WRITE")
	(define-local-abbrev "writeln" "WRITELN")
    ) ;;; End of Make-Pascal-Abbrevs

    (Do-Pascal-Bindings
	(local-bind-to-key "Enter-Comment-Mode" '{')
	(local-bind-to-key "Leave-Comment-Mode" '}')
	(local-bind-to-key "Enter-Fuzzy-Comment" '*')
	(local-bind-to-key "End-Fuzzy-Comment" ')')
	(local-bind-to-key "Toggle-Comment-Mode" 39) ; Single Quote
    ) ;;; End of Do-Pascal-Bindings

    (Toggle-Comment-Mode
	(if (= abbrev-mode 0)
	    (set "abbrev-mode" 1)
	    (set "abbrev-mode" 0))
	(insert-character (last-key-struck))
    ) ;;; End of Toggle-Comment-Mode

    (Enter-Comment-Mode
	(set "abbrev-mode" 0)
	(insert-character (last-key-struck))
    ) ;;; End of Enter-Comment-Mode

    (Leave-Comment-Mode
	(set "abbrev-mode" 1)
	(insert-character (last-key-struck))
    ) ;;; End of Leave-Comment-Mode

    (Enter-Fuzzy-Comment last-key prev-char
	(setq last-key (last-key-struck))
	(setq prev-char (preceding-char))
	(if (& (= last-key  42)		; 42 = Asterisk
	       (= prev-char 40))	; 40 = open paren
	    (progn
		(set "abbrev-mode" 0)
		(insert-string "*"))
	    (insert-character last-key)))

    (End-Fuzzy-Comment last-key prev-char
	(setq last-key (last-key-struck))
	(setq prev-char (preceding-char))
	(if (& (= last-key  41)		; 41 = close paren
	       (= prev-char 42))	; 42 = Asterisk
	    (set "abbrev-mode" 1))
	(insert-character last-key))
	
    (Pascal-Skeleton name type Prompt colno
	(setq Prompt ": Pascal-Skeleton ")
	(setq name (get-tty-string (concat Prompt "name: ")))
	(if (= name "")
	    (error-occured "Aborted."))
	(setq colno (current-column))
	(setq type (get-tty-string (concat Prompt name " Result: ")))
	(if (= type "")
	    (progn pos 				; We have a procedure
		(insert-character 10)(to-col colno)
		(insert-string (concat "PROCEDURE " name ))
		(save-excursion
		    (insert-string ";")
		    (insert-character 10)(to-col colno)
		    (insert-string "BEGIN")
		    (insert-character 10)(to-col colno)
		    (insert-string (concat "END; (* " name " *)"))
		    (insert-character 10)))
	    (progn				; We have a function
		(insert-character 10)(to-col colno)
		(insert-string (concat "FUNCTION " name))
		(save-excursion
		    (insert-string (concat ": " type ";"))
		    (insert-character 10)(to-col colno)
		    (insert-string "VAR")
		    (insert-character 10)(to-col (+ colno 4))
		    (insert-string (concat "Answer: " type ";"))
		    (insert-character 10)(to-col colno)
		    (insert-string "BEGIN")
		    (insert-character 10)(to-col (+ colno 4))
		    (insert-string (concat name " := Answer;"))
		    (insert-character 10)(to-col colno)
		    (insert-string (concat "END; (* " name " *)"))
		    (insert-character 10))))
    );;; End of Pascal-Skeleton


) ;;; End of Massive Defun
    (Make-Pascal-Abbrevs)
    (electric-pascal-mode)
    (use-syntax-table "Pascal")
    (modify-syntax-entry "w    _")
)
