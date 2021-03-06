/* File sort program.		James Gosling @ CMU, January 1981

Usage:
	filesort -k"key" -s files...

	-k"key" specifies that the key 'trigger' is to be the string
		"key".  It defaults to @key.

	-s	specifies Scribe format keys.

filesort reads through a set of files, breaks them into chunks based on the
key trigger and then sorts them based on a key taken from the chunk.  A
chunk begins at a line that contains an instance of the key trigger string;
the sort key used is the remainder of the line following the key trigger
string.  Case is ignored in the comparison.  Scribe format keys have
imbedded scribe directives stripped out and the key trigger must be a scribe
command (ie. it must be followed in the line by a scribe delimiter)

 */

#include <stdio.h>
#include <ctype.h>

struct SortElement {
    char   *key;
    char    filenum;
    short   nchars;
    int     filepos;
};

struct SortElement *L;
int     nelements = 0,
        arrsize = 0;
FILE * files[20];
int     scribe = 0;
int     nfiles;
char   *prefix = "@key";
int     prefixl = 4;

strcanon (dst,src)		/* Canonicalize a string copying from src to
				   dst -- copes with case and scribe mode */
register char *dst, *src;
{
    int     skipping = scribe;
    char    delims[50];
    char *ldst = dst, *lsrc=src;
    register    ndel = 0;
    while (*src)
	if (skipping) {
	    register char  *p = "[](){}<>''`'\"\"";
	    while (*p)
		if (*p++ == *src) {
		    delims[++ndel] = *p;
		    skipping = 0;
		    break;
		}
		else
		    p++;
	    src++;
	}
	else
	    if (isupper (*src))
		*dst++ = tolower (*src++);
	    else
		if (*src == delims[ndel])
		    ndel--, src++;
		else
		    if (scribe && *src == '@')
			skipping++, src++;
		    else
			if(*src<040) (*dst++ = 040), *src++ = '?';
			else *dst++ = *src++;
}

AddElement (key, filenum, filepos) {
    register struct SortElement *p;
    if (arrsize == 0)
	L = (struct SortElement *)
	                        malloc ((arrsize = 100) * sizeof *L);
    if (nelements >= arrsize)
	L = (struct SortElement *)
		realloc ((char *)L, (arrsize = arrsize * 3 / 2) * sizeof *L);
    p = &L[nelements++];
    p -> key = (char *) malloc (strlen (key) + 1);
    strcanon (p -> key, key);
    p -> filenum = filenum;
    p -> filepos = filepos;
    p -> nchars = 0;
/*  if(!p->key) nelements--; */
}

SetLen (nchars) {
    L[nelements - 1].nchars += nchars;
}

quit (fmt, a1, a2) {
	fprintf (stderr, fmt, a1, a2);
	exit(1);
}

ScanFile (p)
register    FILE * p;
{
    register int    filepos,
                    len;
    static char line[400];
    register char  *key;
    register    lastpos = -1;
    files[nfiles++] = p;
    if (nfiles > sizeof files / sizeof files[0])
	quit ("too many files\n");
    filepos = 0;
    while (fgets (line, 400, p) != NULL) {
	len = strlen (line);
	if (key = (char *) sindex (line, prefix)) {
	    if (lastpos >= 0)
		SetLen (filepos - lastpos);
	    AddElement (key + prefixl, nfiles - 1, lastpos = filepos);
	}
	filepos += len;
    }
    if (lastpos >= 0)
	SetLen (filepos - lastpos);
}


DumpArr () {
    register int    i;
    for (i = 0; i < nelements; i++) {
	register struct SortElement *p = &L[i];
	register    k = p -> nchars;
	register    FILE * f = files[p -> filenum];
	fseek (f, p -> filepos, 0);
	while (--k >= 0)
	    putchar (fgetc (f));
    }
}

keycomp (p1, p2)
struct SortElement *p1,
                   *p2;
{
    return strcmp (p1 -> key, p2 -> key);
}

main (argc, argv)
register char **argv; {
    while (--argc > 0)
	if (**++argv == '-')
	    switch (argv[0][1]) {
		case 'k': 
		    prefix = &argv[0][2];
		    prefixl = strlen (prefix);
		    break;
		case 's':
		    scribe++;
		    break;
		default: 
		    quit ("Illegal option: \"%s\"\b", *argv);
	    }
	else {
	    register    FILE * f = fopen (*argv, "r");
	    if (f == NULL)
		quit ("Can't open \"%s\"\n", *argv);
	    ScanFile (f);
	}
    qsort (L, nelements, sizeof L[0], keycomp);
    DumpArr ();
}
