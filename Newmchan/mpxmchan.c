/* These procedures hope to give EMACS a facility for dealing with multiple
   processes in a reasonable way */

/*		Copyright (c) 1981 Carl Ebeling		*/

/* Modified 8-Sept-81 Jeffrey Mogul (JCM) at Stanford
 *	- removed RstDsp() after failure to open mpx file; this
 *	  was leading to nasty infinite loop.  Probably this should
 *	  be done better and in other situations as well.
 */

/* Modified by Chris Torek (ACT) at umcp-cs to answer more ioctls */

/* Modified 17-Jul-82 ACT - rewrote the emacs-share to automatically
 * create buffers for process that access the multiplexed file.  Also
 * changed the definition of '-s' from 'use share' to 'don't use share'
 * with the default being 'use share'.
 */

/* ACT 22-Jul-82: added variable 'emacs-share' (I suspect this used to
 * exist!), default 1, which lets/prevents opens of the share file
 */

/* ACT 21-Oct-1982 adding code to let csh do job control.... */

/* Incorporate Umcp-Cs features to get a really nice version of mchan.c 
   for 4.1bsd */

/* Original changes for 4.2bsd (c) 1982 William N. Joy and Regents of UC */

/* More changes for 4.1aBSD by Spencer Thomas of Utah-Cs */

/* Still more changes for 4.1aBSD by Marshall Rose of UCI */

#include "config.h"
#include <stdio.h>
#include <signal.h>
#include <errno.h>
#include <wait.h>
#include <sgtty.h>
#ifdef MPXcode
#include <sys/mx.h>
#endif
#include "window.h"
#include "keyboard.h"
#include "buffer.h"
#include "mlisp.h"
#include "macros.h"
#include "mchan.h"
#ifdef subprocesses

#define ChunkSize 500		/* amount to truncate when buffer overflows */
#ifndef	TTYconnect
static	PopUpUnexpected;	/* True iff unexpected opens pop up windows */
static	EmacsShare;		/* Share flag, true iff opens allowed */
static struct BoundName
	*UnexpectedProc;	/* What to do with unexpected procs */
static struct BoundName
	*UnexpectedSent;	/* What to do when unexpected procs exit */
#else
int	PopUpUnexpected;	/* True iff unexpected opens pop up windows */
int	EmacsShare;		/* Share flag, true iff opens allowed */
struct BoundName
	*UnexpectedProc;	/* What to do with unexpected procs */
struct BoundName
	*UnexpectedSent;	/* What to do when unexpected procs exit */
#endif
static	ProcessBufferSize;	/* Maximum size for process buffer */

#ifdef MPXcode
static	kbd_fd;			/* keyboard file descriptor, from extract() */

/* ioans_rec is a structure used to return the IOANS message to a sender 
   process. The structure is initialized in InitMpx() by gtty on the 
   terminal. */

struct w_msg {
    short	    code;
    struct sgttyb   sgtty_ans;
} ioans_rec;

struct wh		ioans;		/* The record actually used to send
					   IOANS_REC */
static struct sgttyb	standard_ans;	/* A vanilla terminal */
static int		other_ans;	/* For other ioctl answer value(s) */
static short		short_ans;	/* For answers that need a short */
static struct tchars	special_ans;	/* More vanilla */
static int		lget_ans;	/* For TIOCLGET */
static struct ltchars	ltc_ans;	/* ltchars answer val */

char mpx_filename[50];		/* Name of Multiplexed file */

int	mpx_fd;			/* Multiplexed file */
#ifdef UtahFeatures
char stdin_buf[BUFSIZ];		/* used to buffer stdin chars */
#endif

#else MPXcode
int     sel_ichans;		/* input channels */
int     sel_ochans;		/* blocked output channels */

static	struct sgttyb mysgttyb;
static	struct tchars mytchars;
static	struct ltchars myltchars;
static	int mylmode;
#endif

#ifdef ce
FILE *err_file;			/* Debugging file */
int	err_id;			/* User's ID for error messages */
#endif

struct channel_blk
	stdin_chan;

int	child_changed;		/* Flag when a child process changes status */
struct VariableName
	*MPX_process;
struct channel_blk
	*MPX_chan;

char   *SIG_names[] = {		/* descriptive (?) names of signals */
    "",
    "Hangup",
    "Interrupt",
    "Quit",
    "Illegal instruction",
    "Trace/BPT trap",
    "IOT trap",
    "EMT trap",
    "Floating exception",
    "Killed",
    "Bus error",
    "Segmentation fault",
    "Bad system call",
    "Broken pipe",
    "Alarm clock",
    "Terminated",
#ifdef	SIGURG
    "Urgent I/O condition",
#else
    "Signal 16",
#endif
    "Stopped (signal)",
    "Stopped",
    "Continued",		/* */
    "Child exited",		/* */
    "Stopped (tty input)",	/* */
    "Stopped (tty output)",	/* */
    "Tty input interrupt",	/* */
    "Cputime limit exceeded",
    "Filesize limit exceeded",
    "Signal 26",
    "Signal 27",
    "Signal 28",
    "Signal 29",
    "Signal 30",
    "Signal 31",
    "Signal 32"
};

static char *KillNames[] = {	/* names used for signal-to-process */
    "",     "HUP",  "INT",  "QUIT", "ILL",  "TRAP", "IOT",  "EMT",
    "FPE",  "KILL", "BUS",  "SEGV", "SYS",  "PIPE", "ALRM", "TERM",
#ifdef	SIGURG
    "URG",
#else
    "",     
#endif
	    "STOP", "TSTP", "CONT", "CHLD", "TTIN", "TTOU",
#ifdef	SIGTINT
"TINT",
#else
#ifdef	SIGIO
    "IO",
#else
    "",
#endif
#endif
    "XCPU", "XFSZ"
};

#ifdef MPXcode
/* Set ioans_rec.sgtty_ans */

/* VARARGS */
static
setans (from, count)
register char *from;
register count;
{
    register char *to = (char *) &ioans_rec.sgtty_ans;
    while (count--)
	*to++ = *from++;
}
#else
char *
pty(ptyv)
int *ptyv;
{
#include <sys/types.h>
#include <sys/stat.h>
	struct stat stb;
	static char name[24];
	int on = 1, i;

	strcpy(name, "/dev/ptypX");
	for (;;) {
		name[strlen("/dev/ptyp")] = '0';
		if (stat(name, &stb) < 0)
			return (0);
		for (i = 0; i < 16; i++) {
			name[strlen("/dev/ptyp")] = "0123456789abcdef"[i];
			*ptyv = open(name, 2);
			if (*ptyv >= 0) {
				ioctl(*ptyv, TIOCREMOTE, &on);/* for EOT */
				ioctl(*ptyv, FIONBIO, &on);
				name[strlen("/dev/")] = 't';
				return (name);
			}
		}
		name[strlen("/dev/pty")]++;
	}
}
#endif

/* Start up a subprocess with its standard input and output connected to 
   a channel on the mpx file.  Also set its process group so we can kill it
   and set up its process block.  The process block is assumed to be pointed
   to by current_process. */

