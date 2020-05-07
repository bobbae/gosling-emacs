all:	emacs.press
emacs.press: commands.mss variables.mss introduction.mss hints.mss \
	basics.mss emacs.mss process.incl database.incl database.mss \
	emacsm.mak mlisp.mss
	scribe emacs.mss/device:dover;mv emacs.cont contents.mss
emacs.doc: commands.mss variables.mss introduction.mss hints.mss \
	basics.mss emacs.mss process.incl database.incl database.mss \
	emacsm.mak mlisp.mss
	scribe emacs/device:pagedfile;mv emacs.lcnt lcontents.mss
process.incl: commands.mss variables.mss
	extract process>process.incl
database.incl: commands.mss variables.mss
	extract database>database.incl
