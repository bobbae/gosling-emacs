/* Routines to handle the minibuffer (the one-line display at the
   bottom of the screen) */

/*		Copyright (c) 1981,1980 James Gosling		*/

/* Modified DJH 7-Dec-80	Added InitMiniBuf
 * 				Make help on getword errors optional
 * $Log: minibuf.c,v $
 * Revision 1.9  1993/08/11 21:51:24  reid
 * One more iteration in the BSDI/MIPS/Alpha interoperability wars
 * from some code that predates stdio
 *
 * Revision 1.8  1993/08/11  19:39:54  reid
 * Brian re-fixing MIPS changes necessitated by BSDI changes breaking
 * Alpha. Ah, the joys of multiple versions.
 *
 * Revision 1.7  1993/08/11  18:23:54  reid
 * Get it working on alpha again after BSDI changes.
 *
 * Revision 1.6  1993/08/11  05:18:55  reid
 * Changes for BSDI, by Brian. Whew. When I first put this VarArgs stuff
 * in back in 1988 for the pmax, I didn't really understand it, and now
 * I'm paying the price. Tons of cleanup of varargs routines.
 *
 * Revision 1.5  1993/01/19  14:52:02  mogul
 * Export a variable used in filecomp.c
 *
 * Revision 1.4  93/01/11  13:25:06  mogul
 * Bug fixes for MIPS, Alpha
 * 
 * Revision 1.3  1988/09/28  22:19:28  reid
 * fixed a lot of VARARGS problems.
 *
 * Revision 1.2  86/05/06  14:43:43  mcdaniel
 * 
 * 
 * Revision 1.1  86/04/16  13:53:22  mcdaniel
 * Initial revision
 * 
 */
#include "buffer.h"
#include "window.h"
#include "keyboard.h"
#include "mlisp.h"
#ifdef pmax
#include <varargs.h>
#endif pmax
#include <ctype.h>

#define BufferSize 2000
extern int PopUpWindows;		/* for RemoveHelpWindow */
static char buf[BufferSize];
static StackTraceOnError;	/* if true, whenever an error is encountered
				   a stack trace will be dumped to the stack
				   trace buffer */


#ifndef	pmax
/* sprintrmt(arg) effectively does an sprintf(buf,arg[0],arg[1],...); */
sprintrmt(buf, arg)
char *buf;
register char **arg; {
	FILE _strbuf;

	_strbuf._flag = _IOSTRG;
	_strbuf._ptr = (unsigned char *)buf;
	_strbuf._cnt = BufferSize;
	_doprnt(*arg, arg+1 , &_strbuf);
	putc('\0', &_strbuf);
}
#endif	pmax

#ifndef __osf__
/* This is the same as the standard sprintf (buf, ...) except that it
   guarantees to return buf */
/* VARARGS */
#ifndef pmax
char *sprintf (buf, fmt, args)
char *buf, *fmt; {
	FILE _strbuf;

	_strbuf._flag = _IOSTRG;
	_strbuf._ptr = buf;
	_strbuf._cnt = 10000;
	_doprnt(fmt, &args, &_strbuf);
	putc('\0', &_strbuf);
	return buf;
}
#else pmax
#ifdef i386
int sprintf(buf, fmt, va_alist)
#else  i386
char *sprintf(buf, fmt, va_alist)
#endif i386
char *buf, *fmt;
va_dcl
{
	FILE _strbuf;
	va_list ap;

	va_start(ap);
#ifdef i386
	_strbuf._flags = __SWR | __SSTR;
        _strbuf._bf._base = _strbuf._p = (unsigned char *)buf;
        _strbuf._bf._size = _strbuf._w = 10000;

	(void) vfprintf(&_strbuf, fmt, ap);
	va_end(ap);
	putc('\0', &_strbuf);
	return (int) buf;
#else  i386
	_strbuf._flag = _IOSTRG;
	_strbuf._ptr = buf;
	_strbuf._cnt = 10000;
	(void)_doprnt(fmt, ap, &_strbuf);
	va_end(ap);
	putc('\0', &_strbuf);
	return buf;
#endif i386
}
#endif pmax
#else   __osf__
/* In OSF, sprintf() returns int */
#endif	__osf__

