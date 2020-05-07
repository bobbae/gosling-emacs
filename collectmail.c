/* Collect mail from a mail box and put it into a message directory */

/* For now, it does no locking on the mail box, unless you have the
   exclusive-access mod to the Unix kernel */

/* Mods for UW - Fixed spelling of "separate."  If no "From:" field is
   found, use the "From " field instead.  If no "Date:" field is found,
   use the date in the "From " field. */

/* 
 * Fixed to use lock() routine from ucb mail program. 
 * SWT Sat Apr  9 1983
 * $Log:	collectmail.c,v $
 * Revision 1.2  93/01/11  13:25:00  mogul
 * Bug fixes for MIPS, Alpha
 * 
 * Revision 1.1  1986/04/16  13:52:34  mcdaniel
 * Initial revision
 *
 * Revision 1.3  83/04/11  13:19:07  thomas
 * Add - flag for stdout output (incremental mail reading).
 * 
 */
#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sgtty.h>
#include <sys/ioctl.h>
#include "config.h"
#include <pwd.h>

char    date[BUFSIZ],
        subj[BUFSIZ],
	to[BUFSIZ],
	me[BUFSIZ],
        from[BUFSIZ],
        msgfn[20],
	Fromline[BUFSIZ];
    char   *mbdir;
    extern errno;
    char    mbdbuf[BUFSIZ],
            mbfbuf[BUFSIZ];
    long    now;
    int     seq = 0;
int usestdout = 0;
FILE	*out,
	*dir;
int	HaveNew = 0;
struct passwd	*pw,
		*getpwuid();

main (argc, argv)
char  **argv;
{
    struct stat st;
    pw = getpwuid (getuid ());
    now = time (0);
    {
	register char  *p1 = me,
	               *p2 = pw ? MailOriginator : "XXXX";
	while (*p2)
	    if (*p2 != ' ')
		*p1++ = *p2++;
	    else {
		if (p1 != me && *(p1 - 1) != '.')
		    *p1++ = '.';
		p2++;
	    }
	*p1++ = '\0';
    }
    umask (077);
    if (argc > 1 && strcmp(argv[1], "-") == 0)
    {
	usestdout=1;
	argc--;
	argv++;
    }
    if (argc > 1)
	mbdir = argv[1];
    else {
	sprintf (mbdbuf, "%s/Messages", getenv ("HOME"));
	mbdir = mbdbuf;
    }
    {
	register char  *p;
	for (p = mbdir; *p; p++);
	while (*--p == '/')
	    *p = 0;
    }
    if (stat (mbdir, &st) < 0) {
	int st;
	if (vfork()==0){
	    execlp ("mkdir", "mkdir", mbdir, 0);
	    exit (1);
	}
	wait(&st);
	if (st) {
	    printf ("Can't create mailbox directory %s\n", mbdir);
	    exit (1);
	}
	chmod (mbdir, 0700);
    }
    if (! usestdout)
    {
	sprintf (subj, "%s/Directory", mbdir);
	dir = fopen (subj, "a");
	if (dir == 0) {
	    printf ("Can't append to directory\n");
	    exit (1);
	}
    }
    else
	dir = stdout;

    if (argc > 2)
	do {
	    ScanBox (argv[2]);
	    argv++;
	} while (--argc > 2);
    else {
	sprintf (mbfbuf, "/usr/spool/mail/%s", getenv ("USER"));
	ScanBox (mbfbuf);
    }
    fclose (dir);
}

