@command(name="!", key="[unbound]")
(! @i[e]@-[1]) MLisp function that returns not @i[e]@-[1].

@command(name="!=", key="[unbound]")
(!= @i[e]@-[1] @i[e]@-[2]) MLisp function that returns true
iff @i[e]@-[1] != @i[e]@-[2].

@command(name="%", key="[unbound]")
(% @i[e]@-[1] @i[e]@-[2]) MLisp function that returns
@i[e]@-[1] % @i[e]@-[2] (the C mod operator).

@command(name="&", key="[unbound]")
(& @i[e]@-[1] @i[e]@-[2]) MLisp function that returns
@i[e]@-[1] & @i[e]@-[2].

@command(name="*", key="[unbound]")
(* @i[e]@-[1] @i[e]@-[2]) MLisp function that returns
@i[e]@-[1] * @i[e]@-[2].

@command(name="+", key="[unbound]")
(+ @i[e]@-[1] @i[e]@-[2]) MLisp function that returns
@i[e]@-[1] + @i[e]@-[2].

@command(name="-", key="[unbound]")
(- @i[e]@-[1] @i[e]@-[2]) MLisp function that returns
@i[e]@-[1] - @i[e]@-[2].

@command(name="/", key="[unbound]")
(/ @i[e]@-[1] @i[e]@-[2]) MLisp function that returns
@i[e]@-[1] / @i[e]@-[2].

@command(name="<", key="[unbound]")
(< @i[e]@-[1] @i[e]@-[2]) MLisp function that returns true
iff @i[e]@-[1] < @i[e]@-[2].

@command(name="<<", key="[unbound]")
(<< @i[e]@-[1] @i[e]@-[2]) MLisp function that returns
@i[e]@-[1] << @i[e]@-[2]  (the C shift left operator).

@command(name="<=", key="[unbound]")
(<= @i[e]@-[1] @i[e]@-[2]) MLisp function that returns true
iff @i[e]@-[1] <= @i[e]@-[2].

@command(name="=", key="[unbound]")
(= @i[e]@-[1] @i[e]@-[2]) MLisp function that returns true
iff @i[e]@-[1] = @i[e]@-[2].

@command(name=">", key="[unbound]")
(> @i[e]@-[1] @i[e]@-[2]) MLisp function that returns true
iff @i[e]@-[1] > @i[e]@-[2].

@command(name=">=", key="[unbound]")
(>= @i[e]@-[1] @i[e]@-[2]) MLisp function that returns true
iff @i[e]@-[1] >= @i[e]@-[2].

@command(name=">>", key="[unbound]")
(>> @i[e]@-[1] @i[e]@-[2]) MLisp function that returns
@i[e]@-[1] >> @i[e]@-[2]  (the C shift right operator).

@command(name="^", key="[unbound]")
(^ @i[e]@-[1] @i[e]@-[2]) MLisp function that returns
@i[e]@-[1] ^ @i[e]@-[2]  (the C XOR operator).

@command(name="active-process", key="[unbound]")
(active-process) -- 
Returns the name of the active process as defined in the section describing
the process mechanism.

@command(name="append-region-to-buffer", key="[unbound]")
Appends the region between dot and mark to the named buffer.
Neither the original text in the destination buffer nor the text in the
region between dot and mark will be disturbed.

@command(name="append-to-file", key="[unbound]")
Takes the contents of the current buffer and appends it to the named file.
If the files doesn't exist, it will be created.

@command(name="apropos", key="ESC-?")
Prompts for a keyword and then prints a list of those commands whose short
description contains that keyword.  For example, if you forget which
commands deal with windows, just type "@b[ESC-?]@t[window]@b[ESC]".

@command(name="arg", key="[unbound]")
 @w<(arg i [prompt])> evaluates to the i'th argument of the invoking
function or prompts for it if called interactively [the prompt is optional,
if it is omitted, the function cannot be called interactivly]. For example,
@example<(arg 1 "Enter a number: ")>
Evaluates to the value of the first argument of the current function, if the
current function was called from MLisp.  If it was called interactively then
it is prompted for. As another example, given:
@example<(defun (foo (+ (arg 1 "Number to increment? ") 1)))>
then (foo 10) returns 11, but typing "ESC-Xfoo" causes emacs to ask "Number
to increment? ".  Language purists will no doubt cringe at this rather
primitive parameter mechanism, but what-the-hell...  it's amazingly powerful.

@command(name="argc", key="[unbound]")
Is an MLisp function that returns the number of arguments that were passed
to @Value(Emacs) when it was invoked from the Unix shell. If either @i[argc]
or @i[argv] are called early enough then @Value(Emacs)'s startup action of
visiting the files named on the command line is suppressed.