/* This is the same as sprintf (buf, ...) except that it guards against
   buffer overflow */
/* VARARGS */
#ifndef pmax
char *sprintfl (buf, len, fmt, args)
char *buf, *fmt; {
	FILE _strbuf;

	_strbuf._flag = _IOSTRG;
	_strbuf._ptr = buf;
	_strbuf._cnt = len-1;
	_doprnt(fmt, &args, &_strbuf);
	putc('\0', &_strbuf);
	buf[len-1] = 0;
	return buf;
}
#else pmax

char *sprintfl(buf, len, fmt, va_alist)
int len;
char *buf, *fmt;
va_dcl
{
	FILE _strbuf;
	va_list ap;

#if defined(i386) || defined (__osf__)
#ifdef	__osf__
	_strbuf._ptr = (unsigned char *)buf;
	_strbuf._flag = _IOSTRG;
	_strbuf._cnt = 10000;
#else   __osf__
        _strbuf._bf._base = _strbuf._p = (unsigned char *)buf;
	_strbuf._flags = __SWR | __SSTR;
        _strbuf._bf._size = _strbuf._w = 10000;
#endif  __osf
	va_start(ap);
	(void) vfprintf(&_strbuf, fmt, ap);
	va_end(ap);
	putc('\0', &_strbuf);
	buf[len-1] = 0;
	return buf;
#else  __osf__ || i386
	_strbuf._flag = _IOSTRG;
	_strbuf._ptr = buf;
	_strbuf._cnt = 10000;
	va_start(ap);
	(void)_doprnt(fmt, ap, &_strbuf);
	va_end(ap);
	putc('\0', &_strbuf);
	buf[len-1] = 0;
	return  buf;
#endif i386
}
#endif pmax


#if 0
char *sprintfl(buf, len, fmt, va_alist)
char *buf, *fmt;
int len;
va_dcl
{
	FILE _strbuf;
	va_list ap;

	va_start(ap);
	_strbuf._flag = _IOSTRG;
#ifdef	__osf__
	_strbuf._ptr = (unsigned char *)buf;
	_strbuf._cnt = 10000;
	(void)_doprnt(fmt, ap, &_strbuf);
#else 
	_strbuf._ptr = (char *)buf;
	_strbuf._cnt = 10000;
	(void)_doprnt(fmt, ap, &_strbuf);
#endif	__osf__
	putc('\0', &_strbuf);
	buf[len-1] = 0;
	return buf;
}
#endif 0



