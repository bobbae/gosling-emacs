
/* Developed at University of Maryland by Chris Torek */

/* terminal control module for DEC Gigi color graphics terminal
   with ... MULTI COLOR WINDOWS!!   ACT 21-Oct-1982 */

#include <stdio.h>
#include "Trm.h"

#define	NColors	6		/* see also TrmGigi() */

static	curX, curY, desHL, curHL, curColor, HL[24];
static	ColorSet[NColors];
static	Permutes[NColors] = { 2, 4, 5, 0, 3, 1};

static
HLmode (on) register on; {
	desHL = on;
}

/* put padding stuff in here */

static
writechars (start, end) register char *start, *end; {
	select_color ();
	while (start <= end) putchar (*start++), curX++;
}

static
blanks (n) register n; {
	select_color ();
	while (--n >= 0) putchar (' '), curX++;
}

static
topos (row, column) register row, column; {
	register k;
	if (curY == row) {
		k = curX - column;
		if (k) {
			if (k > 0 && k < 4) {
				while (k--) putchar (010);
				goto done;
			}
		}
		else return;
	}
	if (curY + 1 == row && (column == 1 || column == curX)) {
		if (column != curX) putchar (015);
		putchar (012);
		goto done;
	}
	if (row == 1 && column == 1) {
		printf ("\033[H");
		goto done;
	}
	printf ("\033[%d;%dH", row, column);
done:
	curX = column;
	curY = row;
}

static
init (BaudRate) {
}

static
reset () {
	printf ("\033[m\033[H\033[2J");
	permute_colors ();
	curHL = 0;
	curX = curY = 1;
	curColor = 0;
}

static
cleanup () {
	topos (24, 1);
	HLmode (0);
	select_color ();
	wipeline ();
}

static
wipeline () {
	printf ("\033[K");
}

static
wipescreen () {
	printf ("\033[2J");
	permute_colors ();
}

static
flash () {
	register i;
	printf ("\033Pps");
	for (i=0; i<7; i++)
		printf ("(i%d)", i);
	printf ("(i0)\033\\");
}

extern int NoOperation();

TrmGigi () {
	tt.t_INSmode = NoOperation;
	tt.t_HLmode = HLmode;
	tt.t_inslines = NoOperation;
	tt.t_dellines = NoOperation;
	tt.t_blanks = blanks;
	tt.t_init = init;
	tt.t_cleanup = cleanup;
	tt.t_wipeline = wipeline;
	tt.t_wipescreen = wipescreen;
	tt.t_topos = topos;
	tt.t_reset = reset;
	tt.t_delchars = NoOperation;
	tt.t_writechars = writechars;
	tt.t_window = 0;
	tt.t_flash = flash;
	tt.t_ILmf = tt.t_ILov = tt.t_ICmf = tt.t_ICov = tt.t_DCmf = tt.t_DCov =
		MissingFeature;
	tt.t_length = 24;
	tt.t_width = 84;
	ColorSet[0] = 32;
	ColorSet[1] = 36;
	ColorSet[2] = 34;
	ColorSet[3] = 33;
	ColorSet[4] = 35;
	ColorSet[5] = 31;
	tt.t_modeline = 7;
}

static
select_color () {
	register i, new_color = 0;

	HL[curY-1] = desHL;
	if (curY == 24)
		new_color = 37;	/* make bottom line always white */
	else {
		for (i=0; i<curY-1; i++)
			if (HL[i]) new_color++;
		new_color = ColorSet[new_color % NColors];
	}
	if (curColor == new_color && curHL == desHL)
		return;
	if (tt.t_modeline)
	    printf (desHL ? "\033[0;7;%dm" : "\033[0;%dm", new_color);
	curHL = desHL;
	curColor = new_color;
}

static
permute_colors () {
	register i;
	static t[NColors];

	for (i=0; i<NColors; i++)
		t[i] = ColorSet[Permutes[i]];
	for (i=0; i<NColors; i++)
		ColorSet[i] = t[i];
	for (i=0; i<24; i++)
		HL[i] = 0;
}