@command(name="argument-prefix", key="^U")
@index(Prefix arguments)
When followed by a string of digits @b[^U] causes that string of digits to
be interpreted as a numeric argument which is generally a repetition count
for the following command.  For example, @b[^U10^N] moves down 10 lines
(the 10'th next).  A string of @i[n] @b[^U]'s followed by a command
provides an argument to that command of 4@+[@i[n]].  For example, @b[^U^N]
moves down four lines, and @b[^U^U^N] moves down 16. Argument-prefix should
 @i[never] be called from an MLisp function.

@command(name="argv", key="[unbound]")
(argv @i[i]) returns the @i[i]th argument that was passed to @Value(Emacs)
when it was invoked from the Unix Shell.  If @Value(Emacs) were invoked as
@w["emacs blatto"] then @w[(argv 1)] would return the string "blatto".
If either argc or argv are called early enough then @Value(Emacs)'s startup
action of visiting the files named on the command line is suppressed.

@command(name="auto-execute", key="[unbound]")
Prompt for and remember a command name and a file name pattern.  When a
@Index[visit-file]
@Index[read-file]
file is read in via @i[visit-file] or @i[read-file] whose name matches
the given pattern the given command will be executed.  The command is
generally one which sets the mode for the buffer.  Patterns must be of the
form "*string" or "string*":  "*string" matches any filename whose suffix
is "string"; "string*" matches any filename prefixed by "string".  For
example, @w[@b[auto-execute c-mode *.c]] will put @Value(Emacs) into C mode
for all files with the extension ".c".

@command(name="autoload", key="[unbound]")
@w[@b[(autoload command file)]] defines the associated @i[command] to be
autoloaded from the named @i[file].  When an attempt to execute the command
is encountered, the file is @b[load]ed and then the execution is attempted
again.  the loading of the file must have redefined the command.
Autoloading is useful when you have some command written in MLisp but you
don't want to have the code loaded in unless it is actually needed.  For
example, if you have a function named box-it in a file named box-it.ml, then
the command @w[@b[(autoload "box-it" "box-it.ml")]] will define the box-it
command, but won't load its definition from box-it.ml.  The loading will
happen when you try to execute the box-it command.

@command(name="backward-balanced-paren-line", key="[unbound]")
Moves dot backward until either
@begin(itemize)
The beginning of the buffer is reached.

An unmatched open parenthesis, '(', is encountered.  That is, unmatched
between there and the starting position of dot.

The beginning of a line is encountered at "parenthesis level zero".  That
is, without an unmatched ')' existing between there and the starting
position of dot.
@end(itemize)
The definitions of parenthesis and strings from the syntax table for the
current buffer are used.

@command(name="backward-character", key="^B")
Move dot backwards one character. Ends-of-lines and tabs each count as one
character.  You can't move back to before the beginning of the buffer.

@command(name="backward-paragraph", key="ESC-[")
Moves to the beginning of the current or previous paragraph.  Blank lines,
and Scribe and nroff command lines separate paragraphs and are not parts of
paragraphs.

@command(name="backward-paren", key="[unbound]")
Moves dot backward until an unmatched open parenthesis, '(', or the
beginning of the buffer is found.  This can be used to aid in skipping over
Lisp S-expressions.  The definitions of parenthesis and strings from the
syntax table for the current buffer are used.

@command(name="backward-sentence", key="ESC-A")
Move dot backward to the beginning of the preceeding sentence; if dot is in
the middle of a sentence, move to the beginning of the current sentence.
Sentences are seperated by a `.', `?' or `!' followed by whitespace.

@command(name="backward-word", key="ESC-B")
If in the middle of a word, go to the beginning of that word, otherwise go
to the beginning of the preceding word.  A word is a sequence of
alphanumerics.

@command(name="baud-rate", key="[unbound]")
An MLisp function that returns what @Value(Emacs) thinks is the baud rate of
the communication line to the terminal.  The baud rate is (usually) 10 times
the number of characters transmitted ber second.  (Baud-rate) can be used
@Index[display-file-percentage]
for such things as conditionally setting the display-file-percentage
variable in your @Value(Emacs) profile:
@w[(setq display-file-percentage (> (baud-rate) 600))]
@command(name="beginning-of-file", key="ESC-<")
Move dot to just before the first character of the current buffer.

@command(name="beginning-of-line", key="^A")
Move dot to the beginning of the line in the current buffer that
contains dot; that is, to just after the preceeding end-of-line or the
beginning of the buffer.

@command(name="beginning-of-window", key="ESC-,")
Move dot to just in front of the first character of the first line
displayed in the current window.

@command(name="bind-to-key", key="[unbound]")
Bind a named macro or procedure to a given key.  All future hits on the
key will cause the named macro or procedure to be called.  The key may
be a control key, and it may be prefixed by @b[^X] or @b[ESC].  For
example, if you want @b[ESC-=] to behave the way
@w[@b[ESC-X]@i[print]] does, then typing
@w[@b[ESC-X]@i[bind-to-key print ]@b[ESC-=]] will do it.

@command(name="bobp", key="[unbound]")
(bobp) is an MLisp predicate which is true iff dot is at the beginning of
the buffer.

@command(name="bolp", key="[unbound]")
(bolp) is an MLisp predicate which is true iff dot is at the beginning of a
line.

@command(name="buffer-size", key="[unbound]")
(buffer-size) is an MLisp function that returns the number of characters in
the current buffer.

@command(name="c-mode", key="[unbound]")
Incompletely implemented.

@command(name="c=", key="[unbound]")
(c= @i[e]@-[1] @i[e]@-[2]) MLisp function that returns true iff @i[e]@-[1]
is equal to @i[e]@-[2] taking into account the character translations
@Index[case-fold-search]
indicated by case-fold-search.  If word-mode-search is
in effect, then upper case letters are "c=" to their lower case equivalents.

@command(name="case-region-capitalize", key="[unbound]")
Capitalize all the words in the region between dot and mark by making their
first characters upper case and all the rest lower case.

@command(name="case-region-invert", key="[unbound]")
Invert the case of all alphabetic characters in the region
between dot and mark.

@command(name="case-region-lower", key="[unbound]")
Change all alphabetic characters in the region
between dot and mark to lower case.


@command(name="case-region-upper", key="[unbound]")
Change all alphabetic characters in the region
between dot and mark to upper case.

@command(name="case-word-capitalize", key="[unbound]")
Capitalize the current word (the one above or to the left of dot)
by making its first character upper case and all the rest lower case.

@command(name="case-word-invert", key="[unbound]")
Invert the case of all alphabetic characters in the current word
(the one above or to the left of dot).


@command(name="case-word-lower", key="[unbound]")
Change all alphabetic characters in the current word
(the one above or to the left of dot) to lower case.

@command(name="case-word-upper", key="[unbound]")
Change all alphabetic characters in the current word
(the one above or to the left of dot) to upper case.

@command(name="change-current-process", key="[unbound]")
(change-current-process "process-name") -- 
Sets the current process to the one named.

@command(name="change-directory", key="[unbound]")
Changes the current directory (for @Value(Emacs)) to the named directory.
All future file write and reads (@b[^X^S, ^X^V,] etc.) will be interpreted
relative to that directory.

@command(name="char-to-string", key="[unbound]")
Takes a numeric argument and returns a one character string that results
from considering the number as an ascii character.

@command(name="checkpoint", key="[unbound]")
@index[checkpoint-frequency]
Causes all modified buffers with an out of date checkpoint file to be
checkpointed.  This function is normally called automatically every
@i[checkpoint-frequency] keystrokes.

@command(name="Command prefix, also known as META", key="ESC")
The next character typed will be interpreted as a command based on the fact
that it was preceded by @b[ESC].
The name @b[meta] for the @b[ESC] character comes from funny keyboards at
Stanford and MIT that have a Meta-shift key which is used to extend the
ASCII character set.  Lacking a Meta key, we make do with prefixing with
an @b[ESC] character.  You may see (and hear) commands like @b[ESC-V]
referred to as @b[Meta-V].  Sometimes the @b[ESC] key is confusingly
written as @b[$], so @b[ESC-V] would be written as @b[$V].
@b[ESC] is also occasionally referred to as @i[Altmode], from the labeling of
a key on those old favorites, model 33 teletypes.

@command(name="command-prefix", key="^X")
The next character typed will be interpreted as a command based on the fact
that it was preceded by @b[^X].

@command(name="compile-it", key="^X^E")
@i[Make] is a standard Unix program which takes a description of how to
compile a set of programs and compiles them.
The output of @i[make] (and the compilers it calls) is placed in a buffer
which is displayed in a window.  If any errors were encountered, @Value(Emacs)
makes a note of them for later use with @b[^X^N].  Presumably, a data
base has been set up for @i[make] that causes the files which have been
edited to be compiled.  @b[^X^E] then updates the files that have been
changed and @i[make] does the necessary recompilations, and @Value(Emacs) notes
any errors and lets you peruse them with @b[^X^N].

If @b[^X^E] is given a non-zero argument, then rather than just
executing @i[make] @Value(Emacs) will prompt for a Unix command line to
be executed.  Modified buffers will still be written out, and the
output will still go to the @i[Error log] buffer and be parsed as error
messages for use with @b[^X^N].  One of the most useful applications of
this feature involves the @i[grep] program.  "@b[^U^X^E]grep -n MyProc
*.c@b[ESC]" will scan through all C source files looking for the string
"MyProc" (which could be the name of a procedure).  You can then use
@b[^X^N] to step through all places in all the files where the string
was found.  @b[Note:] The version of @i[grep] in my bin directory,
/usr/jag/bin/grep, must be used: it prints line numbers in a format
that is understood by @Value(Emacs).  (ie.  "@i[FileName], line
@i[LineNumber])

@command(name="concat", key="[unbound]")
Takes a set of string arguments and returns their concatenation.

@command(name="continue-process", key="[unbound]")
(continue-process "process-name") -- 
@Index[stop-process]
Continue a process stopped by @i[stop-process].

@command(name="copy-region-to-buffer", key="[unbound]")
Copies the region between dot and mark to the named buffer.
The buffer is emptied before the text is copied into it; the region between
dot and mark is left undisturbed.

@command(name="current-buffer-name", key="[unbound]")
MLisp function that returns the current buffer name as a string.

@command(name="current-column", key="[unbound]")
(current-column) is an MLisp function that returns the printing column
number of the character immediately following dot.

@command(name="current-file-name", key="[unbound]")
MLisp function that returns the file name associated with the current
buffer as a string.  If there is no associated file name, the null string is
returned.

@command(name="current-indent", key="[unbound]")
(current-indent) is an MLisp function the returns the amount of whitespace
at the beginning of the line which dot is in (the printing column number of
the first non-whitespace character).

@command(name="current-process", key="[unbound]")
(current-process) -- 
Returns the name of the current process as defined in the section describing
the process mechanism.

@command(name="current-time", key="[unbound]")
MLisp function that returns the current time of day as a string in the
format described in CTIME(3), with the exception that the trailing newline
will have been stripped off.  @w[(substr (current-time) -4 4)] is the
current year.

@command(name="declare-buffer-specific", key="[unbound]")
@index(setq-default)
@index(set-default)
@index(buffer-specific)
Takes a list of variables and declares them to have @i[buffer-specific]
values.  A buffer-specific variable has a distinct instance for each buffer
in existance and a default value which is used when new buffers are created.
When a buffer-specific variable is assigned a value only the instance
associated with the currently selected buffer is affected.  To set the
default value for a buffer-specific variable, use @i[setq-default] or
 @i[set-default].  Note that if you have a global variable which is
eventually declared buffer-specific then the global value becomes the
default.

@command(name="declare-global", key="[unbound]")
Takes a list of variables and for each that is not already bound a global
binding is created.  Global bindings outlive all function calls.

@command(name="define-buffer-macro", key="[unbound]")
Take the contents of the current buffer and define it as a macro whose name
is associated with the buffer.  This is how one redefines a macro that has
@Index[edit-macro]
been edited using edit-macro.

@command(name="define-global-abbrev", key="[unbound]")
Define (or redefine) an abbrev with the given name for the given phrase in
the global abbreviation table.

@command(name="define-hooked-global-abbrev", key="[unbound]")
@index(define-global-abbrev)
@index(define-local-abbrev)
The commands @i[define-hooked-global-abbrev] and
 @i[define-hooked-local-abbrev] behave exactly as the unhooked versions do
(@i[define-global-abbrev] and @i[define-local-abbrev]) except that they also
associate a named command with the abbrev.  When the abbrev triggers, rather
than replacing the abbreviation with the expansion phrase the hook procedure
is invoked. The character that trigged the abbrev will not have been
inserted, but will be inserted immediatly after the hook procedure returns
[unless the procedure returns 0].  The abbreviation will be the word
immediatly to the left of dot, and the function @i[abbrev-expansion] returns
the@index(abbrev-expansion) phrase that the abbrev would have expanded to.

@command(name="define-hooked-local-abbrev", key="[unbound]")
See the description of @i[define-hooked-global-abbrev].

@command(name="define-keyboard-macro", key="[unbound]")
Give a name to the current keyboard macro.  A keyboard macro is defined by
using the @b[^X(] and @b[^X)] command; define-keyboard-macro takes the
current keyboard macro, squirrels it away in a safe place, gives it a
@Index[define-string-macro]
name, and erases the keyboard macro.  define-string-macro is another way
to define a macro.

@command(name="define-keymap", key="[unbound]")
(define-keymap "mapname") defines a new, empty, keymap with the given name.
See the section on keymaps, @ref(Keymaps) page @pageref(Keymaps), for more
information.

@command(name="define-local-abbrev", key="[unbound]")
Define (or redefine) an abbrev with the given name for the given phrase in
the local abbreviation table.  A local abbrev table must have already been
@Index[use-abbrev-table]
set up with @i[use-abbrev-table].

@command(name="define-string-macro", key="[unbound]")
Define a macro given a name and a body as a string entered in the
minibuffer.  @b[Note:] to get a control character into the body of the
@Index[define-keyboard-macro]
macro it must be quoted with @b[^Q].  define-keyboard-macro is another
way to define a macro.

@command(name="defun", key="[unbound]")
(defun (name expressions... )... ) is an MLisp function that defines a new
MLisp function with the given name and a body composed of the given
expressions.  The value of the function is the value of the last expression.
For example:
@begin(example)
(defun
    (indent-line		; this function just sticks a tab at
	(save-excursion		; the beginning of the current line
	    (beginning-of-line)	; without moving dot.
	    (insert-string "	")
	)
    )
)
@end(example)

@command(name="delete-buffer", key="[unbound]")
Deletes the named buffer.

@command(name="delete-macro", key="[unbound]")
Delete the named macro.

@command(name="delete-next-character", key="^D")
Delete the character immediatly following dot; that is, the character
on which the terminals cursor sits.  Lines may be merged by deleting
newlines.

@command(name="delete-next-word", key="ESC-D")
Delete characters forward from dot until the next end of a word.  If dot is
currently not in a word, all punctuation up to the beginning of the word is
deleted as well as the word.

@command(name="delete-other-windows", key="^X1")
Go back to one-window mode.  Generally useful when @Value(Emacs) has spontaneously
generated a window (as for @b[ESC-?] or @b[^X^B]) and you want to get
rid of it.

@command(name="delete-previous-character", key="^H")
Delete the character immediatly preceding dot; that is, the character
to the left of the terminals cursor.  If you've just typed a character,
@b[^H] (@i(backspace)) will delete it.  Lines may be merged by deleting
newlines.

@command(name="delete-previous-character", key="RUBOUT")
Delete the character immediatly preceding dot; that is, the character
to the left of the terminals cursor.  If you've just typed a character,
@b[RUBOUT] will delete it.
Lines may be merged by deleting newlines.

@command(name="delete-previous-word", key="ESC-H")
If not in the middle of a word, delete characters backwards (to the left)
until a word is found.  Then delete the word to the left of dot.
A word is a sequence of alphanumerics.

@command(name="delete-region-to-buffer", key="ESC-^W")
Wipe (kill, delete) all characters between dot and the mark.  The deleted
text is moved to a buffer whose name is prompted for, which is emptied first.

@command(name="delete-to-killbuffer", key="^W")
Wipe (kill, delete) all characters between dot and the mark.  The deleted
text is moved to the kill buffer, which is emptied first.

@command(name="delete-white-space", key="[unbound]")
Deletes all whitespace characters (spaces and tabs) on either side of
dot.

@command(name="delete-window", key="^XD")
Removes the current window from the screen and gives it's space to it's
neighbour below (or above) and makes the current window and buffer those
of the neighbour.

@command(name="describe-bindings", key="[unbound]")
Places in the @i[Help] window a list of all the keys and the name of the
procedure that they are bound to.  This listing is suitable for printing
and making you own quick-reference card for your own customized version of
@Value(Emacs).

@command(name="describe-command", key="[unbound]")
Uses the Info system to describe some named command.  You will be prompted
in the minibuf for the name of a command and then Info will be invoked to
show you the manual entry describing it.  You can then use Info to browse
around, or simply type @b[^C] to resume editing.

@command(name="describe-key", key="[unbound]")
Describe the given key.  @b[ESC-X]@t[describe-key ]@b[ESC-X] will print
a short descrition of the @b[ESC-X] key.  It tells you the name of the
command to which the key is bound.  To find out more about the command, use
@comref[describe-command].

@command(name="describe-variable", key="[unbound]")
Uses the Info system to describe some named variable.  You will be prompted
in the minibuf for the name of a variable and then Info will be invoked to
show you the manual entry describing it.  You can then use Info to browse
around, or simply type @b[^C] to resume editing.

@command(name="describe-word-in-buffer", key="^X^D")
Takes the word nearest the cursor and looks it up in a data base and prints
the information found.  This data base contains short one-line descriptions
of all of the Unix standard procedures and Franz Lisp standard functions.
The idea is that if you've just typed in the name of some procedure and
can't quite remember which arguments go where, just type @b[^X^D] and
@Value(Emacs) will try to tell you.

@command(name="digit", key="[unbound]")
Heavy wizardry:  you don't want to know.  "digit" should eventually
disappear.

@command(name="dot", key="[unbound]")
(dot) is an MLisp function that returns the number of characters to the left
of dot plus 1 (ie. if dot is at the beginning of the buffer, (dot) returns
1).  The value of the function is an object of type "marker" -- if it is
assigned to a variable then as changes are made to the buffer the variable's
value continues to indicate the same position in the buffer.

@command(name="dump-syntax-table", key="[unbound]")
Dumps a readable listing of a syntax table into a buffer and makes that
buffer visible.

@command(name="edit-macro", key="[unbound]")
Take the body of the named macro and place it in a buffer called @i[Macro
edit].  The name of the macro is associated with the buffer and appears in
the information bar at the bottom of the window.  The buffer may be edited
just like any other buffer (this is, in fact, the intent).  After the macro
@Index[define-buffer-macro]
body has been edited it may be redefined using @i[define-buffer-macro].

@command(name="emacs-version", key="[unbound]")
Returns a string that describes the current @Value(Emacs) version.

@command(name="end-of-file", key="ESC->")
Move dot to just after the last character of the buffer.

@command(name="end-of-line", key="^E")
Move dot to the end of the line in the current buffer that
contains dot; that is, to just after the following end-of-line
or the end of the buffer.

@command(name="end-of-window", key="ESC-.")
Move dot to just after the last character visible in the window.

@command(name="enlarge-window", key="^XZ")
Makes the current window one line taller, and the window below (or the
one above if there is no window below) one line shorter.  Can't be used if
there is only one window on the screen.

@command(name="eobp", key="[unbound]")
(eobp) is an MLisp predicate that is true iff dot is at the end of the
buffer.

@command(name="eolp", key="[unbound]")
(eolp) is an MLisp predicate that is true iff dot is at the end of a line.

@command(name="eot-process", key="[unbound]")
(eot-process "process-name") -- 
Send an EOT to the process.

@command(name="erase-buffer", key="[unbound]")
Deletes all text from the current buffer.  Doesn't ask to make sure if you
really want to do it.

@command(name="erase-region", key="[unbound]")
Erases the region between dot and mark.  It is like
 @comref[delete-to-killbuffer] except that it doesn't move the text to the
kill buffer.

@command(name="error-message", key="[unbound]")
(error-message "string-expressions") Sends the @i[string-expressions] to the
screen as an error message where it will appear at the bottom of the screen.
 @Value(Emacs) will return to keyboard level, unless caught by
@comref[error-occured].

@command(name="error-occured", key="[unbound]")
(error-occured expressions...) executes the given expressions and ignores
their values.  If all executed successfully, error-occured returns false.
Otherwise it returns true and all expressions after the one which
encountered the error will not be executed.

@command(name="exchange-dot-and-mark", key="^X^X")
Sets dot to the currently marked position and marks the old position
of dot.  Useful for bouncing back and forth between two points in a file;
particularly useful when the two points delimit a region of text that is
going to be operated on by some command like @b[^W] (erase region).

@command(name="execute-extended-command", key="ESC-X")
@Value(Emacs) will prompt in the minibuffer (the line at the bottom of the
screen) for a command from the extended set.  These deal with rarely used
features.  Commands are parsed using a Twenex style command interpreter:
you can type @b[ESC] or @b<space> to invoke command completion, or '?' for
@Index(Help facilities)
help with what you're allowed to type at that point.  This doesn't work
if it's asking for a key or macro name.

@command(name="execute-keyboard-macro", key="^XE")
Takes the keystrokes remembered with @b[^X(] and @b[^X)] and treats them as
though they had been typed again.  This is a cheap and easy macro
@Index[define-string-macro]
facility.  For more power, see the define-string-macro,
@Index[define-keyboard-macro]
@Index[bind-to-key]
define-keyboard-macro and bind-to-key commands.

@command(name="execute-mlisp-buffer", key="[unbound]")
Parse the current buffer as as a single MLisp expression and execute it.
This is what is generally used for testing out new functions: stick your
functions in a buffer wrapped in a @i[defun] and use
execute-mlisp-buffer to define them.

@command(name="execute-mlisp-line", key="ESC-ESC")
Prompt for a string, parse it as an MLisp expression and execute it.

@command(name="execute-monitor-command", key="^X!")
Prompt for a Unix command then execute it, placing its output into a buffer
called @i[Command execution] and making that buffer visible in a window.
The command will not be able to read from its standard input (it will be
connected to /dev/null).  For now, there is no way to execute an interactive
subprocess.

@command(name="exit-emacs", key="^C")
Exit @Value(Emacs).  Will ask if you're sure if there are any buffers that
have been modified but not written out.

@command(name="exit-emacs", key="^X^C")
Exit @Value(Emacs).  Will ask if you're sure if there are any buffers that
have been modified but not written out.

@command(name="exit-emacs", key="ESC-^C")
Exit @Value(Emacs).  Will ask if you're sure if there are any buffers that
have been modified but not written out.

@command(name="expand-file-name", key="[unbound]")
Takes a string representing a file name and expands it into an absolute
pathname.  For example, if the current directory is "/usr/frodo" then
@b[@w[(expand-file-name "../bilbo")]] will return "/usr/bilbo".

@command(name="expand-mlisp-variable", key="[unbound]")
Prompts for the name of a declared variable then inserts the name as text
into the current buffer.  This is very handly for typing in MLisp functions.
It's also fairly useful to bind it to a key for easy access.

@command(name="expand-mlisp-word", key="[unbound]")
Prompt for the name of a command then insert the name as text into the
current buffer.  This is very handly for typing in MLisp functions.  It's
also fairly useful to bind it to a key for easy access.

@command(name="extend-database-search-list", key="[unbound]")
(extend-database-search-list dbname filename) adds the given data base file
to the data base search list (dbname).  If the database is already in the
search list then it is left, otherwise the new database is added at the
beginning of the list of databases.

@command(name="fetch-database-entry", key="[unbound]")
(fetch-database-entry dbname key) takes the entry in the data base
corresponding to the given key and inserts it into the current buffer.

@command(name="file-exists", key="[unbound]")
@t[@w[(file-exists @p[fn])]] returns 1 if the file named by @i[fn] exists
and is writable, 0 if it does not exist, and -1 if it exists and is readable
but not writable.

@command(name="filter-region", key="[unbound]")
Take the region between dot and mark and pass it as the standard input
to the given command line.  Its standard output replaces the region
between dot and mark.  Use this to run a region through a Unix
style-filter.

@command(name="following-char", key="[unbound]")
(following-char) is an MLisp function that returns the character immediatly
following dot.  The null character (0) is returned if dot is at the end of
the buffer.  Remember that dot is not `at' some character, it is between
two characters.

@command(name="forward-balanced-paren-line", key="[unbound]")
Moves dot forward until either
@begin(itemize)
The end of the buffer is reached.

An unmatched close parenthesis, ')', is encountered.  That is, unmatched
between there and the starting position of dot.

The beginning of a line is encountered at "parenthesis level zero".  That
is, without an unmatched '(' existing between there and the starting
position of dot.
@end(itemize)
The definitions of parenthesis and strings from the syntax table for the
current buffer are used.

@command(name="forward-character", key="^F")
Move dot forwards one character. Ends-of-lines and tabs each count as
one character.  You can't move forward to after the end of the buffer.

@command(name="forward-paragraph", key="ESC-]")
Moves to the end of the current or following paragraph.  Blank lines, and
Scribe and nroff command lines separate paragraphs and are not parts of
paragraphs.

@command(name="forward-paren", key="[unbound]")
Moves dot forward until an unmatched close parenthesis, ')', or the
end of the buffer is found.  This can be used to aid in skipping over
Lisp S-expressions.  The definitions of parenthesis and strings from the
syntax table for the current buffer are used.

@command(name="forward-sentence", key="ESC-E")
Move dot forward to the beginning of the next sentence.
Sentences are seperated by a `.', `?' or `!' followed by whitespace.

@command(name="forward-word", key="ESC-F")
Move dot forward to the end of a word.  If not currently in the middle of
a word, skip all intervening punctuation.  Then skip over the word, leaving
dot positioned after the last character of the word.
A word is
a sequence of alphanumerics.

@command(name="get-tty-buffer", key="[unbound]")
Given a prompt string it reads the name of a buffer from the tty using the
minibuf and providing command completion.

@command(name="get-tty-character", key="[unbound]")
Reads a single character from the terminal and returns it as an integer.
The cursor is not moved to the message area, it is left in the text
window.  This is useful when writing things like query-replace and
incremental search.

@command(name="get-tty-command", key="[unbound]")
@w[(get-tty-command @i[prompt])] prompts for the name of a declared
function (using command completion & providing help) and returns the name of
@Index[expand-mlisp-word]
the function as a string.  For example, the @i[expand-mlisp-word] function
is simply @w[(insert-string (get-tty-command ": expand-mlisp-word "))].

@command(name="get-tty-string", key="[unbound]")
Reads a string from the terminal using its single string parameter for a
prompt.  Generally used inside MLisp programs to ask questions.

@command(name="get-tty-variable", key="[unbound]")
@w[(get-tty-variable @i[prompt])] prompts for the name of a declared
variable (using command completion & providing help) and returns the name of
@Index[expand-mlisp-variable]
the variable as a string.  For example, the @i[expand-mlisp-variable] function
is simply @w[(insert-string (get-tty-variable ": expand-mlisp-variable "))].

@command(name="getenv", key="[unbound]")
 @w[(getenv "@i[varname]")] returns the named shell environment variable.  for
example, @w[(getenv "HOME")] will return a string which names your home
directory.

@command(name="global-binding-of", key="[unbound]")
@index(nothing)
Returns the name of the procedure to which a keystroke sequence is bound in
the global keymap. "nothing" is returned if the sequence is unbound.  The
procedure @i[local-binding-of] performs a similar function for the local
keymap.

@command(name="goto-character", key="[unbound]")
Goes to the given character-position.  (goto-character 5) goes to character
position 5.

@command(name="if", key="[unbound]")
(if test thenclause elseclause) is an MLisp function that executes and
returns the value of @i[thenclause] iff @i[test] is true; otherwise it
executes @i[elseclause] if it is present.  For example:
@begin(example)
(if (eolp)
    (to-col 33)
)
@end(example)
will tab over to column 33 if dot is currently at the end of a line.

@command(name="illegal-operation", key="[unbound]")
@i[Illegal-operation] is bound to those keys that do not have a defined
interpretation.  Executing illegal-operation is an error.  Most notably,
@b[^G], @b[ESC-^G], @b[^X^G] are bound to @i[illegal-opetation] by default,
so that typing @b[^G] will always get you out of whatever strange state you
are in.

@command(name="indent-C-procedure", key="ESC-J")
Take the current C procedure and reformat it using the @i[indent]
program, a fairly sophisticated pretty printer.  @i[Indent-C-procedure]
is God's gift to those who don't like to fiddle about getting their
formatting right.  @i[Indent-C-procedure] is usually bound to
@b[ESC-J].  When switching from mode to mode, @b[ESC-J] will be bound
to procedures appropriate to that mode.  For example, in text mode
@Index[justify-paragraph]
@b[ESC-J] is bound to @i[justify-paragraph].

@command(name="insert-character", key="[unbound]")
Inserts its numeric argument into the buffer as a single character.
@w[(insert-character '0')] inserts the character '0' into the buffer.

@command(name="insert-file", key="^X^I")
Prompt for the name of a file and insert its contents at dot in the
current buffer.

@command(name="insert-filter", key="[unbound]")
Insert a filter-procedure between a process and @Value(Emacs). This function
should subsume the @i[start-filtered-process] function, but we should retain
that one for compatibility I suppose...

@command(name="insert-string", key="[unbound]")
(insert-string stringexpressions) is an MLisp function that inserts the
strings that result from evaluating the given @i[stringexpressions] and
inserts them into the current buffer just before dot.

@command(name="int-process", key="[unbound]")
(int-process "process-name") -- 
Send an interrupt signal to the process.

@command(name="interactive", key="[unbound]")
An MLisp function which is true iff the invoking MLisp function was invoked
interactively (ie. bound to a key or by ESC-X).

@command(name="is-bound", key="[unbound]")
an MLisp predicate that is true iff all of its variable name arguments are
bound.
@command(name="justify-paragraph", key="[unbound]")
Take the current paragraph (bounded by blank lines or Scribe control
lines) and pipe it through the "fmt" command which does paragraph
justification.  @i[justify-paragraph] is usually bound to @b[ESC-J] when in
text mode.

@command(name="kill-process", key="[unbound]")
(kill-process "process-name") -- 
Send a kill signal to the process. 

@command(name="kill-to-end-of-line", key="^K")
Deletes characters forward from dot to the immediatly following end-of-line
(or end of buffer if there isn't an end of line).  If dot is positioned at
the end of a line then the end-of-line character is deleted.  Text deleted
by the @b[^K] command is placed into the @i[Kill buffer] (which really
is a buffer that you can look at).  A @b[^K] command normally erases the
contents of the kill buffer first; subsequent @b[^K]'s in an unbroken
sequence append to the kill buffer.

@command(name="last-key-struck", key="[unbound]")
The last command character struck.  If you have a function bound to many
keys the function may use last-key-struck to tell which key was used to
invoke it.  @w[(insert-character (last-key-struck))] does the obvious thing.

@command(name="length", key="[unbound]")
Returns the length of its string parameter.  (length "time") => 4.

@command(name="line-to-top-of-window", key="ESC-!")
What more can I say?  This one is handy if you've just searched for
the declaration of a procedure, and want to see the whole body (or as
much of it as possible).

@command(name="list-buffers", key="^X^B")
Produces a listing of all existing buffers giving their names, the name of
the associated file (if there is one), the number of characters in the buffer
and an indication of whether or not the buffer has been modified since it was
read or written from the associated file.

@command(name="list-databases", key="[unbound]")
(list-databases) lists all data base search lists.

@command(name="list-processes", key="[unbound]")
(list-processes) -- 
Analagous to "list-buffers".  Processes which have died only
appear once in this list before completely disappearing.

@command(name="load", key="[unbound]")
Read the named file as a series of MLisp expressions and execute them.
Typically a loaded file consists primarily of @i[defun]'s and
buffer-specific variable assignments and key bindings.
@i[Load] is usually used to load macro libraries and is used to load
@index(.emacs_pro)@index(profile)
".emacs@ux[@ ]pro" from your home directory when @Value(Emacs) starts
up.

For example, loading this file:
@begin(example)
(setq right-margin 75)
(defun (my-linefeed
	    (end-of-line)
	    (newline-and-indent)
       )
)
(bind-to-key "my-linefeed" 10)
@end(example)
sets the @i[right-margin] to 75 and defines a function called
@i[my-linefeed] and binds it to the linefeed key (which is the ascii
character 10 (decimal))

The file name given to @i[load] is interpreted relative to the EPATH
environment variable, which is interpreted in the same manner as the shell's
PATH variable.  That is, it provides a list of colon-separated names that
are taken to be the names of directories that are searched for the named
files.  The default value of EPATH searches your current directory and then
a central system directory.

@b[Temporary hack:] in previous versions of @Value(Emacs) @i[load]ed files
were treated as a sequence of keystrokes.  This behaviour has been decreed
bogus and unreasonable, hence it has been changed.  However, to avoid loud
cries of anguish the @i[load] command still exhibits the old behaviour if
the first character of the loaded file is an @b[ESC].

@command(name="local-bind-to-key", key="[unbound]")
Prompt for the name of a command and a key and bind that command to the
@Index[bind-to-key]
given key but unlike @i[bind-to-key] the binding only has effect in the
current buffer.  This is generally used for mode specific bindings that
will generally differ from buffer to buffer.

@command(name="local-binding-of", key="[unbound]")
@index(nothing)
Returns the name of the procedure to which a keystroke sequence is bound in
the local keymap. "nothing" is returned if the sequence is unbound.  The
procedure @i[global-binding-of] performs a similar function for the global
keymap.

@command(name="looking-at", key="[unbound]")
(looking-at "SearchString") is true iff the given regular expression search
string matches the text immediatly following dot.  This is for use in
packages that want to do a limited sort of parsing.  For example, if dot is
at the beginning of a line then @w<@b<(looking-at "[ \t]*else])>> will be
true if the line starts with an "else".  See section @ref(searching), page
@pageref(searching) for more information on regular expressions.

@command(name="mark", key="[unbound]")
An MLisp function that returns the position of the marker in the current
buffer.  An error is signaled if the marker isn't set.  The value of the
function is an object of type "marker" -- if it is assigned to a variable
then as changes are made to the buffer the variable's value continues to
indicate the same position in the buffer.

@command(name="message", key="[unbound]")
(message stringexpressions) is an MLisp function that places the strings that
result from the evaluation of the given @i[stringexpressions] into the
message region on the display (the line at the bottom).

@command(name="modify-syntax-entry", key="[unbound]")
Modify-syntax-entry is used to modify a set of entries in the syntax table
associated with the current buffer.  Syntax tables are associated with
@Index[use-syntax-table]
buffers by using the @i[use-syntax-table] command.  Syntax tables are used
@Index[forward-paren]
by commands like @i[forward-paren] to do a limited form of parsing for
language dependent routines.  They define such things as which characters are
parts of words, which quote strings and which delimit comments (currently,
nothing uses the comment specification).  To see the contents of a syntax
@Index[dump-syntax-table]
table, use the @i[dump-syntax-table] command.

The parameter to @i[modify-syntax-entry] is a string whose first five
characters specify the interpretation of the sixth and following characters.

The first character specifies the type.  It may be one of the following:
@begin(description)
@Index[forward-word]
'w'@\A word character, as used by such commands as @i[forward-word] and
@Index[case-word-capitalize]
@i[case-word-capitalize].

space@\A character with no special interpretation.

'('@\A left parenthesis.  Typical candidates for this type are the
characters '(', '[' and '{'.  Characters of this type also have a matching
right parenthesis specified (')', ']' and '}' for example) which appears as
the second character of the parameter to @i[modify-syntax-entry].

')'@\A right parenthesis.  Typical candidates for this type are the
characters ')', ']' and '}'.  Characters of this type also have a matching
left parenthesis specified ('(', '[' and '{' for example) which appears as
the second character of the parameter to @i[modify-syntax-entry].

'"'@\A quote character.  The C string delimiters " and ' are usually given
this class, as is the Lisp |.

'\'@\A prefix character, like \ in C or / in MacLisp.
@end(description)
The second character of the parameter is the matching parenthesis if the
character is of the left or right parenthesis type. If you specify
that '(' is a right parenthesis matched by ')', then you should also specify
that ')' is a left parenthesis matched by '('.

The third character, if equal to '{', says that the character described by
this syntax entry can begin a comment; the forth character, if equal to '}'
says that the character described by this syntax entry can end a comment.
If either the beginning or ending comment sequence is two characters long,
then the fifth character provides the second character of the comment
sequence.

The sixth and following characters specify which characters are described by
this entry; a range of characters can be specified by putting a '-' between
them, a '-' can be described if it appears as the sixth character.

A few examples, to help clear up my muddy exposition:
@begin(example,font smallbodyfont)
(modify-syntax-entry "w    -")	; makes '-' behave as a normal word
				; character (@b[ESC-F] will consider
				; one as part of a word)
(modify-syntax-entry "(]   [")	; makes '[' behave as a left parenthesis
				; which is matched by ']'
(modify-syntax-entry ")[   ]")	; makes ']' behave as a right parenthesis
				; which is matched by '['
@end(example)
@command(name="move-dot-to-x-y", key="[unbound]")
(move-dot-to-x-y @i[x] @i[y]) switches to the buffer and sets dot to the
positon of the character that was displayed at screen coordinates
@i[x],@i[y].  If @i[x] and @i[y] don't point to a valid character (eg. if
they are out of bounds or point to a mode line) an error is flagged.

This function is intended for use supporting mice and tablets.  One way to
do this is to have depressions of the tablet button generate a sequence of
keystrokes that @Value(Emacs) sees as normal tty input.  If, for example,
the tablet was to transmit the four charcters ESC-M-@i[x]-@i[y] when the
button was depressed over character @i[x],@i[y] then the following function
would provide simple support for it:
@begin(ProgramExample)
(defun (mouse-set-dot x y
	   (setq x (get-tty-character))
	   (setq y (get-tty-character))
	   (move-dot-to-x-y x y)
       ))

(bind-to-key "mouse-set-dot" "\eM")
@end(ProgramExample)
@command(name="move-to-comment-column", key="[unbound]")
If the cursor is @i[not] at the beginning of a line, @b[ESC-C] moves the
@Index[comment-column]
cursor to the column specified by the comment-column variable by inserting
tabs and spaces as needed.  In any case, it the sets the right margin to
the column finally reached.  This is usually used in macros for
language-specific comments.

@command(name="nargs", key="[unbound]")
An MLisp function which returns the number of arguments passed to the
invoking MLisp function.  For example, within the execution of @i[foo]
invoked by @w[(foo x y)] the value of @i[nargs] will be 2.

@command(name="narrow-region", key="[unbound]")
@index(region restrictions)
The @i[narrow-region] command sets the restriction to encompass the region
between dot and mark.  Text outside this region will henceforth be totally
invisible.  It won't appear on the screen and it won't be manipulable by any
editing commands.  This can be useful, for instance, when you want to
perform a replacement within a few paragraphs: just narrow down to a region
enclosing the paragraphs and execute @i[replace-string].

@command(name="newline", key="[unbound]")
Just inserts a newline character into the buffer -- this is what the
RETURN (@b[^M]) key is generally bound to.

@command(name="newline-and-backup", key="^O")
Insert an end-of-line immediatly @i[after] dot, effectivly opening
up space.  If dot is positioned at the beginning of a line, then @b[^O]
will create a blank line preceding the current line and position dot on
that new line.

@command(name="newline-and-indent", key="LINEFEED")
Insert a newline, just as typing @b[RETURN] does, but then insert
enough tabs and spaces so that the newly created line has the same
indentation as the old one had.  This is quite useful when you're
typing in a block of program text, all at the same indentation
level.

@command(name="next-error", key="^X^N")
Take the next error message (as returned from the @b[^X^E] (compile)
command), do a @i[visit] (@b[^X^V]) on the file in which the error
occurred and set dot to the line on which the error occurred.  The error
message will be displayed at the top of the window associated with
the @i[Error log] buffer.

@command(name="next-line", key="^N")
Move dot to the next line.  @b[^N] and @b[^P] attempt to
keep dot at the same horizontal position as you move from line to line.

@command(name="next-page", key="^V")
Reposition the current window on the current buffer so that the next
page of the buffer is visible in the window (where a @i[page] is a
group of lines slightly smaller than a window).  In other words, it
flips you forward a page in the buffer.  Its inverse is @b[ESC-V].  If
possible, dot is kept where it is, otherwise it is moved to the middle
of the new page.

@command(name="next-window", key="^XN")
Switches to the window (and associated buffer) that is below the current
window.

@command(name="nothing", key="[unbound]")
@i[Nothing] evaluates the same as novalue (ie. it returns a void result)
except that if it is bound to some key or attached to some hook then the key
or hook behave as though no command was bound to them.  For example, if you
want to remove the binding of a single key, just bind it to "nothing".

@command(name="novalue", key="[unbound]")
Does nothing.  (novalue) is a complete no-op, it performs no action and
returns no value.  Generally the value of a function is the value of the
last expression evaluated in it's body, but this value may not be desired,
so (novalue) is provided so that you can throw it away.

@command(name="page-next-window", key="ESC-^V")
Repositions the window below the current one (or the top one if the current
window is the lowest one on the screen)
on the displayed buffer so that the next page of
the buffer is visible in the window (where a @i[page] is a group of lines
slightly smaller than a window).  In other words, it flips you forward a page
in the buffer of the @i[other] window.

If @b[ESC-^V] is given an argument it will flip the buffer backwards a
page, rather than forwards.  So @b[ESC-^V] is roughly equivalent to @b[^V]
and @b[^UESC-^V] is roughly equivalent to @b[ESC-V] except that they deal
with the other window.  Yes, yes, yes.  I realize that this is a bogus
command structure, but I didn't invent it.  Besides, you can learn to
love it.

@command(name="parse-error-messages-in-region", key="[unbound]")
Parses the region between dot and mark for error messages (as in the
@i[compile-it] (@b[^X^E]) command) and sets up for subsequent invocations of
@i[next-error] (@b[^X^N]).  See the description of the @i[compile-it]
command, and section @ref(CompilingPrograms) (page
@pageref(CompilingPrograms)).

@command(name="pause-emacs", key="[unbound]")
Pause, giving control back to the superior shell using the job control
facility of Berkeley Unix.  The screen is cleaned up before the shell
regains control, and when the shell gives control back to @Value(Emacs) the
screen will be fixed up again.  Users of the sea-shell (csh) will probably
@Index[return-to-monitor]
rather use this command than "return-to-monitor", which is similar, except
that it recursivly invokes a new shell.

@command(name="pop-to-buffer", key="[unbound]")
Switches to a buffer whose name is provided and ties that buffer to a
@Index[switch-to-buffer]
popped-up window.  Pop-to-buffer is exactly the same as switch-to-buffer
except that switch-to-buffer ties the buffer to the current window,
pop-to-buffer finds a new window to tie it to.

@command(name="preceding-char", key="[unbound]")
(preceding-char) is an MLisp function that returns the character
immediatly preceding dot.  The null character (0) is returned if dot is
at the beginning of the buffer.  Remember that dot is not `at' some
character, it is between two characters.

@command(name="prefix-argument-loop", key="[unbound]")
@index(Prefix arguments)
@w[@b[(prefix-argument-loop <statements>)]] executes <statements>
@Index[prefix-argument]
prefix-argument times.  Every function invocation is always prefixed by some
argument, usually by the user typing @b[^U]@i[n].  If no prefix argument has
@Index[provide-prefix-argument]
been provided, 1 is assumed. See also the command provide-prefix-argument
@Index[prefix-argument]
and the variable prefix-argument.

@command(name="prepend-region-to-buffer", key="[unbound]")
Prepends the region between dot and mark to the named buffer.
Neither the original text in the destination buffer nor the text in the
region between dot and mark will be disturbed.

@command(name="previous-command", key="[unbound]")
@t[(previous-command)] @i[usually] returns the character value of the
keystroke that invoked the previous command.  In is something like
@i[last-key-struck], which returns the keystroke that invoked the current
command.  However, a function may set the variable @i[this-command] to some
value, which will be the value of @i[previous-command] after the next
command invocation.  This rather bizarre command/variable pair is intended
to be used in the implementation of MLisp functions which behave differently
when chained together (ie. executed one after the other).  A good example is
@b[^K], @i[kill-to-end-of-line] which appends the text from chained kills to
the killbuffer.

To use this technique for a set of commands which are to exhibit a chaining
behaviour, first pick a magic number.  -84, say.  Then each command in this
set which is chainable should @t[@w[(setq this-command -84)]].  Then to tell
if a command is being chained, it suffices to check to see if
@t[(previous-command)] returns -84.

Did I hear you scream ``hack''??

@command(name="previous-line", key="^P")
Move dot to the previous line.  @b[^N] and @b[^P] attempt to
keep dot at the same horizontal position as you move from line to line.

@command(name="previous-page", key="ESC-V")
Repositions the current window on the current buffer so that the
previous page of
the buffer is visible in the window (where a @i[page] is a group of lines
slightly smaller than a window).  In other words, it flips you
backward a page in the buffer.  Its inverse is @b[^V].
If possible, dot is kept where it is,
otherwise it is moved to the middle of the new page.

@command(name="previous-window", key="^XP")
Switches to the window (and associated buffer) that is above the
current window.

@command(name="print", key="[unbound]")
Print the value of the named variable.  This is the command you use when
you want to inquire about the setting of some switch or parameter.

@command(name="process-filter-name", key="[unbound]")
Returns the name of the filter procedure attached to some buffer.

@command(name="process-id", key="[unbound]")
Returns the process id of the process attached to some buffer.

@command(name="process-output", key="[unbound]")
@Index[on-output-procedure]
(process-output) -- Can only be called by the @i[on-output-procedure] to
procure the output generated by the process whose name is given by
@i[MPX-process]. Returns the output as a string.

@command(name="process-status", key="[unbound]")
(process-status "process-name") -- 
Returns -1 if "process-name" isn't a process, 0 if the process
is stopped, and 1 if the process is running.

@command(name="progn", key="[unbound]")
(progn expressions...) is an MLisp function that evaluates the expressions
and returns the value of the last expression evaluated.  @i[Progn] is
roughly equivalent to a compound statement (begin-end block) in more
conventional languages and is used where you want to execute several
expressions when there is space for only one (eg. the @i[then] or @i[else]
parts of an @i[if] expression).

@command(name="provide-prefix-argument", key="[unbound]")
@index(Prefix arguments)
@w[@b[(provide-prefix-argument <value> <statement>)]] provides the prefix
argument <value> to the <statement>.  For example, the most efficient way to
skip forward 5 words is:
@example[(provide-prefix-argument 5 (forward-word))]
@Index[prefix-argument-loop]
@Index[prefix-argument]
See also the command prefix-argument-loop and the variable prefix-argument.
@command(name="push-back-character", key="[unbound]")
Takes the character provided as its argument and causes it to be used as
the next character read from the keyboard.  It is generally only useful in
MLisp functions which read characters from the keyboard, and upon finding
one that they don't understand, terminate and behave as though the key had
been struck to the @Value(Emacs) keyboard command interpreter. For example,
ITS style incremental search.

@command(name="put-database-entry", key="[unbound]")
(put-database-entry dbname key) takes the current buffer and stores it into
the named database under the given key.

@command(name="query-replace-string", key="ESC-Q")
Replace all occurrences of one string with another, starting at dot and
ending at the end of the buffer.  @Value(Emacs) prompts for an old and a new
string in the minibuffer (the line at the bottom of the screen).  See the
section on searching, section @ref(Searching) page @pageref(Searching) for more
information on search strings. For each occurrence of the old string,
 @Value(Emacs) requests that the user type in a character to tell it what to
do (dot will be positioned just after the found string).  The possible
replies are:
@begin(Description,spread 0,spacing 1, RightMargin +0.5in)
@p[<space>]@\Change this occurrence and continue to the next.

@b[n]@\Don't change this occurrence, but continue to the next

@b[r]@\Enter a recursive-edit.  This allows you to make some local changes, then continue the query-replace-string by typing @b[^C].

@b[!]@\Change this occurrence and all the rest of the occurrences without
bothering to ask.

@b[.]@\Change this one and stop: don't do any more replaces.

@b[^G]@\Don't change this occurrence and stop: don't do any more replaces.

@b[?]@\(or anything else) Print a short list of the query/replace
options.
@end(description)

@command(name="quietly-read-abbrev-file", key="[unbound]")
Read in and define abbrevs appearing in a named file.  This file should
@Index[write-abbrev-file]
have been written using @i[write-abbrev-file].
@Index[read-abbrev-file]
Unlike @i[read-abbrev-file], an error message is not printed
if the file cannot be found.

@command(name="quit-process", key="[unbound]")
(quit-process "process-name") -- 
Send a quit signal to the process.

@command(name="quote", key="[unbound]")
Takes a string and inserts quote characters so that any characters which
would have been treated specially by the reqular expression search command
will be treated as plain characters.  For example, @b[@w[(quote "a.b")]]
returns "a\.b".

@command(name="quote-character", key="^Q")
Insert into the buffer the next character typed without interpreting it
as a command.  This is how you insert funny characters.  For example, to
insert a @b[^L] (form feed or page break character) type @b[^Q^L].  This is
the only situation where @b[^G] isn't interpreted as an abort character.

@command(name="re-query-replace-string", key="[unbound]")
@i[re-query-replace-string] is identical to @i[query-replace-string] except
that the search string is a regular expression rather than an uninterpreted
sequence of characters.  See the section on searching, section
 @ref(Searching) page @pageref(Searching) for more information.

@command(name="re-replace-string", key="[unbound]")
@i[re-replace-string] is identical to @i[replace-string] except that the
search string is a regular expression rather than an uninterpreted sequence
of characters.  See the section on searching, section @ref(Searching) page
 @pageref(Searching) for more information.

@command(name="re-search-forward", key="[unbound]")
@i[re-search-forward] is identical to @i[search-forward] except that the
search string is a regular expression rather than an uninterpreted sequence
of characters.  See the section on searching, section @ref(Searching) page
 @pageref(Searching) for more information.

@command(name="re-search-reverse", key="[unbound]")
@i[re-search-reverse] is identical to @i[search-reverse] except that the
search string is a regular expression rather than an uninterpreted sequence
of characters.  See the section on searching, section @ref(Searching) page
 @pageref(Searching) for more information.

@command(name="read-abbrev-file", key="[unbound]")
Read in and define abbrevs appearing in a named file.  This file should
@Index[write-abbrev-file]
have been written using @i[write-abbrev-file].  An error message is printed
if the file cannot be found.

@command(name="read-file", key="^X^R")
Prompt for the name of a file; erase the contents of the current buffer;
read the file into the buffer and associate the name with the buffer.
Dot is set to the beginning of the buffer.

@command(name="recursion-depth", key="[unbound]")
Returns the depth of nesting within @i[recursive-edit]'s.  It returns 0 at
the outermost level.

@command(name="recursive-edit", key="[unbound]")
The @i[recursive-edit] function is a call on the keyboard
read/interpret/execute routine.  After @i[recursive-edit] is called the user
can enter commands from the keyboard as usual, except that when he exits
@Value(Emacs) by calling @i[exit-emacs] (typing @B[^C]) it actually returns
from the call to @i[recursive-edit].  This function is handy for packages
that want to pop into some state, let the user do some editing, then when
they're done perform some cleanup and let the user resume.  For example, a
mail system could use this for message composition.

@command(name="redraw-display", key="^L")
Clear the screen and rewrite it.  This is useful if some transmission
glitch, or a message from a friend, has messed up the screen.

@command(name="region-around-match", key="[unbound]")
@Label(RegionAroundMatch)
@i[Region-around-match] sets dot and mark around the region matched by the
last search.  An argument of @i[n] puts dot and mark around the @i[n]'th
subpattern matched by `\(' and `\)'.  This can then be used in conjuction
with @i[region-to-string] to extract fields matched by a patter.  For
example, consider the following fragment that extracts user names and host
names from mail addresses:
@begin(example)
(re-search-forward "\\([a-z][a-z]*\\) *@@ *\\([a-z][a-z]*\\)")
(region-around-match 1)
(setq username (region-to-string))
(region-around-match 2)
(setq host (region-to-string))
@end(example)
Applying this MLisp code to the text "send it to jag@@vlsi" would set the
variable `username' to "jag" and `host' to "vlsi".

