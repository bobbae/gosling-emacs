static char rcsid[] = "$Header: U-filecomp.c,v 1.2 88/05/04 17:57:50 trewitt Exp $";

/* File completion routines */

/* Original code by Chris Torek <chris@umcp-cs>

 * Modifications for 4.1[ac]BSD by Marshall Rose <mrose@uci>
   If you want the 4.1[ac]BSD version, #define LIBNDIR.
   Note that this introduces the new global variable fast-file-searches.

 */

#include "config.h"
#include "buffer.h"
#include "window.h"
#include "keyboard.h"
#include "mlisp.h"
#include <sys/param.h>
#include <sys/types.h>
#ifdef	__osf__
#define	_BSD	/* BSD compatibility for directory structure names */
#endif	__osf__
#include <sys/dir.h>
#include <sys/stat.h>

#include "varargs.h"

#define DONE		0
#define CONTIN		1
#define GARBAGE		2
#define CANTHELP	3
#define EMPTY		4
#define MANY		5

#define min(a,b) ((a)<(b)?(a):(b))
#ifdef	LIBNDIR
#define max(a,b) ((a)>(b)?(a):(b))
#define	WID	18
#define	NCOLS	78
#endif

#ifndef	LIBNDIR
static char path[MAXPATHLEN], file[MAXNAMLEN];
#else
static char path[MAXPATHLEN], file[MAXNAMLEN];
#endif
static struct stat st;
static DirUsed;			/* Number of entries in DirEnts */
static unsigned DirSize;	/* Number of bytes allocated to DirEnts */
static DirSorted;		/* True iff table has been sorted */
static DirMatches;		/* Number of matches */
static MatchSize;		/* Number of characters matched */
static time_t	DirMtime;	/* st_mtime of current in-core dir */
static dev_t	DirDevice;	/* st_dev of current dir */
static ino_t	DirInode;	/* st_ino of current dir */
static struct direct *DirEnts;	/* The first entry */
static struct direct *FirstMatch;/* The first entry matching desired name */

extern int AutoHelp;
extern	PopUpWindows;
extern	RemoveHelpWindow;
static	struct window  *killee;

#ifdef	LIBNDIR
int FastFileSearches;		/* If true (the default) then Emacs will
				   not perform any fancy tests to determine
				   what files the user is interested in
				   during filename command completion */
#endif

static NewFilesInCompletion;	/* allow new files in completion routines */

char *malloc (), *realloc (), *index (), *rindex ();

extern char	BackupExtension[];
extern char	CheckpointExtension[];

static	PerformCompletion();
static	ReadDir();
static	MarkDir();
static	SplitPath();
static	showchoices();

/* Get the name of some existing file */

/* char *GetFileName (prompt) */
/* VARARGS 1 */
char *GetFileName(va_alist)
    va_dcl
{
    va_list		ap;
    static char		result[MAXPATHLEN];
    register		char *name = "";
    register		f, len;
    struct marker	*old_dot;
    struct marker	*old_start;
    int			oldpop = PopUpWindows;
    struct buffer	*old = bf_cur;

    if (RemoveHelpWindow)
	PopUpWindows = 0;
    killee = 0;

    *result = 0;
    for (;;) {
	char *prompt;
	char *arg1;
	va_start(ap);
	prompt = va_arg(ap, char *);
	arg1 = va_arg(ap, char *);
	name = BrGetstr (1, result, prompt, arg1, 0, 0, 0);
	if (name == 0)
	    goto cleanup;
	f = name[strlen(name)-1] == '/';
	abspath (name, result, MAXPATHLEN);
	name = result;
	len = strlen (name);
	if (f) {
	    name[len++] = '/';
	    name[len] = 0;
	}
	if (LastKeyStruck == '?') {	/* Show possible completions */
	    name[len - 1] = 0;
	    SplitPath (name, path, file);
	    if (ReadDir (path) == 0) {
		MarkDir (file);
		showchoices ("Choose one of these:\n");
	    }
	    else
		Ding ();
	}
	else switch (PerformCompletion (name)) {
	    case DONE:		/* we got a file */
		goto cleanup;
	    case GARBAGE:	/* foo on you */
		if (AutoHelp) {
		    ReadDir (path);
		    MarkDir (file);
		    showchoices ("Garbage!!  Use one of the following:\n");
		} else
		    Ding ();
		continue;
	    case CONTIN:	/* completed something */
		continue;
	    case CANTHELP:	/* directory unreadable */
		Ding ();
		continue;
	    case EMPTY:		/* empty directory */
		if (AutoHelp)
		    showchoices ("Empty directory!\n");
		Ding ();
		continue;
	    case MANY:		/* matches a bunch of names */
		if (AutoHelp) {
		    MarkDir (file);
		    showchoices ("Ambiguous, use one of the following:\n");
		}
		else
		    Ding ();
		continue;
	}
    }

cleanup:
    if (killee)
	WindowOn(old);
    PopUpWindows = oldpop;
    return name;
}

