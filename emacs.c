/* Yes folks!  This is it!  A for-real Unix Emacs!  With
   all (well...) those features we've come to know and love.

		This atrocity brought to you by:
			James Gosling
			October, 1980
			@ CMU
*/

/*		Copyright (c) 1981,1980 James Gosling		*/

#include "buffer.h"
#include "window.h"
#include "keyboard.h"
#include "macros.h"
#include "config.h"
#include "mlisp.h"
#include <signal.h>
#include <sgtty.h>
#include <sys/types.h>
#include <errno.h>
#include <dirent.h>
#include <sys/param.h>
#ifdef MPXcode
#include <sys/mx.h>
#endif
#include "mchan.h"
#ifdef UciFeatures
#include <pwd.h>
#endif
#ifdef OneEmacsWarning
#undef FIOCXMOD
#endif

#ifdef UmcpFeatures
char	*MyTtyName;		/* name of the tty we're talking to */
#endif

#ifndef titan
typedef long * waddr_t;
#endif

char  *malloc(), *strcpy(), *ttyname(), *getenv();

static  SilentlyKillProcesses;	/* if true, don't ask that annoying
				   question about processes still on the
				   prowl: just kill them! */

#ifdef UmcpFeatures
static	SilentlyExitEmacs;	/* if true, don't ask that annoying
				   question about modified buffers
				   existing: jus exit without
				   saving them! */
#endif
static	DumpedEmacs;		/* if true, this is an emacs that was unexeced
				   useful for paramaterizing .emacs_pro. */

extern  errno;			/* error number returned from Unix
				   system calls */

#ifdef OneEmacsPerTty
static char LockFile[50];	/* The lock file used to determine
				   whether or not multiple emaces are
				   running on this tty */
#ifdef OneEmacsWarning
static AlreadyLocked;		/* True iff lock file was already present */
#endif

UnlockTty () {			/* Allow other Emaces to be created on
				   this tty */
#ifdef OneEmacsWarning
    if (!AlreadyLocked)
#endif
    unlink (LockFile);
}

static  LockTty () {		/* Try to set the per-tty lock.  If we
				   fail, exit back to Unix with a
				   message. */
    register    fd;
#ifndef UmcpFeatures
    register char  *tt = (char *) ttyname (0);
#else
    register char  *tt = MyTtyName;
#endif
    register char  *p;
#ifdef FIOCXMOD
    int     ExclusiveMode;
#endif

#ifdef UtahFeatures
    strcpy (ttydev, tt);	/* SWT - to fix idle problem */
#endif
    for (p = tt; *p;)
	if (*p++ == '/')
	    tt = p;
    sprintfl (LockFile, sizeof LockFile, "/tmp/Emacs-%s", tt);
#ifdef FIOCXMOD			/* use the exclusive access feature if
				   this Unix has it */
    fd = creat (LockFile, 0666);
    ExclusiveMode = FXMWRITE;
    if (fd < 0 && errno != EBUSY) {
	unlink (LockFile);
	fd = creat (LockFile, 0666);
    }
    if (fd < 0 || ioctl (fd, FIOCXMOD, (waddr_t)&ExclusiveMode) < 0) {
	printf ("\
There is already an Emacs running on this terminal.  Since the Unix Kernel\n\
has some rather nasty bugs, if another Emacs starts up all hell will break\n\
loose.  Hence, you'd better get rid of that other Emacs before starting up\n\
a new one.\n");
	exit (1);
    }
    chmod (LockFile, 0666);
#else
    fd = creat (LockFile, 000);
    if (fd < 0) {
	char    buf[100];
#ifdef OneEmacsWarning
	AlreadyLocked++;
	printf ("\
It appears that there are multiple invocations of Emacs running on this\n\
terminal.  You probably don't want to do this since it ties up system\n\
resources.  Do you want me to go ahead and run anyway? ");
#else
	printf ("\
It appears that there are multiple invocations of Emacs running on this\n\
terminal.  You probably don't want to do this since there is a bug in the\n\
Unix kernel that prevents this from working properly.  Do you want me to\n\
ignore this and run anyway? ");
#endif
	if ('y' != *(char *) gets (buf))
	    exit (1);
	unlink (LockFile);
	fd = creat (LockFile, 000);
	if (fd < 0) {
	    printf ("\
Something serious is preventing me from interlocking your tty.  Contact\n\
the person who maintains Emacs at your site.\n");
	    exit (1);
	}
    }
    close (fd);
#endif
}
#endif