@command(name="region-to-process", key="[unbound]")
(region-to-process "process-name") -- 
The region is wrapped up and sent to the process.

@command(name="region-to-string", key="[unbound]")
Returns the region between dot and mark as a string.  Please be kind to the
storage allocator, don't use huge strings.

@command(name="remove-all-local-bindings", key="[unbound]")
@Index[remove-local-binding]
Perform a remove-local-binding for all possible keys; effectively undoes all
local bindings.  Mode packages should execute this to initialize the local
binding table to a clean state.

@command(name="remove-binding", key="[unbound]")
Removes the global binding of the given key.  Actually, it just rebinds the
@Index[illegal-operation]
key to @i[illegal-operation].

@command(name="remove-local-binding", key="[unbound]")
Removes the local binding of the given key.  The global binding will
subsequently be used when interpreting the key.  @p[Bug:] there really
should be some way of saving the current binding of a key, then restoring
it later.

@command(name="replace-string", key="ESC-R")
Replace all occurrences of one string for another, starting at dot and
ending and the end of the buffer.  @Value(Emacs) prompts for an old and a
new string in the minibuffer (the line at the bottom of the screen).  Unlike
 @b[query-replace-string] @Value(Emacs) doesn't ask any questions about
particular occurrences, it just changes them.  Dot will be left after the
last changed string.  See the section on searching, section @ref(Searching) page
 @pageref(Searching) for more information on search strings.

