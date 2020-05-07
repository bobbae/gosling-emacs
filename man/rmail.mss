@Section(rmail -- a mail management system)
@Index(Mail, sending and receiving)
@Value(Emacs) may be used to send and receive electronic mail.  The @i[rmail]
command (Usually invoked as "@b[ESC-X]rmail") is used for reading mail,
@i[smail] is used for sending mail.
@Subsection (Sending Mail)
@index(Sending mail)
When sending mail, either by using the @i[smail] command or from within
 @i[rmail], @Value(Emacs) constructs a buffer that contains an outline of the
message to be sent and allows you to edit it. All that you have to do is
fill in the blanks.  When you exit from @i[smail] (by typing @b[^C] usually
-- when you're editing the message body you will be in a recursive-edit) the
message will be sent to the destinations and blindcopied to you.  Several
commands are available to help you in composing the message:

@begin(description)
justify-paragraph@\(@b[ESC-j]) Fixes up the line breaks in the current
paragraph according to the current left and right margins.

exit-emacs@\(@b[^C]) Exits mail composition and attempts to send the mail.
If all goes well the mail composition window will disappear and a
confirmation message will appear at the bottom of the screen.  If there is
some sort of delivery error you will be placed back into the composition
window and a message will appear.  @b[Bug]: when delivery is attempted and
there are errors in the delivery, the message will have been delivered to
the acceptable addresses and not to the others.  This makes retrying the
message difficult since you have to manually eliminate the addresses to
which the message has already been sent.

mail-abort-send@\(@b[^X^A]) Aborts the message.  If you're part-way through
composing a message and decide that you don't want to send it, @b[^X^A] will
throw it away, after asking for confirmation.

mail-noblind-exit@\(@b[^X^C]) Exits @i[smail] and send the message, just as
 @b[^C] will, except that a blind copy of the message will not be kept.

exit-emacs@\(@b[^X^F]) Same as @b[^C].

exit-emacs@\(@b[^X^S]) Same as @b[^C].

mail-append@\(@b[^Xa]) Positions dot at the end of the body and sets margins
and abbrev tables appropriatly.

mail-cc@\(@b[^Xc]) Positions dot to the "cc:" field, creating it if necessary.

mail-insert@\(@b[^Xi]) Inserts the body of the message that was most
recently looked at with rmail into the body of the message being composed.
If, for instance, what you want to do is forward a message to someone, just
read the message with rmail, then compose a message to the person you want
to forward to, and type @b[^Xi].

mail-subject@\(@b[^Xs]) Positions dot to the "subject:" field of the message.

mail-to@\(@b[^Xt]) Positions dot to the "to:" field of the message.
@end(description)

@Subsection(Reading Mail)
@index(receiving mail)
@index(Reading mail)
The @i[rmail] command provides a facility for reading mail from within
@Value(Emacs).  When it is running there are usually two windows on the
screen: one shows a summary of all the messages in your mailbox and the
other displays the ``current'' message.  The summary window may contain
something like this:
@begin(Verbatim)
    02621525335022 29 Oct 1981  research!dmr    [empty]
  B 02621525335030 29 Oct 1981  =>Unix-Wizards  A plea for understanding
    02621525335040 31 Oct 1981  CSVAX.dmr       rc etymology
    02621525335072 3 Nov 1981   EHF             fyi
 A  02621352421000 3 Nov 1981   JIM             copyrights
  B 02621353040000 3 Nov 1981   =>JIM           Re: copyrights
    02621646433000 [empty]      [empty]         [empty]
  B 02621647417000 4 Nov 1981   =>research!ikey Emacs
@ux[>N ] @ux[02622024522003] @ux[5 November  ] @ux[flaco          ] @ux[cooking class]
@end(Verbatim)
This is broken into five columns, as indicated by the underlining.

@begin(itemize)
The first column contains some flags: '>' indicates the current message, 'B'
indicates that the message is a blindcopy (ie. A copy of a message that you
sent to someone else), 'A' indicates that you've answered the message, and
'N' indicates that the message is new.

The second column contains a long string of digits that is internal
information for the mail system.

The third contains the date on which the mail was sent.

The forth contains the sender of the message, unless it is a blindcopy,
in which case it contains the destination (indicated by the "=>").

The fifth column contains the subject of the message.
@end(itemize)

When in the summary window @i[Rmail] responds to the following commands:
@begin(description)
rmail-shell@\(@b[!]) Puts you into a command shell so that you can execute
Unix commands.  Resume mail reading by typing @b[^C].

execute-extended-command@\(@b[:]) An emergency trap-door for executing
arbitrary @Value(Emacs) commands.  You should never need this.

rmail-first-message@\(@b[<]) Look at the first message in the message file.

rmail-last-message@\(@b[>]) Look at the last message in the message file.

@Index(Help facilities)
rmail-help@\(@b[?]) Print a very brief help message

exit-emacs@\(@b[^C]) Leave rmail.  Changes marked in the message file
directory (eg. deletions) will be made.

rmail-search-reverse@\(@b[^R]) Prompts for a search string and positions at
the first message, scanning in reverse, whose directory entry contains the
string.

rmail-search-forward@\(@b[^S]) Prompts for a search string and positions at
the first message, scanning forward, whose directory entry contains the
string.

rmail-append@\(@b[a]) Append the current message to a file.

rmail-previous-page@\(@b[b]) Moves backward in the window that contains the
current message.

rmail-delete-message@\(@b[d]) Flag the current message for deletion.  It
won't actually be deleted until you leave rmail.

rmail-next-page@\(@b[f]) Moves forward in the window that contains the
current message.  To read a message that is longer than the window that
contains it, just keep typing @b[f] and rmail will show you successive pages
of it.

rmail-goto-message@\(@b[g]) Moves to the @i[n]th message.

smail@\(@b[m]) Lets you send some mail.

rmail-next-message@\(@b[n]) Moves to the next message.

rmail-previous-message@\(@b[p]) Moves to the previous message.

exit-emacs@\(@b[q]) the same as @b[^C]

rmail-reply@\(@b[r]) Constructs a reply to the current message.

rmail-skip@\(@b[s]) Moves to the @i[n]th message relative to this one.

rmail-undelete-message@\(@b[u]) If the current message was marked for
deletion, @b[u] removes that mark.

@end(description)