static
PerformCompletion (name)
register char *name;
{
    register diving = 0;
    register pathlen;		/* Quick index into path or name */

top:
    if (stat (name, &st) == 0 && (st.st_mode & S_IFDIR) == 0)
	return DONE;		/* Got a filename */

    if (NewFilesInCompletion && (LastKeyStruck == '\n' || LastKeyStruck == '\r'))
    	return DONE;		/* if they want to let them happen */

    SplitPath (name, path, file);
    if (stat (path, &st) || (st.st_mode & S_IFDIR) == 0) {
	do {
	    register char *p = path;
	    while (*p++) ;
	    p[-2] = 0;		/* Remove trailing slash */
	    SplitPath (path, path, file);
	}
	while (stat (path, &st) || (st.st_mode & S_IFDIR) == 0);
	strcpy (name, path);
	return GARBAGE;		/* No such directory */
    }

    if (access (path, 4) < 0)	/* Can't read directory */
	return diving ? CONTIN : CANTHELP;

    if (ReadDir (path)) {	/* "Can't happen" -- YES IT CAN  */
	return diving ? CONTIN : CANTHELP;
				/* was "Ding (); return CONTIN;  */
    }
    if (DirUsed == 0)
	return EMPTY;		/* Empty directory */
    pathlen = strlen (path);
    MarkDir (file);
    if (DirMatches == 0) {	/* No such file */
	do file[--MatchSize] = 0;
	while (MarkDir (file) == 0);
	strcpy (name+pathlen, file);
	return GARBAGE;
    }
    if (DirMatches == 1) {	/* Exact match on one name */
	diving++;
#ifndef	LIBNDIR
	strncpy (name+pathlen, FirstMatch -> d_name, MAXNAMLEN);
	*(name+pathlen+MAXNAMLEN) = 0;
#else				/* already null terminated */
	strcpy (name+pathlen, FirstMatch -> d_name);
#endif
	if (stat (name, &st) == 0 && st.st_mode & S_IFDIR)
	    strcat (name, "/");
	goto top;
    }
/*
 * Make the name as long as possible such that it still matches the
 * same entries.  If we cannot add anything then the name was ambiguous.
 */
    {
	register oDirMatches = DirMatches, extended = 0;

	while (file[MatchSize] = FirstMatch -> d_name[MatchSize]) {
	    MatchSize++;
#ifndef	LIBNDIR
	    if (MatchSize < MAXNAMLEN)
		file[MatchSize] = 0;
#else
	    if (MatchSize < MAXNAMLEN)
		file[MatchSize] = 0;
#endif
	    if (MarkDir (file) < oDirMatches) {
		file[--MatchSize] = 0;
		break;
	    }
	    extended++;
	}
#ifndef	LIBNDIR
	strncpy (name+pathlen, file, MAXNAMLEN);/* (current path is correct) */
#else
	strcpy (name+pathlen, file);
#endif
	return extended || diving ? CONTIN : MANY;
    }
}  /* PerformCompletion */


/* Make the table by reading the directory.  Return 0 if everything goes
   well.  Also, remember current table and only remake if new.
   Return -1 if we can't opendir() or allocate enough memory.  */

