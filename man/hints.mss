@Chapter(Compiling programs)@label(CompilingPrograms)
One of the most powerful features of Unix @Value(Emacs) is the facility
provided for compiling programs and coping with error messages from the
compilers.  It essential that you understand the standard Unix program
@i[make] (even if you don't use @Value(Emacs)).  This program takes a database
(a @i[makefile]) that describes the relationships among files and how to
regenerate (recompile) them.  If you have a program that is made up of many
little pieces that have to be individually compiled and carefully crafted
together into a single executable file, @i[make] can make your life orders
of magnitude easier; it will automatically recompile only those pieces that
need to be recompiled and put them together.  @Value(Emacs) has a set of
commands that gracefully interact with this facility.

The @b[^X^E] (@i[execute]) command writes all modified buffers and executes
the @i[make] program.  The output of @i[make] will be placed into a buffer
called @i[Error log] which will be visible in some window on the screen. As
soon as @i[make] has finished @Value(Emacs) parses all of its output to find
all the error messages and figure out the files and lines referred to. All
of this information is squirreled away for later use by the @b[^X^N]
command.

The @b[^X^N] (@i[next]) command takes the next error message from the
set prepared by @b[^X^E] and does three things with it:
@begin(itemize)
Makes the message itself visible at the top of a window.  The
buffer will be named @i[Error log].

Does a @i[visit] (see the @b[^X^V] command) on the file in which the error
occurred.

Sets dot to the beginning of the line where the compiler saw the error. This
setting of dot takes into account changes to the file that may have been
made since the compilation was attempted.  @Value(Emacs) perfectly compensates
for any changes that may have been made and always positions the text on the
correct line (well, correct as far as the compiler was concerned; the
compiler itself may have been a trifle confused about where the error
occurred)
@end(itemize)
If you've seen all the error messages @b[^X^N] will say so and do nothing
else.

So, the general scenario for dealing with programs is:
@begin(itemize)
Build a @i[make] database to describe how your program is to be compiled.

Compile your program from within @Value(Emacs) by typing @b[^X^E].

If there were errors, step through them by typing @b[^X^N],
correcting the error, and typing @b[^X^N] to get the next.

When you run out of error messages, type @b[^X^E] to try the compilation
again.

When you finally manage to get your beast to compile without any errors,
type @b[^C] to say goodbye to @Value(Emacs).

You'll probably want to use @i[sdb], the symbolic debugger, to debug
your program.
@end(itemize)
@Chapter(Dealing with collections of files)
The @b[^X^E] command doesn't always execute the @i[make] program: if it
is given a non-zero argument it will prompt for a Unix command line to
be executed in place of @i[make].  All of the other parts of @b[^X^E]
are unchanged, namely it still writes all modified buffers before executing
the command and parses the output of the command execution for line
numbers and file names.

This can be used in some very powerful ways.  For example, consider the
 @i[grep] program.  Typing @w["@b[^U^X^E]@t[grep -n MyProc *.c]@b[ESC]"]
will scan all C programs in the current directory and look for all
occurrences of the string "MyProc".  After @i[grep] has finished you can use
 @Value(Emacs) (via the @b[^X^N] command) to examine and possibly change
every instance of the string from a whole collection of files.  This makes
the task of changing all calls to a particular procedure much easier.
 @b[Note:] this only works with the version of @i[grep] in /usr/jag/bin
which has been modified to print line numbers in a format that @Value(Emacs)
can understand.

There are many more uses.  The @i[lint] program, for example.
Scribe users might find "@w[@t[cat MyReport.otl]]" to be useful.

A file name/line number pair is just a string embedded someplace in
the text of the error log that has the form
@w["FileName@t[, line ]LineNumber"].  The FileName may or may not be
surrounded by quotes (").  The critical component is the string @t[", line "]
that comes between the file name and the line number.
Roll your own file scanning programs, it can make your life much easier.

@Chapter(Abbrev mode)
Abbrev mode allows the user to type abbreviations into a document and have
@Value(Emacs) automatically expand them.  If you have an abbrev called "rhp"
that has been defined to expand to the string "rhinocerous party" and have
turned on abbrev mode then typing the first non-alphanumeric character
after having typed "rhp" causes the string "rhp" to be replaced by
"rhinocerous party".  The capitalization of the typed in abbreviation
controls the capitalization of the expansion:  "Rhp" would expand as
"Rhinocerous party" and "RHP" would expand as "Rhinocerous Party".

Abbreviations are defined in @i[abbrev tables].  There is a global abbrev
table which is used regardless of which buffer you are in, and a local
abbrev table which is selected on a buffer by buffer basis, generally
depending on the major mode of the buffer.

@Index[Define-global-abbrev]
Define-global-abbrev takes two arguments: the name of an abbreviation and
the phrase that it is to expand to.  The abbreviation will be defined in
the global abbrev table.
@Index[Define-local-abbrev]
Define-local-abbrev is like define-global-abbrev except that it defines the
abbreviation in the current local abbrev table.

@Index[use-abbrev-table]
The use-abbrev-table command is used to select (by name) which abbrev
table is to be used locally in this buffer.  The same abbrev table may
@Index[electric-c]
be used in several buffers.  The mode packages (like electric-c and
text) all set up abbrev tables whose name matches the name of the
mode.

@Index[abbrev-mode]
The switch @i[abbrev-mode] must be turned on before @Value(Emacs) will
attempt to expand abbreviations.  When abbrev-mode is turned on, the
string "abbrev" appears in the mode section of the mode line for the buffer.
Use-abbrev-table automatically turns on abbrev-mode if either the global or
new local abbrev tables are non-empty.

All abbreviations currently defined can be written out to a file using the
@Index[write-abbrev-file]
write-abbrev-file command.  Such a file can be edited (if you wish) and
@Index[Read-abbrev-file]
later read back in to define the same abbreviations again.  Read-abbrev-file
reads in such a file and screams if it cannot be found,
@Index[quietly-read-abbrev-file]
quietly-read-abbrev-file doesn't complain (it is primarily for use in
startups so that you can load a current-directory dependant abbrev file
without worrying about the case where the file doesn't exist).

People writing MLisp programs can have procedures invoked when an abbrev is
triggered.  Use the commands @i[define-hooked-global-abbrev] and
 @i[define-hooked-local-abbrev] to do this.  These behave exactly as the
unhooked versions do except that they also associate a named command with
the abbrev.  When the abbrev triggers, rather than replacing the
abbreviation with the expansion phrase the hook procedure is invoked. The
character that trigged the abbrev will not have been inserted, but will be
inserted immediatly after the hook procedure returns [unless the procedure
returns 0].  The abbreviation will be the word immediatly to the left of
dot, and the function @i[abbrev-expansion] returns
the@index(abbrev-expansion) phrase that the abbrev would have expanded to.

@Chapter(Extensibility)
Unix @Value(Emacs) has two extension features: macros and a built in Lisp
system.  Macros are used when you have something quick and simple to do,
Lisp is used when you want to build something fairly complicated like a new
language dependant mode.
@Section(Macros)
A @i[macro] is just a piece of text that @Value(Emacs) remembers in a
special way.  When a macro is @i[executed] the characters that make up the
macro are treated as though they had been typed at the keyboard.  If you
have some common sequence of keystrokes you can define a macro that
contains them and instead of retyping them just call the macro.  There are
two ways of defining macros:

The easiest is called a @i[keyboard] macro.  A keyboard macro is defined by
@Index[start-remembering]
typing the start-remembering command (@b[^X(]) then typing the commands
which you want to have saved (which will be executed as you type them so
that you can make sure that they are right) then typing the
@Index[stop-remembering]
stop-remembering command (@b[^X)]).  To execute the keyboard macro just
@Index[execute-keyboard-macro]
type the execute-keyboard-macro command (@b[^Xe]).  You can only have one
keyboard macro at a time.  If you define a new keyboard macro the old
keyboard macro vanishes into the mist.

@i[Named] macros are slightly more complicated.  They have names, just like
commands and MLisp functions and can be called by name (or bound to a
@Index[define-string-macro]
key).  They are defined by using the define-string-macro command (which
must be executed by typing @b[ESC-Xdefine-string-macro] since it isn't
usually bound to a key) which asks for the name of the macro and it's
body.  The body is typed in as a string in the prompt area at the bottom
the the screen and hence all special characters in it must be quoted by
prefixing them with @b[^Q].  A named macro may be executed by typing
@w[@b[ESC-Xname-of-macro]] or by binding it to a key with
@Index[bind-to-key]
bind-to-key.

The current keyboard macro can be converted into a named macro by using the
@Index[define-keyboard-macro]
define-keyboard-macro command which takes a name a defines a macro by that
name whose body is the current keyboard macro.  The current keyboard macro
ceases to exist.
@Include(mlisp.mss)
@Section[More on Invoking @Value(Emacs)]
@Label(InvokingEmacs)
When @Value(Emacs) is invoked, it does several things that are not of too
much interest to the beginning user.

@begin(enumerate)
@index(.emacs_pro)@index(profile)
@Value(Emacs) looks for a file called ``@t[.emacs@ux[@ ]pro]'' in your home
directory, if it exists then it is loaded, with the @i[load] command.  This
is the mechanism used for user profiles -- in your @t[.emacs@ux[@ ]pro]
file, place the commands needed to customize @Value(Emacs) to suit your taste.
If a user has not set up an @t[.emacs@ux[@ ]pro] file then @Value(Emacs) will
use a site-specific default file for initialization.
At CMU this file is named /usr/local/lib/emacs/maclib/profile.ml

@Value(Emacs) will then interprete its command line switches.
"-l<filename>" loads the given file (only one may be named), "-e<funcname>"
executes the named function  (again, only one may be named).  -l and -e are
executed in that order, after the user profile is read, but before and file
visits are done.  This is intended to be used along with the csh alias
mechanism to allow you to invoke @Value(Emacs) packages from the shell (that
is, assuming that there is anyone out there who still uses the shell for
anything other than to run under @Value(Emacs)!). For example: "@t[alias rmail
emacs -lrmail -ermail-com]" will cause the csh "rmail" command to invoke
 @Value(Emacs) running rmail.  Exiting rmail will exit @Value(Emacs).

If neither @i[argv] nor @i[argc] have yet been called (eg. by your startup
or by the command line named package) then the list of arguments will be
considered as file names and will be visited; if there are no arguments then
the arguments passed to the last invocation of @Value(Emacs) will be used.

Finally, @Value(Emacs) invokes it's keyboard command interpreter, and
eventually terminates.
@end(enumerate)
@Chapter(Searching)@label(Searching)
@Value(Emacs) is capable of performing two kinds of searches@foot<@i[Regular]
and @i[Vanilla] for those of you with no taste>.  There are two parallel
sets of searching and replacement commands that differ only in the kind of
search performed.
@Section(Simple searches)
@index(search-forward)
@index(search-reverse)
@index(query-replace-string)
@index(replace-string)
The commands @i[search-forward], @i[search-reverse],
@i[query-replace-string] and @i[replace-string] all do simple searches.
That is, the search string that they use is matched directly against
successive substrings of the buffer.  The characters of the search string
have no special meaning.  These search forms are the easiest to understand
and are what most people will want to use.  They are what is conventionally
bound to @b[^S], @B[^R], @b[ESC-Q] and @b[ESC-R].
@Section(Regular Expression searches)
@index(re-search-forward)
@index(re-search-reverse)
@index(re-query-replace-string)
@index(re-replace-string)
@index(looking-at)
The commands @i[re-search-forward], @i[re-search-reverse],
 @i[re-query-replace-string], @i[re-replace-string] and @i[looking-at]
all do regular expression searches.  The search string is interpreted as a
regular expression and matched against the buffer according to the following
rules:
@begin(enumerate)
Any character except a special character matches itself. Special
characters are @b[`\' `[' `.'] and sometimes @b[`^' `*' `$'].

A @b[`.'] matches any character except newline.

A @b[`\'] followed by any character except those mentioned in the following
rules matches that character.

A @b[`\w'] Matches any word character, as defined by the syntax tables.

A @b[`\W'] Matches any non-word character, as defined by the syntax
tables.

A @b[`\b'] Matches at a boundary between a word and a non-word character,
as defined by the syntax tables.

A @b[`\B'] Matches anywhere but at a boundary between a word and a
non-word character, as defined by the syntax tables.

A @b[`\`'] Matches at the beginning of the buffer.

A @b[`\''] Matches at the end of the buffer.

A @b[`\<'] Matches anywhere before dot.

A @b[`\>'] Matches anywhere after dot.

A @b[`\='] Matches at dot.

A nonempty string @i[s] bracketed @b[``[] @i[s] @b(]'') (or  @b[``[^]
 @i[s] @b(]'') matches any character in (or not in) @i[s].  In @i[s], @b<`\'>
has no special meaning, and @b<`]'> may only appear as the first letter. A
substring @i[a-b], with @i[a] and @i[b] in ascending ASCII order, stands for
the inclusive range of ASCII characters.

A @b[`\'] followed by a digit @i[n] matches a copy of the string that the
bracketed regular expression beginning with the @i[n] th @b[`\('] matched.

A regular expression of one of the preceeding forms followed by @b[`*']
matches a sequence of 0 or more matches of the regular expression.

A regular expression, @i[x], bracketed @b[``\(] @i[x] @b[\)''] matches what
 @i[x] matches.

A regular expression of this or one of the preceeding forms, @i[x], followed
by a regular expression of one of the preceeding forms, @i[y] matches a
match for @i[x] followed by a match for @i[y], with the @i[x] match being as
long as possible while still permitting a @i[y] match.

A regular expression of one of the preceeding forms preceded by @b[`^'] (or
followed by @b[`$']), is constrained to matches that begin at the left (or
end at the right) end of a line.

A sequence of regular expressions of one of the preceeding forms seperated
by `\|'s matches any one of the regular expressions.

A regular expression of one of the preceeding forms picks out the longest
amongst the leftmost matches if searching forward, rightmost if searching
backward.

An empty regular expression stands for a copy of the last regular
expression encountered.
@end(enumerate)
In addition, in the replacement commands, @i[re-query-replace-string] and
@i[re-replace-string], the characters in the replacement string are
specially interpreted:
@begin(itemize)
Any character except a special character is inserted unchanged.

A @b[`\'] followed by any character except a digit causes that character
to be inserted unchanged.

A @b[`\'] followed by a digit @i[n] causes the string matched by the @i[n]th
bracketed expression to be inserted.

An @b[`&'] causes the string matched by the entire search string to be
inserted.
@end(itemize)
The following examples should clear a little of the mud:

@begin(description)
@t[Pika]@\Matches the simple string ``Pika''.

@t[Whiskey.*Jack]@\Matches the string ``Whiskey'', followed by the longest
possible sequence of non-newline characters, followed by the string
``Jack''.  Think of it as finding the first line that contains the string
``Whiskey'' followed eventually on the same line by the string ``Jack''

@t<[a-z][a-z]*>@\Matches a non-null sequence of lower case alphabetics.
Using this in the @i[re-replace-string] command along with the replacement
string ``@t[(&)]'' will place parenthesis around all sequences of lower case
alphabetics.

@t<Guiness\|Bass>@\Matches either the string `Guiness' or the string `Bass'.

@t<\Bed\b>@\Matches `ed' found as the suffix of a word.

@t<\bsilly\W*twit\b>@\Matches the sequence of words `silly' and `twit'
seperated by arbitrary punctuation.
@end(description)

@Chapter(Keymaps)@label(Keymaps)
When a user is typing to @Value(Emacs) the keystrokes are interpreted using
a @i[keymap].  A keymap is just a table with one entry for each character in
the ASCII character set.  Each entry either names a function or another
keymap.  When the user strikes a key, the corresponding keymap entry is
examined and the indicated action is performed.  If the key is bound to a
function, then that function will be invoked.  If the key is bound to
another keymap then that keymap is used for interpreting the next keystroke.

There is always a global keymap and a local keymap, as keys are read from
the keyboard the two trees are traversed in parallel (you can think of
keymaps as FSMs, with keystrokes triggering transitions).  When either of
the traversals reaches a leaf, that function is invoked and interpretation
is reset to the roots of the trees.
@Index[use-local-map]
@Index[use-global-map]
@Index[define-keymap]
@Index[local-bind-to-key]
@Index[bind-to-key]

The root keymaps are selected using the @i[use-global-map] or
@i[use-local-map] commands.  A new empty keymap is created using the
@i[define-keymap] command.

The contents of a keymap can be changed by using the @i[bind-to-key] and
 @i[local-bind-to-key] commands.  These two commands take two arguments: the
name of the function to be bound and the keystroke sequence to which it is to
be bound.  This keystroke sequence is interpreted relative to the current
local or global keymaps.  For example,
@b[@w[(bind-to-key "define-keymap" "\^Zd")]] binds the @i[define-keymap]
function to the keystroke sequence @b[`^Z'] followed by @b[`d'].

A named keymap behaves just like a function, it can be bound to a key or
executed within an MLisp function.  When it is executed from within an MLisp
function, it causes the next keystroke to be interpreted relative to that
map.

The following sample uses the keymap to partially simulate the @i[vi]
editor.  Different keymaps are used to simulate the different modes in
@i[vi]: command mode and insertion mode.
@begin(example,leftmargin +0, use NoteStyle, use T, Free)
(defun
    (insert-before		; @i[Enter insertion mode]
	(use-global-map "vi-insertion-mode"))
    
    (insert-after		; @i[Also enter insertion mode, but after]
				; @i[the current character]
	(forward-character)
	(use-global-map "vi-insertion-mode"))
    
    (exit-insertion		; @i[Exit insertion mode and return to]
				; @i[command mode]
	(use-global-map "vi-command-mode"))
    
    (replace-one
	(insert-character (get-tty-character))
	(delete-next-character))
    
    (next-skip
	(beginning-of-line)
	(next-line)
	(skip-white-space))
    
    (prev-skip
	(beginning-of-line)
	(previous-line)
	(skip-white-space))
    
    (skip-white-space
	(while (& (! (eolp)) (| (= (following-char) ' ') (= (following-char) '^i')))
	    (forward-character)))
    
    (vi				; @i[Start behaving like vi]
	(use-global-map "vi-command-mode"))
)

; setup vi mode tables
(define-keymap "vi-command-mode")
(define-keymap "vi-insertion-mode")

(use-global-map "vi-insertion-mode"); @i[Setup the insertion mode map]
(bind-to-key "execute-extended-command" "\^X")
(progn i
    (setq i ' ')
    (while (< i 0177)
	(bind-to-key "self-insert" i)
	(setq i (+ i 1))))
(bind-to-key "self-insert" "\011")
(bind-to-key "newline" "\015")
(bind-to-key "self-insert" "\012")
(bind-to-key "delete-previous-character" "\010")
(bind-to-key "delete-previous-character" "\177")
(bind-to-key "exit-insertion" "\033")

(use-global-map "vi-command-mode"); @i[Setup the command mode map]
(bind-to-key "execute-extended-command" "\^X")
(bind-to-key "next-line" "\^n")
(bind-to-key "previous-line" "\^p")
(bind-to-key "forward-word" "w")
(bind-to-key "backward-word" "b")
(bind-to-key "search-forward" "/")
(bind-to-key "search-reverse" "?")
(bind-to-key "beginning-of-line" "0")
(bind-to-key "end-of-line" "$")
(bind-to-key "forward-character" " ")
(bind-to-key "backward-character" "\^h")
(bind-to-key "backward-character" "h")
(bind-to-key "insert-after" "a")
(bind-to-key "insert-before" "i")
(bind-to-key "replace-one" "r")
(bind-to-key "next-skip" "+")
(bind-to-key "next-skip" "\^m")
(bind-to-key "prev-skip" "-")
(use-global-map "default-global-keymap")
@end(example)

@Chapter(Region Restrictions)
@index(region restrictions)
The portion of the buffer which @Value(Emacs) considers visible when it
performs editing operations may be restricted to some subregion of the whole
buffer.

The @ComRef[narrow-region] command sets the restriction to encompass the
region between dot and mark.  Text outside this region will henceforth be
totally invisible.  It won't appear on the screen and it won't be
manipulable by any editing commands.  It will, however, be read and written
by file manipulation commands like @ComRef[read-file] and
 @ComRef[write-current-file].  This can be useful, for instance, when you
want to perform a replacement within a few paragraphs: just narrow down to a
region enclosing the paragraphs and execute @ComRef[replace-string].

The @ComRef[widen-region] command sets the restriction to encompass the entire
buffer.  It is usually used after a @ComRef[narrow-region] to restore
@Value(Emacs)'s attention to the whole buffer.

@ComRef[Save-restriction] is only useful to people writing MLisp programs.  It is
used to save the region restriction for the current buffer (and @p[only]
the region restriction) during the execution of some subexpression that
presumably uses region restrictions.  The value of @t[(save-restriction
expressions...)] is the value of the last expression evaluated.

@Chapter(Mode Lines)@Index(Mode lines)@label(ModeLines)
A @i[mode line] is the line of descriptive text that appears just below a
window on the screen.  It usually provides a description of the state of the
buffer and is usually shown in reverse video.  The standard mode line shows
the name of the buffer, an `*' if the buffer has been modified, the name of
the file associated with the buffer, the @i[mode] of the buffer, the current
position of dot within the buffer expressed as a percentage of the buffer
size and and indication of the nesting within @ComRef[recursive-edit]'s which is
shown by wrapping the mode line in an appropriate number of `[' `]' pairs.

It is often the case that for some silly or practical reason one wants to
alter the layout of the mode line, to show more, less or different
information.  @Value(Emacs) has a fairly general facility for doing this.
Each buffer has associated with it a format string that describes the layout
of the mode line for that buffer whenever it appears in a window.  The
format string is interpreted in a manner much like the format argument to
the @b[C] printf subroutine.  Unadorned characters appear in the mode line
unchanged.  The `%' character and the following format designator character
cause some special string to appear in the mode line in their place.  The
format designators are:

@begin(description,spread 0, spacing 1)
@B[b]@\Inserts the name of the buffer.

@B[f]@\Inserts the name of the file associated with the buffer.

@B[m]@\Inserts the value of the buffer-specific variable @ComRef[mode-string].

@B[M]@\Inserts the value of the variable @ComRef[global-mode-string].

@B[p]@\Inserts the position of "dot" as a percentage.

@B[*]@\Inserts an `*' if the buffer has been modified.

@B[[]@\Inserts (recursion-depth) `['s.

@B<]>@\Inserts (recursion-depth) `]'s.
@end(description)

If a number @i[n] appears between the `%' and the format designator then the
inserted string is constrained to be exactly @i[n] characters wide.  Either
by padding or truncating on the right.

At CMU the default mode line is built using the following format:
@example<@t<" %[Buffer: %b%*  File: %f  %M (%m)  %p%]">>

The following variables are involved in generating mode lines:

@begin(description)
@ComRef(mode-line-format)@\This is the buffer specific variable that
provides the format of a buffers mode line.

@ComRef(default-mode-line-format)@\This is the value to which
 @ComRef[mode-line-format] is initialized when a buffer is created.

@ComRef(mode-string)@\This buffer-specific string variable can be inserted
into the mode line by using `%m' in the format.  This is it's only use by
 @Value(Emacs).  Usually, mode packages (like `lisp-mode' or `c-mode') put
some string into @ComRef[mode-string] to indicate the @b[mode] of the
buffer.  It is the appearance of this piece of descriptive information that
gives the mode line its name.

@ComRef(global-mode-string)@\This is similar to @i[mode-string] except that
it is global -- the same string will be inserted into all mode lines by
`%M'.  It is usually used for information of global interest.  For example,
the time package puts the current time of day and load average there.
@end(description)