create_process (command)
register char  *command;
{
#ifdef MPXcode
    register index_t channel;
    register newfd;
#else
    index_t channel;
    int     pgrp,
	    len,
	    ld;
    char   *ptyname;
#endif
    register	pid;
    extern char *shell ();
    extern UseCshOptionF;
#ifdef UciFeatures
    extern UseUsersShell;
#endif

#ifdef MPXcode
    if ((channel = chan (mpx_fd)) == -1) {
#ifndef UtahFeatures
	error ("Can't connect subchannel");
#else
	extern int errno, sys_nerr;
	extern char *sys_errlist[];
	error ("Can't connect subchannel: %s",
	    (errno > 0 && errno <= sys_nerr) ? sys_errlist[errno] : "?");
#endif
	return (-1);
    }

    newfd = extract (channel, mpx_fd);
#else
    ptyname = pty (&channel);
    if (ptyname == 0) {
	error ("Can't get a pty");
	return (-1);
    }
    sel_ichans |= 1<<channel;
#endif

#ifdef UtahFeatures
    sighold (SIGCHLD);
#endif
    if ((pid = vfork ()) < 0) {
	error ("Fork failed");
#ifdef MPXcode
	detach (channel, mpx_fd);
	close (newfd);
#else
	close (channel);
	sel_ichans &= ~(1<<channel);
#endif
	return (-1);
    }

    if (pid == 0) {
#ifdef ce
#ifdef	MPXcode
	fprintf (err_file, "Creating pid %d on index %d\n", getpid(), channel);
#else
	fprintf (err_file, "Creating pid %d on %s\n", getpid (), ptyname);
#endif
#endif
#ifndef MPXcode
	close (channel);
#endif
	sigrelse (SIGCHLD);
	setpgrp (0, getpid ());
	sigsys (SIGINT, SIG_DFL);
	sigsys (SIGQUIT, SIG_DFL);
#ifdef MPXcode
	close (0);
	dup (newfd);
	close (1);
	dup (newfd);
	close (2);
	dup (newfd);
#else
	if ((ld = open ("/dev/tty", 2)) >= 0) {
	    ioctl (ld, TIOCNOTTY, 0);
	    close (ld);
	}
	close (2);
	if (open (ptyname, 2) < 0) {
	     write (1, "Can't open tty\n", 15);
	     _exit (1);
	}
	pgrp = getpid();
	ioctl (2, TIOCSPGRP, &pgrp);
	close (0);
	close (1);
	dup (2);
	dup (2);
	ioctl (0, TIOCSETP, &mysgttyb);
	ioctl (0, TIOCSETC, &mytchars);
	ioctl (0, TIOCSLTC, &myltchars);
	ioctl (0, TIOCLSET, &mylmode);
	len = 0;			/* set page features to 0 */
#ifdef	TIOCSWID
	ioctl (0, TIOCSWID, &len);	/* page width */
#endif
#ifdef	TIOCSLEN
	ioctl (0, TIOCSLEN, &len);	/* page len (CCA uses TIOCSSCR) */
#endif
#ifdef	UciFeatures
	len = UseUsersShell;
	UseUsersShell = 1;
#endif
	ld = strcmp(shell(), "/bin/csh") ? OTTYDISC : NTTYDISC;
	ioctl (0, TIOCSETD, &ld);
#ifdef	UciFeatures
	UseUsersShell = len;
#endif
#endif
#ifndef UciFeatures
	execlp (shell (), shell (), UseCshOptionF ? "-cf" : "-c", command, 0);
#else
	execlp (shell (), shell (),
		UseUsersShell && UseCshOptionF ? "-cf" : "-c", command, 0);
#endif
	write (1, "Couldn't exec the shell\n", 24);
	_exit (1);
    }

    current_process -> p_name = command;
    current_process -> p_pid = pid;
    current_process -> p_gid = pid;
#ifndef UtahFeatures
    current_process -> p_flag = RUNNING;
#else
    current_process -> p_flag = RUNNING | CHANGED;
    child_changed++;
#endif
    current_process -> p_chan.ch_index = channel;
    current_process -> p_chan.ch_ptr = NULL;
    current_process -> p_chan.ch_count = 0;
    current_process -> p_chan.ch_outrec.index = channel;
    current_process -> p_chan.ch_outrec.count = 0;
    current_process -> p_chan.ch_outrec.ccount = 0;
#ifdef MPXcode
    close (newfd);  
#endif
    return 0;
}
#endif

/* Process a signal from a child process and make the appropriate change in 
   the process block. Since signals are NOT queued, if two signals are
   received before this routine gets called, then only the first process in
   the process list will be handled.  We will try to get the MPX file stuff
   to help us out since it passes along signals from subprocesses.
*/
int	subproc_id;		/* The process id of a subprocess
				   started by the old subproc stuff.
				   We will zero it so they will know it
				   has finished */
child_sig () {
    register int    pid;
    union wait w;
    register struct process_blk *p;
    extern struct process_blk  *get_next_process ();

loop: 
    pid = wait3 (&w.w_status, WUNTRACED | WNOHANG, 0);
    if (pid <= 0) {
	if (errno == EINTR) {
	    errno = 0;
	    goto loop;
	}
#ifdef subprocesses
	if (pid == -1) {
	    if (!active_process (current_process))
		current_process = get_next_process ();
	}
#endif
	return;
    }
    if (pid == subproc_id) {	/* It may not be our progeny */
	subproc_id = 0;		/* Take care of those subprocesses first 
				*/
	goto loop;
    }
#ifndef subprocesses
    goto loop;
}
#else
    for (p = process_list; p != NULL; p = p -> next_process)
	if (pid == p -> p_pid)
	    break;
    if (p == NULL)
	goto loop;		/* We don't know who this is */

    if (WIFSTOPPED (w)) {
#ifndef UtahFeatures
	p -> p_flag = STOPPED;
#else
	p -> p_flag = STOPPED | CHANGED;
#endif
	p -> p_reason = w.w_stopsig;
#ifdef UtahFeatures
    child_changed++;
#endif
    }
    else
	if (WIFEXITED (w)) {
	    p -> p_flag = EXITED | CHANGED;
	    child_changed++;
	    p -> p_reason = w.w_retcode;
	}
	else
	    if (WIFSIGNALED (w)) {
		p -> p_flag = SIGNALED | CHANGED;
		if (w.w_coredump)
		    p -> p_flag |= COREDUMPED;
		child_changed++;
		p -> p_reason = w.w_termsig;
	    }
    if (!active_process (current_process))
	current_process = get_next_process ();
    goto loop;
}

#ifdef	MPXcode
/* Look through channel blocks to find the matching the channel index */
/* There should probably be a short vector crossreferencing channel to process
   so these look-ups are not quite so stupid (ce) */

struct channel_blk *find_channel (index)
register index_t   index;
{
    register struct process_blk *p;

    if (index == mpxin -> ch_index)
	return (mpxin);
    for (p = process_list; p != NULL; p = p -> next_process)
	if (index == p -> p_chan.ch_index)
	    return (&p -> p_chan);
    return (NULL);
}

/* Find the corresponding process for a pointer to a channel block. */

struct process_blk *index_to_process (index)
register index_t   index;
{
    register struct process_blk *p;

    if (index == mpxin -> ch_index)
	return (NULL);
    for (p = process_list; p != NULL; p = p -> next_process) {
	if (!active_process (p))
	    continue;
	if (p -> p_chan.ch_index == index)
	    break;
    }
    return (p);
}
#endif

/* Find the process which is connected to buf_name */

struct process_blk *find_process (buf_name)
register char   *buf_name;
{
    register struct process_blk *p;

    if (buf_name == NULL)
	return (NULL);
    for (p = process_list; p != NULL; p = p -> next_process) {
	if (!active_process (p))
	    continue;
	if (strcmp (p -> p_chan.ch_buffer -> b_name, buf_name) == 0)
	    break;
    }
    return (p);
}

/* Get the first active process in the process list and assign to the current
   process */

struct process_blk *get_next_process () {
    register struct process_blk *p;

    for (p = process_list; p && !active_process (p); p = p -> next_process);
    return p;
}

/* This corresponds to the filbuf routine used by getchar.  This handles all 
   the input from the mpx file.  Input coming from the terminal is sent back
   to getchar() in the same manner as filbuf.  Control messages are sent to
   Take_msg for interpretation.  Normal input from other channels is routed
   to the correct buffer. */

static char cbuffer[BUFSIZ];	/* used for reading mpx file */
static int  mpx_count;		/* number of unprocessed characters in
				   buffer */
#ifdef MPXcode
static struct rh   *MXP;	/* pointer into buffer of records */
#endif

