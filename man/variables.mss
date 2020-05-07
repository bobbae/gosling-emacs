@variable(name="ask-about-buffer-names")
The @i[ask-about-buffer-names] variable controls what the @i[visit-file]
command does if it detects a collision when constructing a buffer name.  If
@i[ask-about-buffer-names] is true (the default) then Emacs will ask for a
new buffer name to be given, or for <CR> to be typed which will overwrite
the old buffer.  If it is false then a buffer name will be synthesized by
appending "<@i[n]>" to the buffer name, for a unique value of @i[n].  For
example, if I @i[visit-file] "makefile" then the buffer name will be
"makefile"; then if I @i[visit-file] "man/makefile" the buffer name will be
"makefile<2>".

@variable(name="backup-by-copying")
If true, then when a backup of a file is made (see the section on the
@Index[backup-before-writing]
backup-before-writing variable) then rather than doing the fancy
link/unlink footwork, @Value(Emacs) copies the original file onto the backup.
This preserves all link and owner information & ensures that the files
I-number doesn't change (you're crazy if you worry about a files
I-number). Backup-by-copying incurs a fairly heafty performance penalty.
@Index[backup-by-copying-when-linked]
See the section on the backup-by-copying-when-linked variable for a
description of a compromise.  (default OFF)

@variable(name="backup-by-copying-when-linked")
If true, then when a backup of a file is made (see the section on the
@Index[backup-before-writing]
backup-before-writing variable) then if the link count of the file is
greater than 1, rather than doing the fancy link/unlink footwork,
 @Value(Emacs) copies the original file onto the backup.  If the link count
is 1, then the link/unlink trick is pulled. This preserves link information
when it is important, but still manages reasonable performance the rest of
@Index[backup-by-copying]
the time. See the section on the backup-by-copying variable for a
description of a how to have owner & I-number information preserved.
(default OFF)

@variable(name="backup-when-writing")
If ON @Value(Emacs) will make a backup of a file just before the first time
that it is overwritten.  The backup will have the same name as the original,
except that the string ".BAK" will be appended; unless the last name in the
path has more than 10 characters, in which case it will be truncated to 10
characters.  "foo.c" gets backed up on "foo.c.BAK"; "/usr/jag/foo.c" on
"/usr/jag/foo.c.BAK"; and "EtherService.c" on "EtherServi.BAK".  The backup
will only be made the first time that the file is rewritten from within the
same invocation of @Value(Emacs), so if you write out the file several times
the .BAK file will contain the file as it was before @Value(Emacs) was
invoked.  The backup is normally made by fancy footwork with links and
unlinks, to achieve acceptable performance:  when "foo.c" is to be
rewritten, @Value(Emacs) effectivly executes a "mv foo.c foo.c.BAK" and then
creates foo.c a write the new copy.  The file protection of foo.c is copied
from the old foo.c, but old links to the file now point to the .BAK file,
and the owner of the new file is the person running @Value(Emacs).  If you
@Index[backup-by-copying]
don't like this behaviour, see the switches backup-by-copying and
@Index[backup-by-copying-when-linked]
backup-by-copying-when-linked.
(default OFF)

@variable(name="buffer-is-modified")
Buffer-is-modified is true iff the current buffer has been modified
since it was last written out.  You may set if OFF (ie. to 0) if you
want @Value(Emacs) to ignore the mods that have been made to this buffer
-- it doesn't get you back to the unmodified version, it just tells
@Value(Emacs) not to write it out with the other modified files.
@Value(Emacs) sets buffer-is-modified true any time the buffer is
modified.

@variable(name="case-fold-search")
If set ON all searches will ignore the case of alphabetics when doing
comparisons.  (default OFF)

@variable(name="checkpoint-frequency")
The number of keystrokes between checkpoints. Every "checkpoint-frequency"
keystrokes all buffers which have been modified since they were last
checkpointed are written to a file named "@i[file].CKP".  @i[File] is the
file name associated with the buffer, or if that is null, the name of the
buffer.  Proper account is taken of the restriction on file names to 14
characters.  (default 300)

@variable(name="comment-column")
The column at which comments are to start.  Used by the language-dependent
@Index[move-to-comment-column]
commenting features through the @i[move-to-comment-column] command.
(default 33)

