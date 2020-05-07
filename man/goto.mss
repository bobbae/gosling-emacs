@Section(goto -- go to position in buffer)
@Index[goto-line]@index(goto-percent)
@begin(description)
goto-line@\Moves the cursor to beginning of the indicated line. The line
number is taken from the prefix argument if it is provided, it is prompted
for otherwise.  Line numbering starts at 1.

goto-percent@\Moves dot to the indicated percentage of the buffer. The
percentage is taken from the prefix argument if it is provided, it is
prompted for otherwise. @w[@b[(goto-percent @p[n])]] goes to the character
that is @i[n]% from the beginning of the buffer.
@end(description)