/* ARGSUSED */
#ifdef ECHOKEYS
fill_chan (chan, alrmtime)
#else
fill_chan (chan)
#endif
register struct channel_blk *chan;
{
#ifdef MPXcode
    extern int  mpx_fd;		/* mpx file number */
    extern struct channel_blk  *find_channel ();

    register struct mpx_msg *msg;
    register int    record_size,
		    msg_length;
    register struct channel_blk *this_channel;

readloop: 

/* Temporary hack until unblocking is fixed up: retry pending output whenever
   anything is read. */
#define Count	p_chan.ch_outrec.count
#define	CCount	p_chan.ch_outrec.ccount
    {
	register struct process_blk *p;

	for (p = process_list; p != NULL; p = p -> next_process)
	    if (active_process (p) && (p -> Count || p -> CCount))
		send_chan (p);
    }
    if (mpx_count == 0) {
#ifdef ECHOKEYS
	if (alrmtime > 0)
	    alarm ((unsigned) alrmtime);
#endif
	mpx_count = read (mpx_fd, cbuffer, BUFSIZ);
#ifdef ECHOKEYS
	alarm (0);
#endif
	if (mpx_count <= 0)
	    return (EOF);
	MXP = (struct rh *) cbuffer;
    }
#ifndef UtahFeatures
    if (child_changed) {
	child_changed = 0;
	change_msgs ();
    }
#endif

    while (mpx_count > 0) {
	record_size = (MXP -> count + MXP -> ccount + 7) & 0xFFFE;
	if (MXP -> count == 0) {/* process a mpx channel record msg */
	    for (msg = (struct mpx_msg *) (MXP + 1); MXP -> ccount > 0;) {
		msg_length = Take_msg (msg, MXP -> index);
		msg = (struct mpx_msg  *) ((int) msg + msg_length);
		MXP -> ccount -= msg_length;
	    }
	    mpx_count -= record_size;
	    MXP = (struct rh *) ((int) MXP + record_size);
	}
	else {
	    if ((this_channel = find_channel (MXP -> index)) == NULL) {
		error ("Illegal channel index");
		return (EOF);	/* DANGER - THIS EXITS */
	    }
#ifdef UtahFeatures
	if (this_channel == mpxin) {
	    if (this_channel -> ch_count <= 0) {
		this_channel -> ch_ptr = stdin_buf;
		cpyn (stdin_buf, (char *) (MXP +1), MXP -> count);
		this_channel -> ch_count = MXP -> count;
	    }
	    else {
		register count = MXP -> count;
		if (count + this_channel -> ch_count +
			(this_channel -> ch_ptr - stdin_buf) >= BUFSIZ)
		count = BUFSIZ - this_channel -> ch_count -
			(this_channel -> ch_ptr - stdin_buf);
		cpyn (this_channel -> ch_ptr + this_channel -> ch_count,
			(char *) (MXP + 1), count);
		this_channel -> ch_count += count;
		}
	    }
	else {
#endif
	    this_channel -> ch_ptr = (char *) (MXP + 1);
	    this_channel -> ch_count = MXP -> count;
#ifdef UtahFeatures
	}
#endif
	    mpx_count -= record_size;
	    MXP = (struct rh *) ((int) MXP + record_size);

	/* input from TTY comes through the distinguished channel block */

	    if (this_channel == mpxin) {
#ifdef UtahFeatures
		if (chan != NULL) {
		    if (child_changed) {/* need to do this here, too */
			change_msgs ();
			child_changed = 0;
		    }
#endif
		mpxin -> ch_count--;
		return (*mpxin -> ch_ptr++ & 0377);
#ifdef UtahFeatures
		}
#endif
	    }
	    else
		stuff_buffer (this_channel);
	}
    }
#ifndef UtahFeatures
    goto readloop;
#else
    if (child_changed) {
	change_msgs ();
	child_changed = 0;
    }
    if (chan != NULL || mpx_count != 0)
        goto readloop;
#endif
#else MPXcode
    int ichans, ochans, cc;
    register struct channel_blk *this_chan;
    register struct process_blk *p;
readloop:
    if (err != 0)			/* check for ^G interrupts */
	return 0;

    ichans = sel_ichans; ochans = sel_ochans;
    if (chan == NULL)
	ichans &= ~1;			/* don't look at tty in this case */

    /* 
     * If we do this here, iff there is no input, then it will always
     * happen asap.
     */
    if (child_changed) {
	int c_ichans = ichans;
	if (select(32, &c_ichans, 0, 0) <= 0)	/* if none waiting */
	{
	    change_msgs ();
	    child_changed = 0;
	}
    }

#ifdef	ECHOKEYS
    if (alrmtime <= 0)
	alrmtime = 1000000;
    else
	alrmtime *= 1000;
    if ((cc = select(32, &ichans, &ochans, alrmtime)) < 0)
	goto readloop;			/* try again */
    else
	if (cc == 0)
	    EchoThem (1);
#else
    if (select(32, &ichans, &ochans, 1000000) < 0)
	goto readloop;			/* try again */
#endif

#ifdef	TTYconnect
    AttachSocket (ichans);		/* check for a new socket */
#endif

    if (ichans&1) {
        ichans &= ~1;
	cc = read(0, cbuffer, sizeof (cbuffer));
	if (cc > 0) {
	    if (child_changed) {
		change_msgs ();
		child_changed = 0;
	    }
	    mpxin->ch_ptr = cbuffer;
	    mpxin->ch_count = cc - 1;
	    stdin->_flag &= ~_IOEOF;
	    return (*mpxin->ch_ptr++ & 0377);
	}
	else if (cc == 0)
	{
	    fprintf(stderr,"null read from stdin\r\n");
	    stdin->_flag |= _IOEOF;	/* mark EOF encountered */
	    return(EOF);
	}
    }
    for (p = process_list; p != NULL; p = p->next_process) {
	this_chan = &p->p_chan;
	if (ichans & (1<<this_chan->ch_index)) {
	    ichans &= ~(1<<this_chan->ch_index);
	    cc = read(this_chan->ch_index, cbuffer, sizeof (cbuffer));
	    if (cc > 0) {
		this_chan->ch_ptr = cbuffer;
		this_chan->ch_count = cc;
		stuff_buffer(this_chan);
	    }
            else if (cc <= 0)
	    {
/*  With pty:s, when the parent process of a pty exits we are notified,
    just as we would be with any of our other children.  After the process
    exits, select() will indicate that we can read the channel.  When we
    do this, read() returns 0.  Upon receiving this, we close the channel.

    For unexpected processes, when the peer closes the connection, select()
    will indicate that we can read the channel.  When we do this, read()
    returns -1 with errno = ECONNRESET.  Since we never get notified of
    this via wait3(), we must explictly mark the process as having exited.
    (This corresponds to the action performed when a M_CLOSE is received
    with the MPXio version of Emacs.)
 */
#ifdef	ce
		extern int errno;
		fprintf (err_file, "%s read from %s on channel %d errno=%d\n",
			cc == 0 ? "null" : "error", p -> p_name,
			this_chan -> ch_index, cc < 0 ? errno : 0);
#endif
		sel_ichans &= ~(1 << this_chan -> ch_index); /* disconnect */
		sel_ochans &= ~(1 << this_chan -> ch_index); /* disconnect */
		close (this_chan->ch_index);
#ifdef	TTYconnect
		if (cc < 0) {	/* peer dropped it */
		    p -> p_flag = EXITED | CHANGED;
		    p -> p_reason = 0;
		    child_changed++;
		}
#endif
	    }
	}
	if (ochans & (1<<this_chan->ch_index)) {
	    ochans &= ~(1<<this_chan->ch_index);
	    if (this_chan->ch_outrec.ccount) {
	       cc = write(this_chan->ch_index, "", 0);
	       if (cc < 0)
		   continue;
	       this_chan->ch_outrec.ccount = 0;
	    }
	    if (this_chan->ch_outrec.count) {
	       cc = write(this_chan->ch_index,
		   this_chan->ch_outrec.data, this_chan->ch_outrec.count);
	       if (cc > 0) {
		   this_chan->ch_outrec.data += cc;
		   this_chan->ch_outrec.count -= cc;
	       }
	    }
	    if (this_chan->ch_outrec.count == 0)
		sel_ochans &= ~(1<<this_chan->ch_index);
	}
    }
    /* SWT - do this after stuffing output.  Hopefully the "Exited"
     * message will always come at the end of the buffer then.
     */
    if (child_changed) {
	change_msgs ();
	child_changed = 0;
    }

    if (chan != NULL)
	goto readloop;

#endif
#ifdef UtahFeatures
    return 0;
#endif
}

