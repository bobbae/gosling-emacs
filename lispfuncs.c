/* lisp functions to handle environment enquiries */

/*		Copyright (c) 1981,1980 James Gosling		*/

#include "display.h"
#include "buffer.h"
#include "window.h"
#include "keyboard.h"
#include "mlisp.h"
#include "macros.h"
#include "pwd.h"
#include "config.h"
#include <sys/param.h>

char  *malloc(),*realloc(), *ctime(), *getenv();

static struct passwd *pw;	/* password entry for the current user */
static char LoginId[12];	/* login ID of current user */
static char FullName[250];	/* full name of current user */

static char ConvertedSystemName[128];

extern baud_rate;
IntFunc (CurrentWindow, CalcCurrent())
IntFunc (BaudRate, baud_rate);
IntFunc (WindowHeight, wn_cur->w_height - (wn_cur->w_next ? 1 : 0));
IntFunc (WindowWidth, ScreenWidth);
MarkFunc (DotVal,dot)
MarkFunc (MarkVal, bf_cur->b_mark ? ToMark (bf_cur -> b_mark) :
		(error("No mark set in this buffer!"), -1))
IntFunc (BufSize,NumCharacters+1-FirstCharacter)
IntFunc (CurColFunc,CalcCol())
IntFunc (ThisIndent,CurIndent())
IntFunc (bobp, dot<=FirstCharacter)
IntFunc (eobp, dot>NumCharacters)
IntFunc (bolp, dot<=FirstCharacter || CharAt(dot-1)=='\n')
IntFunc (eolp, dot>NumCharacters || CharAt(dot)=='\n')
IntFunc (FollChar, dot>NumCharacters ? 0 : CharAt(dot))
IntFunc (PrevChar, dot<=FirstCharacter ? 0 : CharAt(dot-1))
IntFunc (FetchLastKeyStruck, LastKeyStruck)
IntFunc (FetchPreviousCommand, PreviousCommand)
IntFunc (RecursionDepth, RecurseDepth)
IntFunc (Nargs, ExecutionRoot.CurExec ? ExecutionRoot.CurExec->p_nargs : 0)
IntFunc (Interactive, ExecutionRoot.CurExec==0)
IntFunc (CurrentNumericTime, time( (long *) 0))
StrFunc (CurrentBufferName, bf_cur->b_name)
StrFunc (CurrentFileName, bf_cur->b_fname ? bf_cur->b_fname : "")
StrFunc (UsersLoginName, LoginId)
StrFunc (UsersFullName, FullName)
StrFunc (ReturnSystemName, ConvertedSystemName)
extern char version[];
StrFunc (EmacsVersion, version)

static
ExpandFileName () {
    static char buf[MAXPATHLEN];
    register char  *fn = getstr (": expand-file-name ");
    if (abspath (fn, buf) < 0) {
	error ("Can't expand file name: %s", fn);
	return 0;
    }
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_v.v_string = buf;
    MLvalue -> exp_release = 0;
    MLvalue -> exp_int = strlen (buf);
    return 0;
}

static
CurrentTime () {
    long    now = time ( (long *) 0);
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_v.v_string = (char *) ctime (&now);
    MLvalue -> exp_v.v_string[24] = '\0';
    MLvalue -> exp_release = 0;
    MLvalue -> exp_int = 24;
    return 0;
}

/* (arg i [prompt]) evaluates the i'th argument to the current function
   or prompts if called interactivly */
Arg () {
    register    i = NumericArg (1);
    register struct ProgNode   *p = ExecutionRoot.CurExec;
    struct ExecutionStack   old;
    if (err)
	return 0;
    if (p == 0 || ExecutionRoot.DynParent == 0) {
	if (StringArg (2)) {
	    LastArgUsed = 0;
	    return GetTtySomething ("string");
	}
	return 0;
    }
    if (i > p -> p_nargs || i <= 0) {
	error ("Bad argument index: (arg %d)", i);
	return 0;
    }
    old = ExecutionRoot;
    ExecutionRoot = *ExecutionRoot.DynParent;
    ExecProg (p -> p_args[i - 1]);
    ExecutionRoot = old;
    return 0;
}

