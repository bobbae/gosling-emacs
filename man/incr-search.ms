@Section(incr-search -- ITS style incremental search)
@comment(This section was ripped out of the ITS manual)
ITS @Value(Emacs) has a the search command that is unusual in that it is
"incremental"; it begins to search before you have finished typing the
search string. As you type in the search string, @Value(Emacs) shows you
where it would be found.  When you have typed enough characters to identify
the place you want, you can stop.  The incr-search package perfectly
emulates this in Unix @Value(Emacs).  Typically one binds
 @i[incremental-search] to @b[^S] and @i[reverse-incremental-search] to
 @b[^R].

The command to search is @b[^S] (incremental-search).  @b[^S] reads in
characters and positions the cursor at the first occurrence of the
characters that you have typed.  If you type @b[^S] and then F, the cursor
moves right after the first "F".  Type an "O", and see the cursor move
to after the first "FO".  After another "O", the cursor is after the
first "FOO" after the place where you started the search.  At the same
time, the "FOO" has echoed at the bottom of the screen.

If you type a mistaken character, you can rub it out.  After the FOO,
typing a rubout makes the "O" disappear from the bottom of the screen,
leaving only "FO".  The cursor moves back to the "FO".  Rubbing out the
"O" and "F" moves the cursor back to where you started the search.

When you are satisfied with the place you have reached, you can type an
@b[ESC], which stops searching, leaving the cursor where the search
brought it.  Also, any command not specially meaningful in searches
stops the searching and is then executed.  Thus, typing @b[^A] would exit
the search and then move to the beginning of the line.  @b[ESC] is
necessary only if the next command you want to type is a printing
character, Rubout, @b[ESC] or another search command, since those are
the characters that would not exit the search.

Sometimes you search for "FOO" and find it, but not the one you expected
to find.  There was a second FOO that you forgot about, before the one
you were looking for.  Then type another @b[^S] and the cursor will find
the next FOO.  This can be done any number of times.  If you overshoot,
you can rub out the @b[^S]'s.  You can also repeat the search after exiting
it, if the first thing you type after entering another search (when the
argument is still empty) is a @b[^S].

If your string is not found at all, the echo area says "Failing I-Search".
The cursor is after the place where @Value(Emacs) found as much of your
string as it could.  Thus, if you search for FOOT, and there is no FOOT, you
might see the cursor after the FOO in FOOL.  At this point there are several
things you can do.  If your string was mistyped, you can rub some of it out
and correct it.  If you like the place you have found, you can type @b[ESC]
or some other @Value(Emacs) command to "accept what the search offered".  Or
you can type @b[^G], which throws away the characters that could not be
found (the "T" in "FOOT"), leaving those that were found (the "FOO" in
"FOOT").  A second @b[^G] at that point undoes the search entirely.

The @b[^G] "quit" command does special things during searches; just what,
depends on the status of the search.  If the search has found what you
specified and is waiting for input, @b[^G] cancels the entire search.  The
cursor moves back to where you started the search.  If @b[^G] is typed
while the search is actually searching for something or updating the
display, or after search failed to find some of your input (having
searched all the way to the end of the file), then only the characters
which have not been found are discarded.  Having discarded them, the
search is now successful and waiting for more input, so a second @b[^G]
will cancel the entire search.  Make sure you wait for the first @b[^G] to
ding the bell before typing the second one; if typed too soon, the
second @b[^G] may be confused with the first and effectively lost.

You can also type @b[^R] at any time to start searching backwards.  If a
search fails because the place you started was too late in the file, you
should do this.  Repeated @b[^R]'s keep looking for more occurrences
backwards.  A @b[^S] starts going forwards again.  @b[^R]'s can be rubbed
out just like anything else.  If you know that you want to search backwards,
you can use @b[^R] instead of @b[^S] to start the search, because @b[^R] is
also a command (reverse-incremental-search) to search backward.
