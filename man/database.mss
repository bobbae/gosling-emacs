@Chapter(The @Value(Emacs) database facility)
Unix @Value(Emacs) provides a set of commands for dealing with databases of a
@Index(Help facilities)
rather primitive form.  These databases are intended to be used in @i[help]
facilities to find documentation for a given keyword, but they have many
other uses: managed mailboxes or nodes in an @i[info] tree.

A @i[database] is a set of (key, content) pairs which may be retrieved or
stored based on the key.  Both the key and the content may be arbitrary
strings of characters.  The content may be long, but there are restrictions
on the aggragate length of the keys.

A @i[database search list] is a list of databases.  When a key is looked up
in a database search list the databases in the search list are examined in
order for one containing the key.  The content corresponding to the first
key that matches is returned.  When a key is to have its content changed
only the first database in the search list is used.

The commands available for dealing with databases are:
@include(database.incl)

There are four Unix commands provided for dealing with @Value(Emacs) data
bases (these are commands that you give to the shell, not @Value(Emacs)):

@begin(enumerate)
@b[dbadd] -- add entry to an Emacs data base
@example<@b[dbadd] dbname key>

@b[dbcreate] -- create an Emacs data base
@example<@b[dbcreate] dbname>

@b[dblist] -- list contents of an Emacs data base
@example<@b[dblist] dbname @b<[ -l ] [ -p ]> newdbname>

@b[dbprint] -- print an entry from an Emacs data base
@example<@b[dbprint] dbname key>
@end(enumerate)

@b[Dbadd] adds the text from the standard input to the named database
using the given key.  @b[Dbcreate] creates the named database, making it
empty.  @b[Dbprint] prints the contents of the entry from the database
with the given key.

@b[Dblist] with no arguments simply lists the keys of all the items in the
database.  With the -@b[l] option it prints some internal information from
the database of no interest to anyone but the implementor.  The -@b[p]
option causes the key and content of every entry to be listed as a shell
command file which when executed will repeatedly invoke @b[dbadd] to
rebuild the database.  This form of @b[dblist] is handy when you want a
readable ascii file representation of a data base for shipping around or
editing.  Databases should be recreated periodically to garbage collect them.
