#define ACT
/* Ultra-hot screen management package
  		James Gosling, January 1980			*/

/*		Copyright (c) 1981,1980 James Gosling		*/

/****************************************************************



			 /-------------\
			/		\
		       /		 \
		      /			  \
		      |	  XXXX	   XXXX	  |
		      |	  XXXX	   XXXX	  |
		      |	  XXX	    XXX	  |
		      \		X	  /
		       --\     XXX     /--
			| |    XXX    | |
			| |	      | |
			| I I I I I I I |
			|  I I I I I I	|
			 \	       /
			  --	     --
			    \-------/
		    XXX			   XXX
		   XXXXX		  XXXXX
		   XXXXXXXXX	     XXXXXXXXXX
			  XXXXX	  XXXXX
			     XXXXXXX
			  XXXXX	  XXXXX
		   XXXXXXXXX	     XXXXXXXXXX
		   XXXXX		  XXXXX
		    XXX			   XXX

			  **************
			  *  BEWARE!!  *
			  **************

			All ye who enter here:
		    Most of the code in this module
		       is twisted beyond belief!

			   Tread carefully.

		    If you think you understand it,
			      You Don't,
			    So Look Again.

 ****************************************************************/

/* DJH -- Added Ding() for bell */


#include "display.h"
#include "window.h"
#include "keyboard.h"
#include "mlisp.h"
#include <sgtty.h>
#include <sys/types.h>

#ifndef titan
typedef long * waddr_t;
#endif

char  *malloc(), *getenv();
/* the following macros are used to access terminal specific routines.
   Really, no one outside of display.c should be using them, except for
   the initialize/cleanup routines */
#define topos (*tt.t_topos)
#define reset (*tt.t_reset)
#define INSmode (*tt.t_INSmode)
#define insertlines (*tt.t_inslines)
#define deletelines (*tt.t_dellines)
#define blanks (*tt.t_blanks)
#define wipeline (*tt.t_wipeline)
#define wipescreen (*tt.t_wipescreen)
#define deletechars (*tt.t_delchars)
#define dumpstring (*tt.t_writechars)

#define MScreenWidth 181
#define MScreenLength 107
#define min(a,b) (a<b ? a : b)
#define max(a,b) (a>b ? a : b)
#define hidden static
#define visible
#define procedure
#define function

hidden struct line {		/* a line as it appears in a list of
				   lines (as in the physical and virtual
				   display lists) */
    int     hash;		/* hash value for this line, 0 if not
				   known */
    struct line *next;		/* pointer to the next line in a list of
				   lines */
    short   DrawCost;		/* the cost of redrawing this line */
    short   length;		/* the number of valid characters in the
				   line */
    char    highlighted;	/* true iff this line is to be
				   highlighted */
    char    body[MScreenWidth];	/* the actual text of the line */
}
                   *FreeLines;	/* free space list */

hidden WindowSize;		/* the number of lines on which line ID
				   operations should be done */
int baud_rate;			/* Terminal speed, so we can calculate
				   the number of characters required to
				   make the cursor sit still for n secs. */
hidden CheckForInput;		/* -ve iff UpdateLine should bother
				   checking for input */

/* 'newline' returns a pointer to a new line object, either from the
   free list or from the general unix pool */
struct line *newline () {
    register struct line   *p = FreeLines;

    if (p) {
	FreeLines = p -> next;
	if (p -> hash != 12345) {
/*	    register FILE *f = fopen ("EMACS_TRACE", "w");
	    topos (23, 1);
	    printf ("*****Bogus value in display free list"); */
	    FreeLines = 0;
/*	    if (f) {
		register int *p1 = ((int *) p) - 10;
		register char *p2 = (char *) p1;
		register i;
		fprintf (f, "Bogus value in display free list at %o\n", p);
		for (i=0; i<25; i++) {
		    fprintf (f, "%11o: %011o %9d  %03o %03o %03o %03o\n",
				p1, *p1, *p1,
				p2[0], p2[1], p2[2], p2[3]);
		    p1++; p2 += 4;
		}
		fclose (f);
	    } */
	    return newline ();
	}
    }
    else {
	static Leakage;
	p = (struct line   *) malloc (sizeof *p);
	if (++Leakage>(2*MScreenLength)) printf ("*****Display core leakage!");
    }
    p -> length = 0;
    p -> hash = 0;
    p -> highlighted = 0;
    return p;
}