static
DotIsVisible () {		/* tries to guess whether or not dot is
				   currently visible on the screen */
    register windowtop = ToMark (wn_cur->w_start);
    MLvalue -> exp_type = IsInteger;
    MLvalue -> exp_int =
	dot>=windowtop &&
	 dot-(dot>NumCharacters) < ScanBf('\n', windowtop, wn_cur->w_height-1);
    return 0;
}

static
Index () {			/* evaluate (index str sub skip) */
    register skip = 0;
    register Expression *arg2 = 0;
    register char *p;
    static char buffer[128];
    register int bufflen;
    int i = 0;

    if (CurExec->p_nargs == 3) skip = NumericArg (3) - 1;
    if (StringArg(2)) {
        bufflen = MLvalue -> exp_int < sizeof(buffer) ?
          MLvalue -> exp_int : sizeof(buffer);
        strncpy(buffer, MLvalue -> exp_v.v_string, sizeof(buffer));
        ReleaseExpr(MLvalue);
    }
    if (StringArg(1)) {
        if (skip >= MLvalue -> exp_int) skip = MLvalue -> exp_int;
        for (p=MLvalue->exp_v.v_string+skip;
            *p && strncmp(p, buffer, bufflen); p++)
              ;
        if (*p) i = p - MLvalue->exp_v.v_string +1;
        ReleaseExpr(MLvalue);
    }
    MLvalue -> exp_type = IsInteger;
    MLvalue -> exp_int = i;
    return 0;
}
           
  

static
Substr () {			/* evaluate (substr str pos n) */
    register    pos = NumericArg (2), n = NumericArg (3);
    register char  *p;
    if (StringArg (1)) {
	if (pos < 0)
	    pos = MLvalue -> exp_int + 1 + pos;
	if (pos <= 0)
	    pos = 1;
	if (n < 0) {
	    n = MLvalue -> exp_int + n;
	    if (n < 0)
		n = 0;
	}
	if (pos + n - 1 > MLvalue -> exp_int) {
	    n = MLvalue -> exp_int + 1 - pos;
	    if (n < 0)
		n = 0;
	}
	p = (char *) malloc (n + 1);
/*!*/	cpyn (p, MLvalue -> exp_v.v_string + pos - 1, n);
	p[n] = '\0';
	ReleaseExpr (MLvalue);
	MLvalue -> exp_int = n;
	MLvalue -> exp_release = 1;
	MLvalue -> exp_v.v_string = p;
    }
    return 0;
}

static
ToColCommand () {
    register    n = getnum (": to-col ");
    if (!err)
	ToCol (n);
    return 0;
}

static
CharToString () {
    register    n = getnum (": char-to-string ");
    ReleaseExpr (MLvalue);
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_release = 1;
    MLvalue -> exp_int = 1;
    MLvalue -> exp_v.v_string = (char *) malloc (2);
    MLvalue -> exp_v.v_string[0] = n & 0177;
    MLvalue -> exp_v.v_string[1] = '\0';
    return 0;
}

static
StringToChar () {
    register char  *s = getstr (": string-to-char ");
    ReleaseExpr (MLvalue);
    MLvalue -> exp_type = IsInteger;
    MLvalue -> exp_int = s ? *s : 0;
    return 0;
}

static
InsertCharacter () {
    SelfInsert (getnum (": insert-character "));
    return 0;
}

static
GetTtyString () {		/* get a string from the tty */
    return GetTtySomething ("string");
}

static
GetTtyInput () {		/* get input from the tty with a prefix */
    return GetTtySomething ("input");
}

static
GetTtyNoBlanksInput () {	/* Ditto, but don't allow blanks */
    return GetTtySomething ("no-blanks-input");
}

static
GetTtyCommand () {		/* get a command name from the tty */
    return GetTtySomething ("command");
}

static
GetTtyVariable () {		/* get a variable name from the tty */
    return GetTtySomething ("variable");
}

GetTtyBuffer () {		/* get a buffer name from the tty */
    return GetTtySomething ("buffer");
}

GetTtyKey () {				/* get a key string from the tty */
    return GetTtySomething ("key");
}

/* Helper function for get-tty-string, get-tty-command, and
   get-tty-variable */