@variable(name="ctlchar-with-^")
If set ON control characters are printed as @b[^C] (an '^' character
followed by the upper case alphabetic that corresponds to the control
character), otherwise they are printed according to the usual Unix
convention ('\' followed by a three digit octal number).  (default OFF)

@Variable(name="files-should-end-with-newline")
Indicates that when a buffer is written to a file, and the buffer doesn't
end in a newline, then the user should be asked if they want to have a
newline appended.  It used to be that this was the default action, but some
people objected to the question being asked. (default ON)

@Variable(name="global-mode-string")
@index(Mode lines)
@i[Global-mode-string] is a global variable used in the construction of mode
lines see section @ref(ModeLines), page @pageref(ModeLines) for more
information.

@variable(name="help-on-command-completion-error")
@Index(Help facilities)
If ON @Value(Emacs) will print a list of possibilities when an ambiguous
command is given, otherwise it just rings the bell and waits for you to
type more.  (default ON)

@variable(name="left-margin")
The left margin for automatic text justification.  After an automatically
generated @i[newline] the new line will be indented to the left margin.

@Variable(name="mode-line-format")
@index(Mode lines)
@i[mode-line-format] is a buffer specific variable used to specify the
format of a mode line.  See section @ref(ModeLines), page @pageref(ModeLines)
for more information.

@Variable(name="mode-string")
@index(Mode lines)
@i[Mode-string] is a buffer specific variable used in the construction of mode
lines see section @ref(ModeLines), page @pageref(ModeLines) for more
information.

@Variable(name="needs-checkpointing")
A buffer-specific variable which if ON indicates that the buffer should be
checkpointed periodically.  If it is OFF, then no checkpoints will be done.
(default ON)

@variable(name="pop-up-windows")
If ON @Value(Emacs) will try to use some window other than the current one
when it spontaneously generates a buffer that it wants you to see or when
you visit a file (it may split the current window).  If OFF the current
window is always used.  (default ON)

@variable(name="prefix-argument")
@index(Prefix arguments)
Every function invocation is always prefixed by a numeric argument, either
@Index[provide-prefix-argument]
explicitly with @b[^U]@i[n] or provide-prefix-argument.  The value of the
variable prefix-argument is the argument prefixed to the invocation of the
current MLisp function.  For example, if the following function:
@begin(example)
(defun
    (show-it
	(message (concat "The prefix argument is " prefix-argument))
    )
)
@end(example)
were bound to the key @b[^A] then typing @b[^U^A] would cause the message
``The prefix argument is 4'' to be printed, and @b[^U13^A] would print ``The
@Index[prefix-argument-loop]
prefix argument is 13''.  See also the commands prefix-argument-loop and
provide-prefix-argument.

@Variable(name="prefix-argument-provided")
@index(Prefix arguments)
True iff the execution of the current function was prefixed by a numeric
argument.  Use @i[prefix-argument] to get it's value.

@variable(name="prefix-string")
The string that is inserted after an automatic @i[newline] has been
generated in response to going past the right margin.  This is generally
used by the language-dependent commenting features.  (default "")

@variable(name="quick-redisplay")
If ON @Value(Emacs) won't worry so much about the case where you have the
same buffer on view in several windows -- it may let the other windows be
inaccurate for a short while (but they will eventually be fixed up).
Turning this ON speeds up @Value(Emacs) substantially when the same buffer is
on view in several windows.  When it is OFF, all windows are always
accurate.  (default OFF)

@variable(name="replace-case")
If ON @Value(Emacs) will alter the case of strings substituted with
@Index[replace-string]
@Index[query-replace-string]
@i[replace-string] or @i[query-replace-string] to match the case of the
original string.  For example, replacing "which" by "that" in the string
"Which is silly" results in "That is silly"; in the string "the car which is
red" results in "the car that is red"; and in the string "WHICH THING?"
results in "THAT THING?".

@variable(name="right-margin")
The right margin for automatic text justification.  If a character is
inserted at the end of a line and to the right of the right margin
 @Value(Emacs) will automatically insert at the beginning of the preceding
word a newline, tabs and spaces to indent to the left margin, and the prefix
string.  With the right margin set to something like (for eg.) 72 you can
type in a document without worrying about when to hit the @i[return] key,
 @Value(Emacs) will automatically do it for you at exactly the right place.

@Variable(name="scroll-step")
The number of lines by which windows are scrolled if dot moves outside the
window. If dot has moved more than @i[scroll-step] lines outside of the
window or @i[scroll-step] is zero then dot is centered in the window.
Otherwise the window is moved up or down @i[scroll-step] lines.  Setting
 @i[scroll-step] to 1 will cause the window to scroll by 1 line if you're
typing at the end of the window and hit RETURN.

@variable(name="silently-kill-processes")
If ON @Value(Emacs) will kill processes when it exits @i[without] asking any
questions.  Normally, if you have processes running when @Value(Emacs) exits,
the question "You have processes on the prowl, should I hunt them down for
you" is asked.  (default OFF)

@variable(name="stack-trace-on-error")
If ON @Value(Emacs) will write a MLisp stack trace to the "Stack trace" buffer
whenever an error is encountered from within an MLisp function (even inside
@Index[error-occured]
an @i[error-occured]).  This is all there is in the way of a debugging
facility. (default OFF)

@Variable(name="tab-size")
A buffer-specific variable which specifies the number of characters between
tab stops.  It's not clear that user specifiable tabs are a good idea, since
the rest of Unix and most other DEC styled operating systems have the magic
number 8 so deeply wired into them. (default 8)

@Variable(name="this-command")
The meaning of the variable @i[this-command] is tightly intertwined with the
meaning of the function @i[previous-command].  Look at its documentation for
a description of @i[this-command].

@variable(name="track-eol-on-^N-^P")
If ON then @b[^N] and @b[^P] will "stick" to the end of a line if they are
started there.  If OFF @b[^N] and @b[^P] will try to stay in the same
column as you move up and down even if you started at the end of a line.
(default ON)

@variable(name="unlink-checkpoint-files")
If ON @Value(Emacs) will unlink the corresponding checkpoint file after the
master copy is written -- this avoids having a lot of .CKP files lying
around but it does compromise safety a little.  For example, as you're
editing a file called "foo.c" @Value(Emacs) will be periodically be writing a
checkpoint file called "foo.c.CKP" that contains all of your recent changes.
When you rewrite the file (with @b[^X^F] or @b[^X^S] for example) if
unlink-checkpoint-files is ON then the .CKP file will be unlinked, otherwise
it will be left.  (default OFF)

@variable(name="visible-bell")
If ON @Value(Emacs) will attempt to use a visible bell, usually a horrendous
flashing of the screen, instead of the audible bell, when it is notifying
you of some error.  This is a more "socially acceptable" technique when
people are working in a crowded terminal room.  (default OFF)

@variable(name="wrap-long-lines")
If ON @Value(Emacs) will display long lines by "wrapping" their continuation
onto the next line (the first line will be terminated with a '\').  If OFF
long lines get truncated at the right edge of the screen and a '$' is
display to indicate that this has happened.  (default OFF)