/* 'ReleaseLine' returns a line object to the free list */
hidden procedure ReleaseLine (p)
register struct line   *p; {
    if (p) {
	if (p -> hash == 12345) {
	    printf("\rBogus re-release!");
	    fflush(stdout);
	    /* abort(); */
	    return;
	}
	p -> next = FreeLines;
	p -> hash = 12345;
	FreeLines = p;
    }
}

hidden struct line *PhysScreen[MScreenLength + 1];
 /* the current (physical) screen */
hidden struct line *DesiredScreen[MScreenLength + 1];
 /* the desired (virtual) screen */

visible int
            ScreenGarbaged,	/* set to 1 iff screen content is
				   uncertain. */
            RDdebug,		/* line redraw debug switch */
            IDdebug,		/* line insertion/deletion debug */
            cursX,		/* X and Y coordinates of the cursor */
            cursY,		/* between updates. */
            CurrentLine,	/* current line for writing to the
				   virtual screen. */
            left;		/* number of columns left on the current
				   line of the virtual screen. */
visible char
               *cursor;		/* pointer into a line object, indicates
				   where to put the next character */


/* 'setpos' positions the cursor at position (row,col) in the virtual
   screen */
visible procedure setpos (row, col)
register    row,
            col; {
    register struct line   *p;
    register    n;

    if (CurrentLine >= 0
	    && (p = DesiredScreen[CurrentLine]) -> length
	    <= (n = ScreenWidth - left))
	p -> length = left > 0 ? n : ScreenWidth;
    if (!DesiredScreen[row])
	DesiredScreen[row] = newline ();
    (p = DesiredScreen[row]) -> hash = 0;
    while (p -> length + 1 < col)
	p -> body[p -> length++] = ' ';
    CurrentLine = row;
    left = ScreenWidth + 1 - col;
    cursor = &DesiredScreen[row] -> body[col - 1];
}

/* 'clearline' positions the cursor at the beginning of the
   indicated line and clears the line (in the image) */
clearline (row) {
    setpos (row, 1);
    DesiredScreen[row] -> length = 0;
}

/* 'HighLine' causes the current line to be highlighted */
HighLine () {
    if (CurrentLine >= 0)
	DesiredScreen[CurrentLine] -> highlighted++;
}

/* 'hashline' computes a hash value for a line, unless the hash value
   is already known.  This hash code has a few important properties:
	- it is independant of the number of leading and trailing spaces
	- it will never be zero
 
   As a side effect, an estimate of the cost of redrawing the line is
   calculated */
hidden procedure hashline (p)
register struct line   *p; {
    register char  *c,
                   *l;
    register    h;

    if (!p || p -> hash) {
	if (p && p->hash==12345) printf ("****Free line in screen");
	return;
    }
    h = 0;
    c = p -> body;
    l = &p -> body[p -> length];
    while (--l > c && *l == ' ');
    while (c <= l && *c == ' ')
	c++;
    p -> DrawCost = l - c + 1;
    if (p -> highlighted) {
	p -> hash = -200;
	return;
    }
    while (c <= l)
	h = (h << 5) + h + *c++;
    p -> hash = h!=12345 && h ? h : 1;
}

/*	1   2   3   4   ....	Each Mij represents the minumum cost of
      +---+---+---+---+-----	rearranging the first i lines to map onto
    1 |   |   |   |   |		the first j lines (the j direction
      +---+---+---+---+-----	represents the desired contents of a line,
    2 |   |  \| ^ |   |		i the current contents).  The algorithm
      +---+---\-|-+---+-----	used is a dynamic programming one, where
    3 |   | <-+Mij|   |		M[i,j] = min( M[i-1,j],
      +---+---+---+---+-----		      M[i,j-1]+redraw cost for j,2
    4 |   |   |   |   |			      M[i-1,j-1]+the cost of
      +---+---+---+---+-----			converting line i to line j);
    . |   |   |   |   |		Line i can be converted to line j by either
    .				just drawing j, or if they match, by moving
    .				line i to line j (with insert/delete line)
 */

