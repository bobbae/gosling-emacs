@Section(buff -- one-line buffer list)
@index(buff)@index(buffer list)
Loading the @i[buff] package replaces the binding for
^X-^B (usually @i[list-buffers]) with @i[one-line-buffer-list].

@begin(description)
@index(one-line-buffer-list)
@i[one-line-buffer-list]@\Gives a one-line buffer list in the mini-buffer.
If the buffer list is longer than one line, it will print a line at a time
and wait for a character to be typed before moving to the next line.
Buffers that have been changed since they were last saved are prefixed
with an asterisk (*), buffers with no associated file are prefixed with
a hash-mark (#), and empty buffers are prefixed with an at-sign (@@).
@end(description)