#ifdef SIGXCPU
static
        TimeLimit () {		/* Signal handler for CPU time limit */
#ifndef UciFeatures
#ifdef subprocesses
            kill_processes ();
#endif
#endif
    CheckpointEverything ();
#ifndef UciFeatures
    RstDsp ();
    printf (
	    "Emacs has encountered a CPU time limit.  All of the files\n\
that you were editing and have changed have been checkpointed.\n");
#ifdef OneEmacsPerTty
    UnlockTty ();
#endif
    exit (1);
#else
    quit (1,
"Emacs has encountered a CPU time limit.  All of the files\n\
that you were editing and have changed have been checkpointed.\n");
#endif
}
#endif

DebugTerminate(sig, code, scp)
int sig;
int code;
struct sigcontext *scp;
{
	int i;

	RstDsp ();

	printf("\r\nDebugTerminate(%d, %d, %x)\r\n",
			sig, code, scp);

	printf("sc_pc 0x%x\r\n", scp->sc_pc);

#ifdef	__mips
	for (i = 0; i < (sizeof(scp->sc_regs)/sizeof(scp->sc_regs[0])); i++) {
	    printf("\tr%d=%08x", i, scp->sc_regs[i]);
	    if ((i % 4) == 3)
		printf("\r\n");
	}
#endif	__mips

#ifdef	__alpha
	printf("sc_ps 0x%016x\r\n", scp->sc_ps);
	for (i = 0; i < (sizeof(scp->sc_regs)/sizeof(scp->sc_regs[0])); i++) {
	    printf("\tr%-2d=%16x", i, scp->sc_regs[i]);
	    if ((i % 3) == 2)
		printf("\r\n");
	}
	printf("\r\n");
	for (i = 0; i < (sizeof(scp->sc_fpregs)/sizeof(scp->sc_fpregs[0]));
									 i++) {
	    printf("\tf%-2d=%16g", i, scp->sc_fpregs[i]);
	    if ((i % 3) == 2)
		printf("\r\n");
	}
	printf("\r\n");
	printf("trapargs: %x %x %x\n",
		scp->sc_traparg_a0, scp->sc_traparg_a1,	scp->sc_traparg_a2);
#endif	__alpha

#ifdef subprocesses
	kill_processes ();
#endif
	CheckpointEverything ();

	printf (
"Emacs has encountered an abnormal termination signal.  All of the files\n\
that you were editing and have changed have been checkpointed.\n");
#ifdef OneEmacsPerTty
	UnlockTty ();
#endif
	exit (1);
}

static
        AbnormalTerminate () {	/* Signal handler for abnormal
				   terminations */
#ifndef UciFeatures
#ifdef subprocesses
            kill_processes ();
#endif
#endif
    CheckpointEverything ();
#ifndef UciFeatures
    RstDsp ();
    printf (
	"Emacs has encountered an abnormal termination signal.  All of the files\n\
that you were editing and have changed have been checkpointed.\n");
#ifdef OneEmacsPerTty
    UnlockTty ();
#endif
    exit (1);
#else
    quit (1,
"Emacs has encountered an abnormal termination signal.  All of the files\n\
that you were editing and have changed have been checkpointed.\n");
#endif
}

