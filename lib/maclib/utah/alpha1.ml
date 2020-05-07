;Alpha1 specific gemacs initialization.
(error-occured
    (load "psl-abbrev.ml"))	; PSL template fns
(error-occured
    (load "geom-abbr.ml")	; "geom" mode abbreviations.
    (load "geom-keys.ml")	; Key bindings for shapedit.

    (declare-global rlisp-pgm)	; The rlisp to start;
    (setq-default rlisp-pgm "/usr/local/graphics/shapedit")
    (declare-global geom-screen)	; Display device to use.
    (setq-default geom-screen "mps2")

)
(error-occured (load "dabbrevs.ml"))	; For long variable names.

(setq match/recognize 1)	; Immediate expansion of filenames on blank.

(load "time.ml")
(time)

; Jump the window the minimum amount when falling off the screen bottom.
(setq scroll-step 1)

; Make a 2-line minibuffer at the bottom of the screen, so it can scroll.
(save-excursion
    (pop-to-buffer "  Minibuf")
    (enlarge-window)
)

;  Set up vt100 key bindings.
(if (= (getenv "TERM") "vt100") (load "vt100.ml"))