hidden struct Msquare {
    short   cost;		/* the value of Mij */
    char   fromi,
           fromj;		/* the coordinates of the square that
				   the optimal move comes from */
}                       M[MScreenLength + 1][MScreenLength + 1];

hidden procedure calcM () {
    register struct Msquare *p;
    register    i,
                j,
                movecost,
                cost;
    int     reDrawCost,
            idcost,
            leftcost;
    double  fidcost;

    cost = 0;
    movecost = 0;
    for (i = 0; i <= ScreenLength; i++) {
	p = &M[i][0];
/*	M[i][i].cost = 0;  */
	p[i].cost = 0;
	M[0][i].cost = cost + movecost;
/*	M[i][0].cost = movecost;  */
	p[0].cost = movecost;
	M[0][i].fromi = 0; 
/*	M[0][i].fromj = M[i][i].fromj = i - 1;  */
	M[0][i].fromj = p[i].fromj = i - 1;
/*	M[i][0].fromi = M[i][i].fromi = i - 1;  */
	p[0].fromi = p[i].fromi = i - 1;
/*	M[i][0].fromj = 0;  */
	p[0].fromj = 0;
	movecost += tt.t_ILmf * (ScreenLength - i) + tt.t_ILov;
	if (DesiredScreen[i + 1])
	    cost += DesiredScreen[i + 1] -> DrawCost;
    }

    fidcost = tt.t_ILmf * (WindowSize + 1) + tt.t_ILov;
    for (i = 1; i <= WindowSize; i++)
    {
	p = &M[i][0];
	fidcost -= tt.t_ILmf;
	idcost = fidcost;
	for (j = 1; j <= WindowSize; j++) {
	    p++; 
/*	    p = &M[i][j]; */
	    cost =  DesiredScreen[j] ? DesiredScreen[j] -> DrawCost : 0;
	    reDrawCost = cost;
	    if (PhysScreen[i] && DesiredScreen[j]
		    && PhysScreen[i] -> hash == DesiredScreen[j] -> hash)
		cost = 0;
/*	    idcost = tt.t_ILmf * (WindowSize - i + 1) + tt.t_ILov; */
/*	    movecost = M[i - 1][j].cost + (j == WindowSize ? 0 : idcost); */
	    movecost = p[-MScreenLength-1].cost
				+ (j == WindowSize ? 0 : idcost);
	    p -> fromi = i - 1;	/* now using movecost for */
	    p -> fromj = j;	/* the minumum cost. */
	    if ((
/*			leftcost = M[i][j - 1].cost */
			leftcost = p[-1].cost
				+ (i == WindowSize ? 0 : idcost) + reDrawCost
		    ) < movecost) {
		movecost = leftcost;
		p -> fromi = i;
		p -> fromj = j - 1;
	    }
/*	    cost += M[i - 1][j - 1].cost; */
	    cost += p[-MScreenLength-2].cost;
	    if (cost < movecost)
		movecost = cost,
		    p -> fromi = i - 1, p -> fromj = j - 1;
	    p -> cost = movecost;
	}
    }
}

/* calculate and perform the optimal sequence of insertions/deltions
   given the matrix M from routine calcM */

