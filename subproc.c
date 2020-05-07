/* stuff to handle subprocesses */

/*		Copyright (c) 1981,1980 James Gosling		*/

#include "keyboard.h"
#include "buffer.h"
#include "window.h"
#include "mlisp.h"
#include <sys/param.h>
#include <signal.h>
#include <sys/wait.h>
#include "config.h"
#ifdef	SuFeatures
#include <ctype.h>
#endif	SuFeatures

int	UseUsersShell;		/* if 0, use /bin/sh always */
int	UseCshOptionF;	     /* if 1 and UseUsersShell is 1, give -f to csh */
int     subproc_id;		/* The process id of a subprocess
				   started by the old subproc stuff.
				   Mchan.c will zero it so we will know it
				   has finished */

char  *getenv();

/* Copy stuff from indicated file descriptor into the current
   buffer; return the number of characters read.  This routine is
   useful when reading from pipes and such.  */
ReadPipe (fd, display) {
    register int    red = 0;
    register int    n;
    char    buf[1024];
    if (display)
	message ("Starting up...");
    if (display)
	DoDsp (1);
    while ((n = read (fd, buf, 1024)) > 0) {
	InsCStr (buf, n);
	red += n;
	if (display) {
	    message ("Chugging along...");
	    DoDsp (1);
	}
    }
    if (display)
	message ("Done!");
    return red;
}

#ifndef	SuFeatures
/* execute a subprocess with the output being stuffed into the named
   buffer. */
ExecBf (buffer, display, input, erase, command)
char   *buffer,
       *command; {
    struct buffer  *old = bf_cur;
    int     fd[2];
    int     pid,
            status,
            thispid;

    SetBfn (buffer);
    if(interactive) WindowOn (bf_cur);
    if(erase) EraseBf (bf_cur);
    pipe (fd);
    if ((subproc_id = vfork ()) == 0) {
	close (0);
	close (1);
	close (2);
	if(open (input, 0) != 0) {
	    write (fd[1], "Couldn't open input file\n", 25);
	    _exit (-1);
	}
	dup (fd[1]);
	dup (fd[1]);
	close (fd[1]);
	close (fd[0]);
	execvp (command, &command);
	write (1, "Couldn't execute the program!\n", 30);
	_exit (-1);
    }
    close (fd[1]);
    sigrelse(SIGCHLD);
    ReadPipe (fd[0], interactive && display);
    close (fd[0]);
loop:
    sighold(SIGCHLD);		/* We shouldn't have to hold the signal, but*/
    if(subproc_id){		/* we will just in case */
	sigpause(SIGCHLD);
	goto loop;
    }
    sigrelse(SIGCHLD);

    bf_modified = 0;
    if(interactive) WindowOn (old);
}

/* pass the region starting at dot and extending for n characters through
   the command.  The old contents of the region is left in the kill
   buffer */
FilterThrough (n, command, c2,c3,c4,c5,c6)
char *command;
char *c2;
char *c3;
char *c4;
char *c5;
char *c6;
{
	char tempfile[40];
	register struct buffer *old = bf_cur;
	register struct buffer *kill = DelToBuf (n, 0, 1, "Kill buffer");
	strcpy(tempfile,"/tmp/emacsXXXXXX");
	if (kill) kill->b_mode.md_NeedsCheckpointing = 0;
	mktemp (tempfile);
	SetBfn ("Kill buffer");
	WriteFile (tempfile, 0);
	chmod (tempfile, 0600);
	SetBfp (old);
	ExecBf (bf_cur->b_name, 0, tempfile, 0, command, c2,c3,c4,c5,c6);
	bf_modified++;
	unlink(tempfile);
}
#else
/* execute a subprocess with the output being stuffed into the named
   buffer. ExecBf is called with the command as a list of strings as
   seperate arguments, ExecBfp is the same except that it is called with
   a pointer to the arg list. */
ExecBf (buffer, display, input, erase, command)
char   *buffer,
       *input,
       *command; {
    ExecBfp (buffer, display, input, erase, &command);
}

