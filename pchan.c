/* pchan.c - PTYio handler for multiple processes */

/* Original changes for 4.2bsd (c) 1982 William N. Joy and Regents of UC */

/* More changes for 4.1aBSD by Spencer Thomas of Utah-Cs */

/* Still more changes for 4.1aBSD by Marshall Rose of UCI */

/* Changes for 4.1cBSD by Chris Kent of Dec-Wrl */

#include "config.h"
#ifndef	MPXcode			/* the entire file!!! */

#ifndef	subprocesses
#undef	TTYconnect
#endif	not subprocesses

#include <stdio.h>
#include <signal.h>
#include <errno.h>
#include <wait.h>
#include <sgtty.h>
#ifdef	BSD41c
#include <time.h>
#endif	BSD41c
#include <sys/types.h>
#include <sys/stat.h>
#ifdef	TTYconnect
#include <sys/socket.h>
#ifndef	BSD41c
#include <net/in.h>
#else	not BSD41c
#include <netinet/in.h>
#endif	not BSD41c
#endif	TTYconnect
#include "window.h"
#include "keyboard.h"
#include "buffer.h"
#include "mlisp.h"
#include "macros.h"
#include "mchan.h"


#ifdef	subprocesses

extern	int	child_changed;	/* all these from schan.c */
extern	int	PopUpUnexpected;
extern	int	EmacsShare;
extern	struct	BoundName	*UnexpectedProc;
extern	struct	BoundName	*UnexpectedSent;
extern	struct	process_blk	*GetBufProc ();
extern	struct	process_blk	*find_process ();

extern int  errno;
extern int  sys_nerr;
extern char *sys_errlist[];

static	int     sel_ichans;		/* input channels */
static	int     sel_ochans;		/* blocked output channels */

static	struct sgttyb mysgttyb;
static	struct tchars mytchars;
static	struct ltchars myltchars;
static	int mylmode;

#ifdef	TTYconnect
#ifndef	BSD41c
#define	SO_OPTIONS	(SO_ACCEPTCONN | SO_DONTLINGER | SO_KEEPALIVE)
#else	not BSD41c
#undef	TTYD
#endif	not BSD41c
#ifndef	TTYD
#define	IPPORT_EMACS	010000
#endif	not TTYD

#ifndef	BSD41c
#define	htons(x)	(((x << 8) & 0xff00) | ((x >> 8) & 0xff))
#define	ntohs(x)	(((x << 8) & 0xff00) | ((x >> 8) & 0xff))
#endif	not BSD41c

#define	NOTOK		(-1)
#define	OK		0

static int  tty_port;
#ifdef	TTYD
static char myhost[BUFSIZ];
static char myport[BUFSIZ];
#endif	TTYD

static int  sd;
static struct sockaddr_in   tty_socket;
static struct sockaddr_in   unx_socket;

#ifdef	mtr
static  FILE * log_file;
#endif

char   *RAddr ();
#endif	TTYconnect


/* Find a free pty and open it. */

static	char *pty(ptyv)
int *ptyv;
{
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
				ioctl(*ptyv, FIONBIO, &on);
				name[strlen("/dev/")] = 't';
				return (name);
			}
		}
		name[strlen("/dev/pty")]++;
	}
}

/* Start up a subprocess with its standard input and output connected to 
   a channel on a pty.  Also set its process group so we can kill it
   and set up its process block.  The process block is assumed to be pointed
   to by current_process. */