@command(name="reset-filter", key="[unbound]")
Removes the filter that had been bound to some process in a buffer.

@command(name="return-prefix-argument", key="[unbound]")
@index(Prefix arguments)
@w[@t[(return-prefix-argument @p[n])]] sets the numeric prefix argument to
be used by the next function invocation to @i[n].  The next function may be
either the next function in the normal flow of MLisp execution or the next
function invoked from a keystroke.  @i[Return-prefix-argument] is to be used
by functions that are to be bound to keys and which are to provide a prefix
argument for the next keyboard command.

@command(name="return-to-monitor", key="^@ux[@ ]")
Recursivly invokes a new shell, allowing the user to enter normal shell
commands and run other programs.  Return to @Value(Emacs) by exiting the
shell; ie. by typing @b[^D].

@command(name="save-excursion", key="[unbound]")
(save-excursion expressions...) is an MLisp function that evaluates the
given expressions and returns the value of the last expression evaluated.
It is much like @i[progn] except that before any expressions are executed
dot and the current buffer are "marked" (via the marker mechanism) then
after the last expression is executed dot and the current buffer are reset
to the marked values.  This properly takes into account all movements of
dot and insertions and deletions that occur.  @i[Save-excursion] is useful
in MLisp functions where you want to go do something somewhere else in this
or some other buffer but want to return to the same place when you're done;
for example, inserting a tab at the beginning of the current line.