ExecBfp (buffer, display, input, erase, command)
char   *buffer,
       *input,
      **command; {
    struct buffer  *old = bf_cur;
    int     fd[2];
    int     pid,
            status,
            thispid;

    SetBfn (buffer);
    if(interactive) WindowOn (bf_cur);
    if(erase) EraseBf (bf_cur);
    pipe (fd);
    sighold(SIGCHLD);		/* per JAG Mon Oct  4 22:13:51 1982 */
    if ((subproc_id = vfork ()) == 0) {
	close (0);
	close (1);
	close (2);
	if(open (input, 0) != 0) {
	    write (fd[1], "Couldn't open input file\n", 25);
	    _exit (-1);
	}
	dup (fd[1]);
	dup (fd[1]);
	close (fd[1]);
	close (fd[0]);
	execvp (*command, command);
	write (1, command, 10);
	write (1, "Couldn't execute the program!\n", 30);
	_exit (-1);
    }
    close (fd[1]);
    sigrelse(SIGCHLD);
    ReadPipe (fd[0], interactive && display);
    close (fd[0]);
loop:
    sighold(SIGCHLD);		/* We shouldn't have to hold the signal, but*/
    if(subproc_id){		/* we will just in case */
	sigpause(SIGCHLD);
	goto loop;
    }
    sigrelse(SIGCHLD);

    bf_modified = 0;
    if(interactive) WindowOn (old);
}

/* pass the region starting at dot and extending for n characters through
   the command.  The old contents of the region is left in the kill
   buffer */
FilterThrough (n, command, c2,c3,c4,c5,c6)
int n;
char *command;
char *c2;
char *c3;
char *c4;
char *c5;
char *c6;
{
    char *clist[6];
    clist[0] = command;
    clist[1] = c2;
    clist[2] = c3;
    clist[3] = c4;
    clist[4] = c5;
    clist[5] = c6;
    FilterThroughp (n, clist);
}

FilterThroughp (n, command)
int n;
char **command;
{
	char tempfile[40];
	register struct buffer *old = bf_cur;
	register struct buffer *kill = DelToBuf (n, 0, 1, "Kill buffer");
	strcpy(tempfile,"/tmp/emacsXXXXXX");
	if (kill) kill->b_mode.md_NeedsCheckpointing = 0;
	mktemp (tempfile);
	SetBfn ("Kill buffer");
	WriteFile (tempfile, 0);
	chmod (tempfile, 0600);
	SetBfp (old);
	ExecBfp (bf_cur->b_name, 0, tempfile, 0, command);
	bf_modified++;
	unlink(tempfile);
}
#endif

IndentCProcedure () {
    register    pos = search ("^}", 1, dot - 3, 1);
    register    spos;
    register    nest = 0;
    if (pos <= 0) {
	error ("Can't find procedure boundary");
	return 0;
    }
    spos = pos;
    pos = ScanBf ('\n', pos, 1);
    while (spos > 1) {
	register char   c = CharAt (spos);
	if (c == '}')
	    nest++;
	if (c == '{') {
	    nest--;
	    if (nest <= 0)
		break;
	}
	spos--;
    }
    if (nest == 0) {
	SetDot (ScanBf ('\n', spos, -1));
	FilterThrough (pos - dot, "indent", "-st", 0);
    }
    else
	error ("Can't find procedure boundary");
    return 0;
}

char   *shell () {		/* return the name of the users shell */
    static char *sh;
    if (!sh)
    {
	FluidStatic(&sh, sizeof(sh));
	sh = (char *) getenv ("SHELL");
    }
    if (!sh)
	sh = "/bin/sh";
    return (UseUsersShell ? sh : "/bin/sh");
}

CompileIt () {
    register char  *com = 0;
    register struct buffer *old = bf_cur;
    static char CompileCommand[MAXPATHLEN];
    if (ModWrite ()) {
    /* this test really shouldn't be done this way, all the prefix
       numeric argument stuff needs to be rationalized */
	if (ArgState==HaveArg || !interactive) {
	    com = getstr ("Compilation command: ");
	    if (com == 0)
		return 0;
	    if(*com) strcpy(CompileCommand, com);
	    ExecBf ("Error log", 1, "/dev/null", 1,
		shell (), "-c", CompileCommand, 0);
	}
	else
	    ExecBf ("Error log", 1, "/dev/null", 1, "make", "-k", 0);
	SetBfn ("Error log");
	if (!err) ParseErb (1, NumCharacters);
	SetBfp (old);
    }
    return 0;
}

ExecuteMonitorCommand () {
    char   *com = getstr ("Unix command: ");
    if (com == 0)
	return 0;
    ExecBf ("Command execution", 1, "/dev/null", 1,
	    shell (), "-c", com, 0);
    return 0;
}