/* Code for dealing with MLisp access to the Unix command line */
static  Gargc;			/* global versions of argv and argc, for
				   use by MLisp functions */
static char **Gargv;
static  TouchedCommandArgs;	/* true iff the user has touched the
				   Unix command line arguments, this
				   stops Emacs from doing the VisitFiles
				   */

#ifdef UmcpFeatures
static InvisArgc () {		/* return the value of argc */
    MLvalue -> exp_type = IsInteger;
    MLvalue -> exp_int = Gargc;
    return 0;
}
#endif

static  Argc () {		/* return the value of argc */
            MLvalue -> exp_type = IsInteger;
    MLvalue -> exp_int = Gargc;
    TouchedCommandArgs++;
    return 0;
}

#ifdef UmcpFeatures
static InvisArgv () {
    register int    n = getnum (": argv index: ");
    if (!err)
	if (n >= Gargc)
	    error ("Argv can't return the %d'th argument, there are only %d",
		    n, Gargc);
	else {
	    MLvalue -> exp_type = IsString;
	    MLvalue -> exp_v.v_string = Gargv[n];
	    MLvalue -> exp_int = strlen (MLvalue -> exp_v.v_string);
	}
    return 0;
}
#endif

static  Argv () {		/* return the value of argv[i] */
    register int    n = getnum (": argv index: ");
    if (!err)
	if (n >= Gargc)
	    error ("Argv can't return the %d'th argument, there are only %d",
		    n, Gargc);
	else {
	    MLvalue -> exp_type = IsString;
	    MLvalue -> exp_v.v_string = Gargv[n];
	    MLvalue -> exp_int = strlen (MLvalue -> exp_v.v_string);
	}
    TouchedCommandArgs++;
    return 0;
}

/* When Emacs is saved, there will be certain static variables which
 * need to be set to 0 so that they will be properly re-initialized
 * when Emacs is restarted.  The subroutine FluidStatic will add these
 * statics to a list, and they will be set to 0 when Emacs is dumped.
 */
 struct init_static {
	struct init_static * next;
	char * where;
	int size;
};
static struct init_static * StaticList;

FluidStatic(var, size)
char * var;
{
    register struct init_static * s;

    for (s = StaticList; s; s = s -> next)
	if (s -> where == var)
	    return;
    s = (struct init_static * ) malloc(sizeof(struct init_static));
    s -> next = StaticList;		/* link into list */
    StaticList = s;
    s -> where = var;
    s -> size = size;
}
#ifndef titan
#ifndef pmax
/* Dump the current Emacs using unexec() */
DumpEmacs()
{
    register char *new_name = getstr(": dump-emacs (into) ");
    register char *a_name;
    register struct init_static *s;
    register char * cp;

    if (new_name == NULL)
	return 0;
    new_name = (char *) strcpy(malloc(strlen(new_name)+1), new_name);

    a_name = getstr(": dump-emacs (into) %s (from) ", new_name);
    if (a_name == NULL)
	return 0;
    if (*a_name == 0)
	a_name = NULL;

    for (s = StaticList; s; s = s -> next)	/* zap the statics */
	for (cp = s -> where; cp < s -> where + s -> size; cp++)
	    *cp = 0;
    DumpedEmacs = 1;
    RstDsp();				/* going to exit anyway */
    fflush(stdout);
    setbuf(stdout, 0);
    unexec( new_name, a_name, 0, 0 );
    free(new_name);
    return -1;
}
#endif pmax
#endif titan

/* Define an autoloaded function, bound to the indicated key */
static
DefAutoload (routine, file, map, key)
 char   *routine;
 char   *file;
 struct keymap  *map; {
    DefMac (routine, file, -1);
    if (key >= 0)
	map -> k_binding[key] = MacBodies[FindMac (routine)];
}