@command(name="save-restriction", key="[unbound]")
@index(region restrictions)
@i[Save-restriction] is only useful to people writing MLisp programs.  It is
used to save the region restriction for the current buffer (and @p[only]
the region restriction) during the execution of some subexpression that
presumably uses region restrictions.  The value of @t[(save-excursion
expressions...)] is the value of the last expression evaluated.

@command(name="save-window-excursion", key="[unbound]")
@i[save-window-excursion] is identical to @i[save-excursion] except that it
also saves (in a rough sort of way) the state of the windows.  That is,
@b[@w[(save-window-excursion expressions...)]] saves the current dot, mark,
buffer and window state, executes the expressions, restores the saved
information and returns the value of the last expression evaluated.

When the window state is saved @Value(Emacs) remembers which buffers were
visible.  When it is restored, @Value(Emacs) makes sure that exactly those
buffers are visible.  @Value(Emacs) does @i[not] save and restore the exact
layout of the windows: this is a feature, not a bug.
@command(name="scroll-one-line-down", key="ESC-Z")
Repositions the current window on the current buffer so that the line which
is currently the second to the last
line in the window becomes the last -- effectivly it
moves the buffer down one line in the window.  @b[^Z] is its inverse.

@command(name="scroll-one-line-up", key="^Z")
Repositions the current window on the current buffer so that the line which
is currently the second line in the window becomes the first -- effectivly it
moves the buffer up one line in the window.  @b[ESC-Z] is its inverse.

