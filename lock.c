#

/*
 * A mailing program.
 *
 * Stuff to do version 7 style locking.
 */

/*#include "rcv.h"*/
#define	NOSTR	((char *)0)
extern char * rindex();
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>

/* static char *SccsId = "@(#)lock.c	2.3 10/5/82"; */
static char *RCSid =
"$Header: lock.c,v 1.1 86/04/16 13:53:12 mcdaniel Exp $";

char	*maillock	= ".lock";		/* Lock suffix for mailname */
char	*lockname	= "/tmp/tmXXXXXX";	/* target for link */
char	*lockdir	= "/tmp/";		/* where it all happens */
char	locktmp[30];				/* Usable lock temporary */
static char		curlock[50];		/* Last used name of lock */
static	int		locked;			/* To note that we locked it */

/*
 * Lock the specified mail file by setting the file mailfile.lock.
 * We must, of course, be careful to remove the lock file by a call
 * to unlock before we stop.  The algorithm used here is to see if
 * the lock exists, and if it does, to check its modify time.  If it
 * is older than 5 minutes, we assume error and set our own file.
 * Otherwise, we wait for 5 seconds and try again.
 * Lock file is "/tmp/username.lock".
 */

lock(file)
char *file;
{
	register int f;
	struct stat sbuf;
	long curtime;
	register char *p;

	if (file == NOSTR) {
		printf("Locked = %d\n", locked);
		return(0);
	}
	if (locked)
		return(0);
	if ((p = rindex(file, '/')) == NULL)	/* point to last component */
		p = file;
	else
		p++;
	strcpy(curlock, lockdir);
	strcat(curlock, p);
	strcat(curlock, maillock);
	strcpy(locktmp, lockname);
	mktemp(locktmp);
	remove(locktmp);
	for (;;) {
		f = lock1(locktmp, curlock);
		if (f == 0) {
			locked = 1;
			return(0);
		}
		if (stat(curlock, &sbuf) < 0)
			return(0);
		time(&curtime);
		if (curtime < sbuf.st_ctime + 300) {
			sleep(5);
			continue;
		}
		remove(curlock);
	}
}

/*
 * Remove the mail lock, and note that we no longer
 * have it locked.
 */

unlock()
{

	remove(curlock);
	locked = 0;
}

/*
 * Attempt to set the lock by creating the temporary file,
 * then doing a link/unlink.  If it fails, return -1 else 0
 */

lock1(tempfile, name)
	char tempfile[], name[];
{
	register int fd;

	fd = creat(tempfile, 0);
	if (fd < 0)
		return(-1);
	close(fd);
	if (link(tempfile, name) < 0) {
		remove(tempfile);
		return(-1);
	}
	remove(tempfile);
	return(0);
}

/* Stolen from fio.c */

remove(name)
	char name[];
{
	struct stat statb;
	extern int errno;

	if (stat(name, &statb) < 0)
		return(-1);
	if ((statb.st_mode & S_IFMT) != S_IFREG) {
		errno = EISDIR;
		return(-1);
	}
	return(unlink(name));
}
