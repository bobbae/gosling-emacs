/* terminal control module for DEC VT100's */

/* Modified version of Gosling's C100 driver -- jpershing@bbn */

/* This is a somewhat primitive driver for the DEC VT100 terminal.  The
   terminal is driven in so-called "ansi" mode, using jump scroll.  It is
   assumed to have the Control-S misfeature disabled (although this
   shouldn't get in the way -- it does anyway).  Specific optimization left
   to be done are (1) deferral of setting the window until necessary (as
   the escape sequence to do this is expensive) and (2) being more clever
   about optimizing motion (as the direct-cursor-motion sequence is also
   quite verbose).  Also, something needs to be done about putting the
   terminal back into slow-scroll mode if that's the luser's preference (or
   perhaps having EMACS itself use slow-scroll mode [lose, lose]). */

/* mods for char/line insert/delete on smarter vt1xx terminals
   Jud Leonard, decwrl: Mar 20, 1984

   add padding to insert mode output; turn off insert mode in cleanup()
   Richard Johnsson, decwsl: Jun 26, 1984

   make driver get size of screen from termcap if possible
   Charles Haynes, decwsl: Tue Apr 23 14:45:44 1985 */
   

#include <stdio.h>
#include <sys/ioctl.h>
#include "display.h"

static int editFeatures;
static
int	curX, curY;
static
int	WindowSize;
extern int InverseVideo;
extern NoOperation();

static curHL;
static
HLmode (on) register on; {
    if (curHL == on)
	return;
    if (tt.t_modeline) {
	printf (on ? "\033[7m" : "\033[m" );
	pad (1, 2.0);
    }
    curHL = on;
}

static
enum IDmode { m_insert = 1, m_overwrite = 0 }
	CurMode, DesMode;

static
INSmode (new)
enum IDmode new; {
	DesMode = new;
};

static
inslines (n) register n; {
    printf ("\033[%d;%dr\033[%dH", curY, WindowSize, curY);
    if (editFeatures) {
	printf ("\033[%dL", n);
	pad (1, 30.); }
    else {
	while (--n >= 0) {
	    printf ("\033M");
	    pad (1, 20.);	/* DEC sez pad=30, but what do they know? */
    }   }
    printf ("\033[r");
    pad (1, 2.);		/* ACT */
    curX = curY = 1;
};

static
dellines (n) register n; {
    printf ("\033[%d;%dr", curY, WindowSize);	/* set scrolling region */
    if (editFeatures) {
	printf ("\033[%dH\033[%dM", curY, n);
	pad (1, 30.); }
    else {
	printf ("\033[%dH", WindowSize);
	while (--n >= 0) {
	    printf ("\033E");
	    pad (1, 20.);		/* [see above comment] */
	}
    }
    printf ("\033[r");
    pad (1, 2.);		/* ACT */
    curX = curY = 1;
};

static	Baud;

static
writechars (start, end)
register char	*start,
		*end; {
    register count = 0;
    setmode ();
    while (start <= end) {
	if (*start < 040 || *start >= 0177) {
	    printf (InverseVideo ? "\033[m%c\033[7m" : "\033[7m%c\033[m",
		    	*start < 040 ? (*start & 037) + 0100 : '?');
	    pad (1, 5.0);
	    start++;
	    curX++;
	}
	else
	putchar (*start++);
	curX++;
	if (count++ > 15 && Baud >= 9600) count = 0, pad (1, 5.);/* ACT */
	if (count > 5 && CurMode == m_insert) count = 0, pad (1, 25.0);/* RKJ */
    }
};

static
blanks (n) register n; {
    register count = 0;/* RKJ */
    setmode ();
    while (--n >= 0) {
	putchar (' ');
	curX++;
	if (count++ > 5 && CurMode == m_insert) count = 0, pad (1, 25.0);/* RKJ */
    }
};

static float BaudFactor;

static pad (n,f)
register n;
register float f; {
    register    k = n * f * BaudFactor;
    while (--k >= 0)
 	putchar (0);
};

static				/* This routine needs lots of work */
topos (row, column) register row, column; {
    register k;
    if (curY == row) {
	k = curX - column;
	if (k) {
	    if (k > 0 && k < 4) {
		while (k--) putchar(010);
		goto done;
	    }
	}
	else return;
    }
    if (curY + 1 == row && (column == 1 || column==curX)) {
	if(column!=curX) putchar (015);
	putchar (012);
	goto done;
    }
    if (row == 1 && column == 1) {
	printf ("\033[H");
	pad (1, 5.);		/* ACT */
	goto done;
    }
    if (curY - 1 == row && (column == 1 || column==curX)) {
	if(column!=curX) putchar (015);	/* CR to column 1 */
	printf ("\033M");	/* RI to previous line */
	pad (1, 10.);
	goto done;
    }
    if (column == 1) {
	printf ("\033[%dH", row);
	goto done;
    }
    printf ("\033[%d;%dH", row, column );
    pad (1, 10.);		/* ACT */
done:
    curX = column;
    curY = row;
};

