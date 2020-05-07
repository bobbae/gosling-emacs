/* string search routines */

/*		Copyright (c) 1981,1980 James Gosling		*/

/* Modified Aug. 12, 1981 by Tom London to include regular expressions
   as in ed.  RE stuff hacked over by jag to correct a few major problems,
   mainly dealing with searching within the buffer rather than copying
   each line to a separate array.  Newlines can now appear in RE's */

#include "buffer.h"
#include "window.h"
#include "keyboard.h"
#include "mlisp.h"
#include "syntax.h"
#include "search.h"
#include <ctype.h>

char  *malloc();


/* meta characters in the "compiled" form of a regular expression */
#define	CBRA	2		/* \( -- begin bracket */
#define	CCHR	4		/* a vanilla character */
#define	CDOT	6		/* . -- match anything except a newline */
#define	CCL	8		/* [...] -- character class */
#define	NCCL	10		/* [^...] -- negated character class */
#define	CDOL	12		/* $ -- matches the end of a line */
#define	CEOF	14		/* The end of the pattern */
#define	CKET	16		/* \) -- close bracket */
#define	CBACK	18		/* \N -- backreference to the Nth bracketed
				   string */
#define CIRC	20		/* ^ matches the beginning of a line */
#define BBUF	22		/* beginning of buffer \` */
#define EBUF	24		/* end of buffer \' */
#define BDOT	26		/* matches before dot \< */
#define EDOT	28		/* matches at dot \= */
#define ADOT	30		/* matches after dot \> */
#define WORD	32		/* matches word character \w */
#define NWORD	34		/* matches non-word characer \W */
#define WBOUND	36		/* matches word boundary \b */
#define NWBOUND	38		/* matches non-(word boundary) \B */

#define	STAR	01		/* * -- Kleene star, repeats the previous
				   REas many times as possible; the value
				   ORs with the other operator types */

typedef int    TranslateTable[0400];

static  TranslateTable
        StandardTRT,		/* the identity TRT */
        CaseFoldTRT,		/* folds upper to lower case */
        WordTRT;		/* folds upper to lower case and
				   punctuation to blanks */

static  ReplaceCase;		/* If true then replace and
				   query-replace will modify the case
				   conventions of the new string to
				   match those of the old. */

/* search for the n'th occurrence of string s in the current buffer,
   starting at dot, leaving dot at the end (if forward) or beginning
   (if reverse) of the found string.  returns true or false
   depending on whether or not the string was found */
search (s, n, dot, RE)
char   *s; {
    register    pos = dot;
    register    matl;
    register int  *trt;

    trt = search_globals.TRT = bf_mode.md_FoldCase ? CaseFoldTRT : StandardTRT;
    if (s == 0)
	return -1;
    compile (s, RE);
    while (!err && n)
	if (n < 0) {
	    if (pos <= FirstCharacter)
		return 0;
	    if ((matl = execute (0, pos - 1)) < 0)
		return 0;
	    ++n;
	    pos = search_globals.loc1;
	}
	else {
	    if (pos > NumCharacters)
		return 0;
	    if ((matl = execute (1, pos)) < 0)
		return 0;
	    --n;
	    pos = search_globals.loc1 + matl;
	}
    return err ? -1 : pos;
}

static
LookingAt () {			/* (looking-at "str") is true iff we're
				   currently looking at the given RE */
    register char  *s = getstr (": looking-at ");
    register int **alt = search_globals.alternatives;
    if (s == 0)
	return 0;
    compile (s, 1);
    MLvalue -> exp_int = 0;
    while (*alt && !err)
	if (MLvalue -> exp_int = advance (dot, *alt++))
	    break;
    MLvalue -> exp_type = IsInteger;
    search_globals.loc1 = dot;
    return 0;
}

SearchReverse () {
    register    np;
    if (arg <= 0)
	arg = 1;
    np = search (getstr ("Reverse search for: "), -arg, dot, 0);
    if (np == 0)
	error ("Can't find it");
    else
	if (np > 0)
	    SetDot (np);
    return 0;
}

