; Emacs Scribe bibliography entry package - John A. Nestor March 1982
; 
; The following functions expedite the entry of the various bibliography
; types supported by Scribe.

(defun 
    (get-keypair field		; construct an "attribute=value" line
	(setq field (get-tty-string 
			(concat 
				(arg 1 "bogus1")
				":"))
	)
	(if (!= field "")
	    (insert-string 
		(concat ",\n\t" (arg 1 "bogus2") "=" """" field """")
	    )
	)
    )
)




(defun 				; generate an @article bib entry
    (@article
	(newline)
	(newline)
	(insert-string "@Article(")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Author")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "Journal")
	(get-keypair "Volume")
	(get-keypair "Number")
	(get-keypair "Pages")
	(get-keypair "Month")
	(get-keypair "Year")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))


(defun 				; generate an @book bib entry
    (@book
	(newline)
	(newline)
	(insert-string "@Book(")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Author")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "Publisher")
	(get-keypair "Address")
	(get-keypair "Series")
	(get-keypair "Volume")
	(get-keypair "Year")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))


(defun 				; generate an @Booklet bib entry
    (@booklet
	(newline)
	(newline)
	(insert-string "@Book(")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Author")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "HowPublished")
	(get-keypair "Address")
	(get-keypair "Year")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))


(defun 				; generate an @InBook bib entry
    (@inbook
	(newline)
	(newline)
	(insert-string "@InBook(")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Author")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "Chapter")
	(get-keypair "Pages")
	(get-keypair "Publisher")
	(get-keypair "Address")
	(get-keypair "Series")
	(get-keypair "Volume")
	(get-keypair "Year")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))


(defun 				; generate an @InCollection bib entry
    (@incollection
	(newline)
	(newline)
	(insert-string "@InCollection(")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Author")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "BookTitle")
	(get-keypair "Chapter")
	(get-keypair "Pages")
	(get-keypair "Editor")
	(get-keypair "Publisher")
	(get-keypair "Address")
	(get-keypair "Year")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))


(defun 				; generate an @InProceedings bib entry
    (@inproceedings
	(newline)
	(newline)
	(insert-string "@InProceedings(")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Author")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "Organization")
	(get-keypair "BookTitle")
	(get-keypair "Editor")
	(get-keypair "Address")
	(get-keypair "Pages")
	(get-keypair "Month")
	(get-keypair "Year")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))

(defun 				; generate a @Manual bib entry
    (@manual
	(newline)
	(newline)
	(insert-string "@Manual(")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Author")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "Edition")
	(get-keypair "Organization")
	(get-keypair "Address")
	(get-keypair "Year")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))

(defun 				; generate a @MastersThesis bib entry
    (@mastersthesis
	(newline)
	(newline)
	(insert-string "@MastersThesis(")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Author")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "School")
	(get-keypair "Month")
	(get-keypair "Year")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))


(defun 				; generate a @Misc bib entry
    (@misc
	(newline)
	(newline)
	(insert-string "@Misc(")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Author")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "HowPublished")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))


(defun 				; generate a @PhDThesis bib entry
    (@phdthesis
	(newline)
	(newline)
	(insert-string "@PhDThesis(")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Author")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "School")
	(get-keypair "Month")
	(get-keypair "Year")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))

(defun 				; generate a @Proceedings bib entry
    (@proceedings
	(newline)
	(newline)
	(insert-string "@Proceedings(")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Organization")
	(get-keypair "Editor")
	(get-keypair "Publisher")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "Address")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))


(defun 				; generate a @TechReport bib entry
    (@techreport
	(newline)
	(newline)
	(insert-string "@TechReport(")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Author")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "Institution")
	(get-keypair "Number")
	(get-keypair "Type")
	(get-keypair "Month")
	(get-keypair "Year")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))


(defun 				; generate a @unpublished bib entry
    (@unpublished
	(newline)
	(newline)
     	(insert-string "@Unpublished")
	(insert-string (get-tty-string "CodeWord:"))
	(get-keypair "Author")
	(get-keypair "Key")
	(get-keypair "Title")
	(get-keypair "Note")
	(insert-string ")")
	(newline)))



; Mode setup and related junk

(defun 				; set up Scribe-Bib mode
    (scribe-bib-mode
	(remove-all-local-bindings)
	(setq mode-string "Scribe-Bib")
	(novalue)))
	