static
init (BaudRate) {
    char *getenv();
    static inited = 0;
    if (!inited) {
	static char tbuf[1024];		/* ACT Try for termcap's co# */
        struct winsize ws;

	register char *t;
        ioctl(0, TIOCGWINSZ, &ws);

	t = getenv ("COL");
	tt.t_width = 0;
	if (t != (char *) 0) tt.t_width = atoi (t);
	if (!tt.t_width) tt.t_width = ws.ws_col;
	if (!tt.t_width) {
	    t = getenv ("TERM");
	    tgetent (tbuf,t);
	    tt.t_width = tgetnum ("co");
	}
	if (!tt.t_width) tt.t_width = 80;

	t = getenv ("ROW");
	tt.t_length = 0;
	if (t != (char *) 0) tt.t_length = atoi (t);
	if (!tt.t_length) tt.t_length = ws.ws_row;
	if (!tt.t_length) {
	    t = getenv ("TERM");
	    tgetent (tbuf,t);
	    tt.t_length = tgetnum ("li");
	}
	if (!tt.t_length) tt.t_length = 24;
    }
    Baud = BaudRate;
    BaudFactor = strcmp (getenv ("TERM"), "vt100") ? 
    	BaudRate/4000. : BaudRate/10000.; /* AZ: slow it down for vt101 */
    tt.t_ILmf = 0.0;
    tt.t_ILov = 15 + 2+BaudFactor*20.;
};

static
reset () {
    printf ("\033<\033[r\033[m\033[?4;6l\033[2J\033=");/* Whew! */
/*    if (InverseVideo) printf ("\033[?5h");/* Use inverse video */
/*    else printf ("\033[?5l");*/
    if (editFeatures)
	printf ("\033[4l");	/* ensure replacement mode */
    CurMode = m_overwrite;
    pad (1, 60.);
    printf (ScreenWidth <= 80 ? "\033[?3l" : "\033[?3h");
    	/* set to 80 or 132 columns */
    pad (1, 150.);
       WindowSize = tt.t_length;
    curHL = 0;
    curX = curY = 1;
};

static
cleanup () {
    INSmode (m_overwrite);
    setmode ();
    HLmode (0);
    window (0);
    topos (WindowSize, 1);
    wipeline ();
};

static
wipeline () {
    printf("\033[K");
    pad (1, 10.);
};

static
wipescreen () {
    printf("\033[2J");
    pad (1, 100.);		/* ACT was 45. */
};

static
window (n) register n; {
    if (n <= 0 || n > tt.t_length)
	n = tt.t_length;
    WindowSize = n;
}

setmode () {
    if (DesMode == CurMode)
	return;
    printf (DesMode==m_insert ? "\033[4h" : "\033[4l");
    CurMode = DesMode;
};

static
delchars (n) {
    printf("\033[%dP", n);	/* delete chars at cursor and right */
    pad (n, 2.);
};

/* Visible Bell for DT80/1 -ACT */
static
flash () {
    printf (InverseVideo ? "\033[?5l" : "\033[?5h");
    pad (1, 40.);
    printf (InverseVideo ? "\033[?5h" : "\033[?5l");
}

TrmVT100 (t)
register char *t; {
	editFeatures = 0;
	if (strcmp (t, "vt102") == 0) editFeatures = 1;
	if (strcmp (t, "vt131") == 0) editFeatures = 1;
	if (strcmp (t, "vt300") == 0) editFeatures = 1;
	if (strcmp (t, "xpty") == 0) editFeatures = 1;
	if (strcmp (t, "xterm") == 0) editFeatures = 1;
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
	tt.t_window = window;
	tt.t_flash = flash;
	tt.t_ILmf = 0;		/* reset by init () */
	tt.t_ILov = 0;
	tt.t_ICmf = editFeatures ? 1.0 : MissingFeature;
	tt.t_ICov = editFeatures ? 8 : MissingFeature;
	tt.t_DCmf = editFeatures ? 1.0 : MissingFeature;
	tt.t_DCov = editFeatures ? 4 : MissingFeature;
	tt.t_length = 24;
	tt.t_width = 80;
	tt.t_modeline = 7;		/* highlight modeline */
}