#ifndef	LIBNDIR
static
ReadDir (dir)
char *dir;
{
    static lastrv;
    register struct direct *d, *p;
    register char *s;
    register f, l;

    f = open (dir, 0);
    if (f < 0)
	return lastrv = -1;
    fstat (f, &st);
    if (st.st_mtime == DirMtime && st.st_dev == DirDevice
			&& st.st_ino == DirInode) {
	close (f);
	return lastrv;
    }
    DirMtime = st.st_mtime;
    DirDevice = st.st_dev;
    DirInode = st.st_ino;
    if (st.st_size >= DirSize) {
	if (DirEnts)
	    free ((char *) DirEnts);
	DirSize = st.st_size + 30;
	DirEnts = (struct direct *) malloc (DirSize);
    }
    DirSorted = 0;
    lastrv = read (f, (char *) DirEnts, st.st_size + 1) != st.st_size;
    close (f);
    if (lastrv)
	return lastrv;
    p = DirEnts;
    d = DirEnts;
    for (f = st.st_size / sizeof *p; --f >= 0; p++) {
	if (p -> d_ino == 0)
	    continue;
	s = p -> d_name;
	if (s[0] == '.' && (s[1] == 0 || (s[1] == '.' && s[2] == 0)))
	    continue;
	l = MAXNAMLEN;
	while (*s++ && --l >= 0);
	--s;
	switch (*--s) {
	    case 'o':
		if (*--s == '.')
		    continue;
	    case 'P':
		if (*--s == 'K' && *--s == 'C' && *--s == '.')
		    continue;
	    case 'k':
		if (*--s == 'a' && *--s == 'b' && *--s == '.')
		    continue;
	}
	*d++ = *p;
    }
    DirUsed = d - DirEnts;
    return 0;
}
#else
static
ReadDir (dir)
char *dir;
{
    static int  lastrv;
    register int    f,
                    g,
                    l;
    register char  *e,
                   *s;
    short   byte;		/* 16 bits (I hope) */
    static char filnam[MAXPATHLEN];
    register struct direct *d,
                           *p;
    register    DIR * dd;

    if ((dd = opendir (dir)) == NULL)
	return (lastrv = -1);
    fstat (dd -> dd_fd, &st);
    if (st.st_mtime == DirMtime
	    && st.st_dev == DirDevice
	    && st.st_ino == DirInode) {
	closedir (dd);
	return lastrv;
    }
    DirMtime = st.st_mtime;
    DirDevice = st.st_dev;
    DirInode = st.st_ino;

    for (f = 0; p = readdir (dd); f++)
	continue;
again: ;
    f += 10;			/* fudge factor... */
    l = f * sizeof (struct direct);
    if (l >= DirSize) {
	if (DirEnts)
	    free ((char *) DirEnts);
	DirSize = l;		/*   * 2;	/* why not? */
	/*  Because a 1375-entry directory wants 731280 bytes if you double
		it, you moron!  */
	DirEnts = (struct direct   *) malloc (DirSize);
	/* and malloc fails, and you didn't test it!  */
	if (!DirEnts)
	{
	    DirSize = 0;
	    DirUsed = 0;
	    return (lastrv = -1);
	}
    }

    DirSorted = 0;
    rewinddir (dd);
    for (d = DirEnts, g = 0; p = readdir (dd);) {
	if ((p -> d_namlen == 1 && !strcmp (p -> d_name, "."))
		|| (p -> d_namlen == 2 && !strcmp (p -> d_name, "..")))
	    continue;
	s = p -> d_name + p -> d_namlen;
	if (p -> d_namlen > 2 && !strcmp (s - 2, ".o"))
	    continue;
#ifdef	PrependExtension
	e = CheckpointExtension;
	if (!strncmp (p -> d_name, e, strlen (e)))
	    continue;
	e = BackupExtension;
	if (!strncmp (p -> d_name, e, strlen (e)))
	    continue;
#else
	e = CheckpointExtension;
	if (p -> d_namlen > (l = strlen (e)) && !strcmp (s - l, e))
	    continue;
	e = BackupExtension;
	if (p -> d_namlen > (l = strlen (e)) && !strcmp (s - l, e))
	    continue;
#endif
	if (FastFileSearches)
	    goto no_tricks;
	sprintfl (filnam, sizeof filnam, "%s/%s", dir, p -> d_name);
	if (stat (filnam, &st))
	    continue;
	if ((st.st_mode & S_IFDIR) != 0)
	    l = -1;
	else
	    if ((l = open (filnam, 0)) < 0)
		continue;
	if (l >= 0) {
	    if (read (l, (char *) (&byte), sizeof byte) != sizeof byte)
		byte = 0;
	    close (l);
	    switch (byte) {	/* is it a text file? */
		case 0405: 
		case 0407: 	/* OMAGIC */
		case 0410: 	/* NMAGIC */
		case 0411: 
		case 0413: 	/* ZMAGIC */
		case (char) 0177545: 
		    continue;

		default: 	/* perhaps it is... */
		    break;
	    }
	}

no_tricks: ;
	if (f <= g++) {		/* directory grew!!! */
	    for (f = g; p = readdir (dd); f++)
		continue;
	    goto again;
	}
	d -> d_ino = p -> d_ino;
	d -> d_reclen = sizeof (struct direct);
	d -> d_namlen = p -> d_namlen;
	strcpy (d -> d_name, p -> d_name);
	d++;
    }
    closedir (dd);
    DirUsed = d - DirEnts;
    return (lastrv = 0);
}
#endif

/* Mark all the table entries that match 'string' */
static
MarkDir (string)
char *string;
{
    register struct direct *p;
#ifndef	LIBNDIR
    register len = MAXNAMLEN;
    register char *s = string;
#endif

#ifndef	LIBNDIR
    while (*s++ && --len >= 0) ;
    MatchSize = s - string - 1;
#else
    MatchSize = min (strlen (string), MAXNAMLEN);
#endif
    DirMatches = 0;
    for (p = &DirEnts[DirUsed - 1]; p>=DirEnts; p--)
	if (MatchSize == 0 || p->d_name[0]==string[0]
			&& strncmp(p->d_name,string,MatchSize)==0) {
	    DirMatches++;
	    p -> d_ino = 1;
	    FirstMatch = p;
	} else p->d_ino = 0;
    return DirMatches;
}

