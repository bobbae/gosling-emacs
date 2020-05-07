/* ttyconnect.c - connect to a tty under the control of 4.1c bsd Emacs */

#include <stdio.h>
#include <errno.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <netinet/in.h>


/* This is the other side of the unexpected process handling system for
   use with Gosling Emacs.  See the ttyaccept module for a terse
   description of what's going on.  This routine should be loaded in with
   a program that wants to access another terminal while the user of that
   terminal is running Emacs.

	usage:		char *ttyptr;
	
			if ((fd = ttyconnnect (ttyptr)) == -1) {
			    perror (ttyptr);
			    return;
			}

   If ttyconnect() doesn't return -1, then it returns a valid fd.  You can
   use this descriptor for read()s and write()s.  To close the connection,
   just close() it.  One warning: the file descriptor returned acts much
   like one returned from a pipe() call.  Hence lseek()s won't work, and
   if the other side closes the connection and you try and write to it,
   SIGPIPE is generated.
 */

/* Modified for 4.1cBSD 27 June 1983 by Chris Kent */

#define	IPPORT_EMACS	010000

#define	ATIME		((unsigned) 20)

#define	NOTOK		(-1)

/*  */

extern int  errno;

int    *alrmser ();

int     ttyconnect (ttyptr)
char   *ttyptr;
{
    int     sd,
            tty_port,
            timer;
    int     (*astat) ();
    char   *mp,
           *tp,
            tty_handle[BUFSIZ],
            localname[BUFSIZ],
           *localptr = localname;
    long    iaddr;
    struct sockaddr_in  tty_socket,
                       *tsock = &tty_socket,
                        emacs_socket,
                       *esock = &emacs_socket;
    struct stat st;

    if (stat (ttyptr, &st) == NOTOK)
	return NOTOK;
    if ((st.st_mode & S_IFMT) != S_IFCHR) {
	errno = ENOTTY;
	return NOTOK;
    }
    tty_port = IPPORT_EMACS | minor (st.st_rdev);

    for (mp = tp = ttyptr; *mp;)
	if (*mp++ == '/' && *mp)
	    tp = mp;
    sprintf (tty_handle, "/tmp/dev_%s", tp);
    if (stat (tty_handle, &st) == NOTOK) {
	errno = 0;
	return NOTOK;
    }

    gethostname (localname, sizeof localname);
    if ((iaddr = rhost (&localptr)) == NOTOK) {
	errno = ENETDOWN;
	return NOTOK;
    }

    tsock -> sin_family = AF_INET;
    tsock -> sin_port = 0;
#ifdef vax
    tsock -> sin_port = htons (tsock -> sin_port);
#endif
    tsock -> sin_addr.s_addr = (u_long) INADDR_ANY;
    if ((sd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
	return NOTOK;

    if(bind(sd, tsock, sizeof(*tsock)) < 0)
	return NOTOK;

#ifdef vax
    tsock -> sin_port = ntohs (tsock -> sin_port);
#endif

    esock -> sin_family = AF_INET;
    esock -> sin_port = tty_port;
#ifdef vax
    esock -> sin_port = htons (esock -> sin_port);
#endif
    esock -> sin_addr.s_addr = (u_long) iaddr;

    astat = signal (SIGALRM, alrmser);
    if ((timer = alarm (ATIME)) > 0)
	if ((timer -= ATIME) < 0)
	    timer = 1;

    if (connect (sd, esock, sizeof(*esock)) == NOTOK)
	switch (errno) {
	    default: 
		perror ("unable to complete socket");

	    case EINTR: 
	    case EISCONN: 
	    case ETIMEDOUT: 
	    case ECONNREFUSED: 
		close (sd);
		signal (SIGALRM, astat);
		alarm (timer);
		return NOTOK;
	}

#ifdef vax
    esock -> sin_port = ntohs (esock -> sin_port);
#endif
    signal (SIGALRM, astat);
    alarm (timer);

    return sd;
}

/* ARGSUSED */

static int *alrmser (sig)
int     sig;
{
}
