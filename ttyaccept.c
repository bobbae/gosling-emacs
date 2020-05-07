/* ttyaccept.c - support unexpected processes in 4.1c bsd Emacs */

#include "config.h"

#ifdef	TTYconnect

#include <stdio.h>
#include <signal.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include "buffer.h"
#include "mlisp.h"
#include "mchan.h"

char  *malloc();
#ifdef titan
typedef long * waddr_t;
#endif

/* Since mpxio isn't around in 4.1a bsd, unexpected processes don't have
   an mpx file to use attach() on to get Emacs' attention.  This module
   tries to implement an alternate way for unexpected processes to work.
   The basic idea is that we set-up a passive TCP socket and wait for a
   connect().  We then associate the resulting fd with a process buffer
   and we're off.  When the connection closes, the process should be
   deleted.  Unix is really nice to us, as it will multiplex any number of
   fd:s over a single port.  The u_short port word is divided up in
   this fashion:

        15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
	|------| -- |----------|----------------------|
          zero   on     zero 	    minor (st_rdev)
			   	       of stdin

 */

/* Modified 27 June 1983 by Chris Kent for 4.1c */
/* and again Mar 14, 84 by Jud Leonard for 4.2 */

#define	IPPORT_EMACS	010000
#define	NOTOK		(-1)

extern int  sel_ichans;
extern int  EmacsShare;
extern int  PopUpUnexpected;
extern char *MyTtyName;
extern struct BoundName *UnexpectedProc;
extern struct BoundName *UnexpectedSent;

extern int  errno;
extern int  sys_nerr;
extern char *sys_errlist[];

static int  tty_port;

static int  sd;
static struct sockaddr_in   tty_socket;
static struct sockaddr_in   unx_socket;

static char tty_handle[BUFSIZ];

#ifdef	mtr
static  FILE * log_file;
#endif

char   *raddr ();

AttachSocket (mask)
int mask;
{
    int     enabled = EmacsShare && sflag;
    struct sockaddr_in *usock = &unx_socket;
    int	s, usocklen;

    if (!(mask & (1 << sd)))
	return;

    usocklen = sizeof(*usock);
    if ((s = accept (sd, usock, &usocklen)) == NOTOK) {
	switch (errno) {
	    default: 
		message ("unable to complete socket: %s",
			errno > 0 && errno <= sys_nerr ? sys_errlist[errno]
			: "unknown reason");

	    case ECONNRESET: 	/* we weren't quick enough... */
	    case EISCONN:	/* shouldn't happen */
	    case EWOULDBLOCK:	/* select lied to us */
#ifdef	mtr
		if (log_file)
		    if (errno > 0 && errno <= sys_nerr)
			fprintf (log_file, "unable to complete socket: %s\n",
				sys_errlist[errno]);
		    else
			fprintf (log_file, "unable to complete socket: %d\n",
				errno);
#endif
		break;
	}
	return;
    }

#if vax
    usock -> sin_port = ntohs (usock -> sin_port);
#endif

    sel_ichans |= (1 << s);

    if (!enabled) {		/* we don't want it now */
	sel_ichans &= ~(1 << s);
	close (s);
	return;
    }

#ifdef	mtr
    if (log_file) {
	struct sockaddr_in *tsock = &tty_socket;
	socketaddr (sd, tsock);
	fprintf (log_file,
		"socket completed from port_%s:0%o to port_%s:0%o\n",
		raddr ((int) tsock -> sin_addr.s_addr), tsock -> sin_port,
		raddr ((int) usock -> sin_addr.s_addr), usock -> sin_port);
    }
#endif

    if (usock -> sin_family != AF_INET) {/* wrong family */
	sel_ichans &= ~(1 << s);
	close (s);
    }
    else
	BuildIt (s);

}