static
GetTtySomething (something)
char   *something; {
    char   *prompt1 = getstr (": get-tty-%s (prompt) ", something);
    register    FILE * LInputFD = InputFD;
    register struct ProgNode   *LCurExec = CurExec;
/*  register char  *LMemPtr = MemPtr; */
    register char  *answer;
    if (prompt1) {
	register i;
	char prompt[500], init[500];
	strcpyn (prompt, prompt1, sizeof prompt);
	prompt [sizeof prompt - 1] = 0;
	if (*something == 'i' || *something == 'n')
	{
	    prompt1 = getstr(": get-tty-%s (prompt) %s (init) ",
				something, prompt);
	    if (! prompt1 )
		goto out;

	    strcpyn(init, prompt1, sizeof init);
	    init[sizeof init - 1] = 0;
	}
	InputFD = stdin;
	CurExec = 0;
/*	MemPtr = 0; */
	ReleaseExpr (MLvalue);
	switch (*something) {
	    case 's': 		/* get-tty-string */
		answer = getstr (prompt);
		break;
	    case 'b':		/* get-tty-buffer */
		i = getword (BufNames, prompt);
		answer = i < 0 ? 0 : BufNames[i];
		break;
	    case 'c': 		/* get-tty-command */
		i = getword (MacNames, prompt);
		answer = i < 0 ? 0 : MacNames[i];
		break;
	    case 'v': 		/* get-tty-variable */
		i = getword (VarNames, prompt);
		answer = i < 0 ? 0 : VarNames[i];
		break;
	    case 'k':		/* get-tty-key */
		answer = getkey (CurrentGlobalMap, prompt);
		break;
	    case 'i':		/* get-tty-input */
	    case 'n':		/* get-tty-no-blanks-input */
	    {
		char *fmt[2];

		fmt[0] = "%s";
		fmt[1] = prompt;
#ifdef	pmax
		answer = BrGetstr(*something=='n', init, fmt[0], fmt[1], 0, 0);
#else
		answer = BrGetstr (*something=='n', init, fmt);
#endif	pmax
		break;
	    }
	}
	InputFD = LInputFD;
/*	MemPtr = LMemPtr; */
	CurExec = LCurExec;
	if (answer) {
	    MLvalue -> exp_int = strlen (answer);
	    MLvalue -> exp_v.v_string = savestr (answer);
	    MLvalue -> exp_type = IsString;
	    MLvalue -> exp_release = 1;
	}
	else
	    MLvalue -> exp_type = IsVoid;
    }
out:
    return 0;
}

static
GetTtyCharacter () {		/* get a character from the tty */
    register FILE *LInputFD = InputFD;
    register struct ProgNode   *LCurExec = CurExec;
/*  register char  *LMemPtr = MemPtr; */
    InputFD = stdin;
    CurExec = 0;
/*  MemPtr = 0; */
    MLvalue -> exp_int = GetChar ();
    MLvalue -> exp_type = IsInteger;
    InputFD = LInputFD;
/*  MemPtr = LMemPtr; */
    CurExec = LCurExec;
    return 0;
}

Concat () {			/* implements (concat str str str) */
    StringArg (1);
    if (!err && CurExec -> p_nargs > 1) {
	register char  *p = (char *) malloc (100);
	register    space = 100;
	register    size = 0;
	register    i = 1;
	do {
	    if (size + MLvalue -> exp_int >= space)
		p = (char *) realloc ((char *)p, space += MLvalue -> exp_int + 100);
/*!*/	    cpyn (p + size, MLvalue -> exp_v.v_string, MLvalue -> exp_int);
	    size += MLvalue -> exp_int;
	    i++;
	} while (i <= CurExec -> p_nargs && StringArg (i));
	ReleaseExpr (MLvalue);
	MLvalue -> exp_type = IsString;
	MLvalue -> exp_int = size;
	MLvalue -> exp_release = 1;
	MLvalue -> exp_v.v_string = p;
	p[size] = '\0';
    }
    return 0;
}

static
RegionToString () {
    register    left,
                right;
    if (bf_cur -> b_mark == 0) {
	error ("Mark not set");
	return 0;
    }
    left = ToMark (bf_cur -> b_mark);
    if (left <= dot)
	right = dot;
    else {
	right = left;
	left = dot;
    }
    if (left <= bf_s1 && right > bf_s1)
	GapTo (left);
    MLvalue -> exp_v.v_string =
	(char *) malloc ((MLvalue -> exp_int = right - left) + 1);
/*!*/    cpyn (MLvalue -> exp_v.v_string, &CharAt (left), MLvalue -> exp_int);
    MLvalue -> exp_v.v_string[MLvalue -> exp_int] = '\0';
    MLvalue -> exp_release = 1;
    MLvalue -> exp_type = IsString;
    return 0;
}

