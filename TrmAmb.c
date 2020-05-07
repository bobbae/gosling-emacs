/* terminal control module for Ann Arbor Ambassadors */

/* ACT 16-Oct-1982: Combined Gosling's version and mine to write this one */

#include <stdio.h>
#include "Trm.h"
#include "keyboard.h"
#define	PAD(n,f)	if (Baud > 9600) pad(n,f); else
extern int InverseVideo;

static
int	curX, curY, Baud, CurHL, DesHL;

static
float	BaudFactor;

static
enum IDmode { m_insert = 1, m_overwrite = 0} DesiredMode;

static
INSmode (new)
enum IDmode new; {
	DesiredMode = new;
}

static
HLmode (new) {
	DesHL = new;
}

static
SetHL (OverRide) {
    register LDes = OverRide ? 0 : DesHL;
    if (tt.t_modeline == 0 || LDes == CurHL)
	return;
    if (InverseVideo) printf ("\033[%cm", LDes ? '0' : '7');
	    else 	  printf ("\033[%cm", LDes ? '7' : '0');
    PAD (1, 0.30);
    CurHL = LDes;
}

static
inslines (n) {
    SetHL (1);
    printf (n <= 1 ? "\033[L" : "\033[%dL", n);
    PAD (61-curY, 4.00);
}

static
dellines (n) {
    SetHL (1);
    printf (n <= 1 ? "\033[M" : "\033[%dM", n);

    PAD (61-curY, 4.00);
    if (tt.t_length == 60)
	return;
    if (Baud < 4800) {		/* yeesh! */
	topos (tt.t_length-n+1, 1);
	printf ("\033[J");
    }
    else {
	register i;
	for (i=tt.t_length-n+1; i<=tt.t_length; i++) {
	    topos (i, 1);
	    wipeline ();
	}
/*	i = tt.t_length - n + 1;
	topos (i, 1);
	printf (n <= 1 ? "\033[M" : "\033[%dM", n);
	PAD (60-curY, 4.00);	*/
    }
}

static
writechars (start, end)
register char *start, *end; {
    register char *p;
    register runlen;

    SetHL (0);
    if (DesiredMode == m_insert) {
	printf ("\033[%d@", end - start + 1);
	PAD (80-curX, 0.16);
    }
    while (start <= end) {
	if (*start < 040 || *start >= 0177) {
	    printf (InverseVideo ? "\033[m%c\033[7m" : "\033[7m%c\033[m",
		    	*start < 040 ? (*start & 037) + 0100 : '?');
		/* enter hi-light mode, print char, exit hi-light mode */
	    PAD (1, 1.00);
	    start++;
	    curX++;
	}
	else {
	    if (start+5 < end && *start == start[1]) {
		runlen = 0;
		p = start;
		do runlen++; while (*++start == *p && start <= end);
		if (runlen > 5) {
		    putchar (*p);
		    printf ("\033[%db", runlen - 1);
		    PAD (runlen-1, 1.00);
		    curX += runlen;
		}
		else {
		    start = p;
		    goto normal;
		}
	    }
	    else {
normal:
		putchar (*start++);
		curX++;
	    }
	}
    }
}

static
blanks (n) register n; {
    if (n > 0) {
	SetHL (0);
	curX += n;
	if (DesiredMode == m_insert) {
	    printf ("\033[%d@", n);
	    PAD (80-curX, 0.16);
	}
	if (n > 5) {
	    printf (" \033[%db", n-1);
	    PAD (n-1, 1.00);
	}
	else while (--n >= 0) putchar (' ');
    }
}

static
pad (n, f)
float f; {
    register	k = n * f * BaudFactor;
    while (--k >= 0)
	putchar (0);
}

