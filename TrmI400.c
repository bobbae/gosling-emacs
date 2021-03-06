/* terminal control module for Infoton 400's */

/*		Copyright (c) 1981,1980 James Gosling		*/

/*	added highlight compensation - I400 uses a space on the screen
	for highlighted lines and this affects direct cursor addressing
	    Aug/81  -  BML	 */

#include <stdio.h>
#include "display.h"

#define HSIZE 26

static
int	curX, curY,desHL;

static int  HLine[HSIZE];    /* flags for screen lines, true iff highlighted - BML  */

static curID, curEXT;
static
setID (n) {
    if (curID == n)
	return;
    printf ("\0334%c", n ? 'h' : 'l');
    curID = n;
}

static
setEXT (n) {
    if (curEXT == n)
	return;
    printf ("\033%cQ", n ? '0' : '2');
    curEXT = n;
}

static
enum IDmode { m_insert = 1, m_overwrite = 0}
	CurrentMode, DesiredMode;

static
INSmode (new)
enum IDmode new; {
	DesiredMode = new;
};

static
HLmode (new) {
    if (desHL)
	curX = -1, curY = -1;
    desHL = new;
}

static
inslines (n)    {
  int i;
    for (i = HSIZE-(n+1) ; curY <= i ; i--) HLine[i+n] = HLine[i];   /* update highlght flags - BML */
    for (i = curY ; (i < HSIZE) && (i < curY + n) ; i++) HLine[i] = 0;

    setEXT(1);
    printf (n <= 1 ? "\033L\015" : "\033%dL\015", n);
    curX = 1;					/* fixes bug for BML's mod */
    pad (n*(24-curY), 0.6);
};

static
dellines (n)     {
  int i;	/* update highlight flags - BML  */
    for(i=curY; (i + n)<HSIZE; i++) HLine[i] = HLine[i+n];
    for(i=(curY>(HSIZE - n) ? curY : (HSIZE - n)); i<HSIZE; i++) HLine[i] = 0;

    setEXT(1);
    printf (n <= 1 ? "\033M" : "\033%dM", n);
    pad (n*(24-curY), 0.6);
};

static
writechars (start, end)
register char	*start,
		*end; {
    if (DesiredMode == m_insert) {
	setEXT (0);
	setID (1);
    }
    else
	setID (0);
    while (start <= end) {
	putchar (*start++);
	curX++;
	if (DesiredMode == m_insert)
	    pad (80 - curX,.05);
    }
};

static
blanks (n) {
    if (n > 0) {
	if (DesiredMode == m_insert) {
	    setEXT (0);
	    setID (1);
	}
	else
	    setID (0);
	while (--n >= 0) {
	    putchar (' ');
	    curX++;
	    if (DesiredMode == m_insert)
		pad (80 - curX,.05);
	}
    }
};

static float BaudFactor;

static
pad (n,f)
float   f; {
    register    k = n * f * BaudFactor;
    while (--k >= 0)
	putchar (0);
};

static
topos (row, column) register row, column;  {
    if (HLine[row]) column++;	/* added compensation for curX on highlighted lines - BML  */

    if (curY == row) {
	if (curX == column)
	    return;
	if (curX == column + 1) {
	    putchar (010);
	    goto done;
	}
    }
    if (curY+1 == row && column == 1) {
	putchar (015);
	putchar (012);
	goto done;
    }
    if (row == 1 && column == 1) {
	printf ("\033H");
	goto done;
    }
    if (column == 1) {
	printf ("\033%dH", row);
	goto done;
    }
    if (row == 1) {
	printf ("\033;%dH", column);
	goto done;
    }
    printf ("\033%d;%dH", row, column);
done:
    curX = column;
    curY = row;
};

static
init (BaudRate)  {
  int i;
    for(i = 1; i < HSIZE; i++) HLine[i] = 0;	/* init highlight flags - BML */

    BaudFactor = 1 / (1 - (.45 +.3 * BaudRate / 9600.)) * (BaudRate / 10000.);
    tt.t_ILmf = BaudFactor * 0.3;
    tt.t_ILov = 3;
    tt.t_ICmf = 1;
    tt.t_ICov = 4;
    tt.t_DCmf = 2;
    tt.t_DCov = 0;
    curEXT = curID = -1;
};

static
reset () {
    curX = -1;
    curY = -1;
    curEXT = curID = -1;
    printf ("\0336h\0332Q\0334l\0332J");
    CurrentMode = m_insert;
    DesiredMode = m_overwrite;
};

static
cleanup () {
    setID(0);
    setEXT(1);
    printf ("\0334l\0330Q");
};

static
wipeline (ChangingHighlight) {
 /* Warning: assumes that we only change highlighting at column 1 */
    if (ChangingHighlight && tt.t_modeline != 0)
	if (desHL) {
	    printf ("\0332N\0337m");
	    curX++;
	    HLine[curY]++;
	}
	else {
	    setID (0);
	    setEXT(1);
	    printf ("\0332h\015\040\015\0332N\0332l");
	    curX = 1;				/* fix for BML's mod */
	    HLine[curY] = 0;
	}
    else
	printf ("\0330N");
    pad (80-curX, .1);
};

static
wipescreen () {
  int i;
    for(i = 1; i < HSIZE; i++) HLine[i] = 0;	/* reset highlight flags - BML */

    printf("\0332J");
    curX = curY = 1;
};

static
delchars (n) {
    setEXT(0);
    printf("\033%dP", n);
    pad (n*(80-curX), .05);
};

TrmI400 () {
    tt.t_INSmode = INSmode;
    tt.t_HLmode = HLmode;
    tt.t_inslines = inslines;
    tt.t_dellines = dellines;
    tt.t_blanks = blanks;
    tt.t_init = init;
    tt.t_cleanup = cleanup;
    tt.t_wipeline = wipeline;
    tt.t_wipescreen = wipescreen;
    tt.t_topos = topos;
    tt.t_reset = reset;
    tt.t_delchars = delchars;
    tt.t_writechars = writechars;
    tt.t_window = 0;
    tt.t_ILmf = 0;
    tt.t_ILov = 2;
    tt.t_ICmf = 0;
    tt.t_ICov = 0;
    tt.t_length = 25;
    tt.t_width = 79;
    tt.t_modeline = 7;
}
