/* Unix Emacs Abbrev mode */

/*		Copyright (c) 1981,1980 James Gosling		*/

#include "buffer.h"
#include "syntax.h"
#include "abbrev.h"
#include "window.h"
#include "keyboard.h"
#include "macros.h"
#include "mlisp.h"
#include <ctype.h>

char 	*malloc();
#define MaxAbbrevTables 40	/* the maximum number of abbrev tables */

static
char *AbbrevTableNames[MaxAbbrevTables];
static
struct AbbrevTable *AbbrevTables[MaxAbbrevTables];
static
int NumberOfAbbrevTables;
static
char *LastPhrase;		/* The phrase that an abbrev expands to, for
				   use by abbrev-expansion */

static unsigned
hash (s)			/* hash an abbrev string */
register char *s;
{
    register    unsigned h = 0;
    while (*s)
	h = h * 31 + *s++;
    return h;
}

static struct AbbrevEnt *
lookup(table, name, h)		/* look up an abbrev in the given table with
				   the given name whose hash is h. */
struct AbbrevTable *table;
char *name;
register unsigned h;
{
    register struct AbbrevEnt  *p = table -> a_table[h % AbbrevSize];
    while (p && (p -> a_hash != h || strcmp (name, p -> a_abbrev) != 0))
	p = p -> a_next;
    return p;
}

static
define (table, abbrev, phrase, proc)	/* in the given abbrev table define the
					   given abbreviation for the given
					   phrase */
struct AbbrevTable *table;
char *abbrev, *phrase;
struct BoundName *proc;
{
    register struct AbbrevEnt  *p,
                              **root;
    register unsigned h = hash (abbrev);
    if (p = lookup (table, abbrev, h))
	free (p -> a_phrase);
    else {
	p = (struct AbbrevEnt  *) malloc (sizeof *p);
	p -> a_hash = h;
	p -> a_abbrev = savestr (abbrev);
	root = &table -> a_table[h % AbbrevSize];
	p -> a_next = *root;
	table -> a_NumberDefined++;
	*root = p;
    }
    p -> a_phrase = phrase;
    p -> a_ExpansionHook = proc;
}

static				/* given the name of an abbrev table, return
				   a pointer to it.  If it doesn't exist,
				   create it */
struct AbbrevTable *locate(name)
char *name;
{
    register    i = 0;
    register struct AbbrevTable *p;
    if(name==0 || *name==0) return 0;
    while (i < NumberOfAbbrevTables)
	if (strcmp (AbbrevTableNames[i], name) == 0)
	    return AbbrevTables[i];
	else i++;
    if (NumberOfAbbrevTables >= MaxAbbrevTables) {
	error ("Too many abbrev tables!");
	return 0;
    }
    p = (struct AbbrevTable *) malloc (sizeof *p);
    AbbrevTables[NumberOfAbbrevTables] = p;
    AbbrevTableNames[NumberOfAbbrevTables] = p -> a_name = savestr (name);
    NumberOfAbbrevTables++;
    p -> a_NumberDefined = 0;
    for (i = 0; i < AbbrevSize; i++)
	p -> a_table[i] = 0;
    return p;
}

static
DefineAbbrev (table, s, EProc)
struct AbbrevTable *table;
char *s;
{
    register char  *abbrev = getnbstr (": define-%s%s-abbrev ",
		EProc ? "hooked-" : "", s);
    register char  *phrase;
    register char *hook;
    int hookinx;
    char    s_abbrev[300];
    if (abbrev == 0)
	return;
    strcpyn (s_abbrev, abbrev, 300);
    phrase = getstr (": define-%s%s-abbrev %s phrase: ",
		EProc ? "hooked-" : "", s, s_abbrev);
    if (phrase == 0)
	return;
    hookinx = -1;
    phrase = savestr (phrase);
    if (EProc && (hookinx = getword (MacNames, "Hooked to procedure: ")) < 0)
	return;
    define (table, s_abbrev, phrase, hookinx < 0 ? 0 : MacBodies[hookinx]);
}

static
DefineGlobalAbbrev () {
    DefineAbbrev (&GlobalAbbrev, "global", 0);
    bf_cur -> b_mode.md_AbbrevOn = bf_mode.md_AbbrevOn = 1;
    return 0;
}

static
DefineLocalAbbrev () {
    if (bf_mode.md_abbrev == 0)
	error ("No abbrev table associated with this buffer.");
    else
	DefineAbbrev (bf_mode.md_abbrev, "local", 0);
    bf_cur -> b_mode.md_AbbrevOn = bf_mode.md_AbbrevOn = 1;
    return 0;
}

static
DefineHookedGlobalAbbrev () {
    DefineAbbrev (&GlobalAbbrev, "global", 1);
    return 0;
}

static
DefineHookedLocalAbbrev () {
    if (bf_mode.md_abbrev == 0)
	error ("No abbrev table associated with this buffer.");
    else
	DefineAbbrev (bf_mode.md_abbrev, "local", 1);
    return 0;
}

TestAbbrevExpand () {
    register char  *abbrev = getnbstr (": test-abbrev-expand ");
    register struct AbbrevEnt  *p;
    if (abbrev == 0)
	return 0;
    p = lookup (&GlobalAbbrev, abbrev, hash (abbrev));
    if (p == 0)
	message ("Abbrev \"%s\" isn't defined", abbrev);
    else
	message ("\"%s\" => \"%s\"  (%d)",
		 p -> a_abbrev, p -> a_phrase, p -> a_hash);
    return 0;
}

