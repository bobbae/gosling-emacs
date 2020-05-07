@Chapter(The Screen)
@Value(Emacs) divides a screen into several areas called @i[windows], at the
bottom of the screen there is a one line area that is used for messages and
questions from @Value(Emacs).  Most people will only be using one window, at
least until they become more familiar with @Value(Emacs).  A window is
displayed as a set of lines, at the bottom of each window is its
@index(Mode lines)
@i[mode line] (For more information on mode lines see section
@ref(ModeLines), page @pageref(ModeLines)).
The lines above the mode line contain an image of the text
you are editing in the region around @i[dot] (or @i[point]).  Dot is the
reference around which editing takes place.  Dot is a pointer which points
at a position @i[between] two characters.   On the screen, the cursor will
be positioned on the character that immediatly follows dot.  When
characters are inserted, they are inserted at the position where dot
points; commands exist that delete characters both to the left and to the
right of dot.  The text on the screen always reflects they way that the
text looks @i[now].
@Chapter(Input Conventions)
Throughout this manual, characters which are used as commands are printed
in bold face: @b[X].  They will sometimes have a @i[control] prefix which is
printed as an uparrow character: @b[^X] is control-@b[X] and is typed by
holding down the control (often labeled @i[ctrl] on the top of the key) and
simultaneously striking @b[X].   Some will have an @i[escape] (sometimes
called @i[meta]) prefix which is usually printed thus: @b[ESC-X] and typed
by striking the escape key (often labeled @i[esc]) then @b[X].  And some
will have a @b[^X] prefix which is printed @b[^XX] which is typed by
holding down the control key, striking @b[X], releasing the control key
then striking @b[X] again.

For example, @b[ESC-^J] is typed by striking @b[ESC] then holding down the
control key and striking @b[J].
@Chapter(Invoking @Value(Emacs))
@Value(Emacs) is invoked as a Unix command by typing
@example(emacs @i[files])
to the Shell (the Unix command interpreter).  @Value(Emacs) will start up,
editing the named files.  You will probably only want to name one file.  If
you don't specify any names, @Value(Emacs) will use the same names that it
was given the last time that it was invoked.  Gory details on the
invocation of @Value(Emacs) can be found in section @ref(InvokingEmacs), page
@pageref(InvokingEmacs).

@Chapter(Basic Commands)
Normally each character you type is interpreted individually by @Value(Emacs)
as a command.  The instant you type a character the command it represents
is performed immediatly.

All of the normal printing characters when struck just insert themselves
into the buffer at dot.

To move dot there are several simple commands.  @b[^F] moves dot forward
one character, @b[^B] moves it backward one character.  @b[^N] moves dot to
the same column on the next line, @b[^P] moves it to the same column on the
previous line.

String searches may be used to move dot by using the @b[^S] command to
search in the forward direction and @b[^R] to search in the reverse
direction.

Deletions may be performed using @b[^H] (@i[backspace]) to delete the
character to the left of dot and @b[^D] to delete the character to the
right of dot.

The following table summarizes all of the motion and
deletion commands.
@begin(format, group)
@tabs(+3in,+3in)
@\@=Direction
@tabs(+3in,+1.5in,+1.5in)
@\@=Move@=Delete@\
@tabs(+3in,+.75in,+.75in,+.75in,+.75in)
@ux[Units of Motion@\@=Left@=Right@=Left@=Right@\]
Characters@\@=@b[^B]@=@b[^F]@=@b[^H]@=@b[^D]@\
Words@\@=@b[ESC-B]@=@b[ESC-F]@=@b[ESC-H]@=@b[ESC-D]@\
Intra line@\@=@b[^A]@=@b[^E]@=@=@b[^K]
Inter line@\@=@b[^P]@=@b[^N]@\
@end(format)

@Chapter(Unbound Commands)
Even though the number of characters available to use for @Value(Emacs)
commands is large, there are still more commands than characters.  You
probably wouldn't want to bind them all to keys even if you could.  Each
command has a long name and by that long name may be bound to a key.
For example, @b[^F] is normally bound to the command named
@Index[forward-character]
@i[forward-character] which moves dot forward one character.

There are many commands that are not normally bound to keys.  These must be
executed with the @b[ESC-X] command or by binding them to a key (via the
bind-to-key command).  Heaven help the twit who rebinds @b[ESC-X].