create_process (command)
register char  *command;
{
    index_t channel;
    int     pgrp,
	    len,
	    ld;
    char   *ptyname;
    register	pid;
    extern char *shell ();
    extern UseCshOptionF;
    extern UseUsersShell;

    ptyname = pty (&channel);
    if (ptyname == 0) {
	error ("Can't get a pty");
	return (-1);
    }
    sel_ichans |= 1<<channel;

    sighold (SIGCHLD);
    if ((pid = vfork ()) < 0) {
	error ("Fork failed");
	close (channel);
	sel_ichans &= ~(1<<channel);
	return (-1);
    }

    if (pid == 0) {
#ifdef	ce
	fprintf (err_file, "Creating pid %d on %s\n", getpid (), ptyname);
#endif
	close (channel);
	sigrelse (SIGCHLD);
	setpgrp (0, getpid ());
	sigsys (SIGINT, SIG_DFL);
	sigsys (SIGQUIT, SIG_DFL);
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
	setpgrp (0, pgrp);
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
	len = UseUsersShell;
	UseUsersShell = 1;
	ld = strcmp(shell(), "/bin/csh") ? OTTYDISC : NTTYDISC;
	ioctl (0, TIOCSETD, &ld);
	UseUsersShell = len;
	execlp (shell (), shell (),
		UseUsersShell && UseCshOptionF ? "-cf" : "-c", command, 0);
	write (1, "Couldn't exec the shell\n", 24);
	_exit (1);
    }

    current_process -> p_name = command;
    current_process -> p_pid = pid;
    current_process -> p_gid = pid;
    current_process -> p_flag = RUNNING | CHANGED;
    child_changed++;
    current_process -> p_chan.ch_index = channel;
    current_process -> p_chan.ch_ptr = NULL;
    current_process -> p_chan.ch_count = 0;
    current_process -> p_chan.ch_outrec.index = channel;
    current_process -> p_chan.ch_outrec.count = 0;
    current_process -> p_chan.ch_outrec.ccount = 0;
    return 0;
}
#endif	subprocesses


/* This corresponds to the filbuf routine used by getchar.  This handles all 
   the input from a pty.  Input coming from the terminal is sent back
   to getchar() in the same manner as filbuf.

   With pty:s, when the parent process of a pty exits we are notified,
   just as we would be with any of our other children.  After the process
   exits, select() will indicate that we can read the channel.  When we
   do this, read() returns 0.  Upon receiving this, we close the channel.

   For unexpected processes, when the peer closes the connection, select()
   will indicate that we can read the channel.  When we do this, read()
   returns -1 with errno = ECONNRESET.  Since we never get notified of
   this via wait3(), we must explictly mark the process as having exited.
   (This corresponds to the action performed when a M_CLOSE is received
   with the MPXio version of Emacs -- see mchan.c)
 */

static char cbuffer[BUFSIZ];	/* used for reading mpx file */
static int  mpx_count;		/* number of unprocessed characters in
				   buffer */

/* ARGSUSED */
#ifdef	ECHOKEYS
fill_chan (chan, alrmtime)
#else	ECHOKEYS
fill_chan (chan)
#endif	ECHOKEYS
register struct channel_blk *chan;
{
    int ichans, ochans, cc;
    register struct channel_blk *this_chan;
    register struct process_blk *p;
#ifdef	ECHOKEYS
#ifdef	BSD41c
    struct timeval	timeout;
#endif	BSD41c

    if (alrmtime <= 0 || alrmtime > 100000000)
	alrmtime = 100000;
#ifndef	BSD41c
    alrmtime *= 1000;			/* convert to millisec */
#endif	not BSD41c
#endif	ECHOKEYS

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
#ifdef	BSD41c
	timeout.tv_sec = 0; timeout.tv_usec = 0;
	if (select(32, &c_ichans, 0, 0, &timeout) <= 0)	/* if none waiting */
#else	BSD41c
	if (select(32, &c_ichans, 0, 0) <= 0)	/* if none waiting */
#endif	BSD41c
	{
	    change_msgs ();
	    child_changed = 0;
	}
    }

#ifdef	ECHOKEYS
#ifdef	BSD41c
    timeout.tv_sec = alrmtime; timeout.tv_usec = 0;
    if ((cc = select(32, &ichans, &ochans, 0, &timeout)) < 0)
#else	BSD41c
    if ((cc = select(32, &ichans, &ochans, alrmtime)) < 0)
#endif	BSD41c
	goto readloop;			/* try again */
    else
	if (cc == 0) {
	    EchoThem (1);
#ifndef	BSD41c
	    alrmtime = 10000000;
#else	not BSD41c
	    alrmtime = 10000;
#endif	not BSD41c
	}
#else	ECHOKEYS
#ifdef	BSD41c
    timeout.tv_sec = 100000; timeout.tv_usec = 0;
    if (select(32, &ichans, &ochans, 0, &timeout) < 0)
#else	BSD41c
    if (select(32, &ichans, &ochans, 1000000) < 0)
#endif	BSD41c
	goto readloop;			/* try again */
#endif	ECHOKEYS

#ifdef	TTYconnect
    AttachSocket (ichans);		/* check for a new socket */
#endif	TTYconnect

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
#ifdef	ce
		fprintf (err_file, "%s read from %s on channel %d errno=%d\n",
			cc == 0 ? "null" : "error", p -> p_name,
			this_chan -> ch_index, cc < 0 ? errno : 0);