SearchForward () {
    register    np;
    if (arg <= 0)
	arg = 1;
    np = search (getstr ("Search for: "), arg, dot, 0);
    if (np == 0)
	error ("Can't find it");
    else
	if (np > 0)
	    SetDot (np);
    return 0;
}

static
ReplaceString () {
    PerformReplace (0, 0);
    return 0;
}

static
QueryReplaceString () {
    PerformReplace (1, 0);
    return 0;
}

ReSearchReverse () {
    register    np;
    if (arg <= 0)
	arg = 1;
    np = search (getstr ("Reverse RE search for: "), -arg, dot, 1);
    if (np == 0)
	error ("Can't find it");
    else
	if (np > 0)
	    SetDot (np);
    return 0;
}

ReSearchForward () {
    register    np;
    if (arg <= 0)
	arg = 1;
    np = search (getstr ("RE Search for: "), arg, dot, 1);
    if (np == 0)
	error ("Can't find it");
    else
	if (np > 0)
	    SetDot (np);
    return 0;
}

static
ReReplaceString () {
    PerformReplace (0, 1);
    return 0;
}

static
ReQueryReplaceString () {
    PerformReplace (1, 1);
    return 0;
}

static
PerformReplace (query, RE) {	/* perform either a query replace or a
				   normal replace */
    register char  *old = getstr ("Old %s: ", RE ? "pattern" : "string");
    char  *TempNew;
    char new[1000];
    int     np,
            comma = 0;
    register char   c;
    int     replaced = 0;
    int     olddot = dot;

    if (old == 0 || (compile (old, RE), err)
	    || (TempNew = getstr ("New string: ")) == 0)
	return 0;
    strcpyn (new, TempNew, sizeof new - 1);
    new[sizeof new - 1] = 0;
    if (query)
	message ("Query-Replace mode");
    do {
	np = search ("", 1, dot, RE);
	if (np <= 0)
	    break;
	SetDot (np);
	comma = 0;
	do {
	    switch (c = query ? GetChar () : ' ') {
		case ' ': 
		case '!': 
		case '.': 
		case ',': {
			enum {
			    do_nothing, UPPER, First, FirstAll
			} action = do_nothing;
			if (!comma) {
			    if (ReplaceCase) {
				register    i;
				int     BegOfStr,
				        BegOfWord;
				register char   lc;
				BegOfStr = 1;
				i = search_globals.loc1;
				BegOfWord = i <= FirstCharacter
						|| !isalpha (CharAt (i - 1));
				while (i < search_globals.loc2) {
				    if (isalpha (lc = CharAt (i))) {
					if (isupper (lc)) {
					    if (BegOfStr)
						action = First;
					    else
						if (BegOfWord && action != UPPER)
						    action = FirstAll;
						else
						    action = UPPER;
					}
					else
					    if (action == UPPER || action == FirstAll && BegOfWord) {
						action = do_nothing;
						break;
					    } BegOfStr = 0;
					BegOfWord = 0;
				    }
				    else
					BegOfWord = 1;
				    i++;
				}
			    }
			    {
				int     BegOfStr,
				        BegOfWord;
				register char  *p;
				register unsigned char  lc;
				unsigned char   prefix = 0;
				BegOfStr = 1;
				BegOfWord = dot <= FirstCharacter
					|| !isalpha (CharAt (dot - 1));
				for (p = new; lc = *p++;) {
				    lc |= prefix;
				    prefix = 0;
				    if (action != do_nothing && isascii (lc)
					&& isalpha (lc)) {
					if (islower (lc)
						&& (action == UPPER
						    || action == FirstAll
						    && BegOfWord
						    || action == First
						    && BegOfStr))
					    lc = toupper (lc);
					BegOfWord = 0;
					BegOfStr = 0;
				    }
				    else
					BegOfWord = 1;
				    if (lc == '\\' && RE)	/* ') */
					prefix = 0200;
				    else
					if (lc == '&' && RE)
					    place (search_globals.loc1, search_globals.loc2);
					else
					    if (lc >= ('1' | 0200) && lc < ((search_globals.nbra + '1') | 0200))
						place (search_globals.braslist[lc - ('1' | 0200)],
							search_globals.braelist[lc - ('1' | 0200)]);
					    else {
						InsertAt (dot, (int) lc & 0177);
						DotRight (1);
					    }
				}
			    }
			    if (search_globals.loc1 == search_globals.loc2)
				DotRight (1);
			    else {
				DotLeft (search_globals.loc2 - search_globals.loc1);
				DelBack (search_globals.loc2, search_globals.loc2 - search_globals.loc1);
			    }
			    replaced++;
			} if (c == '!')
			    query = 0;
			if (c == '.')
			    c = Ctl ('G');
			break;
		    }
		case '\033':
		    c = Ctl ('G');
		case 'n': 
		case '\177':
		case Ctl ('G'): 
		    break;
		case 'r':
		    {	struct search_globals lglobals;
			struct marker *m = NewMark ();
			lglobals = search_globals;
			SetMark (m, bf_cur, search_globals.loc1);
			message ("Type ^C to resume query-replace");
			RecursiveEdit ();
			SetDot (ToMark (m));
			DestMark (m);
			WindowOn (bf_cur);
			message ("Continuing with query-replace...");
			search_globals = lglobals;
			break;
		    }
		default: 
		    message ("Options: ' ' ','=>change; 'n'=>don't; '.'=>change, quit; '^G'=>quit");
		    c = '?';
		    break;
	    }
	    if (c == ',')
		comma++;
	} while (c == '?' || c == ',');
    } while (c != Ctl ('G'));
    if (replaced)
	message ("Replaced %d occurrences", replaced);
    else
	error ("No replacements done ");
    SetDot (olddot);
    VoidResult ();
    return 0;
}