main (argc, argv)
char  **argv; {
    char    combuf[MAXPATHLEN];
    int	    nocatch = 0;
#ifndef	UciFeatures
    char   *fn = "";
#endif
    FILE * args = 0;
    char   *lflag = "";		/* value from the -l switch -- file to
				   load after .emacs_pro */
    char   *eflag = "";		/* value from the -e switch -- function
				   to execute after doing the -l load */
#ifdef UmcpFeatures
    int	qflag = 0,		/* set if emacs is called with -q (quick)
				   option */
	dontremember = 0,	/* set if emacs is called with -d (do not
				   create .emacs_uid files) */
	modbufcount;		/* count of modified buffers */
#endif
#ifndef	UciFeatures
    register char   c,
                   *p;
#endif
    register    i,
                rv = 0;
#ifdef UciFeatures
    struct passwd *pwdptr, 
		  *getpwnam();
    char uflag[MAXPATHLEN];	/* expanded value of the -u switch */
    char *xflag = "";		/* value from the -x switch */

    uflag[0] = '\0';
#endif
#ifdef UmcpFeatures
    MyTtyName = (char *) ttyname (0);
    if (MyTtyName == 0)
	MyTtyName = "";
#endif
#ifdef OneEmacsPerTty
    LockTty ();
#endif
    TouchedCommandArgs = 0;		/* on restart */
    Gargc = argc;
    Gargv = argv;
    signal (SIGHUP, AbnormalTerminate);
    signal (SIGINT, AbnormalTerminate);
    signal (SIGTERM, AbnormalTerminate);
    if (!Once) {
    NewNames = MacBodies;
    VarNames = (char **) malloc ((VarTSize = 200) * sizeof *VarNames);
    VarDesc = (struct VariableName **) malloc (VarTSize * sizeof *VarDesc);
    NextInitVarName = VarNames;
    NextInitVarDesc = VarDesc;
    }
#ifdef UmcpFeatures
    sflag = 1;
#endif

/* Command line switch processing.  Emacs understands the following command
 * line switches:
 *	-t<ttyname>	causes Emacs to do its IO to the named tty
 *	-e<funcname>	causes Emacs to execute the named function when it
 *			starts up.
 *	-l<filename>	causes Emacs to load the named file with it starts up
 *			(this is done before the processing for -e)
 *	-s		disables the share-emacs facility
 *      -u<username>    causes Emacs to read the .emacs_profile from the 
 *			specified user's home directory
 *	-x<funcname>	causes Emacs to execute the named function after
 *			visiting any files
 *	-q		quick Emacs; do not load .emacs_pro
 *	-d		do not create .emacs_uid files
 *
 *	-f		turn on flow control (^S/^Q) processing
 *
 *	-D		Do not catch SIGSEGV
 */

    for (i = 1; i < argc; i++)
	if (argv[i][0] == '-')
	    switch (argv[i][1]) {
		case 't': 
		    {
			char    tty[100];
			sprintfl (tty, sizeof tty, "/dev/%s", argv[i] + 2);
			close (0);
			close (1);
			open (tty, 2);
			dup (0);
			fprintf (stderr, "Using %s\n", tty);
		    }
		    break;
		case 'l': 
		    lflag = argv[i] + 2;
		    break;
		case 'e': 
		    eflag = argv[i] + 2;
		    break;
		case 's': 
#ifndef UmcpFeatures
		    sflag++;
#else
		    sflag = 0;
#endif
		    break;
#ifdef UmcpFeatures
		case 'q':
		    qflag++;
		    break;
		case 'd':
		    dontremember++;
		    break;
#endif
#ifdef UciFeatures
		case 'u':
		    strcpy (uflag, 
			((argv[i] + 2)[0]=='\0') ? (char *) getenv ("USER") 
			    : argv[i] + 2);
		    if ((pwdptr = getpwnam (uflag)) == (struct passwd *) 0)
			quit (1, "Unknown user: %s\n", uflag);
		    else
			strcpy (uflag, pwdptr -> pw_dir);
		    break;
		case 'x':
		    xflag = argv[i] + 2;
		    break;
#endif
		case 'f':
		    FlowControl(1);
		    break;

		case 'D':
		    nocatch++;
		    break;

		default: 
#ifndef UciFeatures
#ifdef OneEmacsPerTty	/* TPM 31-Jan-82 */
		    UnlockTty();
#endif
#endif
		    quit (1, "Unknown switch: %s\n", argv[i]);
	    }
    if (nocatch == 0)
	signal (SIGSEGV, DebugTerminate);
    if (!Once) {
    defproc (Argc, "argc");
    defproc (Argv, "argv");
#ifdef UmcpFeatures
    defproc (InvisArgc, "invisible-argc");
    defproc (InvisArgv, "invisible-argv");
#endif
    DefIntVar ("silently-kill-processes", &SilentlyKillProcesses);
#ifdef UmcpFeatures
    DefIntVar ("silently-exit-emacs", &SilentlyExitEmacs);
#endif
#ifndef titan
#ifndef pmax
    defproc(DumpEmacs, "dump-emacs");
#endif pmax
#endif titan
    DefIntVar ("dumped-emacs", &DumpedEmacs);
    }
    InitMpx ();			/* Initialize the multiplex i/o stuff */
    Initbf ();			/* " the buffer system */
    InitDsp ();			/* " the display */
    InitWin ();			/* " the window system */
    InitSimp ();		/* " the simple commands */
    InitWnMan ();		/* " the window management commands */
    InitFIO ();			/* " the file IO system */
    InitFComp ();		/* " the file completion system */
    InitMiniBuf ();		/* " the minibuffer system (DJH) */
    InitSrch ();		/* " the search commands */
    InitMeta ();		/* " the simple meta commands */
    InitProc ();		/* " commands that deal with
				   subprocesses */
    InitOpt ();			/* " commands that deal with options */
    InitKey ();			/* " commands that deal with options */
    InitAbbrev ();		/* " the abbrev system */
    InitSyntax ();		/* " the syntax table system */
    InitDb ();			/* " the data base manager */
    InitCase ();		/* " the case manipulation commands */
    InitUndo ();		/* " the undo facility */
    InitArith ();		/* " the arithmetic operators (for lisp) 
				*/
    InitFunc ();		/* " lisp environment enquiry functions 
				*/
    InitLisp ();		/* " the MLisp system */
    InitAbs ();			/* " the current directory name */
    InitMacros ();		/* " the macro system and name bindings
				   WARNING:	this initialization
				   procedure must be called after all
				   the others */

#ifdef SIGXCPU
    signal (SIGXCPU, TimeLimit);
#endif

/* Autoload definitions.  Sadly, these must follow the call to InitMacros
   and cannot be done in the relevant InitXX routine */
    if (!Once) {
    DefAutoload ("shell", "process",(struct keymap *)0, -1);
    DefAutoload ("justify-paragraph", "justify.ml",(struct keymap *)0, -1);
    DefAutoload ("info", "info.ml",(struct keymap *)0, -1);
#ifdef UmcpFeatures
    DefAutoload ("learn", "learn.ml",(struct keymap *)0, -1);
#endif
    DefAutoload ("manual-entry", "man.ml",(struct keymap *)0, -1);
    DefAutoload ("text-mode", "text-mode.ml",(struct keymap *)0, -1);
    DefAutoload ("lisp-mode", "lisp-mode.ml",(struct keymap *)0, -1);
    DefAutoload ("c-mode", "c-mode.ml",(struct keymap *)0, -1);
    DefAutoload ("normal-mode", "normal-mode.ml",(struct keymap *)0, -1);
    DefAutoload ("describe-command", "info.ml",(struct keymap *)0, -1);
    DefAutoload ("describe-variable", "info.ml",(struct keymap *)0, -1);
    DefAutoload ("expand-mlisp-word", "expandX.ml",(struct keymap *)0, -1);
    DefAutoload ("expand-mlisp-variable", "expandX.ml",(struct keymap *)0, -1);
    DefAutoload ("describe-word-in-buffer", "DesWord.ml",(struct keymap *)&CtlXmap, Ctl ('d'));
    DefAutoload ("backward-paragraph", "paragraphs.ml",(struct keymap *)&ESCmap, '[');
    DefAutoload ("forward-paragraph", "paragraphs.ml",(struct keymap *)&ESCmap, ']');
    DefAutoload ("backward-sentence", "sentences.ml",(struct keymap *)&ESCmap, 'a');
    DefAutoload ("forward-sentence", "sentences.ml",(struct keymap *)&ESCmap, 'e');
    DefAutoload ("rmail", "rmail.ml",(struct keymap *)&CtlXmap, 'r');
    DefAutoload ("smail", "rmail.ml",(struct keymap *)&CtlXmap, 'm');
    DefAutoload ("cd", "pwd.ml",(struct keymap *)0, -1);
    DefAutoload ("pwd", "pwd.ml",(struct keymap *)0, -1);
    DefMac ("default-global-keymap", &GlobalMap, -2);
    DefMac ("ESC-prefix",  &ESCmap, -2);
    DefMac ("Minibuf-local-map", &MinibufLocalMap, -2);
    MinibufLocalMap.k_binding['\n'] = GlobalMap.k_binding[3];
    MinibufLocalMap.k_binding['\r'] = GlobalMap.k_binding[3];
    GlobalMap.k_binding[033] = MacBodies[FindMac ("ESC-prefix")];
    MinibufLocalMap.k_binding['\033'] = GlobalMap.k_binding[3];
    MinibufLocalMap.k_binding['\034'] = GlobalMap.k_binding['\033'];
    DefMac ("Minibuf-local-NS-map", &MinibufLocalNSMap, -2);
    MinibufLocalNSMap = MinibufLocalMap;
    MinibufLocalNSMap.k_binding[' '] = GlobalMap.k_binding[3];
    MinibufLocalNSMap.k_binding['\t'] = GlobalMap.k_binding[3];
    MinibufLocalNSMap.k_binding['?'] =
			MacBodies [FindMac ("self-insert-and-exit")];
    DefMac ("^X-prefix", &CtlXmap, -2);
    GlobalMap.k_binding[030] = MacBodies[FindMac ("^X-prefix")];
    CurrentGlobalMap = &GlobalMap;
    NVars = NextInitVarName - VarNames;
    VarNames[NVars] = 0;
    }					/* Once */
    Once = 1;				/* past one-time init code */
#ifdef UmcpFeatures
    if (!qflag) 
#endif
    {
	char    buf[MAXPATHLEN];
	char    defpro[MAXNAMLEN];
	register char  *home = (char *) getenv ("HOME");
#ifdef UciFeatures
	if (uflag[0] != '\0')
	    sprintfl (buf, sizeof buf, "%s/.emacs_pro", uflag);
	else
#endif
	    if (home)
		sprintfl (buf, sizeof buf, "%s/.emacs_pro", home);
	if (ExecuteMLispFile (buf, 1)){
	    strcpy(defpro, DefaultProfile); /* for ibis; it modifies str */
	    ExecuteMLispFile (defpro, 1);
	}
    }
    InputFD = stdin;
    if (lflag[0])
	ExecuteMLispFile (lflag, 1);
    rv = 0;
    if (eflag[0] && (i = FindMac (eflag)) >= 0)
	rv = ExecuteBound (MacBodies[i]);

    if (rv == 0) {
	if (!TouchedCommandArgs) {
	    int     DoneAnyVisiting = 0;
#ifndef UmcpFeatures
	    for (i = 1; i < argc; i++)
#else
	    for (i = argc - 1; i ; i--)
#endif
		if (argv[i][0] != '-') {
		    VisitFile (argv[i], 1, 1);
		    DoneAnyVisiting++;
		}
	    if (!DoneAnyVisiting &&
		(sprintf(combuf, ".emacs_%d", getuid()) != 0) &&
		(args = fopen(combuf, "r")) )
		while (fgets (combuf, sizeof(combuf), args)) {
		    register char  *p = combuf;
		    register    i;
		    while (*p >= ' ')
			p++;
		    i = *p;
		    *p++ = '\0';
		    VisitFile (combuf, 1, 1);
		    if (i == 1) {
			i = 0;
			while ('0' <= *p && *p <= '9')
			    i = i * 10 + *p++ - '0';
			if (i >= FirstCharacter && i <= NumCharacters)
			    SetDot (i);
		    }
		}
	    if (args != 0)
		fclose (args);
	    }
#ifdef UciFeatures
    if (*xflag && (i = FindMac (xflag)) >= 0)
	ExecuteBound (MacBodies[i]);
#endif
	do
	    ProcessKeys ();

#ifndef UmcpFeatures
	while (!feof(InputFD) &&
	       ModExist () && (*getnbstr (
			"Modified buffers exist, do you really want to exit? "
		    ) & 0137) != 'Y'
#else

	while ((	!SilentlyExitEmacs
			&& !feof(InputFD)
			&& (modbufcount = ModExist())
			&& (ModExistExitOK(modbufcount) == 0)
		)
#endif
#ifdef subprocesses
		|| (!SilentlyKillProcesses && count_processes() && (*getnbstr(
"You have processes still on the prowl, shall I chase them down for you? "
			) & 0137) != 'Y')
#endif
	    );


	if (feof(InputFD))
	{
	    fprintf(stderr, "Exiting due to EOF, files checkpointed\n");
	    CheckpointEverything();
	}
    }
#ifdef UmcpFeatures
    if (!dontremember)
#endif
    {
	register struct window *w;
	int failed = 0;
	args = 0;
	for (w = windows; w; w = w -> w_next)
	    if ((SetBfp (w -> w_buf), bf_cur -> b_fname)
#ifndef	SuFeatures
		    && strcmpn (bf_cur -> b_fname, "/tmp/", 5)
#endif	SuFeatures
			) {
		if ((args == 0) && (failed == 0)) {
		    sprintf (combuf, ".emacs_%d", getuid ());
		    args = fopen (combuf, "w");
		    if (args == NULL)
			failed = 1;
		}
		if (args)
		    fprintf (args, "%s\001%d\n", bf_cur -> b_fname,
			    w == wn_cur ? dot : ToMark (w -> w_dot));
	    }
    }
/* We don't have this fn
#ifdef UmcpFeatures
    {
	register struct buffer *b;

	for (b = buffers; b; b = b -> b_next)
	    DeleteBuffersCheckpointFile (b);
    }
#endif
*/
#ifndef UciFeatures
#ifdef subprocesses
    kill_processes ();
#endif
    RstDsp ();
#ifdef OneEmacsPerTty
    UnlockTty ();
#endif
#else
    quit (0, "");
#endif
}

/*
 * Tell the user that modified buffers exist and ask if it is OK
 * to exit.
 *
 * This has to be done with SIGINT disabled so as to avoid doing
 * a longjmp at a time when it apparently isn't safe.
 */
ModExistExitOK(modbufcount)
int modbufcount;
{
	char *answer;
	void (*prevINT) ();
	
	prevINT = signal (SIGINT, SIG_IGN);

	if (modbufcount == 1)
	    answer = getnbstr(
		"1 modified buffer exists, do you really want to exit? ");
	else
	    answer = getnbstr(
		"%d modified buffers exist, do you really want to exit? ",
				    modbufcount);

	signal (SIGINT, prevINT);

	return ((answer[0] & 0137) == 'Y');
}