/* Compare two table entries (for qsort) */

static
DirCompare (p1, p2)
register struct direct *p1, *p2;
{
#ifndef	LIBNDIR
    return strncmp (p1 -> d_name, p2 -> d_name, MAXNAMLEN);
#else
    return strncmp (p1 -> d_name, p2 -> d_name,
	max (p1 -> d_namlen, p2 -> d_namlen));
#endif
}

/* Write all the matched entries into "Help" buffer.  Sort first if needed. */
static
showchoices (msg)
char *msg;
{
    register struct direct *p;
    register i;
#ifndef	LIBNDIR
    register side = 0;
    char buf[22];
#else
    register pos, j;
    char buf[MAXNAMLEN + WID];
#endif

    if (DirUsed > 1 && !DirSorted)
	qsort (DirEnts, DirUsed, sizeof (struct direct), DirCompare);
    DirSorted++;
    SetBfn ("Help");
    WindowOn (bf_cur);
    EraseBf (bf_cur);
    killee = wn_cur;
    InsStr (msg);
#ifndef	LIBNDIR
    for (p = DirEnts, i=DirUsed; --i>=0; p++) {
	if (p -> d_ino) {
	    sprintfl (buf, sizeof buf, (side==3 ? ((side=0), "%.*s\n")
		  : (side++, "%-18.*s")), MAXNAMLEN, p -> d_name);
	    InsStr (buf);
	}
    }
#else
    for (p = DirEnts, i = DirUsed, pos = 0; --i >= 0; p++)
	if (p -> d_ino) {
	    if (pos > 0) {
		if (pos + (j = WID - (pos % WID)) + p -> d_namlen > NCOLS)
		    pos = j = 0, InsStr ("\n");
	    }
	    else
		j = 0;
	    sprintfl (buf, sizeof buf, "%*s%.*s", j, "",
		    p -> d_namlen, p -> d_name);
	    InsStr (buf);
	    pos += p -> d_namlen +j;
	}
#endif
    BeginningOfFile ();
    bf_cur -> b_mode.md_NeedsCheckpointing = 0;
    bf_modified = 0;
    return;
}

/* Split a pathname into directory and filename components */
static SplitPath (path, dir, file)
register char *path;
char *dir, *file; {
    register char *p, *d = 0;

    for (p = path; *p; ) if (*p++ == '/') d = p;
    if (d) {
	strncpy (dir, path, d - path);
	dir[d-path] = 0;
#ifndef	LIBNDIR
	strncpy (file, d, MAXNAMLEN);
#else
	strncpy (file, d, MAXNAMLEN);
#endif
    } else {
	dir[0] = 0;
#ifndef	LIBNDIR
	strncpy (file, path, MAXNAMLEN);
#else
	strncpy (file, path, MAXNAMLEN);
#endif
    }
}

static	VisitExistingFileCommand () {
    VisitFile (GetFileName ("Visit existing file: "), 1, 1);
    return 0;
}

static	InsertExistingFileCommand () {
    readfile ( SaveAbs (GetFileName ("Insert existing file: ")), 0, 0);
    bf_modified++;
    return 0;
}

/* ACT */
GetExistingFile () {
    char *prompt = savestr (getstr (": get-existing-file (prompt) ")),
	 *GetFileName ();
    register struct ProgNode *OldExec = CurExec;

    CurExec = 0;
    ReleaseExpr (MLvalue);
    MLvalue -> exp_v.v_string = GetFileName ("%s", prompt);
    free (prompt);
    CurExec = OldExec;
    if (MLvalue -> exp_v.v_string == 0)
	MLvalue -> exp_type = IsVoid;
    else {
	MLvalue -> exp_type = IsString;
	MLvalue -> exp_release = 0;
	MLvalue -> exp_int = strlen (MLvalue -> exp_v.v_string);
    }
    return 0;
}

InitFComp () {
#ifdef DumpableEmacs
    if (!Once)
#endif
    {
#ifdef	LIBNDIR
	DefIntVar ("fast-file-searches", &FastFileSearches);
	FastFileSearches = 1;
#endif	LIBNDIR
	DefIntVar ("new-files-in-completion", &NewFilesInCompletion);
	NewFilesInCompletion = 1;
	defproc (GetExistingFile, "get-existing-file");
	defproc(InsertExistingFileCommand, "insert-existing-file");
	setkey (CtlXmap, (Ctl ('Q')), VisitExistingFileCommand, "visit-existing-file");
    }
}