/* put dot and mark around the region matched by the n'th parenthesised
   expression from the last search (n=0 => the whole thing) */
RegionAroundMatch () {
    register    n = getnum (": region-around-match ");
    register    lo,
                hi;
    if (n < 0 || n > search_globals.nbra)
	error (" Out-of-bounds argument to region-around-match ");
    if (err)
	return 0;
    if (n == 0)
	lo = search_globals.loc1, hi = search_globals.loc2;
    else
	lo = search_globals.braslist[n-1], hi = search_globals.braelist[n-1];
    SetDot (lo);
    SetMarkCommand ();
    SetDot (hi);
    return 0;
}

/* Quote a string to inactivate reg-expr chars */
Quote() {
    register char *p, *cp, *s = getstr(": quote ");
    register int size;

    if (s == 0)
	return 0;
    size = strlen(s);
    for (cp=s;
	*cp;
	cp++)
	if (*cp == '[' || *cp == ']' || *cp == '*' || *cp == '.' || *cp=='\\'
		|| (*cp == '^' && cp==s) || (*cp == '$' && *(cp+1) == 0))
	    size++;
    p = (char *) malloc(size+1);
    for (cp=p; *s; )
	if (*s == '[' || *s == ']' || *s == '*' || *s == '.' || *s=='\\'
		|| (*s == '^' && cp==p) || (*s == '$' && *(s+1) == 0)) {
	    *cp++ = '\\';
	    *cp++ = *s++;
	}
	else
	    *cp++ = *s++;
    *cp = 0;
    ReleaseExpr (MLvalue);
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_int = size;
    MLvalue -> exp_release = 1;
    MLvalue -> exp_v.v_string = p;
    return 0;
}

/* Compare two chars according to case-fold   APW 1/81 */
static
CharCompare () {
    register int  *trt = search_globals.TRT;
    register    a = binsetup ();
    register    b = NumericArg (2);
    trt = search_globals.TRT = bf_mode.md_FoldCase ? CaseFoldTRT : StandardTRT;
    MLvalue -> exp_type = IsInteger;
    MLvalue -> exp_int = (trt[a] == trt[b]);
    return (0);
}