#endif
		sel_ichans &= ~(1 << this_chan -> ch_index); /* disconnect */
		sel_ochans &= ~(1 << this_chan -> ch_index); /* disconnect */
		close (this_chan->ch_index);
#ifdef	TTYconnect
		if (p -> p_pid == -1) {/* peer dropped it */
		    p -> p_flag = EXITED | CHANGED;
		    p -> p_reason = 0;
		    child_changed++;
		}
#endif	TTYconnect
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
    if (child_changed) {
	change_msgs ();
	child_changed = 0;
    }

    if (chan != NULL)
	goto readloop;

    return 0;
}


#ifdef	subprocesses

/* Send any pending output as indicated in the process block to the 
   appropriate channel. */

send_chan (process)
register struct process_blk *process;
{
    register struct wh *output;

    output = &process -> p_chan.ch_outrec;
    if (output -> count == 0 && output -> ccount == 0) {
	/* error ("Null output"); */
	return 0;		/* No output to be done */
    }
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
    return 0;			/* ACT 8-Sep-1982 */
}


/* Kill off all active processes: done only to exit when user really
   insists. */

kill_processes () {
    register struct process_blk *p;

    for (p = process_list; p != NULL; p = p -> next_process) {
	if (active_process (p)) {
	    ioctl (p -> p_chan.ch_index, TIOCGPGRP, &(p -> p_gid));
	    if (p -> p_gid != -1)
		killpg (p -> p_gid, SIGKILL);
	    if (p -> p_pid != -1)
		killpg (p -> p_pid, SIGKILL);
	}
    }
}


/* Send an signal to the specified process group.  Goes to leader
   (process which started whole mess) iff "leader". */

sig_process (signal, leader) register   leader; {
    register struct process_blk *process;
    struct tchars   mytchars;
    struct ltchars  myltchars;

    if ((process = GetBufProc ()) == NULL) {
	error ("Not a process");
	return 0;
    }

#ifdef	ce
    fprintf (err_file, "Sending signal %d to proc (%d, %d), leader=%d\n",
	signal, process -> p_pid, process -> p_gid, leader);
#endif

/* We must update the process flag explicitly in the case of continuing a 
   process since no signal will come back */
    if (signal == SIGCONT) {
	sighold (SIGCHLD);
	process -> p_flag =
	    (process -> p_flag & ~STOPPED) | RUNNING | CHANGED;
	child_changed++;
	sigrelse (SIGCHLD);
    }

    if (!leader)
	switch (signal) {
	    case SIGINT: 
		mytchars.t_intrc = -1;
		ioctl (process -> p_chan.ch_index, TIOCGETC, &mytchars);
		if (mytchars.t_intrc == -1)
		    break;
		return send_char (process, mytchars.t_intrc);

	    case SIGQUIT: 
		mytchars.t_quitc = -1;
		ioctl (process -> p_chan.ch_index, TIOCGETC, &mytchars);
		if (mytchars.t_quitc == -1)
		    break;
		return send_char (process, mytchars.t_quitc);

	    case SIGTSTP: 
		myltchars.t_suspc = -1;
		ioctl (process -> p_chan.ch_index, TIOCGLTC, &myltchars);
		if (myltchars.t_suspc == -1)
		    break;
		return send_char (process, myltchars.t_suspc);
	}
    ioctl (process -> p_chan.ch_index, TIOCGPGRP, &(process -> p_gid));

    leader = leader ? process -> p_pid : process -> p_gid;

#ifndef	TTYconnect
    if (leader != -1)
	killpg (leader, signal);
#else	not TTYconnect
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
#endif	not TTYconnect
    return 0;
}


/* Send an EOT to a process. */

EOTProcess () {
    register struct process_blk *process;
    struct tchars   mytchars;

    if ((process = GetBufProc ()) == NULL) {
	error ("Not a process");
	return (0);
    }

    mytchars.t_eofc = -1;
    ioctl (process -> p_chan.ch_index, TIOCGETC, &mytchars);
    if (mytchars.t_eofc == -1) {
	error ("Unable to determine EOT");
	return 0;
    }
    return send_char (process, mytchars.t_eofc);
}


/* Send a special character to a process. */