The @b[ESC-X] command will print ": " on the last line of the display and
expect you to type in the name of a command.  Space and @b[ESC] characters
may be struck to invoke Tenex style command completion (ie. you type in the
first part of the command, hit the space bar, and @Value(Emacs) will fill in
the rest for you -- it will complain if it can't figure out what you're
trying to say).  If the command requires arguments, they will also be
prompted for on the bottom line.
@Chapter(Getting Help)
@Index(Help facilities)
@Value(Emacs) has many commands that let you ask @Value(Emacs) for help
about how @Index[apropos] to use @Value(Emacs).  The simplest one is
 @b[ESC-?] (apropos) which asks you for a keyword and then displays a list
of those commands whose full name contains the keyword as a substring.  For
example, to find out which commands are available for dealing with windows,
type @b[ESC-?], @Value(Emacs) will ask "Keyword:" and you reply "window".  A
list like the following appears:
@begin(Example, Font SmallBodyFont)
beginning-of-window	     ESC-,
delete-other-windows	     ^X1
delete-window		     ^XD
end-of-window		     ESC-.
enlarge-window		     ^XZ
line-to-top-of-window	     ESC-!
next-window		     ^XN
page-next-window	     ESC-^V
previous-window		     ^XP
shrink-window		     ^X^Z
split-current-window	     ^X2
@end(Example)

@Index[describe-command]
To get detailed information about some command, the @i[describe-command]
command can be used.  It asks for the name of a command, then displays
the long documentation for it from the manual.  For example, if you wanted
@Index[shrink-window]
more information about the @i[shrink-window] command, just type
@w["@b[ESC-X]describe-command shrink-window]" and @Value(Emacs) will reply:
@begin(example,font SmallBodyFont)
 shrink-window                                                          ^X^Z
             Makes the current window one line shorter, and the window below
           (or the one above if there is no window below) one  line  taller.
           Can't be used if there is only one window on the screen.
@end(example)

If you want to find out what command is bound to a particular key,
@Index[describe-key]
@Index[Describe-bindings]
@i[describe-key] will do it for you.  @i[Describe-bindings] can be used
to make a "wall chart" description of the key bindings in the currently
running @Value(Emacs), taking into account all of the bindings you have made.

@Chapter(Buffers and Windows)
There are two fundamental objects in @Value(Emacs), @i[buffers] and
@i[windows].  A buffer is a chunk of text that can be edited, it is often
the body of a file.  A window is a region on the screen through which a
buffer may be viewed.  A window looks at one buffer, but a buffer may be on
view in several windows.  It is often handy to have two windows looking at
the same buffer so that you can be looking at two separate parts of the
same file, for example, a set of declarations and a piece of code that uses
those declarations.  Similarly, it is often handy to have two different
buffers on view in two windows.

The commands which deal with windows and buffers are:
beginning-of-window @b((ESC-,)),
delete-other-windows @b((^X1)),
delete-region-to-buffer (@b(ESC-^W)),
delete-window @b((^XD)),
end-of-window @b((ESC-.)),
enlarge-window @b((^XZ)),
line-to-top-of-window @b((ESC-!)),
list-buffers (@b(^X^B)),
next-window @b((^XN)),
page-next-window @b((ESC-^V)),
previous-window @b((^XP)),
shrink-window @b((^X^Z)),
split-current-window @b((^X2)),
switch-to-buffer (@b(^XB)),
use-old-buffer (@b(^X^O)) and
yank-buffer (@b(ESC-^Y)).
See the command description section for more details on each of these.

@Chapter(Terminal types)
Grim reality being what it is, @Value(Emacs) has to deal with a wide
assortment of displays from many manufacturers.  Each manufacturer has their
own perverted idea of how programs should communicate with the display, so
it is important for @Value(Emacs) to correctly be told what type of terminal
is being used.  Under Unix, this is done by setting the environment variable
`TERM'.  Normally, the operating system should set this to correspond to the
type of terminal that you are using and you won't have to concern yourself
with it.  However, problems may arise and there are a few things that you
should know.

`TERM' is a string variable whose value is the name of the type of terminal
that you are using.  If you are using the standard Unix shell then it should
be set using the commands:
@example<TERM=...
export TERM>
If you're using the C shell (csh) then it should be set using the command:
@example<setenv TERM ...>
where `...' is the appropriate terminal type.  Consult your system
administrator for a current list of valid terminal types.  A good place to
look is the file ``/etc/termcap'', it contains a list of all the terminals
supported by @Value(Emacs).  A few of the more common values are:
@begin(description,spread 0)
concept-lnz@\For Concepts with the special firmware for @Value(Emacs).

concept@\Concept 100, 104 and 108's from HDS.

h19@\For Heathkit or Zenith model 19 terminals.

vt100@\For VT100's from DEC, or any of the thousands of look-alikes.

aaa@\For the Ann Arbor Ambassador.
@end(description)