#ifdef MPXcode
/* Take a channel message and do the right thing with it:
	IOCTL -> return appropriate IOANS
	EOT   -> ignore (spurious & bogus EOT's seem to thrive !!)
	CLOSE -> close the channel
	anything else -> print msg and ignore
*/

Take_msg (msg, index)
register struct mpx_msg *msg;
register index_t index;
{
    extern  mpx_fd;
    register struct process_blk *p;

    switch (msg -> mpx_code & 0377) {
	case M_IOCTL:
	    ioans.index = index;
	    ioans_rec.sgtty_ans =
		msg -> mpx_ioctl;	/* init answer, in case we send back
					   less than sizeof(struct sgttyb) */
	    switch (msg -> mpx_arg) {
	    default:		/* ignore most ioctls */
		break;
	    case TIOCGETD:	/* Get line discipline, give NTTYDISC */
		other_ans = NTTYDISC;
		setans (&other_ans, sizeof (int));
		break;
	    case TIOCGETP:	/* Give vanilla terminal description */
		setans (&standard_ans, sizeof (struct sgttyb));
		break;
	    case TIOCSTI:	/* Simulate Terminal Input */
				/* this one should eventually be
				   fixed, for ucbmail */
		break;
	    case TIOCGPGRP:	/* Get process group */
		p = index_to_process (index);
		if (p) {
#ifdef ce
		    fprintf (err_file, "GPGRP returning %d\n",p->p_gid);
#endif
		    short_ans = p -> p_gid;
		}
		else
		    short_ans = -1;
		setans (&short_ans, sizeof (short));
		break;
	    case TIOCSPGRP:	/* Set process group */
#ifdef ce
		if (index == mpxin->ch_index) {
		    fprintf (err_file, "somethin' funny here\n");
		    return 4+sizeof(struct sgttyb);
		}
#endif
		p = index_to_process (index);
		if (p) {
		    short t;
		    sighold (SIGCHLD);
		    t = *((short *)(&msg->mpx_ioctl));/* kludge! */
		    if (getpgrp (t) < 0) {/* klude some more */
/* Believe it or not, the above test is necessary or the cshell gets very
   confused on interrupts. */
#ifdef ce
			fprintf (err_file, "SPGRP on chan %d, to %d FAILED\n",
			index, t);
#endif
			short_ans = -1;
		    }
		    else {
			p -> p_gid = t;
#ifdef ce
			fprintf (err_file, "SPGRP on chan %d, to %d\n", index,
			t);
#endif
			short_ans = t;
		    }
		    sigrelse (SIGCHLD);
		}
		else
		    short_ans = -1;
		setans (&short_ans, sizeof (short));
		break;
	    case TIOCGETC:	/* Get special chars */
		setans (&special_ans, sizeof (struct tchars));
		break;
	    case TIOCLGET:	/* Get local mode word */
		setans (&lget_ans, sizeof (int));
		break;
	    case TIOCGLTC:	/* Get ltchars */
		setans (&ltc_ans, sizeof (struct ltchars));
		break;
	    }
	    if (write (mpx_fd, &ioans, sizeof (ioans)) != sizeof (ioans))
		error ("Unable to reply to process IOCTL");
	    return (4 + sizeof (struct sgttyb));

	/* We get a WATCH message when someone opens our multiplexed file. If
	   we do an attach then they can connect.
	*/
	case M_WATCH:
#ifdef ce
	    fprintf(err_file, "Watch: %d\n", index); 
#endif
	    if (sflag && EmacsShare &&
		start_other_process (msg -> mpx_arg, index) == 0)
		    attach (index, mpx_fd);/* Let him open */
	    else
		detach (index, mpx_fd);/* Don't allow open */
	    return(4);

	case M_UBLK: 
	    if ((p = index_to_process (index)) == NULL) {
#ifdef ce
		fprintf(err_file, "%d: Msg code:%d, arg:%d, index:%d\n",
		err_id, msg->mpx_code, msg->mpx_arg, index); 
#endif
		return (4);
	    }
	    message ("Unblocking");
	    send_chan (p);
	    return (4);

	case M_EOT: 
	 /* if (index != mpxin->ch_index) 
		fprintf(err_file, "%d: Msg code:%d, arg:%d, index:%d\n", 
			err_id, msg->mpx_code, msg->mpx_arg, index); */
	   return (4);				/* ignore ! */
	case M_CLOSE: 
#ifdef ce
	    fprintf(err_file, "Close: %d\n", index); 
#endif
	    detach (index, mpx_fd);		/* reuse channel */
	    {
		register struct process_blk *p = index_to_process (index);
		if (p) {
		    p -> p_flag = EXITED | CHANGED;
		    p -> p_reason = 0;
		    child_changed++;
		}
	    }
	    return (4);
	case M_SIG:
#ifdef ce
	    fprintf(err_file, "SIG: %d\n", index);  
#endif
	    return (4);
	case M_BLK:
#ifdef ce
	    fprintf(err_file, "Blocking: %d\n", index);  
#endif
	    return (4);
	case M_OPEN:
#ifdef ce
	    fprintf(err_file, "Opening: %d\n", index);
#endif
	    return (4);
	default: 
#ifdef ce
	    fprintf(err_file, "%d: Msg code:%d, arg:%d, index:%d\n",
		err_id, msg->mpx_code, msg->mpx_arg, index);
#endif

	    return (4);
    }
}
#endif

/* Give a message that a process has changed and indicate why.  Dead processes
   are not removed until after a Display Processes command has been issued so
   that the user doesn't wonder where his process went in times of intense
   hacking. */

change_msgs () {
    register struct process_blk *p;
    register struct buffer *old = bf_cur;
    char    line[50];

#ifdef HalfBaked
    sighold (SIGINT);
#endif
    for (p = process_list; p != NULL; p = p -> next_process)
	if (p -> p_flag & CHANGED) {
	    p -> p_flag &= ~CHANGED;
	    switch (p -> p_flag & (SIGNALED | EXITED)) {
		case SIGNALED: 
		    SetBfp (p -> p_chan.ch_buffer);
		    SetDot (bf_s1 + bf_s2 + 1);
		    sprintfl (line, sizeof line, "%s%s\n",
			SIG_names[p -> p_reason],
			p -> p_flag & COREDUMPED ? " (core dumped)" : "");
		    InsStr (line);
		    break;
		case EXITED: 
		    if (p -> p_chan.ch_sent == NULL) {
			SetBfp (p -> p_chan.ch_buffer);
			SetDot (bf_s1 + bf_s2 + 1);
			sprintfl (line, sizeof line,
			    p -> p_reason ? "Exit %d\n" : "Exited\n",
			    p -> p_reason);
			InsStr (line);
		    }
		    else {
			register    Expression * MPX_Exp =
			            MPX_process -> v_binding -> b_exp;
			int     larg = arg;
			enum ArgStates lstate = ArgState;
			int     old_int = MPX_Exp -> exp_int;
			char   *old_str = MPX_Exp -> exp_v.v_string;
			register struct channel_blk *chan =
			                           &(p -> p_chan);

			arg = p -> p_reason;
			ArgState = HaveArg;
			MPX_Exp -> exp_int =
			    strlen (chan -> ch_buffer -> b_name);
			MPX_Exp -> exp_v.v_string =
			    chan -> ch_buffer -> b_name;
			ExecuteBound (chan -> ch_sent);
			MPX_Exp -> exp_int = old_int;
			MPX_Exp -> exp_v.v_string = old_str;
			arg = larg;
			ArgState = lstate;
		    }
		    break;
		}
	}
#ifdef HalfBaked
    sigrelse (SIGINT);
#endif
    DoDsp (1);
    SetBfp (old);
}