static send_char (process, c)
register struct process_blk *process;
char c;
{
    register struct wh *output = &process -> p_chan.ch_outrec;

    if (output -> count || output -> ccount)
	error ("Overwriting on blocked channel");

    output -> index = process -> p_chan.ch_index;
    output -> ccount = 0;
    output -> count = 1;
    output -> data = &c;
    send_chan (process);
    return 0;
}


/* Find the process-id of a process (or parent process). */

PID (leader) {
    register char  *p_name = getstr ("Process name: ");
    register struct process_blk *process;

    MLvalue -> exp_type = IsInteger;
    process = find_process (p_name);
    if (process == NULL)
	MLvalue -> exp_int = 0;
    else {
	ioctl (process -> p_chan.ch_index, TIOCGPGRP, &(process -> p_gid));
	MLvalue -> exp_int = leader ? process -> p_pid : process -> p_gid;
    }
    return 0;
}
#endif	subprocesses


/* Initialize the PTYio system. */

/* When a connection closes, any write()s to it will cause a SIGPIPE to
   be given to us.  By ignoring the signal, write() will return NOTOK
   after setting errno = EPIPE.  The relevant routines should test for
   this after a losing write().  In reality though, when the peer closes
   the connection, we'll find out via select() and an error read().
   Hence, fill_chan() will handle things for us. */

InitProcesses () {
#ifdef	TTYconnect
#ifndef	TTYD
    struct stat st;
#endif	not TTYD
#endif	TTYconnect

    mpxin -> ch_index = 0;
    mpxin -> ch_ptr = NULL;
    mpxin -> ch_count = 0;

#ifdef	subprocesses
    sel_ichans = 1 << 0;	/* stdin */

    ioctl (0, TIOCGETP, &mysgttyb);
    mysgttyb.sg_flags = EVENP | ODDP;
    ioctl (0, TIOCGETC, &mytchars);
    ioctl (0, TIOCGLTC, &myltchars);
    ioctl (0, TIOCLGET, &mylmode);

#ifdef	TTYconnect
    sigset (SIGPIPE, SIG_IGN);

#ifndef	TTYD
    if (fstat (0, &st) == NOTOK)
	quit (1, "fstat failed on stdin\n");
    tty_port = IPPORT_EMACS | minor (st.st_rdev);
#else	not TTYD
    gethostname (myhost, sizeof myhost);
    tact ("push", NULL);
#endif	not TTYD

#ifdef	mtr
    if (access ("/tmp/emacs.tcpdebug", 6) == NOTOK)
	unlink ("/tmp/emacs.tcpdebug");
    if ((log_file = fopen ("/tmp/emacs.tcpdebug", "a")) != NULL) {
	setbuf (log_file, NULL);
	fprintf (log_file, "tty_port=%d\n", tty_port);
#ifdef	TTYD
	fprintf (log_file, "myhost=%s\n", myhost);
#endif	TTYD
	chmod ("/tmp/emacs.tcpdebug", 0666);
    }
#endif

#ifndef	BSD41c
    sd = NOTOK;
#else	not BSD41c
    StartTtyAccept ();
#endif	not BSD41c
#endif	TTYconnect
#endif	subprocesses
}

/* named this way for historical reasons... */

QuitMpx () {
#ifdef	TTYconnect
#ifdef	TTYD
    tact ("pop", NULL);
#endif	TTYD
#ifdef	mtr
    if (log_file)
	fclose (log_file);
#endif
#endif	TTYconnect
}

/* This isn't quite correct, the close() should do it, but Unix doesn't
   fully cooperate with us -- it sometimes will tell other processes that
   the port is still open for business. */

SuspendMpx () {
#ifdef	TTYconnect
#ifdef	TTYD
    tact ("pop", NULL);
#endif	TTYD
#ifndef	BSD41c
#ifndef	TTYD
    if (sd != NOTOK) {
	sel_ichans &= ~(1 << sd);
	close (sd);
	sd = NOTOK;
    }
#endif	not TTYD
#else	not BSD41c
    sel_ichans &= ~(1 << sd);
    close (sd);
#endif	not BSD41c
#endif	TTYconnect
}

ResumeMpx () {
#ifdef	TTYconnect
#ifdef	TTYD
    tact ("push", NULL);
    if (sd != NOTOK) {
	int     i;
	struct sockaddr_in *tsock = &tty_socket;

	if ((i = socketaddr (sd, tsock)) != NOTOK) {
#ifdef	vax
	    tsock -> sin_port = htons (tsock -> sin_port);
#endif
	    i = tact ("port", tsock);
	}
	if (i == NOTOK) {
	    sel_ichans &= ~(1 << sd);
	    close (sd);
	    sd = NOTOK;
	}
    }
#endif	TTYD
#ifdef	BSD41c
    StartTtyAccept ();
#endif	BSD41c
    if (EmacsShare == NOTOK)	/* retry from error */
	EmacsShare = 1;
#endif	TTYconnect
}


