/* Display routines */

/*		Copyright (c) 1981,1980 James Gosling		*/

#include "config.h"
#include "keyboard.h"
#include "macros.h"					/* CEH 2/1/85 */
#include "buffer.h"
#include "window.h"
#include "display.h"
#include <sys/ioctl.h>
#include <sgtty.h>
#include <stdio.h>
#include <sys/types.h>

#ifndef titan
typedef long * waddr_t;
#endif

struct sgttyb old;		/* The initial tty mode bits */
#ifdef HalfBaked
static struct tchars OldTchars;
static struct ltchars OldLtchars;
static int OldLmode;
#endif

extern int EmacsFlowControl;				/* CEH 7/23/85 */

FlowControl(onOff) int onOff; {
    struct tchars tchars;
    ioctl(0, TIOCGETC, &tchars);
    if (onOff) {
	tchars.t_startc = '';
	tchars.t_stopc = '';
	EmacsFlowControl = 1;
    } else {
	tchars.t_startc = -1;
	tchars.t_stopc = -1;
	EmacsFlowControl = 0;
    }
    ioctl(0, TIOCSETC, &tchars);
}

SetFlowControl() {
    int onOff = getnum(": set flow control  (0 = off, 1 = on): ");
    FlowControl(onOff);
}

InitDsp () {
    struct sgttyb   sg;
#ifdef i386
    static char _sobuf[BUFSIZ];
#else  i386
    extern char _sobuf[];
#endif i386
    ioctl(0, TIOCGETP, &old);
    sg = old;
#ifdef HalfBaked
    ioctl (0, TIOCGETC, (waddr_t)&OldTchars);
    ioctl (0, TIOCGLTC, (waddr_t)&OldLtchars);
    ioctl (0, TIOCLGET, (waddr_t)&OldLmode);
    sg.sg_flags = (sg.sg_flags & ~(ECHO | CRMOD | XTABS | ANYP)) | CBREAK;
    {   struct tchars tchars;
	struct ltchars ltchars;
	int lmode;
	tchars.t_intrc = Ctl ('G');
	tchars.t_quitc = -1;
	if (EmacsFlowControl) {				/* CEH 7/23/85 */
		tchars.t_startc = '';			/* CEH 7/23/85 */
		tchars.t_stopc = '';			/* CEH 7/23/85 */
	} else {					/* CEH 7/23/85 */
		tchars.t_startc = -1;
		tchars.t_stopc = -1;
	}						/* CEH 7/23/85 */
	tchars.t_eofc = -1;
	tchars.t_brkc = -1;
	ltchars.t_suspc = -1;
	ltchars.t_dsuspc = -1;
	ltchars.t_rprntc = -1;
	ltchars.t_flushc = -1;
	ltchars.t_werasc = -1;
	ltchars.t_lnextc = -1;
	lmode = OldLmode | LLITOUT;
	ioctl (0, TIOCSETC, (waddr_t)&tchars);
	ioctl (0, TIOCSLTC, (waddr_t)&ltchars);
	ioctl (0, TIOCLSET, (waddr_t)&lmode);
    }
#else
    sg.sg_flags = (sg.sg_flags & ~(ECHO | CRMOD | XTABS)) | RAW;
#endif
    ioctl(0, TIOCSETP, &sg);
    ScreenGarbaged = 1;
    setbuf (stdout, _sobuf);
    MetaFlag = 0;
    if (Once) {						/* CEH 2/1/85 */
      int i = FindMac ("emacs-dsp-entry-hook");		/* CEH 2/1/85 */
      if (i >= 0) ExecuteBound (MacBodies[i]);		/* CEH 2/1/85 */
    } else {						/* CEH 2/1/85 */
      defproc(SetFlowControl, "set-flow-control");
    }
    term_init ();
    if (tt.t_window) (*tt.t_window) (0);
}

RstDsp () {
    int i = FindMac ("emacs-dsp-exit-hook");		/* CEH 2/1/85 */
    if (i >= 0) ExecuteBound (MacBodies[i]);		/* CEH 2/1/85 */
    if (tt.t_window) (*tt.t_window) (0);
    (*tt.t_topos) (ScreenLength, 1);
    (*tt.t_wipeline) (0);
    (*tt.t_cleanup) ();
    fflush (stdout);
#ifdef HalfBaked
    ioctl (0, TIOCSETC, (waddr_t)&OldTchars);
    ioctl (0, TIOCSLTC, (waddr_t)&OldLtchars);
    ioctl (0, TIOCLSET, (waddr_t)&OldLmode);
#endif
    ioctl(0, TIOCSETP, &old);
}

/* CEH 2/1/85
    Added two new hooks "emacs-dsp-entry-hook" and "emacs-dsp-exit-hook".
    They are intended for any special processesing you might want to do just
    after emacs sets up it't tty modes, or just before it restores the
    shell's. Added so that we could turn the mouse on and off for emacs and
    not clutter up other programs with mouse output.
*/

/* CEH 7/23/85
    Added emacs-flow-control boolean to allow flow control as an option under
    emacs. Default is off (0).
*/