/* Send any pending output as indicated in the process block to the 
   appropriate channel.
*/
send_chan (process)
register struct process_blk *process;
{
    register struct wh *output;

    output = &process -> p_chan.ch_outrec;
    if (output -> count == 0 && output -> ccount == 0) {
	/* error ("Null output"); */
	return 0;		/* No output to be done */
    }
#ifdef MPXcode
    if (write (mpx_fd, output, sizeof (*output)) != sizeof (*output))
	/* message ("Blocking")*/ ;
    else {
	output -> count = 0;
	output -> ccount = 0;
    }
#else
    if (output->ccount) {
	if (write(output->index, "", 0) >= 0) {
	    output->ccount = 0;
	    return 0;
	}
    } else {
	if (output->count) {
	    int cc = write(output->index, output->data, output->count);
	    if (cc > 0) {
		output->data += cc;
		output->count -= cc;
	    }
	}
        if (output->count == 0)
	    return 0;
    }
    sel_ochans |= 1<<(output->index);
#endif
    return 0;			/* ACT 8-Sep-1982 */
}

/* Output has been recieved from a process on "chan" and should be stuffed in
   the correct buffer */
/* ACT 9-Sep-1982 Modified to remove "lockout" restriction and allow
   recursive stuffs. */

stuff_buffer (chan)
register struct channel_blk *chan;
{
    struct buffer  *old_buffer = bf_cur;

#ifdef HalfBaked
    sighold (SIGINT);
#endif

    if (chan -> ch_proc == NULL) {
	SetBfp (chan -> ch_buffer);
	SetDot (bf_s1 + bf_s2 + 1);
	InsCStr (chan -> ch_ptr, chan -> ch_count);
	if ((bf_s1 + bf_s2) > ProcessBufferSize) {
	    DelFrwd (1, ChunkSize);
	    DotLeft (ChunkSize);
	}
	if (bf_cur -> b_mark == NULL)
	    bf_cur -> b_mark = NewMark ();
	SetMark (bf_cur -> b_mark, bf_cur, dot);
	DoDsp (1);
	SetBfp (old_buffer);
	if (interactive)
	    WindowOn (bf_cur);
    }
    else {			/* ACT 31-Aug-1982 Added hold on prefix arg */
	register char	*old_str;
	int		larg = arg, old_int;
	enum ArgStates	lstate = ArgState;
	register Expression
			*MPX_Exp = MPX_process -> v_binding -> b_exp;
	struct channel_blk
			*old_chan = MPX_chan;

	old_int = MPX_Exp -> exp_int;
	old_str = MPX_Exp -> exp_v.v_string;
	arg = 1;
	ArgState = NoArg;	/* save arg & arg state */
	MPX_Exp -> exp_int = strlen (chan -> ch_buffer -> b_name);
	MPX_Exp -> exp_v.v_string =  chan -> ch_buffer -> b_name;
	MPX_chan = chan;	/* User will be able to get the output
				   for */
	ExecuteBound (chan -> ch_proc);
	MPX_chan = old_chan;	/* a very short time only */
	MPX_Exp -> exp_int = old_int;
	MPX_Exp -> exp_v.v_string = old_str;
	arg = larg;
	ArgState = lstate;	/* restore arg */
	SetBfp (chan -> ch_buffer);
	if ((bf_s1 + bf_s2) > ProcessBufferSize) {
	    DelFrwd (1, ChunkSize);
	    DotLeft (ChunkSize);
	}
	SetBfp (old_buffer);
    }
    chan -> ch_count = 0;

#ifdef HalfBaked
    sigrelse (SIGINT);
#endif
    return 0;			/* ACT 8-Sep-1982 */
}

/* Return a count of all active processes */

count_processes () {
    register struct process_blk *p;
    register    count = 0;

    for (p = process_list; p != NULL; p = p -> next_process)
	if (active_process (p))
	    count++;
    return (count);
}

/* Flush a process but only if process is inactive */

flush_process (process)
register struct process_blk *process;
{
    register struct process_blk *p,
				*lp;

    if (active_process (process)) {
	error ("Can't flush an active process");
	return 0;
    }

    for (lp = NULL, p = process_list;
	    (p != NULL) && (p != process);
	    lp = p, p = p -> next_process);
    if (p != process) {
	error ("Can't find process");
	return 0;
    }
    if (lp == NULL)
	process_list = process -> next_process;
    else
	lp -> next_process = process -> next_process;
    free (process);
    return 0;
}

/* Kill off all active processes: done only to exit when user really
   insists */

kill_processes () {
    register struct process_blk *p;

    for (p = process_list; p != NULL; p = p -> next_process) {
	if (active_process (p)) {
#ifndef	MPXcode
	    ioctl (p -> p_chan.ch_index, TIOCGPGRP, &(p -> p_gid));
#endif
	    if (p -> p_gid != -1)
		killpg (p -> p_gid, SIGKILL);
	    if (p -> p_pid != -1)
		killpg (p -> p_pid, SIGKILL);
	}
    }
#ifdef MPXcode
    detach (mpxin -> ch_index, mpx_fd);
#endif
}

/* Start up a new process by creating the process block and initializing 
   things correctly */

start_process (com, buf, proc)
register char	*com,
		*buf;
{
    extern struct process_blk  *get_next_process ();

    if (com == 0)
	return 0;
    current_process =
	(struct process_blk *) malloc (sizeof (struct process_blk));
    if (current_process == NULL) {
	error ("Out of memory");
	return 0;
    }
    sighold (SIGCHLD);
    current_process -> next_process = process_list;
    process_list = current_process;
    if (create_process (com) < 0) {/* job was not started, so undo */
	flush_process (current_process);
	current_process = get_next_process ();
	sigrelse (SIGCHLD);
	return 0;
    }
    SetBfn (buf == NULL ? "Command execution" : buf);
    if (interactive)
	WindowOn (bf_cur);
    current_process -> p_chan.ch_buffer = bf_cur;
    current_process -> p_chan.ch_proc = (proc < 0 ? NULL : MacBodies[proc]);
    current_process -> p_chan.ch_sent = NULL;
    sigrelse (SIGCHLD);
    return 0;
}

#ifdef	MPXcode
/* Start up a new process caused by someone opening the share file */
start_other_process (uid, index)
register index_t index;
{
    static char buf[40];

    register struct buffer *old = bf_cur;
    register struct process_blk *newproc;

    sighold (SIGCHLD);

    sprintf (buf, "proc_%d", uid);
    if (find_process (buf)) {
	register i = 1;
	do sprintf (buf, "proc_%d<%d>", uid, i++);
	while (find_process (buf));
    }
    newproc = (struct process_blk *) malloc (sizeof (struct process_blk));
    if (newproc == NULL) {
	sigrelse (SIGCHLD);
	error ("Out of memory");
	return -1;
    }
    newproc -> next_process = process_list;
    process_list = newproc;
    newproc -> p_name = savestr (buf);
    newproc -> p_pid = -1;
    newproc -> p_gid = -1;
    newproc -> p_flag = RUNNING;
    newproc -> p_chan.ch_index = index;
    newproc -> p_chan.ch_ptr = NULL;
    newproc -> p_chan.ch_count = 0;
    newproc -> p_chan.ch_outrec.index = index;
    newproc -> p_chan.ch_outrec.count = 0;
    newproc -> p_chan.ch_outrec.ccount = 0;

    SetBfn (newproc -> p_name);
    if (PopUpUnexpected)
	WindowOn (bf_cur);
    newproc -> p_chan.ch_buffer = bf_cur;
    newproc -> p_chan.ch_proc = UnexpectedProc;
    newproc -> p_chan.ch_sent = UnexpectedSent;
    sigrelse (SIGCHLD);
#ifdef UciFeatures
    bf_modified = 0;
    bf_cur -> b_mode.md_NeedsCheckpointing = 0;
#endif
    SetBfp (old);
    if (PopUpUnexpected)
	WindowOn (bf_cur);
    return 0;
}
#endif

