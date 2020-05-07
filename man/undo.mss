@Section(undo -- undo previous commands)@label(undoing)
@index[undo]@index[undo-more]@index[undo-boundary]@index[Help facilities]
The @b[new-undo] command, which is usually bound to @b[^X^U] allows the user
to interactively undo the effects of previous commands.  Typing @b[^X^U]
undoes the effects of the last command typed.  It will then ask ``Hit
<space> to undo more'', each <space> that you then hit will undo one more
command.  Typing anything but space will terminate undoing.  If it is
terminated with anything other than <return> the termination character will
be executed just as though it were a normal command.  @b[new-undo] is an
undoable command, just like the others, so if you find that you've undone
too much just type @b[^X^U] again to undo the undo's.