hidden procedure CalcID (i, j, InsertsDesired)
register    i,
            j; {
    register    ni,
                nj;
    register struct Msquare *p = &M[i][j];
    if (i > 0 || j > 0) {
	ni = p -> fromi;
	nj = p -> fromj;
	if (ni == i) {
	    CalcID (ni, nj, i != WindowSize ? InsertsDesired + 1 : 0);
	    InsertsDesired = 0;
	    if (InputPending) {
		if (PhysScreen[j] != DesiredScreen[j])
		    ReleaseLine (PhysScreen[j]);
		PhysScreen[j] = 0;
		ReleaseLine (DesiredScreen[j]);
		DesiredScreen[j] = 0;
		LastRedisplayPaused++;
	    }
	    else {
		UpdateLine ((struct line *) 0, DesiredScreen[j], j);
		if (PhysScreen[j] != DesiredScreen[j])
		    ReleaseLine (PhysScreen[j]);
		PhysScreen[j] = DesiredScreen[j];
		DesiredScreen[j] = 0;
	    }
	}
	else
	    if (nj == j) {
		if (j != WindowSize) {
		    register    nni,
		                dlc = 1;
		    for (; ni;) {
			p = &M[ni][nj];
			nni = p -> fromi;
			if (p -> fromj == nj) {
			    dlc++;
			    ni = nni;
			}
			else
			    break;
		    }
		    topos (i - dlc + 1, 1);
		    deletelines (dlc);
		}
		CalcID (ni, nj, 0);
	    }
	    else {
		register struct line   *old = PhysScreen[i];
		register    DoneEarly = 0;
		if (old == DesiredScreen[i]) DesiredScreen[i] = 0;
		PhysScreen[i] = 0;

	    /* The following hack and all following lines involving the
	       variable "DoneEarly" cause the bottom line of the screen to
	       be redisplayed before any others if it has changed and it
	       would be redrawn in-place.  This is purely for Emacs,
	       people using this package for other things might want to
	       lobotomize this section. */
		if (i == ScreenLength && j == ScreenLength
/*			&& old != PhysScreen[j]) { */
			&& DesiredScreen[j]) {
		    DoneEarly++;
		    UpdateLine (old, DesiredScreen[j], j);
		}
		CalcID (ni, nj, 0);
		if (InputPending && !DoneEarly) {
		    if (PhysScreen[j] != old)
			ReleaseLine (PhysScreen[j]);
		    if (DesiredScreen[j] != old
			    && DesiredScreen[j] != PhysScreen[j])
			ReleaseLine (DesiredScreen[j]);
		    PhysScreen[j] = old;
		    DesiredScreen[j] = 0;
		    LastRedisplayPaused++;
		}
		else {
		    if (!DoneEarly && (DesiredScreen[j] || i != j))
			UpdateLine (old, DesiredScreen[j], j);
		    if (PhysScreen[j] != DesiredScreen[j])
			ReleaseLine (PhysScreen[j]);
		    if (old != DesiredScreen[j] && old != PhysScreen[j])
			ReleaseLine (old);
		    PhysScreen[j] = DesiredScreen[j];
		    DesiredScreen[j] = 0;
		}
	    }
    }
    if (InsertsDesired) {
	topos (j + 1, 1);
	insertlines (InsertsDesired);
    }
}

/* modify current screen line 'old' to match desired line 'new',
   the old line is at position ln.  Each line
   is scanned and partitioned into 4 regions:

	     <osp><----m1-----><-od--><----m2----->
    old:    "     Twas brillig and the slithy toves"
    new:    "        Twas brillig where a slithy toves"
             <-nsp--><----m1-----><-nd--><----m2----->

	nsp, osp	- number of leading spaces on each line
	m1		- length of a leading matching sequence
	m2		- length of a trailing matching sequence
	nd, od		- length of the differing sequences
 */