InitSrch () {			/* Initialize the search package, mostly just
				   sets up translation tables */
    register int    i;
    if (!Once)
    {
	for (i = 0;
	    i < 0400;
	    i++) {
	    StandardTRT[i] = CaseFoldTRT[i] = i;
	    WordTRT[i] = ' ';
	}
	for (i = 'A';
	    i <= 'Z';
	    i++)
	    WordTRT[i + ('a' - 'A')] = WordTRT[i] = CaseFoldTRT[i] =
		i + ('a' - 'A');
	for (i = '0';
	    i <= '9';
	    i++)
	    WordTRT[i] = i;
	setkey (GlobalMap, (Ctl ('S')), SearchForward, "search-forward");
	setkey (GlobalMap, (Ctl ('R')), SearchReverse, "search-reverse");
	setkey (ESCmap, ('r'), ReplaceString, "replace-string");
	setkey (ESCmap, ('q'), QueryReplaceString, "query-replace-string");
	defproc (ReSearchForward, "re-search-forward");
	defproc (ReSearchReverse, "re-search-reverse");
	defproc (ReReplaceString, "re-replace-string");
	defproc (ReQueryReplaceString, "re-query-replace-string");
	defproc (LookingAt, "looking-at");
	defproc (RegionAroundMatch, "region-around-match");
	defproc (Quote, "quote");
	defproc (CharCompare, "c=");
	DefIntVar ("replace-case", &ReplaceCase);
    }
}

/* Compile the given regular expression into a [secret] internal format */
static
compile (strp, RE)
char   *strp; {
    register    c;
    register int  *ep;
    int    *lastep;
    int     bracket[NBRA],
           *bracketp;
    int     cclcnt;
    int **alt = search_globals.alternatives;

    ep = search_globals.expbuf;
    *alt++ = ep;
    bracketp = bracket;
    if (*strp == 0) {
	if (*ep == 0)
	    error ("null search string");
	return;
    }
    search_globals.nbra = 0;
    lastep = 0;
    for (;;) {
	if (ep >= &search_globals.expbuf[ESIZE])
	    goto cerror;
	c = *strp++;
	if (c == 0) {
	    if (bracketp != bracket)
		goto cerror;
	    *ep++ = CEOF;
	    *alt++ = 0;
	    return;
	}
	if (c != '*')
	    lastep = ep;
	if (!RE) {
	    *ep++ = CCHR;
	    *ep++ = c;
	}
	else
	    switch (c) {

		case '\\': 
		    switch (c = *strp++) {
		    case '(':
			if (search_globals.nbra >= NBRA)
			    goto cerror;
			*bracketp++ = search_globals.nbra;
			*ep++ = CBRA;
			*ep++ = search_globals.nbra++;
			break;
		    case '|':
			if (bracketp>bracket) goto cerror;	/* Alas! */
			*ep++ = CEOF;
			*alt++ = ep;
			break;
		    case ')':
			if (bracketp <= bracket)
			    goto cerror;
			*ep++ = CKET;
			*ep++ = *--bracketp;
			break;
		    case '<':
			*ep++ = BDOT;
			break;
		    case '=':
			*ep++ = EDOT;
			break;
		    case '>':
			*ep++ = ADOT;
			break;
		    case '`':
			*ep++ = BBUF;
			break;
		    case '\'':
			*ep++ = EBUF;
			break;
		    case 'w':
			*ep++ = WORD;
			break;
		    case 'W':
			*ep++ = NWORD;
			break;
		    case 'b':
			*ep++ = WBOUND;
			break;
		    case 'B':
			*ep++ = NWBOUND;
			break;
		    case '1':
		    case '2':
		    case '3':
		    case '4':
		    case '5':	/* if (c >= '1' && c < '1' + NBRA) */
			*ep++ = CBACK;
			*ep++ = c - '1';
			break;
		    default:
			*ep++ = CCHR;
			if (c == '\0')
			    goto cerror;
			*ep++ = c;
			break;
		    }
		    break;
		case '.': 
		    *ep++ = CDOT;
		    continue;

		case '*': 
		    if (lastep == 0 || *lastep == CBRA || *lastep == CKET
			|| *lastep == CIRC || BBUF<=*lastep && *lastep<=ADOT
			|| (*lastep&STAR)|| *lastep>NWORD)
			goto defchar;
		    *lastep |= STAR;
		    continue;

		case '^':
		    if (ep != search_globals.expbuf && ep[-1] != CEOF)
			goto defchar;
		    *ep++ = CIRC;
		    continue;

		case '$': 
		    if (*strp != 0 && (*strp != '\\' || strp[1] != '|'))
			goto defchar;
		    *ep++ = CDOL;
		    continue;

		case '[': 
		    *ep++ = CCL;
		    *ep++ = 0;
		    cclcnt = 1;
		    if ((c = *strp++) == '^') {
			c = *strp++;
			ep[-2] = NCCL;
		    }
		    do {
			if (c == '\0')
			    goto cerror;
			if (c == '-' && ep[-1] != 0) {
			    if ((c = *strp++) == ']') {
				*ep++ = '-';
				cclcnt++;
				break;
			    }
			    while (ep[-1] < c) {
				/* Ridiculous!  This should be reflected
				   in the compiled form! */
				*ep = ep[-1] + 1;
				ep++;
				cclcnt++;
				if (ep >= &search_globals.expbuf[ESIZE])
				    goto cerror;
			    }
			}
			*ep++ = c;
			cclcnt++;
			if (ep >= &search_globals.expbuf[ESIZE])
			    goto cerror;
		    } while ((c = *strp++) != ']');
		    lastep[1] = cclcnt;
		    continue;

	    defchar: 
		default: 
		    *ep++ = CCHR;
		    *ep++ = c;
	    }
    }
cerror: 
    search_globals.expbuf[0] = 0;
    search_globals.nbra = 0;
    error ("Badly formed search string");
}