ScanBox (mbf)
char *mbf; {
    int     inheader = 0;
    int     RationalSeparators = 0;/* true iff entries in this mbox are
				   rationally separated */
    register    FILE * in;
    struct stat st;
    out = 0;
    inheader = 0;
    if (mbf==0) return;
    if (stat (mbf, &st) < 0 || st.st_size <= 0)
	return;
#ifndef FXMUPD
    if ((in = fopen (mbf, "r")) == 0)
	return;
    lock(mbf);				/* lock the mail file */
#else
    { static mode = FXMUPD; int lock;int infd;
    while ((infd = open (mbf, 2))<0 && errno==EBUSY
		|| (lock = ioctl (infd, FIOCXMOD, &mode))<0 && errno==EBUSY) {
	if (infd>=0) close(infd);
	sleep (5);
    }
    if (lock<0 || infd<0) perror("collectmail");
    in = fdopen (infd, "r");
    }
#endif
    if (in==0) return;
    while (1) {
	char    line[BUFSIZ];
	if (fgets (line, sizeof line, in) == 0)
	    break;
	if (line[0] == '\n') {
	    if (out == 0)
		continue;
	    inheader = 0;
	    fputs (line, out);
	    continue;
	}
	if (!inheader && !RationalSeparators &&
		(strncmp (line, "From ", 5) == 0
		    || strncmp (line, "Date: ", 6) == 0)
		|| out == 0
		|| strncmp (line, "\003\n", 2) == 0) {
	    CloseMessage ();
	    inheader++;
/***/	    if (strncmp(line, "From ", 5) == 0)
		strcpy(Fromline, line);
	    else
		Fromline[0] = '\0';
	    do {
		sprintf (msgfn, "%011o%03o", now, seq++);
		sprintf (subj, "%s/%s", mbdir, msgfn);
	    } while (stat (subj, &st) >= 0);
	    out = fopen (subj, "w");
	    subj[0] = to[0] = date[0] = from[0] = 0;
	    if (line[0] == 3) {
		RationalSeparators++;
		continue;
	    }
	}
	if (inheader) {
	    extractfield (line, "from", from, sizeof from) ;
	    extractfield (line, "subject", subj, sizeof subj) ;
	    extractfield (line, "subj", subj, sizeof subj) ;
	    extractfield (line, "to", to, sizeof to) ;
	    extractfield (line, "date", date, sizeof date) ;
	}
	if (out)
	    fputs (line, out);
    }
    CloseMessage ();
    fflush (dir);
    fclose (in);		/* There's a narrow window in the locking
				   here, but I can't truncate the file
				   without closing it and losing the lock */
    creat (mbf, 0600);
#ifndef	FXMUPD
    unlock();				/* unlock the mail file */
#endif
}

extractfield (line, field, buf, bufsz)
register char *field, *line, *buf; {
    while (1) {
	while (isspace(*field)) field++;
	while (isspace(*line)) line++;
	if (*field==0) break;
	if (*field++ != (isupper (*line) ? tolower (*line++) : *line++)) {
	    return 0;
	}
    };
    if (*line++ != ':') return 0;
    while (isspace (*line)) line++;
    while (--bufsz > 0 && *line != '\n' && (*buf++ = *line++));
    *buf++ = 0;
    return 1;
}

char   *trim (str, limit)
register char  *str;
{
    register char  *p;
    while (isspace(*str))
	str++;
    for (p = str; *p; p++);
    if (limit) {
	register char *at = (char *) sindex (str, " at ");
	if (at) *at = '\0', p = at;
    }
    while (isspace (*--p) && p >= str)
	*p = 0;
    if (limit && p - str > limit)
	for (p = str + limit; p > str; p--)
	    if (*p == ' ') {
		*p = '\0';
		break;
	    }
    return * str ? str : "[empty]";
}

CloseMessage () {
	int i;
	char *f, *d;

/***/	if (from[0] == '\0' && *Fromline) {
		for (i = 5; Fromline[i] == ' '; i++)
			;
		f = from;
		while (Fromline[i] != ' ' && Fromline[i] != '\0')
			*f++ = Fromline[i++];
		*f = '\0';
	}
/***/	if (date[0] == '\0' && *Fromline) {
		for (i = 5; Fromline[i] == ' '; i++)	/* Skip to fromname */
			;
		while (Fromline[i] != ' ' && Fromline[i] != '\0')
			i++;
		while (Fromline[i] == ' ')	/* Skip to date */
			i++;
		d = date;
		while (Fromline[i] != '\n' && Fromline[i] != '\0')
			*d++ = Fromline[i++];
		*d = '\0';
	}

    if (out == 0)
	return;
    if (sindex (from, me))
	fprintf (dir, "  B %14s %-12.12s =>%-13.13s %.30s\n",
		msgfn, trim (date, 12), trim (to, 13), trim (subj, 0));
    else {
	fprintf (dir, " N  %14s %-12.12s %-15.15s %.30s\n",
		msgfn, trim (date, 12), trim (from, 15), trim (subj, 0));
	HaveNew++;
    }
    fclose (out);
}
