@begin(text,font SmallBodyFont,above 0,below 0,boxed,columns 2,
	ColumnMargin 0.25in, ColumnWidth 3.75in, LineWidth 3.5in,
	spacing=1,nofill,spread=0,Blanklines ignored)
@Define(RefTitle, use P, use UX, break around, above .25)
@Define(Key=B)
@begin(description, spread 0, LeftMargin +8, Indent -8)
@begin(Reftitle,above 0,centered)
Unix Emacs Reference Card
@end(reftitle)
@RefTitle(SOME NECESSARY NOTATION)
@tabs(+4,+4,+4,+4)
@\Any ordinary character goes into the buffer (no insert command needed).
Commands are all control characters or other characters prefixed by Escape or
a control-X. Escape is sometimes called Meta or Altmode in EMACS.

@Key[^]@\A control character.  ^F means "control F".

@Key[ESC-]@\A two-character command sequence where the first character is
Escape.  ESC-F means "ESCAPE then F".

@Key[ESC-X string]@\A command designated "by hand".  "ESC-x read-file" means:
type "Escape", then "x", then "read-file", then <cr>.

@Key[dot]@\EMACS term for cursor position in current buffer.

@Key[mark]@\An invisible set position in the buffer used by region commands.

@Key[region]@\The area of the buffer between the dot and mark.

@RefTitle(CHARACTER OPERATIONS)

@Key[^B]@\Move left (Back)

@Key[^F]@\Move right (Forward)

@Key[^P]@\Move up (Previous)

@Key[^N]@\Move down (Next)

@Key[^D]@\Delete right

@Key[^H or BS or DEL or RUBOUT]@\Delete left

@Key[^T]@\Transpose previous 2 characters (ht_ -> th_)

@Key[^Q]@\Literally inserts (quotes) the next character typed (e.g. ^Q-^L)

@Key[^U-n]@\Provide a numeric argument of n to the command that follows
(n defaults to 4, eg. try ^U-^N and ^U-^U-^F)

@Key[^M or CR]@\newline

@Key[^J or NL]@\newline followed by an indent

@RefTitle(WORD OPERATIONS)

@Key[ESC-b]@\Move left (Back)

@Key[ESC-f]@\Move right (Forward)

@Key[ESC-d]@\Delete word right

@Key[ESC-h]@\Delete word left

@Key[ESC-c]@\Capitalize word

@Key[ESC-l]@\Lowercase word

@Key[ESC-u]@\Uppercase word

@Key[ESC-^]@\Invert case of word

@RefTitle(LINE OPERATIONS)

@Key[^A]@\Move to the beginning of the line

@Key[^E]@\Move to the end of the line

@Key[^O]@\Open up a line for typing

@Key[^K]@\Kill from dot to end of line (^Y yanks it back at dot)

@RefTitle(PARAGRAPH OPERATIONS)

@Key[ESC-[]@\Move to beginning of the paragraph

@Key<ESC-]>@\Move to end of the paragraph

@Key[ESC-j]@\Justify the current paragraph

@RefTitle(GETTING OUT)

@Key[^X-^S]@\Save the file being worked on

@Key[^X-^W]@\Write the current buffer into a file with a different name

@Key[^X-^M]@\Write out all modified files

@Key[^X-^F]@\Write out all modified files and exit

@Key[^C or ESC-^C or ^X-^C]@\Finish by exiting to the shell

@Key[^_]@\Recursively push (escape) to a new shell

@RefTitle(SCREEN AND SCREEN OPERATIONS)

@Key[^V]@\Show next screen page

@Key[ESC-V]@\Show previous screen page

@Key[^L]@\Redisplay screen

@Key[^Z]@\Scroll screen up

@Key[ESC-Z]@\Scroll screen down

@Key[ESC-!]@\Move the line dot is on to top of the screen

@Key[ESC-,]@\Move cursor to beginning of window

@Key[ESC-.]@\Move cursor to end of window

@Key[^X-2]@\Split the current window in two windows (same buffer shown in each)

@Key[^X-1]@\Resume single window (using current buffer)

@Key[^X-d]@\Delete the current window, giving space to window below

@Key[^X-n]@\Move cursor to next window

@Key[^X-p]@\Move cursor to previous window

@Key[ESC-^V]@\Display the next screen page in the other window

@Key[^X-^Z]@\Shrink window

@Key[^X-z]@\Enlarge window

@RefTitle(BUFFER AND FILE OPERATIONS)

@Key[^Y]@\Yank back the last thing killed (kill and delete are different)

@Key[^X-^V]@\Get a file into a buffer for editing

@Key[^X-^R]@\Read a file into current buffer, erasing old contents

@Key[^X-^I]@\Insert file at dot

@Key[^X-^O]@\Select a different buffer (it must already exist)

@Key[^X-B]@\Select a different buffer (it need not pre-exist)

@Key[^X-^B]@\Display a list of available buffers

@Key[ESC-^Y]@\Insert selected buffer at dot

@Key[ESC-<]@\Move to the top of the current buffer

@Key[ESC->]@\Move to the end of the current buffer

@RefTitle(HELP AND HELPER FUNCTIONS)

@Key[^G]@\Abort anything at any time.

@Key[ESC-?]@\Show every command containing string (try ESC-? para)

@key[ESC-X info]@\Browse through the Emacs manual.

@key[^X^U]@\Undo the effects of previous commands.

@RefTitle(SEARCH)

@Key[^S]@\Search forward

@Key[^R]@\Search backward

@RefTitle(REPLACE)

@Key[ESC-r]@\Replace one string with another

@Key[ESC-q]@\Query Replace, one string with another

@RefTitle(REGION OPERATIONS)

@Key[^@@]@\Set the mark

@Key[^X-^X]@\Interchange dot and mark (i.e. go to the other end of the region)

@Key[^W]@\Kill region (^Y yanks it back at dot)

@RefTitle(MACRO OPERATIONS)

@Key[^X-(]@\Start remembering keystrokes, ie. start defining a keyboard macro

@Key[^X-)]@\Stop remembering keystrokes, ie. end the definition

@Key[^X-e]@\Execute remembered keystrokes, ie. execute the keyboard macro

@RefTitle<COMPILING (MAKE) OPERATIONS.>

@Key[^X-^E]@\Execute the "make" (or other) command, saving output in a buffer

@Key[^X-^N]@\Go to the next error in the file

@Key[^X-!]@\Execute the given command, saving output in a buffer

@RefTitle(MAIL)

@Key[^X-r]@\Read mail.

@Key[^X-m]@\Send mail
@end(description)
@end(text)