Length () {
    if (StringArg (1)) {
	ReleaseExpr (MLvalue);
	MLvalue -> exp_type = IsInteger;
    }
    return 0;
}

static
GotoCharacter () {
    register    n = getnum (": goto-character ");
    if (!err) {
	if (n < 1)
	    n = 1;
	if (n > NumCharacters)
	    n = NumCharacters + 1;
	SetDot (n);
    }
    return 0;
}

NoValue () {			/* (novalue) acts like a non-existant value,
				   useful for returning from MLisp
				   functions. */
    return 0;
}

static  Getenv () {
    char   *vname = getnbstr (": getenv ");
    if (vname == 0)
	return 0;
    if ((MLvalue -> exp_v.v_string = (char *) getenv (vname)) == 0) {
	error ("There is no environment variable named %s", vname);
	MLvalue -> exp_v.v_string = "";
    }
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_release = 0;
    MLvalue -> exp_int = strlen (MLvalue -> exp_v.v_string);
    return 0;
}

InitFunc () {
    if (!Once)
    {
	defproc (ExpandFileName, "expand-file-name");
	defproc (NoValue, "novalue");
	defproc (GotoCharacter, "goto-character");
	defproc (ToColCommand, "to-col");
	defproc (CharToString, "char-to-string");
	defproc (StringToChar, "string-to-char");
	defproc (RegionToString, "region-to-string");
        defproc (CurrentWindow, "current-window");
	defproc (BaudRate, "baud-rate");
	defproc (WindowHeight, "window-height");
	defproc (WindowWidth, "window-width");
	defproc (DotIsVisible, "dot-is-visible");
	defproc (Length, "length");
	defproc (Substr, "substr");
	defproc (Index, "index");
	defproc (Concat, "concat");
	defproc (GetTtyString, "get-tty-string");
	defproc (GetTtyCommand, "get-tty-command");
	defproc (GetTtyVariable, "get-tty-variable");
	defproc (GetTtyBuffer, "get-tty-buffer");
	defproc (GetTtyKey, "get-tty-key");
	defproc (GetTtyInput, "get-tty-input");
	defproc (GetTtyNoBlanksInput, "get-tty-no-blanks-input");
	defproc (DotVal, "dot");
	defproc (MarkVal, "mark");
	defproc (BufSize, "buffer-size");
	defproc (CurColFunc, "current-column");
	defproc (ThisIndent, "current-indent");
	defproc (bobp, "bobp");
	defproc (eobp, "eobp");
	defproc (bolp, "bolp");
	defproc (eolp, "eolp");
	defproc (FollChar, "following-char");
	defproc (PrevChar, "preceding-char");
	defproc (FetchLastKeyStruck, "last-key-struck");
	defproc (FetchPreviousCommand, "previous-command");
	defproc (RecursionDepth, "recursion-depth");
	defproc (InsertCharacter, "insert-character");
	defproc (GetTtyCharacter, "get-tty-character");
	defproc (CurrentBufferName, "current-buffer-name");
	defproc (CurrentFileName, "current-file-name");
	defproc (UsersLoginName, "users-login-name");
	defproc (UsersFullName, "users-full-name");
	defproc (CurrentTime, "current-time");
        defproc (CurrentNumericTime, "current-numeric-time");
	defproc (Getenv, "getenv");
	defproc (Arg, "arg");
	defproc (Nargs, "nargs");
	defproc (Interactive, "interactive");
	defproc (ReturnSystemName, "system-name");
	defproc (EmacsVersion, "emacs-version");
    }
    pw = (struct passwd *) getpwuid (getuid ());
    strcpyn (LoginId, pw->pw_name, sizeof LoginId);
    strcpyn (FullName, MailOriginator, sizeof FullName);
    {
	register char  *p = SystemName;
	if (p == 0 || *p == 0)
	    p = "Bogus System Name";
	strcpyn (ConvertedSystemName, p, sizeof ConvertedSystemName);
	p = ConvertedSystemName;
	while (*p) {
	    if (*p < ' ')
		*p = 0;
	    else
		if (*p == ' ')
		    *p = '-';
	    p++;
	}
    }
}
