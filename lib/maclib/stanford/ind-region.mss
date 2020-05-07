@Section[ind-region -- indent (slide) blocks of lines left or right]
@index(ind-region)@index(indent region)
@index(indenting code, manual)
The @i[ind-region] package provides a function that will move a block of
text lines left or right, for manually meddling with indentation.
The set of lines that it operates on is defined by point and mark, but in
order to behave intuitively it doesn't quite use point and mark as a region.
In particular, it will include the complete contents of any line if any
character of that line falls in the marked region, and it will also include
a line if the first character of that line is right after the end of the
region. This behavior, while it sounds unusual, provides visual fidelity: if
you set the mark anywhere on one line, and then move the point to anywhere
on another line (including their beginnings or ends, respectively), then
those lines will be included in the set of lines that is indented left or
right.

If no argument is provided, the function will assume an indentation of +4,
which is a right shift of 4 spaces. In all cases, after the function has
finished indenting a line it will compute the minimal sequence of tabs and
spaces to effect the indentation.

