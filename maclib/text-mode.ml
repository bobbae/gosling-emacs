(defun
    (text-mode
	(remove-all-local-bindings)
	(local-bind-to-key "justify-paragraph" (+ 128 'j'))
	(setq right-margin 75)
	(setq mode-string "Text")
	(setq case-fold-search 1)
	(use-syntax-table "text-mode")
	(use-abbrev-table "text-mode")
	(setq left-margin 1)
	(novalue)
    )
)