ReturnToMonitor () {		/* ^_ */
    register    pid;
    void     (*prevHUP) ();
    void     (*prevINT) ();
    void     (*prevQUIT) ();
    extern int  subproc_id;
    char    buf[50];
/* All of the prompt-setting for inferior shells has been commented out, it
   doesn't work with the C shell, whose use seems unavoidable */
/*  char   *prompt = (char *) getenv ("PS1"); */

    RstDsp ();
/*  putenv ("PS1", sprintf (buf, "[emacs]	%s",
		prompt ? prompt : "$ ")); */
    if ((subproc_id = vfork ()) == 0) {
	execlp (shell (), "sh", "-i", 0);
	_exit (-1);
    }
    prevHUP = signal (SIGHUP, SIG_IGN);
    prevINT = signal (SIGINT, SIG_IGN);
    prevQUIT = signal (SIGQUIT, SIG_IGN);
loop: 
    sighold (SIGCHLD);
    if (subproc_id) {
	sigpause (SIGCHLD);
	goto loop;
    }
    sigrelse (SIGCHLD);

    signal (SIGHUP, prevHUP);
    signal (SIGINT, prevINT);
    signal (SIGQUIT, prevQUIT);

/*  putenv ("PS1", sprintf (buf, "%s", prompt ? prompt : "$ ")); */
    InitDsp ();
    return 0;
}

/* Relinquish control of the terminal to the shell */
PauseEmacs () {
#ifdef SIGTSTP
#ifdef UciFeatures
    SuspendMpx();
#endif
    RstDsp ();
    kill (0, SIGTSTP);
    InitDsp ();
#ifdef UciFeatures
    ResumeMpx();
#endif
#else
    error("pause-emacs doesn't work in this version of Unix.");
#endif
    return 0;
}

NextError () {
    NextErr ();
    return 0;
}

static
FilterRegion () {
    register char  *s;
    if (bf_cur -> b_mark == 0) {
	error ("Mark not set");
	return 0;
    }
    s = getstr (": filter-region (through command) ");
    if (s) {
	char saveit[3000];
	strcpy (saveit, s);	/* what the world needs is a language with
				   real strings. */
	FilterThrough (ToMark (bf_cur->b_mark) - dot, shell (), "-c", saveit, 0);
    }
    return 0;
}

#ifdef	SuFeatures
static
FastFilterRegion () {
    register char  *s;
    if (bf_cur -> b_mark == 0) {
	error ("Mark not set");
	return 0;
    }
    s = getstr (": fast-filter-region (through command) ");
    if (s) {
	char    saveit[3000];
	char   *args[500];
	register char **p;
	strcpy (saveit, s);	/* what the world needs is a language
				   with real strings. */
	s = saveit;
	p = args;
	*p++ = s;
	while (*s)
	    if (isspace (*s++)) {
		s[-1] = '\0';
		while (isspace (*s))
		    s++;
		if (*s == '\0')
		    break;
		*p++ = s;
	    }
	*p++ = 0;
	FilterThroughp (ToMark (bf_cur -> b_mark) - dot, args);
    }
    return 0;
}
#endif

/* Parse all of the error messages found in a region */
ParseErrorMessagesInRegion () {
    register    left,
                right = dot;
    if (bf_cur -> b_mark == 0)
	error ("Mark not set.");
    else {
	left = ToMark (bf_cur -> b_mark);
	if (left > right)
	    right = left, left = dot;
	ParseErb (left, right);
    }
    return 0;
}

InitProc () {
    if (!Once)
    {
	DefIntVar ("use-users-shell", &UseUsersShell);
	DefIntVar ("use-csh-option-f", &UseCshOptionF);
	setkey (GlobalMap, (Ctl ('_')), ReturnToMonitor, "return-to-monitor");
	defproc (FilterRegion, "filter-region");
#ifdef	SuFeatures
	defproc (FastFilterRegion, "fast-filter-region");
#endif
	defproc (ParseErrorMessagesInRegion,
		 "parse-error-messages-in-region");
	defproc (PauseEmacs, "pause-emacs");
	setkey (CtlXmap, (Ctl ('E')), CompileIt, "compile-it");
	setkey (CtlXmap, (Ctl ('N')), NextError, "next-error");
	setkey (CtlXmap, ('!'), ExecuteMonitorCommand,
				"execute-monitor-command");
	setkey (ESCmap, ('j'), IndentCProcedure, "indent-C-procedure");
    }
}
