/* Simple data base manager routines, styled after the dbm routines that came
   with Unix V7 (it uses a much modified version of them) */

/*		Copyright (c) 1981 James Gosling		*/

#include "buffer.h"
#include "window.h"
#include "keyboard.h"
#include "ndbm.h"
#define SearchLen 10		/* maximum number of components in a database
				   search list */
char  *malloc(), *SaveAbs();

struct dbsearch {		/* a database search list */
    int dbs_size;			/* number of components */
    struct dbsearch *dbs_next;	/* the next search list */
    char *dbs_name;		/* the name of this search list */
    database *dbs[SearchLen];	/* the components -- each is a database from
				   the ndbms package */
};

static struct dbsearch *dbroot;	/* the root of the list of database search
				   lists */

/* find a named search list */
static struct dbsearch *FindSL(name)
char   *name; {
    register struct dbsearch   *p;
    for (p = dbroot; p; p = p->dbs_next)
	if (strcmp (p -> dbs_name, name) == 0)
	    return p;
    return 0;
}

/* define a named search list (extend-database-search-list name content) */
static  ExtendDatabaseSearchList () {
    char   *name,
           *content;
    register struct dbsearch   *p;
    register i;
    name = getnbstr (": extend-database-search-list (name) ");
    if (name == 0)
	return 0;
    p = FindSL (name);
    if (p == 0) {
	p = (struct dbsearch   *) malloc (sizeof *p);
	p -> dbs_name = savestr (name);
	p -> dbs_next = dbroot;
	dbroot = p;
	p -> dbs_size = 0;
    }
    content = getnbstr (": extend-database-search-list (name) %s (dbname) ",
	    p -> dbs_name);
    if (content == 0)
	return 0;
    content = (char *) SaveAbs (content);
    for (i = 0; i < p -> dbs_size; i++)
	if (strcmp (content, p -> dbs[i] -> dbnm) == 0)
	    return 0;
    if (p -> dbs_size == SearchLen) {
	error ("Too many components in search list");
	return 0;
    }
    {
	register    database * db = open_db (content);
	if (db == 0)
	    error ("Can't find database \"%s\"", content);
	else {
	    for (i = p -> dbs_size; i > 0; i--)
		p -> dbs[i] = p -> dbs[i - 1];
	    p -> dbs[0] = db;
	    p -> dbs_size++;
	}
    }
    return 0;
}

/* function for inserting text into a buffer -- given a size returns a
   pointer to a region of size characters */
static char *InsertionFunc (n) {
            GapTo (dot);
    if (GapRoom (n))
	return 0;
    DoneIsDone ();
    if (n > 0) {
	bf_s1 += n;
	bf_gap -= n;
	bf_p2 -= n;
    }
    bf_modified++;
    return & CharAt (dot);
}

/* fetch an entry from a database into the current buffer
   (fetch-database-entry dbname key) */
static  FetchDatabaseEntry () {
    char   *dbname = getnbstr (": fetch-database-entry (database) ");
    register struct dbsearch   *dbs;
    register int    i;
    char   *key,
           *content;
    int     keylen,
            contentlen;
    if (dbname == 0)
	return 0;
    dbs = FindSL (dbname);
    if (dbs == 0) {
	error ("No such database search list defined");
	return 0;
    }
    key = getnbstr (": fetch-database-entry (database) %s (key) ",
	    dbs -> dbs_name);
    keylen = strlen (key);
    for (i = 0; i < dbs -> dbs_size; i++)
	if (get_db (key, keylen,
		    &content, &contentlen,
		    InsertionFunc, dbs -> dbs[i]) == 0)
	    break;
    Cant1LineOpt++;
    if (i >= dbs -> dbs_size)
	error ("Entry not found.");
    return 0;
}

/* Put the contents of the current buffer into a database
   (put-database-entry database key) */
static  PutDatabaseEntry () {
    char   *dbname = getnbstr (": put-database-entry (database) ");
    register struct dbsearch   *dbs;
    register int    i,
                    slot;
    int     keylen;
    int     contentlen;
    char   *key,
           *content;
    if (dbname == 0)
	return 0;
    dbs = FindSL (dbname);
    if (dbs == 0) {
	error ("No such database search list defined");
	return 0;
    }
    key = getnbstr (": put-database-entry (database) %s (key) ",
	    dbs -> dbs_name);
    keylen = strlen (key);
    GapTo (bf_s1 + bf_s2 + 1);
    slot = -1;
    for (i = 0; i < dbs -> dbs_size; i++)
	if (!dbs -> dbs[i] -> dbrdonly)
	    if (get_db (key, keylen, 0, 0, 0, dbs -> dbs[i])) {
		slot = i;
		break;
	    }
	    else
		if (slot < 0)
		    slot = i;
    if (slot < 0) {
	error ("%s is a read-only database.", dbs -> dbs_name);
	return 0;
    }
    if (put_db (key, strlen (key),
		&CharAt (1), bf_s1 + bf_s2,
		dbs -> dbs[slot]) < 0)
	error ("Database put failed -- probably a fatal key collision");
    return 0;
}

/* List the names and contents of all database search lists */
static  ListDatabases () {
    register struct dbsearch   *p;
    register    i;
    register struct buffer *old = bf_cur;
    SetBfn ("Database list");
    if (interactive)
	WindowOn (bf_cur);
    EraseBf (bf_cur);
    for (p = dbroot; p; p = p -> dbs_next) {
	char    buf[500];
	InsStr (sprintfl (buf, sizeof buf, "%s:\n", p -> dbs_name));
	for (i = 0; i < p -> dbs_size; i++) {
	    register    database * db = p -> dbs[i];
	    InsStr (sprintfl (buf, sizeof buf, "    %s%s\n", db -> dbnm,
			     db -> dbrdonly ? "   (read only)" : ""));
	}
    }
    bf_cur -> b_mode.md_NeedsCheckpointing = 0;
    bf_modified = 0;
    SetBfp (old);
    WindowOn (bf_cur);
    return 0;
}

InitDb () {
    if (!Once)
    {
	defproc (ExtendDatabaseSearchList, "extend-database-search-list");
	defproc (FetchDatabaseEntry, "fetch-database-entry");
	defproc (PutDatabaseEntry, "put-database-entry");
	defproc (ListDatabases, "list-databases");
    }
}
