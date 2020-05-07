@Section(scribe -- weak assistance for dealing with Scribe documents)
Scribe mode binds @i[justify-paragraph] to @b[ESC-j], defines
@i[appply-look] and binds it to @b[ESC-l], turns on autofill, sets the right
margin to 77 and updates the LastEditDate to the current date.

If the string ``LastEditDate="'' exists somewhere in the first 2000
characters of the document then then the region extending from it to the
next `"' is replaced by the current date and time.  You're intended to stick
in your document something like:
@example[@@String(LastEditDate="Sat Nov 28 11:17:29 1981")]
@Value(Emacs) will automatically maintain the date.  The date will only
change in the file you make some changes, the mere act of starting
scribe-mode does not cause the date change to be permanent.

@i[Apply-look] reads a single character and then surrounds the current word
with ``@@@i[c]['' and ``]''.  So, if you've just typed ``begin'', typing
@b[ESC-l-i] will change it to ``@@i[begin]'', which appears in the document
as ``@i[begin]''.  This use of the word ``look'' comes from the @i[Bravo]
text editor.