/* dump an error message; called like printf */
/* VARARGS 1 */
#ifndef pmax
error (m)
char * m; {
    NextLocalKeymap = 0;
    NextGlobalKeymap = 0;
    if(err && MiniBuf) return;	/* the first error message probably makes the
				   most sense, so we suppress subsequent
				   ones. */
    err++;
    sprintrmt (buf, &m);
    MiniBuf = buf;
    DumpMiniBuf++;
    if (StackTraceOnError && CurExec) DumpStackTrace ();
}
#else pmax
error (fmt, va_alist)
char *fmt;
va_dcl
{
    va_list ap;

    NextLocalKeymap = 0;
    NextGlobalKeymap = 0;
    if(err && MiniBuf) return;	/* the first error message probably makes the
				   most sense, so we suppress subsequent
				   ones. */
    err++;
    va_start(ap);
    vsprintf(buf, fmt, ap);
    va_end(ap);
    MiniBuf = buf;
    DumpMiniBuf++;
    if (StackTraceOnError && CurExec) DumpStackTrace ();
}
#endif pmax
/* dump an informative message to the minibuf */
/* VARARGS 1 */
#ifndef pmax
message (m)
char * m; {
    if(!interactive || err && MiniBuf) return;
    sprintrmt (buf, &m);
    MiniBuf = buf;
    DumpMiniBuf++;
}
#else pmax
message (fmt, va_alist)
char *fmt;
va_dcl
{
    va_list ap;

    if(!interactive || err && MiniBuf) return;
    va_start(ap);
    vsprintf(buf, fmt, ap);
    va_end(ap);
    MiniBuf = buf;
    DumpMiniBuf++;
}
#endif pmax
/* read a number from the terminal with prompt string s */
/* VARARGS 1 */
#ifndef pmax
getnum (s)
char * s; {	/* gmcd */
    register char  *p,
                   *answer;
    if (CurExec) {		/* we are being called from an
				   MLisp-called function.  Instead of
				   prompting for a string we evaluate it
				   from the arg list */
	register larg = arg;
	register enum ArgStates largstate = ArgState;
	register n;
	ArgState = NoArg;
	if (++LastArgUsed >= CurExec -> p_nargs) {
	    error ("Too few arguments given to %s",
			CurExec -> p_proc -> b_name);
	    return 0;
	}
	n = NumericArg (LastArgUsed+1);
	arg = larg;
	ArgState = largstate;
	return n;
    }
    return StrToInt (BrGetstr (1, "", &s)); /* gmcd */
}
#else pmax
getnum (s)
char *s;
 {	/* gmcd */
    register char  *p,
                   *answer;
    if (CurExec) {		/* we are being called from an
				   MLisp-called function.  Instead of
				   prompting for a string we evaluate it
				   from the arg list */
	register larg = arg;
	register enum ArgStates largstate = ArgState;
	register n;
	ArgState = NoArg;
	if (++LastArgUsed >= CurExec -> p_nargs) {
	    error ("Too few arguments given to %s",
			CurExec -> p_proc -> b_name);
	    return 0;
	}
	n = NumericArg (LastArgUsed+1);
	arg = larg;
	ArgState = largstate;
	return n;
    }
    return StrToInt (BrGetstr (1, "", s, 0, 0, 0, 0)); /* gmcd */
}
#endif pmax

StrToInt (answer)
char *answer; {
    register char *p = answer;
    register n = 0, neg = 0;
    if (p == 0)
	return 0;
    while(isspace(*p)) p++;
    if(*p>='A'){
	register len = strlen(answer);
	if(strncmp(answer,"on",len)==0
		|| strncmp(answer,"true",len)==0) return 1;
	if(strncmp(answer,"off",len)==0
		|| strncmp(answer,"false",len)==0) return 0;
    }
    while (*p) {
	if (isdigit (*p))
	    n = n * 10 + *p - '0';
	else
	    if (*p == '-')
		neg = !neg;
	    else
		if (!isspace (*p) && *p != '+') {
		    error ("Malformed integer: \"%s\"", answer);
		    return 0;
		}
	p++;
    }
    return neg ? -n : n;
}

/* Read a string from the terminal with prompt string s */
/* VARARGS 1 */
#ifndef pmax
char   *getstr (s) {
    return BrGetstr (0, "", &s);
}
#else
char   *getstr (va_alist)
va_dcl
{
    va_list ap;
    char *fmt;
    char *arg0;
    char *arg1;
    char *arg2;
    char *arg3;
    
    va_start(ap);
    fmt = va_arg(ap, char *);
    arg0 = va_arg(ap, char *);
    arg1 = va_arg(ap, char *);
    arg2 = va_arg(ap, char *);
    arg3 = va_arg(ap, char *);
    return BrGetstr (0, "", fmt, arg0, arg1, arg2, arg3);
    va_end(ap);
}
#endif

/* Read a string from the terminal with prompt string s, whitespace
   will terminate it. */

/* VARARGS 1 */
#ifndef pmax
char   *getnbstr (s) {
    return BrGetstr (1, "", &s);
}
#else  pmax
char   *getnbstr(va_alist)
va_dcl
{
    va_list ap;
    char *fmt;
    char *arg0;
    char *arg1;
    char *arg2;
    char *arg3;
    
    va_start(ap);

    fmt = va_arg(ap, char *);
    arg0 = va_arg(ap, char *);
    arg1 = va_arg(ap, char *);
    arg2 = va_arg(ap, char *);
    arg3 = va_arg(ap, char *);
    return BrGetstr (0, "", fmt, arg0, arg1, arg2, arg3);
    va_end(ap);
}
#endif pmax

