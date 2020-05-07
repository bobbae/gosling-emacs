@Section(tags -- a function tagger and finder)
The tags package closely resembles the tags package found in Twenex
@Value(Emacs).  The database used by the tag package (called a tagfile)
correlates function definitions to the file in which the definitions appear.
The primary function of the tag package is to allow the user to specify the
name of a function, and then have @Value(Emacs) locate the definition of
that function.  The commands implemented are:

@begin(description)
add-tag@\Adds the current line (it should be the definition line for some
function) to the current tagfile.

goto-tag@\@begin(multiple)
@i[goto-tag] takes a single string argument which is usually the
name of a function and visits the file containing that function with the
first line of the function at the top of the window.  The string may
actually be a substring of the function name (actually, any substring of the
first line of the function definition).  If @i[goto-tag] is given a numeric
argument then rather than asking for a new string it will use the old string
and search for the next occurrence of that string in the tagfile.  This is
used for stepping through a set of tags that contain the same string.

This is the most commonly used command in the tag package so it is
often bound to a key: Twenex @Value(Emacs) binds it to @b[ESC-.], but the
Unix tag package doesn't bind it to anything, it presumes that the user will
bind it (I use @b[^X^G]).
@end(multiple)

make-tag-table@\Takes a list of file names (with wildcards allowed) and
builds a tagfile for all the functions in all of the files.  It determines
the language of the contents of the file from the extension.  This command
may take a while on large directories, be prepared to wait.  A common use is
to type "make-tag-table *.c".

recompute-all-tags@\Goes through your current tag file and for each file
mentioned refinds all of the tags.  This is used to rebuild an entire tag
file if you've made very extensive changes to the files mentioned and the
tag package is no longer able to find functions.  The tagfile contains
@i[hints] to help the system locate the tagged function, as you make changes
to the various files the hints become out of date.  Periodically (no too
often!) you should recompute the tagfile.

visit-function@\Takes the function name at or before dot, does a
@i[goto-tag] on that name, then puts you into a recursive-edit to look at
the function definition.  To get back to where you were, just type @b[^C].  
This is used when you're editing something, have dot positioned at some
function invocation, then want to look at the function.

visit-tag-table@\Normally the name of the tagfile is ".tags" in the current
directory.  If you want to use some other tagfile, visit-tag-table lets you
do that.
@end(description)