AbbrevExpand () {		/* called from SelfInsert to possibly
				   expand the abbrev that preceeds dot */
    register char  *p;
    register    n = dot;
    register struct AbbrevEnt  *a;
    register char   c;
    register int    h;
/*  static ExpandingAbbrev; */
    int rv = 0;
    int     uccount = 0;
    char    buf[200];
/*  if (ExpandingAbbrev) return 0; */
    p = buf + sizeof buf / sizeof buf[0];
    *--p = 0;
    while (--n >= 1 && CharIs (c = CharAt (n), WordChar)) {
	*--p = c;
	if (isupper (c))
	    uccount++, *p += 'a' - 'A';
    }
    h = hash (p);
    if ((!bf_mode.md_abbrev || (a = lookup (bf_mode.md_abbrev, p, h)) == 0)
	    && (a = lookup (&GlobalAbbrev, p, h)) == 0)
	return 0;
    bf_mode.md_AbbrevOn = 0;
    if (a -> a_ExpansionHook) {
	LastPhrase = a -> a_phrase;
/*	ExpandingAbbrev = 1; */
	ExecuteBound (a -> a_ExpansionHook);
/*	ExpandingAbbrev = 0; */
	LastPhrase = 0;
	rv = MLvalue -> exp_type == IsInteger && MLvalue ->exp_int == 0;
    }
    else {
	DelBack (dot, h = buf + sizeof buf / sizeof buf[0] - p - 1);
	DotLeft (h);
	for (p = a -> a_phrase; *p;)
	    SelfInsert (
		    islower (*p) && uccount
		    && (p == a -> a_phrase || uccount > 1
		    && isspace (*(p - 1)))
		    ? toupper (*p++) : *p++);
    }
    bf_mode.md_AbbrevOn = 1;
    return rv;
}

static
UseAbbrevTable () {		/* select a named abbrev table for this
				   buffer and turn on abbrev mode if it
				   or the global abbrev table is
				   non-empty */
    register struct AbbrevTable *p = locate (getnbstr (": use-abbrev-table "));
    if (p == 0)
	return 0;
    bf_cur -> b_mode.md_abbrev = bf_mode.md_abbrev = p;
    if (p -> a_NumberDefined > 0 || GlobalAbbrev.a_NumberDefined > 0)
	bf_cur -> b_mode.md_AbbrevOn = bf_mode.md_AbbrevOn = 1;
    return 0;
}

static
WriteAbbrevs(f,table)		/* write the given abbrev table to file f */
register FILE *f;
register struct AbbrevTable *table;
{
    register    i;
    register struct AbbrevEnt  *p;
    fprintf (f, "%s\n", table -> a_name);
    for (i = 0; i < AbbrevSize;)
	for (p = table -> a_table[i++]; p; p = p -> a_next)
	    fprintf (f, " %s	%s\n", p -> a_abbrev, p -> a_phrase);
}

static  WriteAbbrevFile () {
    register    i;
    register char  *fn = getstr (": write-abbrev-file ");
    register    FILE * f;
    if (fn == 0)
	return 0;
    if ((f = fopen (SaveAbs (fn), "w")) == NULL)
	error ("Can't write %s", fn);
    else {
	for (i = 0; i < NumberOfAbbrevTables; i++)
	    WriteAbbrevs (f, AbbrevTables[i]);
	fclose (f);
    }
    return 0;
}

static
ReadAbbrevs (s)
char *s;
{
    register char  *name = getstr (s);
    register    FILE * f;
    char    buf[500];
    register struct AbbrevTable *table = 0;
    register char  *p, *phrase;
    if (name == 0)
	return 0;
    if ((f = fopen (SaveAbs(name), "r")) == NULL)
	return 1;
    while (fgets (buf, sizeof buf, f) && !err)
	if (*buf != ' ') {
	    for(p=buf; *p; ) if(*p++=='\n') *--p = '\0';
	    table = locate (buf);
	}
	else if(table) {
	    p = buf + 1;
	    while (*p && *p != '\t')
		p++;
	    if(*p==0) {
		error ("Improperly formatted abbrev file.");
		return 0;
	    }
	    *p++ = 0;
	    phrase = p;
	    while(*p && *p!='\n') p++;
	    *p = 0;
	    define (table, buf + 1, savestr (phrase), 0);
	}
    fclose (f);
    return 0;
}

static
ReadAbbrevFile () {
    if (ReadAbbrevs (": read-abbrev-file "))
	error ("Can't find abbrev file");
    return 0;
}

static
QuietlyReadAbbrevFile () {
    ReadAbbrevs (": quietly-read-abbrev-file ");
    return 0;
}

StrFunc (AbbrevExpansion, LastPhrase ? LastPhrase : "")

InitAbbrev () {
    if (!Once)
    {
	defproc (DefineGlobalAbbrev, "define-global-abbrev");
	defproc (DefineLocalAbbrev, "define-local-abbrev");
	defproc (DefineHookedGlobalAbbrev, "define-hooked-global-abbrev");
	defproc (DefineHookedLocalAbbrev, "define-hooked-local-abbrev");
	defproc (WriteAbbrevFile, "write-abbrev-file");
	defproc (ReadAbbrevFile, "read-abbrev-file");
	defproc (AbbrevExpansion, "abbrev-expansion");
	defproc (QuietlyReadAbbrevFile, "quietly-read-abbrev-file");
	defproc (TestAbbrevExpand, "test-abbrev-expand");
	defproc (UseAbbrevTable, "use-abbrev-table");
	GlobalAbbrev.a_name = AbbrevTableNames[0] = "global";
	AbbrevTables[0] = &GlobalAbbrev;
	NumberOfAbbrevTables = 1;
    }
}
