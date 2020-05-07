@Section(dired -- directory editor)
@index(dired)@index(deleting files)
The @i[dired] package implements the @i[dired] command which provides some
simple convenient directory editing facilities.  When you run @i[dired] it
will ask for the name of a directory, displays a listing of it in a buffer,
and processes commands to examine files and possibly mark them for deletion.
When you're through with @i[dired] it actually deletes the marked files,
after asking for confirmation.  The commands it recognizes are:

@begin(description)
d@\Marks the current file for deletion.  A `D' will appear at the left
margin.  It does not actually delete the file, it just marks it.  The
deletion will be performed when @i[dired] is exited.  It also makes the next
file be the current one.

u@\Removes the deletion mark from the current file.  This is the command to
use if you change your mind about deleting a file.  It also makes the next
file be the current one.

RUBOUT@\Removes the deletion mark from the line preceeding the current one.
If you mark a file for deletion with `d' the current file will be advanced
to the next line.  RUBOUT undoes both the advancing and the marking for
deletion.

e, v@\Examine a file put putting it in another window and doing a
recursive-edit on it.  To resume @i[dired] type @b[^C].

r@\Removes the current file from the directory listing.  It doesn't delete
the file, it just gets rid of the directory listing entry.  Use it to remove
some of the clutter on your screen.

q, ^C@\Exits @i[dired].  For each file that has been marked for deletion you
will be asked for confirmation.  If you answer `y' the file will be deleted,
otherwise not.

n, ^N@\Moves to the next entry in the directory listing.

p, ^P@\Moves to the previous entry in the directory listing.

^V@\Moves to the next page in the directory listing.

ESC-v@\Moves to the previous page in the directory listing.

ESC-<@\Moves to the beginning of the directory listing.

ESC->@\Moves to the end of the directory listing.
@end(description)