int AutoHelp;			/* true iff ambiguous or misspelled words
				   should create a help window (DJH) */
int RemoveHelpWindow;		/* true iff help window should go away  */
				/* after reading word */

/* Read a word from the terminal using prompt string s and
   restricting the word to be one of those in the given table.
   Returns the index of the word in the table.
   Returns -1 on failure.
   eg.	static char **words = { "command1", "command2", 0 };
	switch(getword(words,"prompt")){ */
/* VARARGS 2 */
getword(table, s)
register char **table;
char *s; {
    register char  *word;
    register int    p;
    int             bestp = -1,
                    nfound;
    register char *s1, *s2;
    int ctr;
    struct window  *killee = 0;
    struct buffer  *old = bf_cur;
    int     len;
    char    prefix[200];
    int     side, popup = PopUpWindows;

    if (RemoveHelpWindow) PopUpWindows = 0;
    prefix[0] = '\0';
#ifdef	pmax
    while (word = BrGetstr (1, prefix, s, 0, 0, 0, 0)) {
#else
    while (word = BrGetstr (1, prefix, &s)) {
#endif	pmax
	len = strlen (word);
	prefix[0] = '\0';
	nfound = 0;
	if (word[len - 1] != '?')
	    for (p = 0; s1 =table[p]; p++) {
		s2 = word;
		for (ctr = len; *s1++==*s2++ && --ctr>0;);
		if (ctr <= 0) {
		    nfound++;
		    if (nfound == 1)
			strcpy (prefix, table[p]);
		    else {
			register char  *pfx = prefix,
			               *w = table[p];
			while (*pfx++ == *w++);
			*--pfx = '\0';
		    }
		    bestp = p;
		    if (table[p][len] == 0) {/* exact match */
			nfound = 1;
			break;
		    }
		}
	    }
	if (nfound == 1)
	    break;
	bestp = -1;
	if (nfound > 1 && strcmp (prefix, word) != 0)
	    continue;
	if (!interactive){
	    bestp = -1;
	    error ("\"%s\" %s", word,
		nfound	? "is ambiguous."
			: "doesn't make any sense to me.");
	    break;
	}
	if (AutoHelp == 0 && (len <= 0 || word[len - 1] != '?')) {
	    register int    maxlegal = 0;
	    Ding ();		/* DJH -- Don't pop up help window */
	    strcpy (prefix, word);
	    if (nfound == 0) {
		for (p = 0; table[p]; p++)
		    while (strncmp (table[p], word, maxlegal + 1) == 0)
			maxlegal++;
		prefix[maxlegal] = 0;
	    }
	    continue;
	}
	SetBfn ("Help");
	WindowOn (bf_cur);
	EraseBf (bf_cur);
	{
	    register char  *msg;
	    if (len > 0 && word[len - 1] == '?') {
		len--;
		strcpy (prefix, word);
		prefix[len] = '\0';
		msg = "Choose one of the following:\n";
	    }
	    else
		if (nfound > 1)
		    msg = "Ambiguous, choose one of the following:\n";
		else {
		    len = 0;
		    msg = "Rubbish!  Please use one of the following words:\n";
		};
	    InsStr (msg);
	}
	killee = wn_cur;
	side = 0;
	for (p = 0; table[p]; p++)
	    if (len <= 0 || strncmp (table[p], word, len) == 0) {
		char    buf[100];
		sprintfl (buf, sizeof buf, (side == 2 ? ((side = 0), "%s\n")
			    : (side++, "%-25s")),
			table[p]);
		InsStr (buf);
	    }
	BeginningOfFile ();
	bf_cur -> b_mode.md_NeedsCheckpointing = 0;
	bf_modified = 0;
    }
    if (killee) {
/*	DelWin (killee);	*/
	WindowOn (old);
    }
    PopUpWindows = popup;
    return bestp;
}
/* read a string from the terminal with prompt string s.
   Whitespace will break iff breaksp is true.
   The string "prefix" behaves as though the user had typed that first. */
#ifdef	pmax
char   *BrGetstr (breaksp, prefix, fmt, arg0, arg1, arg2, arg3)
char   *prefix;
char   *fmt;
char   *arg0;
char   *arg1;
char   *arg2;
char   *arg3;
#else
char   *BrGetstr (breaksp, prefix, s)
char   *prefix,
       ** s;
#endif	pmax
{
    register    larg = arg;
    register    enum ArgStates largstate = ArgState;
    ArgState = NoArg;

    if (CurExec) {		/* we are being called from an
				   MLisp-called function.  Instead of
				   prompting for a string we evaluate it
				   from the arg list */
	if (++LastArgUsed >= CurExec -> p_nargs) {
	    error ("Too few arguments given to %s",
		    CurExec -> p_proc -> b_name);
	    return 0;
	}
	if (!StringArg (LastArgUsed + 1) || MLvalue -> exp_type != IsString) {
	    error ("%s expected %s to return a value.",
		    CurExec -> p_proc -> b_name,
		    CurExec -> p_args[LastArgUsed] -> p_proc -> b_name);
	    return 0;
	}
	arg = larg;
	ArgState = largstate;
	if (err)
	    return 0;
	if (MLvalue -> exp_v.v_string[MLvalue -> exp_int]) {
	    static char holdit[200];
	/* sigh...  yet another hideous atrocity! */
	    register    len = MLvalue -> exp_int >= sizeof holdit
	    ?           (sizeof holdit) - 1 : MLvalue -> exp_int;
/*!*/	    cpyn (holdit, MLvalue -> exp_v.v_string, len);
	    holdit[len] = 0;
	    return holdit;
	}
	else
	    return MLvalue -> exp_v.v_string;
    }
    {
	register struct marker *olddot = NewMark ();
	register char  *result = 0;
	struct keymap  *outermap;
	char   *OuterReset = ResetMiniBuf;
	char    lbuf[BufferSize];
	char    outer[BufferSize];
	int     OuterLen,
	        OuterDot;
	int     WindowNum = -1;
	if (interactive) {
#ifdef	pmax
	    sprintf(lbuf, fmt, arg0, arg1, arg2, arg3);
#else
	    sprintrmt(lbuf, s);
#endif	pmax
	}
	if (interactive) {
	    DumpMiniBuf++;
	    ResetMiniBuf = MiniBuf = lbuf;
	}
	SetMark (olddot, bf_cur, dot);
	{
	    register struct window *w = windows;
	    register int    i = 0;
	    while (w -> w_next) {
		if (w == wn_cur)
		    WindowNum = i;
		i++;
		w = w -> w_next;
	    }
	    if (WindowNum == -1)
		WindowNum = i;
	    SetWin (w);
	}
	outermap = bf_mode.md_keys;
	bf_mode.md_keys = bf_cur -> b_mode.md_keys =
	    breaksp ? &MinibufLocalNSMap : &MinibufLocalMap;
	NextGlobalKeymap = NextLocalKeymap = 0;
	OuterLen = bf_s1 + bf_s2;
	if (OuterLen > BufferSize)
	    OuterLen = BufferSize;
	OuterDot = dot;
	for (dot = 1; dot <= OuterLen; dot++)
	    outer[dot - 1] = CharAt (dot);
	EraseBf (bf_cur);
	InsStr (prefix);
	MinibufDepth++;
	RecursiveEdit ();
	MinibufDepth--;
	arg = larg;
	ArgState = largstate;
	SetBfp (minibuf);
	bf_mode.md_keys = bf_cur -> b_mode.md_keys = outermap;
	InsertAt (bf_s1 + bf_s2 + 1, 0);
	SetDot (1);
	if (OuterLen)
	    InsCStr (outer, OuterLen);
	SetDot (OuterDot);
	result = err ? 0 : &CharAt (OuterLen + 1);
	if (ResetMiniBuf = OuterReset)
	    MiniBuf = ResetMiniBuf;
	else
	    if (MiniBuf == lbuf)
		MiniBuf = "";
	DelBack (bf_s1 + bf_s2 + 1, bf_s1 + bf_s2 - OuterLen);
	{
	    register struct window *w = windows;
	    while (WindowNum && w -> w_next) {
		WindowNum--;
		w = w -> w_next;
	    }
	    if (WindowNum == 0 && w) {
		SetWin (w);
		dot = ToMark (olddot);
	    }
	    else
		WindowOn (bf_cur);
	}
	dot = ToMark (olddot);
	DestMark (olddot);
	return result;
    }
}

/* Get the name of a key.  Alas, you can't type a control-G,
   since that aborts the key name read.  Returns -1 if aborted. */
/* VARARGS 2 */
#ifndef pmax
char   *getkey (map, prompt)
register struct keymap *map;
char *prompt;
#else pmax
char   *getkey (map, va_alist)
register struct keymap *map;
va_dcl
#endif pmax
{
    register    c;
    register char  *p,
                   *keys;
    register    nkeys;
    static char FakeIt[30];
    static char lbuf[BufferSize];
#ifdef pmax
    va_list ap;
#endif pmax
    if (CurExec) {
	register larg = arg;
	register enum ArgStates largstate = ArgState;
	ArgState = NoArg;
	EvalArg (++LastArgUsed + 1);
	arg = larg;
	ArgState = largstate;
	if (err)
	    return 0;
	if (MLvalue -> exp_type == IsString)
	    return MLvalue -> exp_v.v_string;
	if (MLvalue -> exp_int > 0177) {
	    FakeIt[0] = MLvalue -> exp_int >= 0400 ? '\030' : '\033';
	    FakeIt[1] = MLvalue -> exp_int & 0177;
	    MLvalue -> exp_int = 2;
	}
	else {
	    FakeIt[0] = MLvalue -> exp_int;
	    MLvalue -> exp_int = 1;
	}
	MLvalue -> exp_type = IsString;
	MLvalue -> exp_release = 0;
	MLvalue -> exp_v.v_string = FakeIt;
	return FakeIt;
    }
    if (interactive) {
#ifndef pmax
	sprintrmt (lbuf, &prompt);
#else pmax
	va_start(ap);
	vsprintf (lbuf, va_arg(ap, char *), ap);
	va_end(ap);
#endif pmax
	p = lbuf + strlen (lbuf);
    }
    else
	p = lbuf;
    keys = FakeIt;
    nkeys = 0;
    do {
	*p = 0;
	if (interactive)
	    InMiniBuf++, MiniBuf = lbuf, DumpMiniBuf++;
	if ((c = GetChar ()) == Ctl ('G')) {
	    error ("Aborted.");
	    InMiniBuf = 0;
	    return 0;
	}
	if (++nkeys >= sizeof FakeIt) {
	    error ("key sequence too long");
	    return 0;
	}
	*keys++ = c;
	if (map && map -> k_binding[c]
		&& map -> k_binding[c] -> b_binding == KeyBound)
	    map = map -> k_binding[c] -> b_bound.b_keymap;
	else
	    map = 0;
	if (c == 033) {
	    *p++ = 'E';
	    *p++ = 'S';
	    *p++ = 'C';
	}
	else
	    if (c < 040) {
		*p++ = '^';
		*p++ = (c & 037) + 0100;
	    }
	    else
		*p++ = c;
	if (map)
	    *p++ = '-';
    } while (map);
    *p++ = 0;
    if (interactive)
	MiniBuf = lbuf, DumpMiniBuf++;
    else
	lbuf[0] = '\0';
    InMiniBuf = 0;
    MLvalue -> exp_int = nkeys;
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_release = 0;
    MLvalue -> exp_v.v_string = FakeIt;
    return FakeIt;
}

SelfInsertAndExit () {
    SelfInsert (-1);
    return -1;
}

ErrorAndExit () {
    error ("Aborted.");
    return -1;
}

InitMiniBuf() {
    if (!Once)
    {
	AutoHelp = 1;
	RemoveHelpWindow = 1;
	DefIntVar ("stack-trace-on-error", &StackTraceOnError);
	DefIntVar ("remove-help-window", &RemoveHelpWindow);
	defproc (SelfInsertAndExit, "self-insert-and-exit");
	setkey (MinibufLocalMap, Ctl('g'), ErrorAndExit, "error-and-exit");
    }
}