/* Emacs command to start up a default process: uses "Command Execution"
   buffer if one is not specified.  Also does default stuffing */

StartProcess () {
register char   *com = (char *) (savestr (getstr ("Command: ")));
register char   *buf;

    if ((com == 0) || (*com == 0)) {
	error ("No command");
	return 0;
    }
    buf = (char *) getstr ("Connect to buffer: ");
    if (*buf == 0)
	buf = NULL;
    start_process (com, buf, -1);
    return 0;			/* ACT 8-Sep-1982 */
}

/* Start up a process whose output will get filtered through a procedure
   specified by the user */

StartFilteredProcess () {
    register char   *com = (char *) (savestr (getstr ("Command: ")));
    register char   *buf;
    int	 proc;
    char bufname[200];

    if ((com == 0) || (*com == 0)) {
	error ("No command");
	return 0;
    }
    buf = getstr ("Connect to buffer: ");
    if (buf == 0) return 0;
    strcpy (bufname, buf);
    proc = getword (MacNames, "On-output procedure: ");
    start_process (com, bufname[0] ? bufname : NULL, proc);
    return 0;			/* ACT 8-Sep-1982 */
}

/* Set the UnexpectedProc pointer */
static
SetUnexpectedProc () {
    register proc =
	getword (MacNames, "Filter unexpected processes through command: ");
    UnexpectedProc = proc < 0 ? NULL : MacBodies[proc];
}

/* Return a process buffer or NULL */
struct process_blk *
GetBufProc ()
{
    register    b = getword (BufNames, "Process: ");
    if (b < 0)
	return NULL;
    return find_process (BufNames[b]);
}

/* Insert a filter-procedure between a process and emacs. This function
   should subsume the StartFilteredProcess function, but we should retain
   that one for compatibility I suppose. */
InsertFilter ()
{
    register struct process_blk *process;
    register int proc;

    if ((process = GetBufProc ()) == NULL) {
	error ("Not a Process");
	return 0;
    }
    proc = getword(MacNames, "On-output procedure: ");
    process -> p_chan.ch_proc = (proc < 0 ? NULL : MacBodies[proc]);
    return(0);
}

/* Reset filter rebinds the process filter to NULL */
ResetFilter () {
    register struct process_blk *process;
  
    if ((process = GetBufProc ()) == NULL) {
	error ("Not a Process");
	return 0;
    }
    process -> p_chan.ch_proc = NULL;
    return 0;			/* ACT 8-Sep-1982 */
}

/* ProcessFilterName returns the name of the process filter */
ProcessFilterName () {
    register struct process_blk *process;
    char   *name;

    if ((process = GetBufProc ()) == NULL) {
	error ("Not a Process");
	return 0;
    }
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_release = 0;
    name = process -> p_chan.ch_proc
	? process -> p_chan.ch_proc -> b_name : "";
    MLvalue -> exp_int = strlen (name);
    MLvalue -> exp_v.v_string = name;
    return 0;
}

static
InsertSentinel ()
{
    register struct process_blk *process;
    register int proc;

    if ((process = GetBufProc ()) == NULL) {
	error ("Not a Process");
	return 0;
    }
    proc = getword(MacNames, "On-exit procedure: ");
    process -> p_chan.ch_sent = (proc < 0 ? NULL : MacBodies[proc]);
    return(0);
}

static
ResetSentinel () {
    register struct process_blk *process;
  
    if ((process = GetBufProc ()) == NULL) {
	error ("Not a Process");
	return 0;
    }
    process -> p_chan.ch_sent = NULL;
    return 0;
}

static
ProcessSentinelName () {
    register struct process_blk *process;
    char   *name;

    if ((process = GetBufProc ()) == NULL) {
	error ("Not a Process");
	return 0;
    }
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_release = 0;
    name = process -> p_chan.ch_sent
	? process -> p_chan.ch_sent -> b_name : "";
    MLvalue -> exp_int = strlen (name);
    MLvalue -> exp_v.v_string = name;
    return 0;
}

static
SetUnexpectedSent() {
    register proc =
	getword (MacNames, "unexpected processes on exit call command: ");
    UnexpectedSent = proc < 0 ? NULL : MacBodies[proc];
}

/* List the current processes.  After listing stopped or exited processes,
   flush them from the process list. */

ListProcesses () {
    register struct buffer *old = bf_cur;
    register struct process_blk *p;
    char    line[150], tline[20];

    SetBfn ("Process list");
    if (interactive)
	WindowOn (bf_cur);
    EraseBf (bf_cur);
    InsStr ("\
Buffer			Status		   Command\n\
------			------		   -------\n");
    sighold (SIGCHLD);
    for (p = process_list; p != NULL; p = p -> next_process) {
	sprintfl (line, sizeof line, "%-24s", p -> p_chan.ch_buffer -> b_name);
	InsStr (line);
	switch (p -> p_flag & (STOPPED | RUNNING | EXITED | SIGNALED)) {
	    case STOPPED: 
		sprintfl (line, sizeof line, "%-17s", "Stopped");
		break;
	    case RUNNING: 
		sprintfl (line, sizeof line, "%-17s", "Running");
		break;
	    case EXITED: 
		sprintfl (tline, sizeof tline,
			p -> p_reason ? "Exit %d" : "Exited", p -> p_reason);
		sprintf (line, "%-17s", tline);
		flush_process (p);
		break;
	    case SIGNALED: 
		sprintfl (tline, sizeof tline, "%s%s",
			SIG_names[p -> p_reason],
			p -> p_flag & COREDUMPED ? " (core dumped)" : "");
		sprintf (line, "%-17s", tline);
		flush_process (p);
		break;
	    default: 
		continue;
	}
	InsStr (line);
	sprintfl (line, sizeof line, "   %-32s\n", p -> p_name);
	InsStr (line);
    }
    sigrelse (SIGCHLD);
    bf_modified = 0;
    SetBfp (old);
    WindowOn (bf_cur);
    return 0;
}

/* Take input from mark to dot and feed to the subprocess */
RegionToProcess () {
    register	left,
		right;
    register struct process_blk *process;
    register struct wh *output;

    if ((process = GetBufProc ()) == NULL) {
	error ("Not a Process");
	return 0;
    }

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
    if (right - left <= 0) {
	error ("Region is null");
	return 0;
    }
    if (left < bf_s1 && right >= bf_s1)
	GapTo (left);
    output = &process -> p_chan.ch_outrec;
    if (output -> count || output -> ccount)
	error ("Overwriting data on blocked channel");
    output -> index = process -> p_chan.ch_index;
    output -> ccount = 0;
    output -> count = right - left;
    output -> data = &CharAt (left);
    send_chan (process);
    return 0;
}

/* Send a string to the process as input */
StringToProcess () {
    register char *input_string;
    register struct process_blk *process;
    register struct wh *output;
 
    if ((process = GetBufProc()) == NULL) {
	error ("Not a Process");
	return 0;
    }
    input_string = getstr("String: ");
    output = &process -> p_chan.ch_outrec;
    if (output -> count || output -> ccount)
	error("Overwriting data on blocked channel");
    output -> index = process -> p_chan.ch_index;
    output -> ccount = 0;
    output -> count = strlen(input_string);
    if (output -> count <= 0)
	error("Null string");
    output -> data = input_string;
    send_chan (process);
    return 0;
}
   
