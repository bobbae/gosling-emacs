/* keyboard manipulation primitives */

/*		Copyright (c) 1981,1980 James Gosling		*/

#include "keyboard.h"
#include "window.h"
#include "buffer.h"
#include "config.h"
#include "mlisp.h"
#include <sgtty.h>
#include <sys/types.h>

#ifndef titan
typedef long * waddr_t;
#endif

#ifdef	subprocesses
#ifdef MPXcode
#include <sys/mx.h>
#endif
#include "mchan.h"
#endif

#define MAXPUSHBACK 128

#ifdef HalfBaked
#include <signal.h>
#include <setjmp.h>

static Reading;			/* True iff currently trying to read a
				   character from the tty */
static InterruptChar;		/* Set true when an interrupt character is
				   recieved */
static jmp_buf ReaderEnv;	/* a buffer for the only non-local goto in
				   Emacs.  It has to be done this way because
				   with the new signal system, system calls
				   get continued, and if we get a SIGINT when
				   reading from the tty we want to fake the
				   receipt of a ^G, so we have to break out
				   of the read. */
#endif


/* A keyboard called procedure returns:
	 0 normally
	-1 to quit */

static EndOfMac;		/* the place where the keyboard macro
				   currently being defined should end. */
static PushedBack[MAXPUSHBACK];		/* A buffer of most recently
                                   pushed back characters;
				   the last character in the buffer 
				   will be returned by GetChar the next
				   time that GetChar is called */
static int pbhead;			/* points to the most recently pushed back
				   character */
static MetaChar;		/* The meta-ized character between when */
				/* the meta-char is typed and it is read */
				/* (The escape is returned, this is saved) */
static CheckpointFrequency;	/* The number of keystrokes between
				   checkpoints. */
static Keystrokes;		/* The number of keystrokes since the last
				   checkpoint. */
static CanCheckpoint;		/* True iff we're allowed to checkpoint
				   now. */
#ifdef UmcpFeatures
static char KeyBuf[10];		/* Buffer for keys from GetChar() */
static NextK;			/* Next index into KeyBuf */
static EchoKeys;		/* >= 0 iff we are to echo keystrokes */
static EchoArg;			/* >= 0 iff we are to echo arg */
static Echo1, Echo2;		/* Stuff for final echo */

#define	min(a,b)	((a)<(b)?(a):(b))

#ifdef	MPXcode
static
#endif
EchoThem (notfinal)
register notfinal;
{
    char *dash = notfinal ? "-" : "";

    if (EchoArg >= 0 && ArgState != NoArg) {
	if (EchoKeys >= 0 && NextK)
	    message ("Arg: %d %s%s", arg, KeyToStr (KeyBuf, NextK), dash);
	else
	    message ("Arg: %d", arg);
    }
    else {
	if (EchoKeys >= 0 && NextK)
	    message ("%s%s", KeyToStr (KeyBuf, NextK), dash);
	else
	    return;
    }
    if (notfinal)
	Echo1++;		/* set echoed-flag */
    if (notfinal >= 0)
	DoDsp (0);
}

#endif UmcpFeatures

/* ProcessKeys reads keystrokes and interprets them according to the
   given keymap and its inferior keymaps */