static
topos (row, column) register row, column; {
    if (curY == row) {
	if (curX == column)
	    return;
	if (curX == column + 1) {
	    putchar (010);
	    goto done;
	}
	printf ("\033[%d`", column);
	goto done;
    }
    if (curY+1 == row && (column == 1 || column == curX)) {
	if (column != curX) putchar (015);
	putchar (012);
	goto done;
    }
    if (row == 1 && column == 1) {
	printf ("\033[f");
	goto done;
    }
    if (column == 1) {
	printf ("\033[%df", row);
	goto done;
    }
    if (row == 1) {
	printf ("\033[;%df", column);
	goto done;
    }
    printf ("\033[%d;%df", row, column);
done:
    curX = column;
    curY = row;
    PAD (1, 1.00);
}

static
init (BaudRate) {
    Baud = BaudRate;
    BaudFactor = (BaudRate / 10000.);
    MetaFlag++;
};

#define ScreenLength (tt.t_length)
#define ScreenWidth (tt.t_width)

static
reset () {
    curX = -1;
    curY = -1;
    SetHL (1);
    if (ScreenLength <= 18 ) printf ("\033[60;0;0;18p");
    if (ScreenLength > 18 && ScreenLength <= 22) printf ("\033[60;0;0;22p");
    if (ScreenLength > 22 && ScreenLength <= 24) printf ("\033[60;0;0;24p");
    if (ScreenLength > 24 && ScreenLength <= 26) printf ("\033[60;0;0;26p");
    if (ScreenLength > 26 && ScreenLength <= 28) printf ("\033[60;0;0;28p");
    if (ScreenLength > 28 && ScreenLength <= 30) printf ("\033[60;0;0;30p");
    if (ScreenLength > 30 && ScreenLength <= 36) printf ("\033[60;0;0;36p");
    if (ScreenLength > 36 && ScreenLength <= 40) printf ("\033[60;0;0;40p");
    if (ScreenLength > 40 && ScreenLength <= 48) printf ("\033[60;0;0;48p");
    if (ScreenLength > 48 && ScreenLength <= 60) printf ("\033[60;0;0;60p");
    pad (1, 10.00);
    printf ("\033[>52h");	/* SM meta key */
    printf ("\033[>30;33;34;37;38;39l");
    /* RM(ZDBM,ZWFM,ZWBM,ZAXM,ZAPM,ZSSM) */
    printf ("\033[1Q");		/* SEE */
    printf ("\033[H");		/* CUP */
    printf ("\033[2J");		/* ED */
    pad (1, 350.00);
/*    wipescreen(); */
    curX = curY = 1;
    DesiredMode = m_overwrite;
}

static
cleanup () {
/*    InverseVideo = 0;	/* reset to normal video */
    CurHL = -1;
    SetHL (0);
    topos (tt.t_length, 1);
#if 0
    printf ("\033[J\033[%dm", InverseVideo ? 7 : 0);
    pad (10, 1.00);
    printf ("\033[>30;33;34;37h"); /* SM(ZDBM,ZWFM;ZWBM;ZAXM) */
    pad (20, 1.00);
    printf ("\033[>52l");	  /* RM Metakey */
    pad (10, 1.00);
#endif
}

static
wipeline () {
    SetHL (0);
    printf ("\033[K");
    PAD (80-curX, 0.25);
}

static
wipescreen () {
    SetHL (0);
    printf ("\033[2J");
    pad (1, 350.00);
    curX = curY = -1;
}

static
delchars (n) {
    if (n <= 0) return;
    SetHL (0);
    printf (n == 1 ? "\033[P" : "\033[%dP", n);
    PAD (80-curX, 0.20);
}

TrmAmb (tname)
char *tname;
{
    int i;				/* get preferred page length from */
    char   *p = (char *) getenv ("PL"); /* environment - DCL */

    tt.t_length = p == 0 ? 60 : atoi (p);	/* default 60 lines */
    if (strncmp(tname, "aaa", 3) == 0 && strlen(tname) > 3 &&
	tname[3] >= '0' && tname[3] <= '9')
	tt.t_length = atoi(tname+3);

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
    tt.t_ILov = 4;
    tt.t_ICmf = 1;
    tt.t_ICov = 4;
    tt.t_DCmf = 0;
    tt.t_DCov = 5;
    tt.t_width = 80;
    tt.t_modeline = 7;		/* do highlight */
}