/* Get the current output which has been thrown at us and send it
   to the user as a string; this is only allowed if MPX_chan is non-null
   indicating that this has been indirectly called from stuff_buffer. */

ProcessOutput () {
    if (MPX_chan == NULL) {
	error ("process-output can only be called from filter");
	return 0;
    }

    MLvalue -> exp_type = IsString;
    MLvalue -> exp_release = 1;
    MLvalue -> exp_int = MPX_chan -> ch_count;
    MLvalue -> exp_v.v_string = (char *) malloc (MLvalue -> exp_int + 1);
#ifndef UtahFeatures
    strcpyn (MLvalue -> exp_v.v_string, MPX_chan -> ch_ptr,
	MLvalue -> exp_int);
#else
    cpyn (MLvalue -> exp_v.v_string, MPX_chan -> ch_ptr,
	MLvalue -> exp_int);
#endif
    MLvalue -> exp_v.v_string[MLvalue -> exp_int] = '\0';
    return 0;
}

/* Send an signal to the specified process group.  Goes to leader
   (process which started whole mess) iff "leader". */

sig_process (signal, leader) register leader; {
    register struct process_blk *process;

    if ((process = GetBufProc ()) == NULL) {
	error ("Not a process");
	return 0;
    }

/* We must update the process flag explicitly in the case of continuing a 
   process since no signal will come back */

    if (signal == SIGCONT) {
	sighold (SIGCHLD);
#ifndef UtahFeatures
	process -> p_flag = (process -> p_flag & ~STOPPED) | RUNNING;
#else
	process -> p_flag = (process -> p_flag & ~STOPPED) | RUNNING | CHANGED;
	child_changed++;
#endif
	sigrelse (SIGCHLD);
    }

#ifndef MPXcode
    ioctl (process -> p_chan.ch_index, TIOCGPGRP, &(process -> p_gid));
    switch (signal) {
	case SIGINT:  case SIGQUIT:
	    ioctl (process -> p_chan.ch_index, TIOCFLUSH, 0);
	    process -> p_chan.ch_outrec.count = 0;
	    process -> p_chan.ch_outrec.count = 0;
	    break;
    }
#endif

#ifdef ce
    fprintf (err_file, "Sending signal %d to proc (%d, %d), leader=%d\n",
	signal, process -> p_pid, process -> p_gid, leader);
#endif
    leader = leader ? process -> p_pid : process -> p_gid;
#ifndef	TTYconnect
    if (leader != -1)
	killpg (leader, signal);
#else
    if (leader != -1)
	killpg (leader, signal);
    else
	if (process -> p_pid == -1 && signal == SIGKILL) {
	    sel_ichans &= ~(1 << process -> p_chan.ch_index);
	    sel_ochans &= ~(1 << process -> p_chan.ch_index);	    
	    close (process -> p_chan.ch_index);
	    sighold (SIGCHLD);
	    process -> p_flag = SIGNALED | CHANGED;
	    process -> p_reason = SIGKILL;
	    child_changed++;
	    sigrelse (SIGCHLD);
	}
#endif
    return 0;
}

IntProcess () {
    return (sig_process (SIGINT, 0));
}

IntPLeader () {
    return (sig_process (SIGINT, 1));
}

QuitProcess () {
    return (sig_process (SIGQUIT, 0));
}

QuitPLeader () {
    return (sig_process (SIGQUIT, 1));
}

KillProcess () {
    return (sig_process (SIGKILL, 0));
}

KillPLeader () {
    return (sig_process (SIGKILL, 1));
}

StopProcess () {
    return (sig_process (SIGTSTP, 0));
}

StopPLeader () {
    return (sig_process (SIGTSTP, 1));
}

ContProcess () {
    return (sig_process (SIGCONT, 0));
}

ContPLeader () {
    return (sig_process (SIGCONT, 1));
}

SignalToProcess () {
    return SignalToProcOrLeader (0);
}

SignalToPLeader () {
    return SignalToProcOrLeader (1);
}

SignalToProcOrLeader (leader) {
    register char *s = getnbstr ("Signal: ");
    register i;

    if (!s || !*s) return 0;
    if (*s >= '0' && *s <= '9')
	return sig_process (atoi (s), leader);
    for (i = 0; i < sizeof KillNames/sizeof *KillNames; i++)
	if (strcmp (KillNames[i], s) == 0)
	    return sig_process (i, leader);
    error ("\"%s\" is not a signal name", s);
    return 0;
}

EOTProcess () {
    register struct process_blk *process;
#ifdef	MPXcode
    struct {
	short	code,
		arg;
    }	EOT_msg;
#endif
    register struct wh *output;

    if ((process = GetBufProc ()) == NULL) {
	error ("Not a process");
	return (0);
    }
    output = &process -> p_chan.ch_outrec;
    if (output -> count || output -> ccount)
	error ("Overwriting on blocked channel");

    output -> index = process -> p_chan.ch_index;
    output -> count = 0;
#ifdef MPXcode
    output -> ccount = sizeof (EOT_msg);
    output -> data = (char *) & EOT_msg;
    EOT_msg.code = M_EOT;
#else
    output -> ccount = 1;
    output -> data = "";
#endif
    send_chan (process);
    return 0;			/* ACT 8-Sep-1982 */
}

/* Some useful functions on the process */
StrFunc (CurrentProcess,
    (current_process ? current_process -> p_chan.ch_buffer -> b_name : ""));

/* Return the name of the currently active process: it is defined as the name
   of the current buffer if is attached to an active process. */

ActiveProcess () {
    register struct process_blk *p;

    for (p = process_list; p != NULL; p = p -> next_process)
	if (active_process (p) && (p -> p_chan.ch_buffer == bf_cur))
	    break;
    if (p == NULL)
	p = current_process;
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_release = 0;
    if (p == NULL) {
	MLvalue -> exp_int = 0;
	MLvalue -> exp_v.v_string = NULL;
    }
    else {
	MLvalue -> exp_int = strlen (p -> p_chan.ch_buffer -> b_name);
	MLvalue -> exp_v.v_string = p -> p_chan.ch_buffer -> b_name;
    }
    return 0;
}

/* Change the current-process to the one indicated */

ChangeCurrentProcess () {
    register struct process_blk *process = GetBufProc ();

    if (process == NULL) {
	error ("Not a process");
	return 0;
    }
    current_process = process;
    return 0;
}

/* Return the process' status:
	-1 - not an active process
	 0 - a stopped process
	 1 - a running process
*/

/* It's tempting to make this call GetBufProc() - but do not ... */
ProcessStatus () {
    register char *name = getstr ("Process: ");
    register struct process_blk *process = find_process (name);

    MLvalue -> exp_type = IsInteger;
    if (process == NULL)
	MLvalue -> exp_int = -1;
    else
	if (process -> p_flag & RUNNING)
	    MLvalue -> exp_int = 1;
	else
	    MLvalue -> exp_int = 0;
    return 0;
}

/* Get the process id */
ProcessID () {
    return PID (0);
}

/* Get the process leader id */
PLeaderID () {
    return PID (1);
}

PID (leader) {
    register char  *p_name = getstr ("Process name: ");
    register struct process_blk *process;

    MLvalue -> exp_type = IsInteger;
    process = find_process (p_name);
#ifndef	MPXcode
    if (process == NULL)
	MLvalue -> exp_int = 0;
    else
	MLvalue -> exp_int = leader ? process -> p_pid : process -> p_gid;
#else
    if (process == NULL)
	MLvalue -> exp_int = 0;
    else {
	ioctl (process -> p_chan.ch_index, TIOCGPGRP, &(process -> p_gid));
	MLvalue -> exp_int = leader ? process -> p_pid : process -> p_gid;
    }
#endif
    return 0;
}