ProcessKeys () {
    register struct keymap *m;
    static struct keymap    NullMap;
    register    c;
    NextGlobalKeymap = 0;
    NextLocalKeymap = 0;

    while (1) {
	if (NextGlobalKeymap == 0) {
	    if (Remembering)
		EndOfMac = MemUsed;
	    if (ArgState != HaveArg && MemPtr == 0 && bf_cur != minibuf)
		UndoBoundary ();
	}
	CanCheckpoint++;
#ifdef UmcpFeatures
	if (!InputPending && (EchoKeys == 0 || EchoArg == 0))
	    EchoThem (-1);
#endif
	if ((c = GetChar ()) < 0) {
	    CanCheckpoint = 0;
	    return 0;
	}
#ifdef UmcpFeatures
	if (NextK >= sizeof KeyBuf)
	    NextK = 0;
	KeyBuf[NextK++] = c;
#endif
	CanCheckpoint = 0;
	if (NextGlobalKeymap == 0)
	    NextGlobalKeymap = CurrentGlobalMap;
	if (NextLocalKeymap == 0)
	    NextLocalKeymap = bf_mode.md_keys;
	if (wn_cur -> w_buf != bf_cur)
	    SetBfp (wn_cur -> w_buf);
	if (m = NextLocalKeymap) {
	    register struct BoundName  *p;
	    NextLocalKeymap = 0;
	    if (p = m -> k_binding[c]) {
		LastKeyStruck = c & 0177;
#ifndef	UmcpFeatures
		if (p -> b_binding != KeyBound)
		    ThisCommand = LastKeyStruck;
#else
		if (p -> b_binding != KeyBound) {
		    /* If echoed immediate preceding key, echo this one */
		    if (!InputPending && Echo2)
			EchoThem (0);
		    NextK = 0;
		    ThisCommand = LastKeyStruck;
		}
#endif
		if (ExecuteBound (p) < 0)
		    return 0;
		if (ArgState != HaveArg)
		    PreviousCommand = ThisCommand;
		if (NextLocalKeymap == 0 || NextGlobalKeymap == 0) {
		    NextGlobalKeymap = 0;
		    continue;
		}
	    }
	}
	if (m = NextGlobalKeymap) {
	    register struct BoundName  *p;
	    register struct keymap *local;
	    local = NextLocalKeymap;
	    NextGlobalKeymap = 0;
	    NextLocalKeymap = 0;
	    if (p = m -> k_binding[c]) {
		LastKeyStruck = c & 0177;
#ifndef UmcpFeatures
		if (p -> b_binding != KeyBound)
		    ThisCommand = LastKeyStruck;
#else
		if (p -> b_binding != KeyBound) {
		    if (!InputPending && Echo2)
			EchoThem (0);
		    NextK = 0;
		    ThisCommand = LastKeyStruck;
		}
#endif
		if (ExecuteBound (p) < 0)
		    return 0;
		if (ArgState != HaveArg)
		    PreviousCommand = ThisCommand;
		if (NextLocalKeymap) {
		    NextGlobalKeymap = NextLocalKeymap;
		    NextLocalKeymap = local ? local : &NullMap;
		}
		else {
		    NextGlobalKeymap = local ? &NullMap : 0;
		    NextLocalKeymap = local;
		}
		continue;
	    }
	    else {
		NextGlobalKeymap = local ? &NullMap : 0;
		NextLocalKeymap = local;
	    }
	}
#ifndef UmcpFeatures
	if (NextLocalKeymap == 0)
	    IllegalOperation ();
#else
	if (NextLocalKeymap == 0) {
	    NextK = 0;
	    IllegalOperation ();
	}
#endif
	else
	    NextGlobalKeymap = &NullMap;
    }
}