static
BuildIt (s) {
    int     i;
    char    name[50],
            port[40];
    struct in_addr *addr = &unx_socket.sin_addr;
    struct buffer  *old = bf_cur;
    struct process_blk *p;
    extern int child_changed;

    sighold (SIGCHLD);

    sprintf (port, "port_%s:%o",
	    raddr ((int) addr -> s_addr), unx_socket.sin_port);
    for (i = 2, strcpy (name, port); find_process (name); i++)
	sprintf (name, "%s<%d>", port, i);

    p = (struct process_blk *) malloc ((unsigned) sizeof *p);
    if (p == NULL) {
	sigrelse (SIGCHLD);
	message ("out of memory");
	sel_ichans &= ~(1 << s);
	close (s);
	sd = NOTOK;
	return;
    }

    SetBfn (name);
    if (PopUpUnexpected)
    {
	WindowOn (bf_cur);
	DoDsp(1);
    }
    bf_modified = 0;
    bf_cur -> b_mode.md_NeedsCheckpointing = 0;

    p -> next_process = process_list;
    process_list = p;
    p -> p_name = savestr (name);
    p -> p_pid = p -> p_gid = -1;
    p -> p_flag = RUNNING | CHANGED; child_changed++;
    p -> p_chan.ch_index = s;
    p -> p_chan.ch_outrec.index = s;
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

/*  */


/* When a connection closes, any write()s to it will cause a SIGPIPE to
   be given to us.  By ignoring the signal, write() will return NOTOK
   after setting errno = EPIPE.  The relevant routines in mchan should
   test for this after a losing write().  In reality though, when the
   peer closes the connection, we'll find out via select() and an error
   read().  Hence, fill_chan() in mchan.c will handle things for us.
 */


InitTtyAccept () {
    int     fd;
    char   *mp,
           *tp;
    struct stat st;

    sigset (SIGPIPE, SIG_IGN);

    if (fstat (0, &st) == NOTOK)
	quit (1, "fstat failed on stdin\n");
    tty_port = IPPORT_EMACS | minor (st.st_rdev);

    for (mp = tp = MyTtyName; *mp;)
	if (*mp++ == '/' && *mp)
	    tp = mp;

    sprintfl (tty_handle, sizeof tty_handle, "/tmp/dev_%s", tp);
    unlink (tty_handle);
    if ((fd = creat (tty_handle, 0000)) == NOTOK)
	quit (1, "unable to create %s\n", tty_handle);
    close (fd);

#ifdef	mtr
    if (access ("/tmp/emacs.tcpdebug", 6) == NOTOK)
	unlink ("/tmp/emacs.tcpdebug");
    if ((log_file = fopen ("/tmp/emacs.tcpdebug", "a")) != NULL) {
	setbuf (log_file, NULL);
	fprintf (log_file, "tty_handle=\"%s\" tty_port=0%o\n",
		tty_handle, tty_port);
	chmod ("/tmp/emacs.tcpdebug", 0666);
    }
#endif

    StartTtyAccept();
}

static
StartTtyAccept()
{
    struct sockaddr_in *tsock = &tty_socket;
    int block = 1;

    sd = socket(AF_INET, SOCK_STREAM, 0);
    if(sd < 0)
	switch (errno) {
	    default:		/* perhaps do something else here??? */
		message ("unable to start socket: %s",
			errno > 0 && errno <= sys_nerr ? sys_errlist[errno]
			: "unknown reason");

		EmacsShare = 0;	/* enough of this nonsense */
#ifdef	mtr
		if (log_file)
		    if (errno > 0 && errno <= sys_nerr)
			fprintf (log_file, "unable to start socket: %s\n",
				sys_errlist[errno]);
		    else
			fprintf (log_file, "unable to start socket: %d\n",
				errno);
#endif
		return;
	}/*esac*/

    tsock -> sin_family = AF_INET;
    tsock -> sin_port = tty_port;
#ifdef vax
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
		EmacsShare = 0;	/* enough of this nonsense */
#ifdef	mtr
		if (log_file)
		    if (errno > 0 && errno <= sys_nerr)
			fprintf (log_file, "unable to bind socket: %s\n",
				sys_errlist[errno]);
		    else
			fprintf (log_file, "unable to bind socket: %d\n",
				errno);
#endif
		return;
	}/*esac*/
#ifdef vax
    tsock -> sin_port = ntohs (tsock -> sin_port);
#endif

    listen(sd, 5);
    ioctl(sd, FIOCLEX, (waddr_t)0);
    sel_ichans |= 1 << sd;
}

QuitTtyAccept () {
    unlink (tty_handle);
#ifdef	mtr
    if (log_file)
	fclose (log_file);
#endif
}

SuspendTtyAccept () {
    unlink (tty_handle);

    sel_ichans &= ~(1 << sd);
    close (sd);
}


ResumeTtyAccept () {
    int     fd;

    unlink (tty_handle);
    if ((fd = creat (tty_handle, 0000)) == NOTOK)
	quit (1, "unable to re-create %s\n", tty_handle);
    close (fd);

    StartTtyAccept();
}
#endif	TTYconnect
