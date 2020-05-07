@Section(spell -- a simple spelling corrector)
@index(spell)
The spell package implements the single function @i[spell].  It provides a
simple facility for doing spelling correction.  If you invoke @i[spell] it
will scan your file looking for spelling errors, then it will go through a
dialogue to let you fix them up.  For each misspelled word @Value(Emacs)
will show you the word, some context around it and ask you what to do.  If
you type `e' or `^G' the spelling corrector will exit.  If you type ` ' it
will ignore the word.  If you type `r' it will ask for the text to use in
replacing the word and perform a query-replace.
@p[Bug:] This uses the Unix @i[spell] command which believes that its input
is a source for the Unix standard text formatter troff/nroff;
Spell misbehaves on Scribe .mss files.
