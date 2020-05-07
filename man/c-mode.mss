@Section(c-mode -- simple assist for C programs)
@begin(description)
@ComRef[begin-C-comment]@\(ESC-`) Initiates the typing in of a comment.
Moves the cursor over to the comment column, inserts "/* " and turns on
autofill.  If ESC-` is typed in the first column, the the comment begins
there, otherwise it begins where ever @ComRef[comment-column] says it
should.

@ComRef[end-C-comment]@\(ESC-') Closes off the current comment.

@ComRef[indent-C-procedure]@\(ESC-j) Takes the current function (the one in which dot
is) and fixes up its indentation by running it through the "indent" program.

@end(description)