@command(name="search-forward", key="^S")
Prompt for a string and search for a match in the current buffer, moving
forwards from dot, stopping at the end of the buffer.  Dot is left
at the end of the matched string if a match is found, or is unmoved
if not.  See the section on searching, section @ref(Searching) page
 @pageref(Searching) for more information.

@command(name="search-reverse", key="^R")
Prompt for a string and search for a match in the current buffer,
moving backwards from dot, stopping at the beginning of the buffer.
Dot is left at the beginning of the matched string if a match is found,
or is unmoved if not.  See the section on searching, section @ref(Searching) page
 @pageref(Searching) for more information.

@command(name="self-insert", key="[unbound]")
This is tied to those keys which are supposed to self-insert.  It is
roughly the same as @w[(insert-character (last-key-struck))] with the
exception that it doesn't work unless it is bound to a key.

@command(name="send-string-to-terminal", key="[unbound]")
(send-string-to-terminal "string") sends the string argumetn out to the
terminal with @i[no] conversion or interpretation.  This should only be used
for such applications as loading function keys when @Value(Emacs) starts up.
If you screw up the screen, @Value(Emacs) won't know about it and won't fix it
up automatically for you -- you'll have to type @b[^L].

@command(name="set", key="[unbound]")
Set the value of some variable internal to @Value(Emacs).  @Value(Emacs) will
ask for the name of a variable and a value to set it to.  The variables
control such things as margins, display layout options, the behavior of
search commands, and much more.  The available variables and switches are
described elsewhere.  Note that if @i[set] is used from MLisp the variable
name must be a string: (set "left-margin" 77).