#ifdef UtahFeatures
/* Get input from a subprocess (or the tty) and process it.
 * Tty input is just buffered until requested.
 */
static AwaitProcessInput ()		/* just poll for input */
{
#ifdef ECHOKEYS
    fill_chan(NULL, 0);
#else
    fill_chan(NULL);
#endif
}
#endif
#endif

#ifdef MPXcode
static char *
tail (s)
register char *s;
{
    register char *t = s;

    while (*s) if (*s++ == '/' && *s) t = s;
    return t;
}
#endif

/* Initialize things on the multiplexed file.  This involves connecting the
   standard input to a channel on the mpx file. */

InitMpx () {
#ifdef subprocesses
    extern  child_sig ();
    extern char *MyTtyName;

#ifdef ce
    err_file = fopen ("/tmp/emacs.mxdebug", "a");
    if (err_file == NULL) {
	unlink ("/tmp/emacs.mxdebug");
	err_file = fopen ("/tmp/emacs.mxdebug", "a");
    }
    chmod ("/tmp/emacs.mxdebug", 0666);
    setbuf (err_file, NULL);
    err_id = getuid ();
#endif
#ifdef MPXcode
 /* We will make children think they have a vanilla terminal */
    ioans_rec.code = M_IOANS;
    ioans.ccount = sizeof (ioans_rec);
    ioans.data = (char *) &ioans_rec;
    ioctl (0, TIOCGETP, &standard_ans);	/* Set up GETP answer */
    ioctl (0, TIOCGETC, &special_ans);	/* Set up GETC answer */
    ioctl (0, TIOCLGET, &lget_ans);	/* Set up LGET answer */
#ifdef TIOCGLTC
    ioctl (0, TIOCGLTC, &ltc_ans);	/* Set up GLTC answer */
#endif

/* Open the multiplexed file with a file name so that it can be shared from
   the outside */

    if (sflag) {
	sprintfl(mpx_filename, sizeof mpx_filename,
		 "/tmp/dev_%s", tail (MyTtyName));
	unlink(mpx_filename);	/* Remove the file first */
    }
    if ((mpx_fd = mpx (sflag ? mpx_filename : 0, 0666)) < 0) {
#ifndef UciFeatures
	fprintf (stderr, "Can't open the multiplexed file\n");
/*	RstDsp (); */	/* JCM - seems to cause infinite loop */
	exit (1);
#else
	quit (1, "Can't open mpx file.\n");
#endif
    }
  
    if (sflag) chmod(mpx_filename, 0666);

    mpxin -> ch_index = chan (mpx_fd);
    ioctl (mpx_fd, MXNBLK, 0);	/* set up non-blocking mode */
    if (mpxin -> ch_index == (index_t) -1) {
#ifndef UciFeatures
	fprintf (stderr, "Couldn't get a channel to mpx file\r\n");
	RstDsp ();
	exit (1);
#else
	quit (1, "Couldn't get a channel to mpx file.\n");
#endif
    }
    kbd_fd = extract (mpxin -> ch_index, mpx_fd);
    connect (0, kbd_fd, 0);
#else
    mpxin -> ch_index = 0;
    sel_ichans = 1;
    ioctl (0, TIOCGETP, &mysgttyb);
    mysgttyb.sg_flags = EVENP | ODDP;
    ioctl (0, TIOCGETC, &mytchars);
    ioctl (0, TIOCGLTC, &myltchars);
    ioctl (0, TIOCLGET, &mylmode);
#endif
    mpxin -> ch_ptr = NULL;
    mpxin -> ch_count = 0;
#endif
    sigset (SIGCHLD, child_sig);
#ifdef subprocesses
#ifdef	TTYconnect
    InitTtyAccept ();
#endif

    DefStrVar ("MPX-process", "");
    MPX_process = NextInitVarDesc[-1];

    ProcessBufferSize = 10000;	/* # of chars in buffer before truncating */
    DefIntVar ("process-buffer-size", &ProcessBufferSize);

    PopUpUnexpected = 1;
    DefIntVar ("pop-up-process-windows", &PopUpUnexpected);

    EmacsShare = 1;
    DefIntVar ("emacs-share", &EmacsShare);

    defproc (StartProcess, "start-process");
    defproc (StartFilteredProcess, "start-filtered-process");
    defproc (InsertFilter, "insert-filter");
    defproc (ResetFilter, "reset-filter");
    defproc (ProcessFilterName, "process-filter-name");
    defproc (RegionToProcess, "region-to-process");
    defproc (StringToProcess, "string-to-process");
    defproc (IntProcess, "int-process");
    defproc (QuitProcess, "quit-process");
    defproc (KillProcess, "kill-process");
    defproc (StopProcess, "stop-process");
    defproc (ContProcess, "continue-process");
    defproc (IntPLeader, "int-process-leader");
    defproc (QuitPLeader, "quit-process-leader");
    defproc (KillPLeader, "kill-process-leader");
    defproc (StopPLeader, "stop-process-leader");
    defproc (ContPLeader, "continue-process-leader");
    defproc (SignalToProcess, "signal-to-process");
    defproc (SignalToPLeader, "signal-to-process-leader");
    defproc (EOTProcess, "eot-process");
    defproc (CurrentProcess, "current-process");
    defproc (ProcessStatus, "process-status");
    defproc (ChangeCurrentProcess, "change-current-process");
    defproc (ActiveProcess, "active-process");
    defproc (ProcessID, "process-id");
    defproc (PLeaderID, "process-leader-id");
    defproc (ProcessOutput, "process-output");
    defproc (ListProcesses, "list-processes");
    defproc (SetUnexpectedProc, "unexpected-process-filter");
    defproc (InsertSentinel, "insert-sentinel");
    defproc (ResetSentinel, "reset-sentinel");
    defproc (ProcessSentinelName, "process-sentinel-name");
    defproc (SetUnexpectedSent, "unexpected-process-sentinel");
#ifdef	UtahFeatures
    defproc (AwaitProcessInput, "await-process-input");
#endif
#endif
}

QuitMpx () {
#ifdef subprocesses
#ifdef MPXcode
    if (sflag) unlink (mpx_filename);
#else
#ifdef	TTYconnect
    QuitTtyAccept ();
#endif
#endif
#endif
}

#ifdef MPXcode
static char tempname[50];
#endif

SuspendMpx () {
#ifdef subprocesses
#ifdef MPXcode
    if (sflag) {		/* must save mpx file... */
	sprintfl (tempname, sizeof tempname, "/tmp/Emacs-Mpx%d", getpid ());
	link (mpx_filename, tempname);
	unlink (mpx_filename);
    }
    close (kbd_fd);
    detach (mpxin -> ch_index, mpx_fd);/* dis-connect() tty */
    mpxin -> ch_index = chan (mpx_fd);
    if (mpxin -> ch_index == (index_t) -1) {
#ifndef UciFeatures
	kill_processes ();
	fprintf (stderr,
	"Urk!  Couldn't get recreate channel for mpxin!  Byebye\r\n");
	exit (1);
#else
	quit (1, "Couldn't recreate a channel for mpxin.\n");
#endif
    }
    mpxin -> ch_ptr = NULL;
    mpxin -> ch_count = 0;
#else
#ifdef	TTYconnect
    SuspendTtyAccept ();
#endif
#endif
#endif
}

ResumeMpx () {
#ifdef subprocesses
#ifdef MPXcode
    if (sflag) {
	link (tempname, mpx_filename);
	unlink (tempname);
    }
    kbd_fd = extract (mpxin -> ch_index, mpx_fd);
    connect (0, kbd_fd, 0);
#else
#ifdef	TTYconnect
    ResumeTtyAccept ();
#endif
#endif
#endif
}