/* Check to see whether the most recently compile'd regular expression
   matches the string starting at addr in the buffer.
   The search match is performed in the current buffer.
   fflag is true iff we're doing a forward search. */
static
execute (fflag, addr) {
    register int    p1 = addr;
    register int   *trt = search_globals.TRT;
    register    c;
    int     incr = fflag ? 1 : -1;

    for (c = 0; c < NBRA; c++) {
	search_globals.braslist[c] = 0;
	search_globals.braelist[c] = 0;
    }
    if (addr == 0)
	return (-1);
    if (search_globals.expbuf[0] == CCHR && !search_globals.alternatives[1]) {
	c = trt[search_globals.expbuf[1]];	/* fast check for first character */
	do {
	    if (trt[CharAt (p1)] == c && advance (p1, search_globals.expbuf)) {
		search_globals.loc1 = p1;
		return (search_globals.loc2 - search_globals.loc1);
	    }
	    p1 += incr;
	} while (p1 <= NumCharacters && p1 >= FirstCharacter && !err);
	return (-1);
    }
    else			/* regular algorithm */
	do {
	    register int **alt = search_globals.alternatives;
	    while (*alt)
		if (advance (p1, *alt++)) {
		    search_globals.loc1 = p1;
		    return (search_globals.loc2 - search_globals.loc1);
		}
	    p1 += incr;
	} while (p1 <= NumCharacters && p1 >= FirstCharacter && !err);
    return (-1);
}

/* advance the match of the regular expression starting at ep along the
   string lp, simulates an NDFSA */