/* read a character from the keyboard; call the redisplay if needed */
GetChar () {
    register c;
#ifdef UmcpFeatures
    register alarmtime =
	EchoKeys >= 0 ? (EchoArg >= 0 ? min (EchoKeys, EchoArg)
				      : EchoKeys)
		      : EchoArg;
#endif

    if(pbhead >= 0){
        c = PushedBack[pbhead--];
	goto ReturnIt;
    }
    if((c = MetaChar) >= 0) {
	MetaChar = -1;
	if (InputPending > 0)
	    InputPending--;
	goto ReturnIt;
    }
    if (MemPtr) {
	if (err) {
	    MemPtr = 0;
	    c = -1;
	    goto ReturnIt;
	}
	c = (unsigned char) *MemPtr++;
	if (c)
	{
	    c &= 0177;			/* fix up ^@-s */
	    goto ReturnIt;
	}
	MemPtr = 0;
	c = -1;
	goto ReturnIt;
    }
    if (err && InputFD!=stdin){
	c = -1;
	goto ReturnIt;
    }
#ifdef subprocesses
    if (InputFD==stdin && mpxin->ch_count==0 && !InputPending) {
#else

#ifdef i386
     if (InputFD==stdin && stdin->_r==0 && !InputPending) {
#else  i386
     if (InputFD==stdin && stdin->_cnt==0 && !InputPending) {
#endif i386

#endif
#ifdef FIONREAD
	ioctl (fileno(stdin), FIONREAD, (waddr_t)&InputPending);
#endif
	if(!InputPending) {
	    DoDsp (0);
	    if(CheckpointFrequency>0 && CanCheckpoint
		    && Keystrokes>CheckpointFrequency) {
#ifdef	MPXcode
		long now[2];		/* to fix idle problem */
		now[0] = now[1] = time(0);
		utime(ttydev, now);	/* fix idle prob - set access time */
#endif
		CheckpointEverything ();
		Keystrokes = 0;
	    }
	}
    }
    Keystrokes++;
#ifdef HalfBaked
    if (setjmp (ReaderEnv) || ((Reading=1),InterruptChar)) {
	c = Ctl ('G');
#ifdef subprocesses
	if (InputFD == stdin) mpxin->ch_count = 0;
#else
	if (InputFD == stdin) stdin->_cnt = 0;
#endif
	InputPending = 0;
	InterruptChar = 0;
    } else
#endif
#ifdef subprocesses
    if(InputFD == stdin) {
#ifndef UmcpFeatures
	c = mpx_getc(mpxin);
#else
	if (alarmtime > 0)
	    sigset (SIGALRM, EchoThem);
#ifndef ECHOKEYS
	c = mpx_getc(mpxin);
#else
	c = mpx_getc(mpxin, alarmtime);
#endif
#endif
	InputPending = mpxin->ch_count;
    }
    else {
	c = getc(InputFD);
#ifdef i386
	InputPending = stdin->_r>0;
#else  i386
	InputPending = stdin->_cnt>0;
#endif i386
    }
#else
    {
#ifdef UmcpFeatures
	if (alarmtime > 0) {
	    sigset (SIGALRM, EchoThem);
	    alarm ((unsigned) alarmtime);
	}
#endif
	c = getc(InputFD);
#ifdef UmcpFeatures
	alarm (0);
#endif
	InputPending = stdin->_cnt>0;
    }
#endif
    if (MiniBuf && (!InMiniBuf || *MiniBuf) && !ResetMiniBuf)
	MiniBuf = *MiniBuf ? "" : 0;	/* Only reset minibuf w/ kbd input */
#ifdef HalfBaked
    Reading = 0;
#endif
    if(c<0)
    {
	c = -1;
	goto ReturnIt;
    }

    if (MetaFlag)
    {
	c &= 0377;
	if (c & 0200)			/* if real meta char */
	{
	    MetaChar = c & 0177;	/* remember the character */
	    c = '\033';			/* and return an ESC */
	    InputPending++;
	}				/* this is a kludge, but it''s the */
    }					/* easiest thing to do */
    else
	c &= 0177;

    Remember(c);
    if (MetaFlag && MetaChar >= 0)	/* handle meta''s right */
	Remember(MetaChar);

ReturnIt:
    Echo2 = Echo1;		/* Save last echoed-flag */
    Echo1 = 0;			/* Clear echoed-flag */
    return c;
}

/* Remember for kbd macros */
static
Remember(c)
unsigned char c;
{
    if (Remembering) {
	if (c)
	    KeyMem[MemUsed++] = c;
	else
	    KeyMem[MemUsed++] = 128;	/* handle ^@ right */
	if (MemUsed >= MemLen) {
	    error ("Keystroke memory overflow!");
	    Remembering = EndOfMac = MemUsed = KeyMem[0] = 0;
	}
    }
}

/* Given a keystroke sequence look up the BoundName that it is bound to */
struct BoundName **LookupKeys (map, keys, len)
register struct keymap *map;
register char *keys;
register len;
{
    register struct BoundName  *b;
    while (map && --len >= 0) {
	b = map -> k_binding[*keys];
	if (len == 0)
	    return &map -> k_binding[*keys];
	keys++;
	if (b == 0 || b -> b_binding != KeyBound)
	    break;
	map = b -> b_bound.b_keymap;
    }
    return 0;
}

StartRemembering () {
    if (Remembering)
	error ("Already remembering!");
    else {
	Remembering++;
	MemUsed = EndOfMac = 0;
	message("Remembering...");
    }
    return 0;
}

StopRemembering () {
    if (Remembering) {
	Remembering = 0;
	KeyMem[EndOfMac] = 0;
	message("Keyboard macro defined.");
    }
    return 0;
}

/* Execute the given command string */
ExecStr (s)
char *s; {
    register char  *old = MemPtr;
    MemPtr = s;
    ProcessKeys ();
    MemPtr = old;
}

ExecuteKeyboardMacro () {
#ifdef UmcpFeatures
    static Executing;		/* true iff already executing */
#endif

    if (Remembering)
	error ("Sorry, you can't call the keyboard macro while defining it.");
    else
	if (MemUsed == 0)
	    error ("No keyboard macro to execute.");
#ifdef UmcpFeatures
	else if (Executing)
	    return 0;
#endif
	else {
	    register i = arg;
#ifdef UmcpFeatures
	    Executing++;
#endif
	    arg = 0;
	    ArgState = NoArg;
	    do ExecStr (KeyMem);
	    while (!err && --i>0);
	    Executing = 0;
	}
    return 0;
}

static
PushBackCharacter () {
    register    n = (int) *getkey (&GlobalMap, ": push-back-character ");
    if (!err)
	if (++pbhead >= MAXPUSHBACK) {
            pbhead = -1;
            error ("Can't push back this many characters.");
        }
        else
            PushedBack[pbhead] = n;
    return 0;
}

RecursiveEdit () {
    struct ProgNode *oldp = CurExec;
    register FILE *oldf = InputFD;
    InputFD = stdin;
    CurExec = 0;
    RecurseDepth++;
    Cant1LineOpt++;
    RedoModes++;
    ProcessKeys ();
    RecurseDepth--;
    Cant1LineOpt++;
    RedoModes++;
    CurExec = oldp;
    InputFD = oldf;
    return 0;
}

#ifdef UmcpFeatures
/* Return MLisp value nonzero if (a) input pending or (b) we can't tell */
static
KeysPending () {
    ReleaseExpr (MLvalue);
    MLvalue -> exp_type = IsInteger;
#ifdef FIONREAD
    if (!InputPending)
	ioctl (fileno(stdin), FIONREAD, (waddr_t)&InputPending);
    MLvalue -> exp_int = InputPending;
#else
    MLvalue -> exp_int = -1;
#endif
    return 0;
}
#endif

/* This routine is called at interrupt level on receipt of an INT signal.  It
   cleanly terminates whatever is going on at the moment. */

#ifdef HalfBaked

static InterruptKey () {
    if (!Reading)
	IllegalOperation ();
    InterruptChar++;
    if (Reading) {
	Reading = 0;
	sigrelse (SIGINT);
	longjmp (ReaderEnv, 1);
    }
}

#endif

InitKey () {
    pbhead = -1;
    MetaChar = -1;
#ifdef HalfBaked
/*    sigset (SIGINT, InterruptKey); *//*XXXXXXXXX*/
    sigset (SIGINT, InterruptKey);/*XXXXXXXXX*/
#endif
    if (!Once)
    {
	setkey (CtlXmap, ('e'), ExecuteKeyboardMacro, "execute-keyboard-macro");
	setkey (CtlXmap, ('('), StartRemembering, "start-remembering");
	setkey (CtlXmap, (')'), StopRemembering, "stop-remembering");
	DefIntVar ("checkpoint-frequency", &CheckpointFrequency);
	CheckpointFrequency = 300;
#ifdef UmcpFeatures
	DefIntVar ("echo-keystrokes", &EchoKeys);
	EchoKeys = -1;
	DefIntVar ("echo-argument", &EchoArg);
	EchoArg = -1;
#endif
	defproc (PushBackCharacter, "push-back-character");
	defproc (RecursiveEdit, "recursive-edit");
#ifdef UmcpFeatures
	defproc (KeysPending, "pending-input");
#endif
	DefIntVar ("this-command", &ThisCommand);
    }
}