@command(name="set-auto-fill-hook", key="[unbound]")
@i[set-auto-fill-hook] associates a command with the current buffer.  When
the right margin is passed by the attempt to insert some character the hook
procedure for that buffer is invoked.  The character that triggered the hook
will not have been inserted, but will be inserted immediatly after the hook
procedure returns [unless the procedure returns 0].  The hook procedure is
responsible for maintaining the position of dot. last-key-struck may be
usually used to determine which character triggered the hook.  If no hook
procedure is associated with a buffer then the old action (break the line
and indent) will be taken.  This procedure may be used for such things as
automatically putting boxes around paragraph comments as they are typed.

@command(name="set-default", key="[unbound]")
@index(setq-default)
@index(declare-buffer-specific)
@index(buffer-specific)
@index(set)
@index(setq)
This commands bears the same relationship to @i[setq-default] that @i[set]
does to @i[setq].  It is the command that you use from the keyboard to set
the default value of some variable.  See the description of @i[setq-default]
for more detailed information.

@command(name="set-mark", key="^@@")
Puts the marker for this buffer at the place where dot is now, and
leaves it there.  As text is inserted or deleted around the mark, the
mark will remain in place.  Use ^X^X to move to the currently marked
position.

@command(name="setq", key="[unbound]")
Assigns a new value to a variable.  Variables may have either string or
integer values.  @w[(setq i 5)] sets i to 5; @w[(setq s (concat "a" "b"))]
sets s to "ab".

@command(name="setq-default", key="[unbound]")
@index(declare-buffer-specific)
@index(set-default)
@index(buffer-specific)
@i[Setq-default] is used to set the default value of some variable.  It can
be a global parameter, a buffer-specific variable or a system variable.  It
makes no matter, @i[setq-default] will set the default.  @i[Setq-default] is
the command to use from within some MLisp program, like your start up
profile (".@Value(Emacs)@ux[@ ]pro"@index(.emacs_pro)@index(profile)).  For
example, @b[@w[(setq-default right-margin 60)]] will set the default right
margin for newly created buffers to 60.  In previous versions of
 @Value(Emacs) certain system variables had default versions from which