hidden procedure UpdateLine (old, new, ln)
register struct line	*old,
			*new; {
    register char	*op,
			*np,
			*ol,
			*nl;
    int	osp,
	nsp,
	m1,
	m2,
	od,
	nd,
	OldHL,
	NewHL,
	t,
	OldLineWipeTo;

    if (old == new)
	return;
    if (old) {
	op = old -> body;
	ol = &old -> body[OldLineWipeTo = old -> length];
	OldHL = old -> highlighted;
    }
    else
	op = "", ol = op, OldHL = 0, OldLineWipeTo = 1;
    if (new) {
	np = new -> body;
	nl = &new -> body[new -> length];
	NewHL = new -> highlighted;
    }
    else
	np = "", nl = np, NewHL = 0;
    osp = nsp = m1 = m2 = od = od = 0;

/* calculate the magic parameters */
    if (NewHL == OldHL) {
	while (*--ol == ' ' && ol >= op) --OldLineWipeTo;
	while (*--nl == ' ' && nl >= np);
	while (*op == ' ' && op <= ol)
	    op++, osp++;
	while (*np == ' ' && np <= nl)
	    np++, nsp++;
#ifdef ACT
	if (!NewHL && ol < op && !tt.t_needspaces)
	    osp = nsp;
#endif
	while (*op == *np && op <= ol && np <= nl)
	    op++, np++, m1++;
#ifdef ACT
	if (!NewHL && op > ol && !tt.t_needspaces)
	    while (*np == ' ' && np <= nl)
		np++, m1++;
#endif
	while (*ol == *nl && op <= ol && np <= nl)
	    ol--, nl--, m2++;
    }
    else {
	ol--;
	nl--;
	osp = 0;
	while (*np == ' ' && np < nl)
	    np++, nsp++;
    }
    od = ol - op + 1;
    nd = nl - np + 1;

/* forget matches which would be expensive to capitalize on */
    if (m1 || m2) {
	register int    c0,
	                c1,
	                c2,
	                c3;
	c0 = nsp + m1 + m2;
	if (c1 = nsp - osp)
	    c1 = c1<0 ? tt.t_DCov - c1*tt.t_DCmf
		      : tt.t_ICov + c1*tt.t_ICmf;
	if (c3 = nd - od)
	    c3 = c3<0 ? tt.t_DCov - c3*tt.t_DCmf
		      : tt.t_ICov + c3*tt.t_ICmf;
	if (c2 = (nsp + nd) - (osp + od))
	    c2 = c2<0 ? tt.t_DCov - c2*tt.t_DCmf
		      : tt.t_ICov + c2*tt.t_ICmf;
	c3 += c1;
	c1 += m2;
	c2 += m1;
	if (m2 && (c0 < c2 && c0 < c3 || c1 < c2 && c1 < c3)) {
	    nd += m2;
	    od += m2;
	    ol += m2;
	    nl += m2;
	    m2 = 0;
	}
	if (m1 && (c0 < c1 && c0 < c3 || c2 < c1 && c2 < c3)) {
	    nd += m1;
	    od += m1;
	    np -= m1;
	    op -= m1;
	    m1 = 0;
	}
    }
    if (RDdebug && (m1 || m2 || nd || od)) {
	fprintf (stderr, "%2d nsp=%2d  osp=%2d  m1=%2d  nd=%2d  od=%2d  m2=%2d",
		ln, nsp, osp, m1, nd, od, m2);
    }
    (*tt.t_HLmode) (NewHL);
    if (NewHL != OldHL) {
	topos (ln, 1);
	wipeline (1, OldLineWipeTo);
	OldLineWipeTo = 1;
    }
    if (m1 == 0)
	if (m2 == 0) {
	    if (od == 0 && nd == 0)
		goto cleanup;
#ifndef ACT
	    if (od == 0 && !tt.t_needspaces)
		osp = nsp;
#endif
	    topos (ln, (t = min (nsp, osp)) + 1);
	    INSmode (0);
	    if (nsp > osp)
		blanks (nsp - osp);
	    dumpstring (np, nl);
	    if (nsp + nd < osp + od)
		wipeline (0, OldLineWipeTo);
	}
	else {			/* m1==0 && m2!=0 && (nd!=0 || od!=0) */
	    t = (nsp + nd) - (osp + od);
	    topos (ln, min (nsp, osp) + 1);
	    if (nsp > osp)
		np -= nsp - osp;
	    if (t >= 0) {
		if (nl - t >= np)
		    INSmode (0), dumpstring (np, nl - t);
		if (t > 0)
		    INSmode (1), dumpstring (nl - t + 1, nl);
	    }
	    else
		INSmode (0), dumpstring (np, nl), deletechars (-t);
	}
    else {			/* m1!=0 */
	register    lsp = osp;
	if (nsp < osp) {
	    topos (ln, 1);
	    deletechars (osp - nsp);
	    lsp = nsp;
	}
	if (m2 == 0) {
	    if (nd == 0 && od == 0) {
		if (nsp > osp) {
		    topos (ln, 1);
		    INSmode (1);
		    blanks (nsp - osp);
		}
		goto cleanup;
	    }
#ifndef ACT
	    if (od == 0 && !tt.t_needspaces)
		while (*np==' ') np++, m1++;
#endif
	    topos (ln, lsp + m1 + 1);
	    INSmode (0);
	    dumpstring (np, nl);
	    if (nd < od)
		wipeline (0, OldLineWipeTo);
	    if (nsp > osp) {
		topos (ln, 1);
		INSmode (1);
		blanks (nsp - osp);
	    }
	}
	else {			/* m1!=0 && m2!=0 && (nd!=0 || od!=0) */
	    topos (ln, lsp + m1 + 1);
	    t = nd - od;
	    if (nd > 0 && od > 0)
		INSmode (0), dumpstring (np, np + min (nd, od) - 1);
	    if (nd < od)
		deletechars (od - nd);
	    else
		if (nd > od)
		    INSmode (1), dumpstring (np + od, nl);
	    if (nsp > osp) {
		topos (ln, 1);
		INSmode (1);
		blanks (nsp - osp);
	    }
	}
    }
cleanup:
#ifdef FIONREAD
#ifdef i386
    if(--CheckForInput<0 && !InputPending){
#else  i386
    if(--CheckForInput<0 && !InputPending &&
				((stdout->_ptr - stdout->_base) > 20)){
#endif i386
	fflush (stdout);
#ifdef TIOCOUTQ			/* prevent system I/O buffering */
	if (baud_rate < 2400) {
	    int out1;
	    float outtime;
	    ioctl (fileno(stdin), TIOCOUTQ, (waddr_t)&out1);
	    out1 *= 10;
	    outtime = ((float) out1) / ((float) baud_rate);
	    if (outtime >= 1.5) sleep ((unsigned) (outtime - .5));
	}
#endif
	ioctl (fileno(stdin), FIONREAD, (waddr_t)&InputPending);
	CheckForInput = baud_rate / 2400;
    }
#endif
}

visible procedure UpdateScreen (SlowUpdate) {
    register    n,
                c;

    CheckForInput = 999;
    if (ScreenGarbaged) {
	reset ();
	ScreenGarbaged = 0;
	for (n = 0; n <= ScreenLength; n++) {
	    ReleaseLine (PhysScreen[n]);
	    PhysScreen[n] = 0;
	}
    }
#ifdef FIONREAD			/* one quick test */
    if (!InputPending) ioctl (fileno(stdin), FIONREAD, (waddr_t)&InputPending);
#endif
    if (CurrentLine >= 0
	    && DesiredScreen[CurrentLine] -> length <= ScreenWidth - left)
	DesiredScreen[CurrentLine] -> length =
	    left > 0 ? ScreenWidth - left : ScreenWidth;
    CurrentLine = -1;
    if (tt.t_ILov == MissingFeature)
	SlowUpdate = 0;
    if (SlowUpdate) {
	for (n = 1; n <= ScreenLength; n++) {
	    if (DesiredScreen[n] == 0)
		DesiredScreen[n] = PhysScreen[n];
	    else
		hashline (DesiredScreen[n]);
	    hashline (PhysScreen[n]);
	}
	c = 0;
	for (n = ScreenLength; n >= 1 && c <= 2; n--)
	    if (PhysScreen[n] != DesiredScreen[n]
		    && PhysScreen[n]
		    && DesiredScreen[n] -> hash != PhysScreen[n] -> hash)
		c++;
	if (c <= 2)
	    SlowUpdate = 0;
	else {
	    if (tt.t_window) {
		for (n = ScreenLength;
			n >= 1
			&& (PhysScreen[n] == DesiredScreen[n]
			    || PhysScreen[n]
			    && DesiredScreen[n] -> hash == PhysScreen[n] -> hash);
			n--);
		WindowSize = n;
		(*tt.t_window) (n);
	    }
	    else
		WindowSize = ScreenLength;
	    calcM ();
	    CheckForInput = baud_rate / 2400;
	    CalcID (ScreenLength, ScreenLength, 0);
/*	for (n = 1; n <= ScreenLength; n++) {
	    if (DesiredScreen[n] != PhysScreen[n]) {
		ReleaseLine (PhysScreen[n]);
		PhysScreen[n] = DesiredScreen[n];
	    }
	    DesiredScreen[n] = 0;
	} */
	}
    }
    if (!SlowUpdate) {		/* fast update */
	for (n = 1; n <= ScreenLength; n++)
	    if (DesiredScreen[n]) {
		UpdateLine (PhysScreen[n], DesiredScreen[n], n);
		if (PhysScreen[n] != DesiredScreen[n])
		    ReleaseLine (PhysScreen[n]);
		PhysScreen[n] = DesiredScreen[n];
		DesiredScreen[n] = 0;
	    }
    }
    (*tt.t_HLmode) (0);
    if (!InputPending)
	topos (cursY, cursX);
}

static VisibleBell;		/* If true and the terminal will support it
				   then the screen will flash instead of
				   feeping when an error occurs */
visible int InverseVideo;	/* If true and the terminal will support it
				   then we will use inverse video */
visible int EmacsFlowControl;	/* CEH 7/23/85 use ^S/^Q flow control */

/* AZ routine to change number of lines on screen */
visible procedure ScreenLines(){
     tt.t_length = getnum (": lines-on-screen ");
     ScreenGarbaged = 1;
     InitWin();
     DoDsp(1);
}
/* AZ routine to change number of cols. on screen */
visible procedure ScreenCols(){
     tt.t_width = getnum (": columns-on-screen ");
     ScreenGarbaged = 1;
     DoDsp(1);
}

/* DJH common routine for a feep */
Ding () {			/* BOGUS!  this should really be terminal
				   type specific! */
    if (VisibleBell && tt.t_flash) (*tt.t_flash) ();
    else putchar (07);
}

/* DLK routine to make the cursor sit for n/10 secs */
hidden procedure SitFor () {
    register    num_chars, CharsPerInputCheck;

#ifdef i386
    if(InputPending || stdin->_r!= 0) return 0;
#else  i386
    if(InputPending || stdin->_cnt!= 0) return 0;
#endif i386
    CharsPerInputCheck = baud_rate / 100;
    num_chars = getnum (": sit-for ") * CharsPerInputCheck;
    DoDsp (1);			/* Make the screen correct */
    INSmode (0);
    while (num_chars-- && !InputPending){
#ifdef FIONREAD
	if ( ((num_chars+1) % CharsPerInputCheck) == 0){
		fflush (stdout);
		ioctl (fileno(stdin), FIONREAD, (waddr_t)&InputPending);
	}
#endif
	putchar(0);			/* BOGUS */
    }
    return 0;
}

/* ACT 18-Oct-1982 sleep for n seconds, do not update display */
hidden procedure SleepFor () {
    register t = getnum (": sleep-for ");
    if (t >= 1 && t <= 10) sleep (t);
    return 0;
}

/* initialize the teminal package */
term_init () {
    static short    baud_convert[] =
    {
	0, 50, 75, 110, 135, 150, 200, 300, 600, 1200,
	1800, 2400, 4800, 9600, 19200, 300
    };
    struct sgttyb   sg;
    extern short    ospeed;
    static  BeenHere;		/* true iff we've been here before (some
				   things must only be done once!) */

    FluidStatic(&BeenHere, sizeof(BeenHere));
    RDdebug = 0;		/* line redraw debug switch */
    IDdebug = 0;		/* line insertion/deletion debug */
    cursX = 1;			/* X and Y coordinates of the cursor */
    cursY = 1;			/* between updates. */
    CurrentLine = -1;		/* current line for writing to the
				   virtual screen. */
    left = -1;			/* number of columns left on the current
				   line of the virtual screen. */
    ioctl(fileno(stdin), TIOCGETP, &sg);

    ospeed = sg.sg_ospeed;
    baud_rate = sg.sg_ospeed == 0 ? 1200
	: sg.sg_ospeed < sizeof baud_convert / sizeof baud_convert[0]
	? baud_convert[sg.sg_ospeed] : 9600;
    if (!BeenHere) {
	char   *tname = (char *) getenv ("TERM");
	struct termtype {
	    char   *name;
	    int     cmplen;
	    int     (*startup) ();
	};
    /* A terminal driver is selected by looking up the value of the
       environment variable TERM in the following table.  The string is
       matched against the name, considering at most "cmplen" characters
       to be significant.  "startup" points to the function that sets up
       the terminal driver.  The driver is called with the terminal type
       as a parameter and is free to use that to specialize itself. */
	struct termtype *p;
	extern  TrmAmb ();
	extern  TrmC100 ();
	extern  TrmI400 ();
	extern  TrmMiniB ();
	extern  TrmPERQ ();
	extern  TrmVT100 ();
	extern  TrmT1061 ();
	extern	TrmGigi ();
	extern  TrmTEK4025 ();
        extern  TrmVS100 ();	/* Prisner 29 Mar 84 */
	static struct termtype  termtable[] = {
	    "4025", 99, TrmTEK4025,
	    "aaa", 99, TrmAmb,
	    "amb", 99, TrmAmb,
	    "ambassador", 99, TrmAmb,
	    "C10", 3, TrmC100,
	    "c10", 3, TrmC100,
	    "Concept", 7, TrmC100,
	    "concept", 7, TrmC100,
	    "GG", 99, TrmGigi,
	    "Gigi", 4, TrmGigi,
	    "perq", 4, TrmC100,
	    "i400", 99, TrmI400,
	    "minibee", 99, TrmMiniB,
	    "t10", 3, TrmT1061,
	    "tek4025", 99, TrmTEK4025,
	    "vt1", 3, TrmVT100,
	    "vt2", 3, TrmVT100,
	    "vt3", 3, TrmVT100,
            "vs1", 3, TrmVS100, 	/* Prisner 29 Mar 84 */
	    "xpty", 4, TrmVT100,	/* Haynes Tue Apr 23 14:32:46 1985 */
	    "xterm", 5, TrmVT100,	/* Haynes Fri Aug 30 18:29:22 1985 */
	    0, 0, 0
	};
	BeenHere++;
	if (tname == 0)
	    tname = "t10";
	for (p = termtable; p -> name; p++)
	    if (strncmp (p -> name, tname, p -> cmplen) == 0) {
		(*p -> startup) (tname);
		break;
	    }
	if (p -> name == 0)
	    TrmTERM (tname);
	if (! Once)
	{
	    defproc (SitFor, "sit-for");
	    defproc (ScreenLines, "lines-on-screen");
	    defproc (ScreenCols, "columns-on-screen");
	    defproc (SleepFor, "sleep-for");
	    DefIntVar ("inverse-video", &InverseVideo);
	    DefIntVar ("visible-bell", &VisibleBell);
	    DefIntVar ("mode-line-highlight", &tt.t_modeline);
	    DefIntVar ("emacs-flow-control", &EmacsFlowControl); /* CEH 7/23/85 */
	}
    }
    (*tt.t_init) (baud_rate);
    if (tt.t_length > MScreenLength)
	tt.t_length = MScreenLength;
    if (tt.t_width > MScreenWidth)
	tt.t_width = MScreenWidth;
    (*tt.t_reset) ();
}

/* Debugging routines -- called from sdb only */

/* print out the insert/delete cost matrix */
#ifdef DEBUG
PrintM () {
    register    i,
                j;
    register struct Msquare *p;
    for (i = 0; i <= ScreenLength; i++) {
	for (j = 0; j <= ScreenLength; j++) {
	    p = &M[i][j];
	    fprintf (stderr, "%4d%c", p -> cost,
		    p -> fromi < i && p -> fromj < j ? '\\' :
		    p -> fromi < i ? '^' :
		    p -> fromj < j ? '<' : ' ');
	}
	fprintf (stderr, "\n");
    }
    fprintf (stderr, "\014");
}
#endif

visible procedure
NoOperation () {}
