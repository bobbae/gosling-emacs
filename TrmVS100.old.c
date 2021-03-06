
#include <stdio.h>
#include <ctype.h>
#include "config.h"
#include "keyboard.h"
#include "display.h"

static
int	curX, curY, WindowSize;

char *tgetstr ();
char *UP;
char *BC;
char PC;
short ospeed;

static char *InsertLineStr,
*DeleteLineStr,
*InsertCharStr,
*DeleteCharStr,
*EndLineStr,
*EraseScreenStr,
*HighlightBeginStr,
*HighlightEndStr,
*CursorMoveStr,
*SetScrollRegion,
*NLstr;

static
dumpchar (c) {
	putchar (c);
}

static
enum IDmode { 
	m_insert = 1, m_overwrite = 0 }
CurMode, DesMode;

static
INSmode (new)
enum IDmode new; 
{
	DesMode = new;
	if(DesMode==m_insert ) abort();
};

static curHL, desHL;
static
HLmode (on) {
	desHL = on;
}

static
setHL () {
	register char *com;
	if (tt.t_modeline == 0 || curHL == desHL)
		return;
	if(com = desHL ? HighlightBeginStr : HighlightEndStr)
		printf (com);
	curHL = desHL;
}

static
clearHL () {
	if (curHL) {
		register oldes = desHL;
		desHL = 0;
		setHL ();
		desHL = oldes;
	}
}

static
setmode () {
	if (DesMode == CurMode)
		return;
	CurMode = DesMode;
};

static
inslines (n) {
	HLmode (0);	
	setHL ();
	tputs(tgoto (SetScrollRegion, WindowSize-1, curY-1), 0, dumpchar);
	while (--n >= 0)
		printf(InsertLineStr);
	tputs(tgoto (SetScrollRegion, tt.t_length-1, 0), 0, dumpchar);
};

static
dellines (n) {
	tputs(tgoto (SetScrollRegion, WindowSize-1, curY-1), 0, dumpchar);
	while (--n >= 0)
		printf(DeleteLineStr);
	tputs(tgoto (SetScrollRegion, tt.t_length-1, 0), 0, dumpchar);
}

static
writechars (start, end)
register char	*start,
*end; 
{
	setmode ();
	setHL();



	    while (start <= end) {
		if(CurMode == m_insert) 
			printf(InsertCharStr);
		if (curX >= tt.t_width) {
		    if (curY < tt.t_length) {
		        putchar (*start);
		        curX = 1;
		        curY++;}

		} else {
		    putchar (*start);
		    curX++;}
	        start++;
	    }
};

static
blanks (n) {
	setmode ();
	setHL ();
	while (--n >= 0) {
		if (CurMode == m_insert)
			printf(InsertCharStr);
		putchar (' ');
		curX++;
	}
};


static pad(n,f)
{
	return 0;
};

static
topos (row, column) {
	clearHL ();			/* many terminals can't hack highlighting
					   around cursor positioning.  Silly twits! */
	if (CurMode==m_insert) {
		CurMode = m_overwrite;	
	}
	if (curY == row) {
		if (curX == column)
			return;
		if (curX == column + 1 && (CurMode != m_insert)) {
			putchar(*BC);
			goto done;
		}
	}
	if (curY - 1 == row && curX == column
	    && CurMode != m_insert){
		printf(UP);
		goto done;
	}
	if ( (curY + 1 == row && (column == 1 || column==curX))
	    && (CurMode != m_insert) ){
		if(column!=curX) putchar (015);
		putchar(*NLstr);
		goto done;
	}
	tputs(tgoto (CursorMoveStr, column-1, row-1), 0, dumpchar);
done:
	curX = column;
	curY = row;
};

static
flash () {
	return 0;
}

static
init (BaudRate) {
	static char tbuf[1024];
	static char combuf[1024];
	extern  old;
	char   *fill = combuf;
	int	    mf, ov;			/* for timing calculations */
	static  inited;
	if (!inited)
	{
		FluidStatic(&inited, sizeof(inited));	/* reset on restart */
		if (tgetent (tbuf, getenv ("TERM")) <= 0) {
			stty (1, &old);
			quit (1, "No environment-specified terminal type -- see TSET(1), sh(1)\n");
		}
	}
	inited = 1;
	InsertLineStr = tgetstr ("al", &fill);
	DeleteLineStr = tgetstr ("dl", &fill);
	DeleteCharStr = tgetstr ("dc", &fill);
	EndLineStr = tgetstr ("ce", &fill);
	EraseScreenStr = tgetstr ("cl", &fill);
	HighlightBeginStr = tgetstr ("so", &fill);
	HighlightEndStr = tgetstr ("se", &fill);
	InsertCharStr = tgetstr ("ic", &fill);
	CursorMoveStr = tgetstr ("cm", &fill);
	SetScrollRegion = tgetstr("cs", &fill);
	UP = tgetstr ("up", &fill);
	BC = "\b";
	NLstr = "\n";
	MetaFlag = 0;
	PC = 0;
	tt.t_ILmf = 1;
	tt.t_ILov = 2;
	tt.t_ICmf = MissingFeature;
	tt.t_ICov = MissingFeature;
	tt.t_DCmf = MissingFeature;
	tt.t_DCov = MissingFeature;
	tt.t_length = tgetnum ("li");
	tt.t_width = tgetnum ("co");
};

static
costof (str, ov, mf)
char *str;
int *ov, *mf;
{
	register char *cp;

	*mf  = 0;
	*ov = strlen(str);
	return *ov;
}

static
reset () {
	curX = -1;
	curY = -1;
	topos(1,1);
	printf(EraseScreenStr);
	CurMode = m_insert;
	DesMode = m_overwrite;
	WindowSize = tt.t_length;
};

static
cleanup () {
	HLmode (0);
	DesMode = m_overwrite;
	setmode();
	topos(WindowSize, 1);
};

static
wipeline () {
	setHL ();
	printf(EndLineStr);
};

static
window (n) {
	if (n <= 0 || n > tt.t_length)
		n = tt.t_length;
	WindowSize = n;
};

static
wipescreen () {
	printf(EraseScreenStr);
	curX = curY = -1;
};

static
delchars (n) {
	while (--n >= 0) {
		printf(DeleteCharStr);
	}
};

TrmVS100 () {
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
	tt.t_ILmf = 0;
	tt.t_ILov = 0;
	tt.t_ICmf = 0;
	tt.t_ICov = 0;
	tt.t_length = 24;
	tt.t_width = 80;
	tt.t_modeline = 1;		/* do highlight */
};