default values were taken. So, to set the default value of @i[right-margin]
one would assign a value to
@i[default-right-margin] -- but no more.  Use @i[setq-default] (or
@i[set-default] instead.

The precise semantics of @i[setq-default] are:
@begin(itemize)
If the variable being assigned to has not yet been declared, then declare it
as a global variable.

If it is a global variable (whether or not the declaration was implicit)
then assign the value to it just as the @i[setq]@index(setq) command would
have done.

Otherwise, if the variable is buffer specific then set the default value for
the variable.  This will be used in all buffers where the variable hasn't
been explicitly assigned a value.  Note that if you have a global variable
which is eventually declared buffer-specific then the global value becomes
the default.  The intent of this is that users should be able to put
@i[setq-default]'s in their .emacs_pro's without concerning themselves over
whether the variable will eventually be a simple global or buffer-specific.
@end(itemize)

@command(name="shell", key="[unbound]")
The @i[shell] command is used to either start or reenter a shell
process.  When the shell command is executed, if a shell process doesn't
exist then one is created (running the standard ``sh'') tied to a buffer
named ``shell'.  In any case, the shell buffer becomes the current one and
dot is positioned at the end of it.  In that buffer output from the shell
and programs run with it will appear.  Anything typed into it will get sent
to the subprocess when the @i[return] key is struck.  This lets you interact
with a shell using @Value(Emacs), and all of it's editing capability, as an
intermediary.  You can scroll backwards over a session, pick up pieces of
text from other places and use them as input, edit while watching the
execution of some program, and much more...

@command(name="shrink-window", key="^X^Z")
Makes the current window one line shorter, and the window below (or the
one above if there is no window below) one line taller.  Can't be used if
there is only one window on the screen.

@command(name="sit-for", key="[unbound]")
Updates the display and pauses for n/10 seconds.  @w[(sit-for 10)] waits
for one second.  This is useful in such things as a Lisp auto-paren balencer.

@command(name="split-current-window", key="^X2")
Enter two-window mode.  Actually, it takes the current window and splits
it into two windows, dividing the space on the screen equally between the
two windows.  An arbitrary number of windows can be created -- the only
limit is on the amount of space available on the screen, which, @i[sigh],
is only 24 lines on most terminals available these days (with the
notable exception of the Ann Arbor Ambassador which has 60).

@command(name="start-filtered-process", key="[unbound]")
(start-filtered-process "command" "buffer-name" "on-output-procedure") -- 
@Index[start-process]
Does the same thing as start-process except that things are set
@Index[on-output-procedure]
up so that "on-output-procedure" is automatically called whenever
output has been received from this process.  This procedure can access
the name of the process producing the output by refering to the
variable @i[MPX-process], and can retrieve the output itself by calling the
procedure @i[process-output].

@begin(B, leftmargin +5, rightmargin +5)
The filter procedure must be careful to avoid generating side-effects
(eg. @i[search-forward]).  Moreover, if it attempts to go to the terminal for
information, output from other processes may be lost.
@end(b)

@command(name="start-process", key="[unbound]")
(start-process "command" "buffer-name") -- 
The home shell is used to start a process executing the
command.  This process is tied to the buffer "buffer-name" unless it is
null in which case the "Command execution" buffer is used.  Output from
the process is automatically attached to the end of the buffer.  Each time
this is done, the mark is left at the end of the output (which is the end of
the buffer).

@command(name="start-remembering", key="^X(")
All following keystrokes will be remembered by @Value(Emacs).

@command(name="stop-process", key="[unbound]")
(stop-process "process-name") -- 
Tell the process to stop by sending it a stop signal.  Use
@Index[continue-process]
@i[continue-process] to carry on.

@command(name="stop-remembering", key="^X)")
Stops remembering keystrokes, as initiated by @b[^X(].  The remembered
keystrokes are not forgotten and may be re-executed with @b[^XE].

@command(name="string-to-char", key="[unbound]")
Returns the integer value of the first character of its string argument.
@w[(string-to-char "0") = '0'].

@command(name="string-to-process", key="[unbound]")
(string-to-process "process-name" "string") -- 
The string is sent to the process.

@command(name="substr", key="[unbound]")
@w[(substr str pos n)] returns the substring of string @i[str] starting at
position @i[pos] (numbering from 1) and running for @i[n] characters.
If @i[pos] is less than 0, then length of the string is added to it; the
same is done for @i[n].  @w[(substr "kzin" 2 2) = "zi"];
@w[(substr "blotto.c" -2 2) = ".c"].

@command(name="switch-to-buffer", key="^XB")
Prompt for the name of the buffer and associate it with the current
window.  The old buffer associated with this window merely loses that
association: it is not erased or changed in any way.  If the new buffer
does not exist, it will be created, in contrast with @b[^X^O].

@command(name="system-name", key="[unbound]")
Is an MLisp function that returns the name of the system on which
 @Value(Emacs) is being run.  This should be the ArpaNet or EtherNet (or
whatever) host name of the machine.

@command(name="temp-use-buffer", key="[unbound]")
Switch to a named buffer @i[without] changing window associations.  The
@Index[pop-to-buffer]
@Index[switch-to-buffer]
commands pop-to-buffer and switch-to-buffer both cause a window to be
tied to the selected buffer, temp-use-buffer does not.  There are a
couple of problems that you must beware when using this command:  The
keyboard command driver insists that the buffer tied to the current
window be the current buffer, if it sees a difference then it changes
the current buffer to be the one tied to the current window.  This
means that temp-use-buffer will be ineffective from the keyboard,
switch-to-buffer should be used instead.  The other problem is that
"dot" is really a rather funny concept.  There is a value of "dot"
associated with each @i[window], not with each @i[buffer].  This is
done so that there is a valid interpretation to having the same buffer
visible in several windows.  There is also a value of "dot" associated
with the current buffer.  When you switch to a buffer with
temp-use-buffer, this "transient dot" is what gets used.  So, if you
switch to another buffer, then use temp-use-buffer to get back, "dot"
@Index[save-excursion]
will have been set to 1.  You can use save-excursion to remember your
position.

@command(name="to-col", key="[unbound]")
(to-col @i[n]) is an MLisp function that insert tabs and spaces to move the
following character to printing column @i[n].

@command(name="transpose-characters", key="^T")
Take the two characters preceding dot and exchange them.  One of the most
common errors for typists to make is transposing two letters, typing
"hte" when "the" is meant.  @b[^T] makes correcting these errors easy,
especially if you can develop a "@b[^T] reflex".

@command(name="undo", key="[unbound]")
Undoes the effects of the last command typed.  Arbitrarily complicated
commands may be undone successfully.  Only the buffer modifying effects of a
command may be undone -- variable assignments, key bindings and similar
operations will not be undone.  Even `undo' may be undone, so executing undo
twice in a row effectivly does nothing.  See the section on undoing, page
@pageref(Undoing).

@command(name="undo-boundary", key="[unbound]")
@b[undo-boundary] lays down the boundary between two undoable commands.
When commands are undone, a `command' is considered to be the series of
operations between undo boundaries.  Normally, they are laid down between
keystrokes but MLisp functions may choose to lay down more.  See the section
on undoing, page @pageref(undoing).
@command(name="undo-more", key="[unbound]")
Undoes one more command from what was last undone.  @b[undo-more] must be
preceeded by either an @b[undo] or an @b[undo-more].  This is usually used
by first invoking @b[undo] to undo a command, then invoking @b[undo-more]
repeatedly to undo more and more commands, until you've retreated to the
state you want to be back to.  See the section on undoing, page
 @pageref(Undoing).

@command(name="unlink-file", key="[unbound]")
@t[@w[(unlink-file @p[fn])]] attempts to unlink (remove) the file named
@i[fn].  It returns true if the unlink failed.

@command(name="use-abbrev-table", key="[unbound]")
Sets the current local abbrev table to the one with the given name.  Local
abbrev tables are buffer specific and are usually set depending on the
major mode.  Several buffers may have the same local abbrev table.  If
either the selected abbrev table or the global abbrev table have had some
@Index[abbrev-mode]
abbrevs defined in them, @i[abbrev-mode] is turned on for the current
buffer.
@command(name="use-global-map", key="[unbound]")
(use-global-map "mapname") uses the named map to be used for the global
interpretation of all key strokes.  @i[use-local-map] is used to change the
local interpretation of key strokes. See the section on keymaps,
 @ref(Keymaps) page @pageref(Keymaps), for more information.

@command(name="use-local-map", key="[unbound]")
(use-local-map "mapname") uses the named map to be used for the local
interpretation of all key strokes.  @i[use-global-map] is used to change the
global interpretation of key strokes.
See the section on keymaps, @ref(Keymaps) page @pageref(Keymaps), for more
information.

@command(name="use-old-buffer", key="^X^O")
Prompt for the name of the buffer and associate it with the current
window.  The old buffer associated with this window merely loses that
association: it is not erased or changed in any way.  The buffer must
already exist, in contrast with @b[^XB].

@command(name="use-syntax-table", key="[unbound]")
Associates the named syntax table with the current buffer.  See the
@Index[modify-syntax-entry]
description of the modify-syntax-entry command for more information on
syntax tables.

@command(name="users-full-name", key="[unbound]")
MLisp function that returns the users full name as a string. [Really, it
returns the contents of the gecos field of the passwd entry for the current
user, which is used on many systems for the users full name.]

@command(name="users-login-name", key="[unbound]")
MLisp function that returns the users login name as a string.

@command(name="visit-file", key="^X^V")
Visit-file asks for the name of a file and switches to a buffer that
contains it.  The file name is expanded to it's full absolute form (that is,
it will start with a '/').  If no buffer contains the file already then
 @Value(Emacs) will switch to a new buffer and read the file into it.  The
name of this new buffer will be just the last component of the file name
(everything after the last '/' in the name).  If there is already a buffer
by that name, and it contains some other file, then @Value(Emacs) will ask
"Enter a new buffer name or <CR> to overwrite the old buffer".  For example,
if my current directory is "/usr/jag/emacs" and I do a @b[^X^V] and give
 @Value(Emacs) the file name "../.emacs@ux[@ ]pro"then the name of the new
buffer will be ".emacs@ux[@ ]pro" and the file name will be
"/usr/jag/.emacs@ux[@ ]pro". @b[^X^V] is the approved way of switching from
one file to another within an invocation of @Value(Emacs).

@command(name="while", key="[unbound]")
(while test expressions...) is an MLisp function that executes the given
expressions while the test is true.

@command(name="widen-region", key="[unbound]")
@index(region restrictions)
The @i[widen-region] command sets the restriction to encompass the entire
buffer.  It is usualy used after a @i[narrow-region] to restore
@Value(Emacs)'s attention to the whole buffer.

@command(name="window-height", key="[unbound]")
Returns the number of text lines of a window that are visible on the
screen.
@command(name="working-directory", key="[unbound]")
Returns the pathname of the current working directory.

@command(name="write-abbrev-file", key="[unbound]")
Write all defined abbrevs to a named file.  This file is suitable for
@Index[read-abbrev-file]
reading back with @i[read-abbrev-file].

@command(name="write-current-file", key="^X^S")
Write the contents of the current buffer to the file whose name is associated
with the buffer.

@command(name="write-file-exit", key="^X^F")
Write all modified buffers to their associated files and if all goes
well, @Value(Emacs) will exit.

@command(name="write-modified-files", key="^X^M")
Write each modified buffer (as indicated by @b[^X^B]) onto the file
whose name is associated with the buffer.  @Value(Emacs) will complain if a
modified buffer does not have an associated file.

@command(name="write-named-file", key="^X^W")
Prompt for a name; write the contents of the current buffer to the
named file.

@command(name="yank-buffer", key="ESC-^Y")
Take the contents of the buffer whose name is prompted for
and insert it at dot in the current
buffer.  Dot is left after the inserted text.

@command(name="yank-from-killbuffer", key="^Y")
Take the contents of the kill buffer and inserts it at dot in the
current buffer.  Dot is left after the inserted text.

@command(name="|", key="[unbound]")
(| @i[e]@-[1] @i[e]@-[2]) MLisp function that returns
@i[e]@-[1] | @i[e]@-[2].