static
advance (lp, ep)
register int  *ep;
register lp; {
    register curlp;
    int     i;
    register int  *trt = search_globals.TRT;

    while ((*ep & STAR) || lp <= NumCharacters || *ep == CKET || *ep == EBUF)
	switch (*ep++) {

	    case CCHR: 
		if (trt[*ep++] != trt[CharAt(lp)]) return (0);
		lp++;
		continue;

	    case CDOT: 
		if (CharAt(lp) == '\n') return (0);
		lp++;
		continue;

	    case CDOL: 
		if (CharAt(lp) == '\n')
		    continue;
		return (0);

	    case CIRC:
		if (lp<=FirstCharacter || CharAt (lp-1)=='\n')
		    continue;
		return 0;

	    case BBUF:
		if (lp<=FirstCharacter)
		    continue;
		return 0;

	    case EBUF:
		if (lp>NumCharacters)
		    continue;
		return 0;

	    case BDOT:
		if (lp<=dot)
		    continue;
		return 0;

	    case EDOT:
		if (lp==dot)
		    continue;
		return 0;

	    case ADOT:
		if (lp>=dot)
		    continue;
		return 0;

	    case WORD:
		if (CharIs (CharAt (lp), WordChar)) {
		    lp++;
		    continue;
		}
		return 0;

	    case NWORD:
		if (!CharIs (CharAt (lp), WordChar)) {
		    lp++;
		    continue;
		}
		return 0;

	    case WBOUND:
		if ((lp<=FirstCharacter || !CharIs (CharAt (lp-1), WordChar)) !=
			(lp>NumCharacters || !CharIs (CharAt (lp), WordChar)))
		    continue;
		return 0;

	    case NWBOUND:
		if ((lp<=FirstCharacter || !CharIs (CharAt (lp-1), WordChar)) ==
			(lp>NumCharacters || !CharIs (CharAt (lp), WordChar)))
		    continue;
		return 0;

	    case CEOF: 
		search_globals.loc2 = lp;
		return (1);

	    case CCL: 
		if (cclass (ep, CharAt(lp), 1)) {
		    ep += *ep;
		    lp++;
		    continue;
		}
		return (0);

	    case NCCL: 
		if (cclass (ep, CharAt(lp), 0)) {
		    ep += *ep;
		    lp++;
		    continue;
		}
		return (0);

	    case CBRA: 
		search_globals.braslist[*ep++] = lp;
		continue;

	    case CKET: 
		search_globals.braelist[*ep++] = lp;
		continue;

	    case CBACK: 
		if (search_globals.braelist[i = *ep++] == 0)
		    error ("bad braces");
		if (backref (i, lp)) {
		    lp += search_globals.braelist[i] - search_globals.braslist[i];
		    continue;
		}
		return (0);

	    case CBACK | STAR: 
		if (search_globals.braelist[i = *ep++] == 0)
		    error ("bad braces");
		curlp = lp;
		while (backref (i, lp)) {
		    lp += search_globals.braelist[i] - search_globals.braslist[i];
		}
		while (lp >= curlp) {
		    if (advance (lp, ep))
			return (1);
		    lp -= search_globals.braelist[i] - search_globals.braslist[i];
		}
		continue;

	    case CDOT | STAR: 
		curlp = lp;
		while (lp++ <= NumCharacters && CharAt(lp-1) != '\n');
		goto star;

	    case WORD | STAR: 
		curlp = lp;
		while (lp++ <= NumCharacters && CharIs (CharAt(lp-1), WordChar));
		goto star;

	    case NWORD | STAR: 
		curlp = lp;
		while (lp++ <= NumCharacters && !CharIs (CharAt(lp-1), WordChar));
		goto star;

	    case CCHR | STAR: 
		curlp = lp;
		while (lp++ <= NumCharacters && trt[CharAt(lp-1)] == trt[*ep]);
		ep++;
		goto star;

	    case CCL | STAR: 
	    case NCCL | STAR: 
		curlp = lp;
		while (lp++ <= NumCharacters
			&& cclass (ep, CharAt(lp-1), ep[-1] == (CCL | STAR)));
		ep += *ep;
		goto star;

	star: 
		do {
		    lp--;
		    if (advance (lp, ep))
			return (1);
		} while (lp > curlp);
		return (0);

	    default: 
		error ("Badly compiled pattern (Emacs internal error!)");
	}
    if (*ep == CEOF || *ep == CDOL) {
	search_globals.loc2 = lp;
	return 1;
    }
    return 0;
}

static
backref (i, lp)
register i;
register lp;
{
    register bp;

    bp = search_globals.braslist[i];
    while (lp <= NumCharacters && CharAt(bp) == CharAt(lp)) {
	bp++;
	lp++;
	if (bp >= search_globals.braelist[i])
	    return (1);
    }
    return (0);
}

static
cclass (set, c, af)
register int  *set;
register    c;
{
    register    n;
    register int  *trt = search_globals.TRT;

    if (c == 0)
	return (0);
    n = *set++;
    while (--n)
	if (trt[*set++] == trt[c])
	    return (af);
    return (!af);
}

static
place (l1, l2)
register l1, l2; {
    while (l1 < l2) {
	InsertAt (dot, CharAt (l1));
	DotRight (1);
	l1++;
    }
}