#ifdef	TTYconnect

static	AttachSocket (mask)
int mask;
{
    int     enabled = (EmacsShare > 0) && sflag;
    struct sockaddr_in *usock = &unx_socket;
#ifdef	BSD41c
    int	    s, usocklen;
#endif	BSD41c

#ifndef	BSD41c
    if (sd == NOTOK) {
	if (enabled)
	    NewSocket ();
	return;
    }
#endif	not BSD41c

    if (!(mask & (1 << sd)))
	return;

#ifndef	BSD41c
    if (accept (sd, usock) == NOTOK) {
#else	not BSD41c
    usocklen = sizeof (*usock);
    if ((s = accept (sd, usock, &usocklen)) == NOTOK) {
#endif	not BSD41c
	switch (errno) {
	    default: 
		message ("unable to complete socket: %s",
			errno > 0 && errno <= sys_nerr ? sys_errlist[errno]
			: "unknown reason");
		EmacsShare = NOTOK;

	    case ECONNRESET: 	/* we were not quick enough... */
	    case EISCONN:	/* should not happen */
	    case EWOULDBLOCK:	/* select lied to us */
#ifdef	mtr
		if (log_file)
		    fprintf (log_file, "unable to complete socket: %d\n",
			    errno);
#endif
		break;
	}
#ifndef	BSD41c
	sel_ichans &= ~(1 << sd);
	close (sd);
	sd = NOTOK;
	if (enabled)
	    NewSocket ();
#endif	not BSD41c
	return;
    }

#if vax
    usock -> sin_port = ntohs (usock -> sin_port);
#endif

#ifdef	BSD41c
    sel_ichans |= (1 << s);
#endif	BSD41c
    if (!enabled) {		/* we do not want it now */
#ifndef	BSD41c
	sel_ichans &= ~(1 << sd);
	close (sd);
	sd = NOTOK;
#else	not BSD41c
	sel_ichans &= ~(1 << s);
	close (s);
#endif	not BSD41c
	return;
    }

#ifdef	mtr
    if (log_file) {
	struct sockaddr_in *tsock = &tty_socket;
	socketaddr (sd, tsock);
#ifdef	vax
	tsock -> sin_port = htons (tsock -> sin_port);
#endif
	fprintf (log_file,
		"socket completed from port_%s:%d to port_%s:%d\n",
		RAddr (&(tsock -> sin_addr)), tsock -> sin_port,
		RAddr (&(usock -> sin_addr)), usock -> sin_port);
    }
#endif

    if (usock -> sin_family != AF_INET) {/* wrong family */
#ifndef	BSD41c
	sel_ichans &= ~(1 << sd);
	close (sd);
	sd = NOTOK;
#else	not BSD41c
	sel_ichans &= ~(1 << s);
	close (s);
#endif	not BSD41c
    }
    else
#ifndef	BSD41c
	BuildIt ();
#else	not BSD41c
	BuildIt (s);
#endif	not BSD41c

#ifndef	BSD41c
    NewSocket ();
#endif	not BSD41c
}


#ifndef	BSD41c

static  NewSocket () {
    struct sockaddr_in *tsock = &tty_socket;

    if (!sflag)
	return;

    if ((sd = getport (tsock, SO_OPTIONS)) == NOTOK)
	switch (errno) {
	    default:		/* perhaps do something else here??? */
		message ("unable to start socket: %s",
			errno > 0 && errno <= sys_nerr ? sys_errlist[errno]
			: "unknown reason");

#ifndef	TTYD
	    case EADDRINUSE:	/* another Emacs on this tty */
	    case EADDRNOTAVAIL:	/* should not happen */
#endif	not TTYD
		EmacsShare = NOTOK;/* enough of this nonsense */
#ifdef	mtr
		if (log_file)
		    fprintf (log_file, "unable to start socket: %d\n",
			    errno);
#endif
		return;
	}

    sel_ichans |= 1 << sd;
}

static int  getport (tsock, options)
struct sockaddr_in  *tsock;
unsigned    options;
{
    int     block = 1;
    int     fd;
#ifdef	TTYD
    int     port;
#endif	TTYD

    tsock -> sin_family = AF_INET;
#ifndef	TTYD
    tsock -> sin_port = tty_port;
#ifdef	vax
    tsock -> sin_port = htons (tsock -> sin_port);
#endif
#endif	not TTYD
    tsock -> sin_addr.s_addr = (u_long) INADDR_ANY;

#ifndef	TTYD
    if ((fd = socket (SOCK_STREAM, NULL, tsock, options)) == NOTOK)
	return NOTOK;
#ifdef	vax
    tsock -> sin_port = ntohs (tsock -> sin_port);
#endif
#else	not TTYD
    for (port = IPPORT_RESERVED + 1;; port++) {
	tsock -> sin_port = port;
#ifdef	vax
	tsock -> sin_port = htons (tsock -> sin_port);
#endif

	if ((fd = socket (SOCK_STREAM, NULL, tsock, options)) == NOTOK)
	    switch (errno) {
		case EADDRINUSE:/* to be expected */
		case EADDRNOTAVAIL:/* should not happen */
		    continue;

		default: 
		    return NOTOK;
	    }
#ifdef	vax
	tsock -> sin_port = ntohs (tsock -> sin_port);
#endif
	break;
    }
    if (tact ("port", tsock) == NOTOK) {
	close (fd);
	return NOTOK;
    }
#endif	not TTYD

    ioctl (fd, FIONBIO, &block);
    return fd;
}
#else	not BSD41c

static	StartTtyAccept()
{
    struct sockaddr_in *tsock = &tty_socket;
    int block = 1;

    if (!sflag) {
	sd = NOTOK;
	return;
    }

    sd = socket(AF_INET, SOCK_STREAM, 0);
    if(sd < 0)
	switch (errno) {
	    default:		/* perhaps do something else here??? */
		message ("unable to start socket: %s",
			errno > 0 && errno <= sys_nerr ? sys_errlist[errno]
			: "unknown reason");

		EmacsShare = NOTOK;/* enough of this nonsense */
#ifdef	mtr
		if (log_file)
		    fprintf (log_file, "unable to start socket: %d\n",
			    errno);
#endif
		return;
	}/*esac*/

    tsock -> sin_family = AF_INET;
    tsock -> sin_port = tty_port;
#ifdef	vax
    tsock -> sin_port = htons (tsock -> sin_port);
#endif
    tsock -> sin_addr.s_addr = (u_long) INADDR_ANY;

    setsockopt(sd, SOL_SOCKET, SO_DONTLINGER, (char *) 0, 0);
    setsockopt(sd, SOL_SOCKET, SO_KEEPALIVE, (char *) 0, 0);
    setsockopt(sd, SOL_SOCKET, SO_REUSEADDR, (char *) 0, 0);
    if(bind(sd, tsock, sizeof(*tsock)) < 0)
	switch (errno) {
	    default:		/* perhaps do something else here??? */
		message ("unable to bind socket: %s",
			errno > 0 && errno <= sys_nerr ? sys_errlist[errno]
			: "unknown reason");

	    case EADDRINUSE:	/* another Emacs on this tty */
	    case EADDRNOTAVAIL:	/* should not happen */
		EmacsShare = NOTOK; /* enough of this nonsense */
#ifdef	mtr
		if (log_file)
		    fprintf (log_file, "unable to bind socket: %d\n",
			    errno);
#endif
		return;
	}/*esac*/
#ifdef	vax
    tsock -> sin_port = ntohs (tsock -> sin_port);
#endif

    listen(sd, 5);
    ioctl(sd, FIOCLEX, 0);
    sel_ichans |= 1 << sd;
}
#endif	not BSD41c

#ifndef	BSD41c
static  BuildIt () {
#else	not BSD41c
static	BuildIt (s) {
#endif	not BSD41c
    int     i;
    char    name[50],
            port[40];
    struct in_addr *addr = &unx_socket.sin_addr;
    struct buffer  *old = bf_cur;
    struct process_blk *p;

    sighold (SIGCHLD);

    sprintf (port, "port_%s/%d", RAddr (addr), unx_socket.sin_port);
    for (i = 2, strcpy (name, port); find_process (name); i++)
	sprintfl (name, sizeof name, "%s<%d>", port, i);

    p = (struct process_blk *) malloc ((unsigned) sizeof *p);
    if (p == NULL) {
	sigrelse (SIGCHLD);
	message ("out of memory");
#ifndef	BSD41c
	sel_ichans &= ~(1 << sd);
	close (sd);
#else	not BSD41c
	sel_ichans &= ~(1 << s);
	close (s);
#endif	not BSD41c
	sd = NOTOK;
	return;
    }

    SetBfn (name);
    if (PopUpUnexpected)
	WindowOn (bf_cur);
    bf_modified = 0;
    bf_cur -> b_mode.md_NeedsCheckpointing = 0;

#ifndef	BSD41c
    sel_ichans |= 1 << sd;	/* not really needed */
#endif	not BSD41c
    p -> next_process = process_list;
    process_list = p;
    p -> p_name = savestr (name);
    p -> p_pid = p -> p_gid = -1;
    p -> p_flag = RUNNING | CHANGED;
#ifndef	BSD41c
    p -> p_chan.ch_index = sd;
    p -> p_chan.ch_outrec.index = sd;
#else	not BSD41c
    p -> p_chan.ch_index = s;
    p -> p_chan.ch_outrec.index = s;
#endif	not BSD41c
    p -> p_chan.ch_outrec.count = p -> p_chan.ch_outrec.ccount = 0;
    p -> p_chan.ch_outrec.data = NULL;
    p -> p_chan.ch_ptr = NULL;
    p -> p_chan.ch_count = 0;
    p -> p_chan.ch_buffer = bf_cur;
    p -> p_chan.ch_proc = UnexpectedProc;
    p -> p_chan.ch_sent = UnexpectedSent;

    sigrelse (SIGCHLD);

    SetBfp (old);
    if (PopUpUnexpected)
	WindowOn (bf_cur);
}

#ifdef	TTYD

static int  tact (cmd, sock)
char   *cmd;
struct sockaddr_in *sock;
{
    extern int  subproc_id,
                child_sig ();
#ifdef	mtr
    if (log_file)
	fprintf (log_file, sock ? "tact(%s,%d)\n" : "tact(%s,NULL)\n",
		cmd, sock ? sock -> sin_port : 0);
#endif
    if (!sflag)
	return NOTOK;

    if (sock)
	if (tty_port == sock -> sin_port)
	    return;
	else
	    tty_port = sock -> sin_port;
    else
	tty_port = NOTOK;

    sigset (SIGCHLD, child_sig);/* may not be set yet */

    sighold (SIGCHLD);
    switch (subproc_id = vfork ()) {
	case NOTOK: 
	    return NOTOK;

	case OK: 
	    sigrelse (SIGCHLD);
	    setpgrp (0, getpid ());
	    sigsys (SIGINT, SIG_IGN);
	    sigsys (SIGQUIT, SIG_IGN);
	    sigsys (SIGTERM, SIG_IGN);
	    sigsys (SIGTSTP, SIG_IGN);
	    sigsys (SIGTTOU, SIG_IGN);
	    close (0);
	    open ("/dev/null", 0);
	    dup2 (0, 1);
	    if (sock) {
		sprintfl (myport, sizeof myport, "%d", sock -> sin_port);
		execlp ("tact", "tact", "-quiet", cmd, myhost, myport, NULL);
	    }
	    else
		execlp ("tact", "tact", "-quiet", cmd, NULL);
	    _exit (1);

	default: 
#ifdef	mtr
	    if (log_file)
		fprintf (log_file, "begin wait for %d\n", subproc_id);
#endif		
	    sigrelse (SIGCHLD);
	    for (sighold (SIGCHLD); subproc_id; sighold (SIGCHLD)) {
#ifdef	mtr
		if (log_file)
		    fprintf (log_file, "waiting for %d\n", subproc_id);
#endif		
		sigpause (SIGCHLD);
	    }
	    sigrelse (SIGCHLD);
	    return OK;
    }
}
#endif

static char	*RAddr(ip)
struct	in_addr	*ip;
{
    static char host[200];
    char   *p,
           *raddr ();

    if (p = raddr ((int) (ip -> s_addr))) {
	strcpy (host, p);
	free (p);
	return host;
    }

    sprintfl (host, sizeof host, "%d.%d.%d.%d",
	    ip -> S_un.S_un_b.s_b1, ip -> S_un.S_un_b.s_b2,
	    ip -> S_un.S_un_b.s_b3, ip -> S_un.S_un_b.s_b4);
    return host;
}
#endif	TTYconnect

#endif	not MPXcode
