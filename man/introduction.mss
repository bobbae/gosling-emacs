@Chapter(Introduction)
@begin(quotation,LeftMargin 3.5in, indent -5)
@>``@\What is @Value(Emacs)?  It is a tree falling in the forest with no one to
hear it.  It is a beautiful flower that smells awful.''
@end(quotation)
This manual attempts to describe the Unix implementation of @Value(Emacs), 
an extensible display editor.
It is an @i[editor] in that it is primarily used for typing in and
modifying documents, programs, or anything else that is represented as
text.  It uses a @i[display] to interact with the user, always keeping an
accurate representation of what is happening visible on the screen that
changes in step with the changes made to the document.  The feature that
distinguishes @Value(Emacs) from most other editors is its @i[extensibility],
that is, a user of @Value(Emacs) can dynamically change @Value(Emacs) to suit
his own tastes and needs.

Calling this editor @Value(Emacs) is rather presumptuous and even dangerous.
There are two major editors called @Value(Emacs). The first was written at
MIT for their ITS systems as an extension to TECO.  This editor is the
spiritual father of all the @Value(Emacs)-like editors; it's principal author
was Richard Stallman.  The other was also written at MIT, but it was
written in MacLisp for Multics by Bernie Greenberg.  This editor picks up
where ITS @Value(Emacs) leaves off in terms of its extension facilities.
Unix @Value(Emacs) was called @Value(Emacs) in the hope that the cries of
outrage would be enough to goad the author and others to bring it up to the
standards of what has come before.

This manual is organized in a rather haphazard manner.  The first several
sections were written hastily in an attempt to provide a general
introduction to the commands in @Value(Emacs) and to try to show the method
in the madness that is the @Value(Emacs) command structure.  Section
@ref(CommandDescription) (page @pageref(CommandDescription))
contains a complete but concise description of all the commands and is in
alphabetical order based on the name of the command.  Preceding sections
generally do not give a complete description of each command, rather they
give either the name of the command or the key to which the command is
conventionally bound.  Section @ref(CommandSummary) (page
@pageref(CommandSummary)) lists for each key the command to which it is
conventionally bound.  The options which may be set with the @i[set]
command are described in section @ref(OptionDescription),
(page @pageref(OptionDescription)).
