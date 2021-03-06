/* terminal control module for Teleray t1061 terminals		*/
/*								*/
/*		Copyright (c) 	1982   Hans Koomen		*/
/*				University of Rochester		*/
/*	Adapted from TrmTERM.c					*/

#include <stdio.h>
#include "Trm.h"
#include "keyboard.h"

static int	curX, curY;
static float	BaudFactor;
static int	desHL;
static char	HighLighted[25];	/* only once per line */

static enum IDmode { m_insert = 1, m_overwrite = 0 }	CurMode, DesMode;

static pad (n, f)
float   f;
{
    register int k = n * f * BaudFactor;
    while (--k >= 0)
	putchar (0);
}

static INSmode (new)
enum IDmode new;
{
	DesMode = new;
}

static HLmode (on)
{
    desHL = on;
}

static setHL ()
{
/* stupid Telerays chew up a character for display control for such things as
   underlining and highlighting, hence cursor positioning tends to get out of
   whack. Allow only one highlight per line, i.e. either a line is entirely
   highlighted, or it isn't at all */

    if ((curX-HighLighted[curY] == 1) &&
			((desHL && ! HighLighted[curY]) ||
			 (! desHL && HighLighted[curY])) ) {
	if (desHL)
	{
	    putchar (033);
	    putchar ('R');
	    putchar ('@'+tt.t_modeline);	/* Inverse video */
	    ++curX;			/* chew up display attribute char */
	}
	else
	{
	    putchar ('\r');
	    putchar (' ');
	}
/*	pad (80 - curX, 0.2);*/
	HighLighted[curY] = desHL;	/* one dispattr char */
    }
}

static setmode ()
{
  CurMode = DesMode;
}

static inslines (n)
{
    register int i;
    while (--n >= 0) {
	putchar (033);
	putchar ('L');
/*	pad (24 - curY, 2.0);*/
	for (i=24; i>curY; i--)
	    HighLighted[i] = HighLighted[i-1];
	HighLighted[curY] = 0;
	curX = 1;		  /* insert line moves to beginning of line */
    }
}

static dellines (n)
{
    register int i;
    while (--n >= 0) {
	putchar (033);
	putchar ('M');
/*	pad (24 - curY, 2.0);*/
	for (i=curY; i<24; i++)
	    HighLighted[i] = HighLighted[i+1];
	HighLighted[24] = 0;
	curX = 1;		  /* delete line moves to beginning of line */
    }
}

static dumpchar (ch)
{
    if (CurMode == m_insert) {
	putchar (033);
	putchar ('P');
	putchar (ch);
/*	pad (80 - curX, 0.4);*/
    }
    else putchar (ch);
    curX++;
}

static writechars (start, end)
register char	*start, *end;
{
    setmode ();
    setHL ();
    while (start <= end && curX <= 80)
	dumpchar (*start++);
}

static blanks (n)
{
    setmode ();
    setHL ();
    while (--n >= 0)
	dumpchar (' ');
}

static topos (row, column)
{
/*    if (column > 1)*/
        column += HighLighted[row];
    if (curY == row) {
	if (curX == column)
	    return;
	if (curX == column + 1) {
	    putchar (010);
	    goto done;
	}
	if (curX == column - 1) {
	    putchar (033);
	    putchar ('C');
	    goto done;
	}
    }
    if (curY - 1 == row && curX == column) {
	putchar (033);
	putchar ('A');
	goto done;
    }
    if (curY + 1 == row && (column == 1 || column == curX)) {
	if (column != curX)
	    putchar (015);
	putchar (012);
	goto done;
    }
    if (row == 1 && column == 1) {
	putchar (033);
	putchar ('H');
	goto done;
    }
    putchar (033);
    putchar ('Y');
    putchar (row + 31);
    putchar (column + 31);
done:
    curX = column;
    curY = row;
}

static init (BaudRate)
{
    BaudFactor = BaudRate / 10000.;
    tt.t_ILmf = 0;
    tt.t_ILov = 2;
    tt.t_DCmf = tt.t_ICmf = 2;
    tt.t_DCov = tt.t_ICov = 0;
    tt.t_length = 24;
    tt.t_width = 80;
    MetaFlag = 1;			/* has a metakey */
}

static reset ()
{
    wipescreen ();
    CurMode = m_insert;
    DesMode = m_overwrite;
}

static cleanup ()
{
    HLmode (0);
    DesMode = m_overwrite;
    setmode();
}

static wipeline ()
{
/*    if (curX == 1)
	HighLighted[curY] = 0;*/
    setHL ();
    putchar (033);
    putchar ('K');
}

static wipescreen ()
{
    register int i;
    putchar (014);
    pad (1, 17.0);
    curX = curY = -1;
    for (i = 24; i >= 0; HighLighted[i--] = 0);
}

static delchars (n)
{
    while (--n >= 0) {
	putchar (033);
	putchar ('Q');
/*	pad (80 - curX, 0.3);*/
    }
}

TrmT1061 () {
	tt.t_topos = topos;
	tt.t_reset = reset;
	tt.t_INSmode = INSmode;
	tt.t_HLmode = HLmode;
	tt.t_inslines = inslines;
	tt.t_dellines = dellines;
	tt.t_blanks = blanks;
	tt.t_init = init;
	tt.t_cleanup = cleanup;
	tt.t_wipeline = wipeline;
	tt.t_wipescreen = wipescreen;
	tt.t_delchars = delchars;
	tt.t_writechars = writechars;
	tt.t_window = 0;
        tt.t_flash = 0;
	tt.t_ILmf = 0.0;
	tt.t_ILov = 0;
        tt.t_ICmf = 0.0;
        tt.t_ICov = 0;
        tt.t_DCmf = 0.0;
        tt.t_DCov = 0;
	tt.t_length = 24;
	tt.t_width = 80;
        tt.t_needspaces = 0;
	tt.t_modeline = 'D' - '@';	/* default to inverse video */
}
