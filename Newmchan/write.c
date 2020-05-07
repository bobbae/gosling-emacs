static char *sccsid = "@(#)write.c	4.3 (UCI Modified) 4/10/82";
/*
 * write to another user
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <utmp.h>
#include <time.h>
#include <pwd.h>

#ifdef	TTYconnect
#undef	MPXcode
#endif

#define NMAX sizeof(ubuf.ut_name)
#define LMAX sizeof(ubuf.ut_line)

char	*strcat();
char	*strcpy();
struct	utmp ubuf;
int	signum[] = {SIGHUP, SIGINT, SIGQUIT, 0};
char	me[10];
char	*him;
char	*mytty;
char	histty[32];
#ifdef	MPXcode
char    histtyt[32];
#endif
char	*histtya, *CRstr;
char	*ttyname();
char	*rindex();
int	logcnt, NoCR;
int	eof();
int	timout();
FILE	*tf;
char	*getenv(), *getlogin();
struct	passwd *p, *getpwnam(), *getpwuid();
char	writeprog[30];
int	pipe_file[2];
char	*write_args[3], **write_argp = write_args;

#ifdef	MPXcode
/* Couldn't open mpx file, probably a paused emacs */

foo()
{
}
#endif

main(argc, argv)
char *argv[];
{
	struct stat stbuf;
	register i;
	register FILE *uf;
	int c1, c2;
	long	clock = time( 0 );
	struct tm *localtime();
	struct tm *localclock = localtime( &clock );

	if(argc < 2) {
		printf("usage: write user [ttyname]\n");
		exit(1);
	}
	him = argv[1];
	if(argc > 2)
		histtya = argv[2];
	if ((uf = fopen("/etc/utmp", "r")) == NULL) {
		printf("cannot open /etc/utmp\n");
		goto cont;
	}
	mytty = ttyname(2);
	if (mytty == NULL) {
		printf("Can't find your tty\n");
		exit(1);
	}
	if (stat (mytty, &stbuf) < 0) {
		printf ("Can't stat your tty\n");
		exit (1);
	}
	if ((stbuf.st_mode&02) == 0) {
		printf ("You have write permission turned off.\n");
		exit (1);
	}
#ifdef	MPXcode
	if (strncmp (mytty, "/tmp/dev_", 9) == 0) mytty += 9;
	else mytty = rindex(mytty, '/') ? rindex(mytty, '/') + 1 : mytty;
#else
	mytty = rindex(mytty, '/') ? rindex(mytty, '/') + 1 : mytty;
#endif
	if (histtya) {
		strcpy(histty, "/dev/");
		strcat(histty, histtya);
	}
	while (fread((char *)&ubuf, sizeof(ubuf), 1, uf) == 1) {
		if (ubuf.ut_name[0] == '\0')
			continue;
		if (strcmp(ubuf.ut_line, mytty)==0) {
			for(i=0; i<NMAX; i++) {
				c1 = ubuf.ut_name[i];
				if(c1 == ' ')
					c1 = 0;
				me[i] = c1;
				if(c1 == 0)
					break;
			}
		}
		if(him[0] != '-' || him[1] != 0)
		for(i=0; i<NMAX; i++) {
			c1 = him[i];
			c2 = ubuf.ut_name[i];
			if(c1 == 0)
				if(c2 == 0 || c2 == ' ')
					break;
			if(c1 != c2)
				goto nomat;
		}
		logcnt++;
		if (histty[0]==0) {
			strcpy(histty, "/dev/");
			strcat(histty, ubuf.ut_line);
		}
	nomat:
		;
	}
cont:
	if (logcnt==0 && histty[0]=='\0') {
		printf("%s not logged in.\n", him);
		exit(1);
	}
	fclose(uf);
	if (histtya==0 && logcnt > 1) {
		printf("%s logged more than once\nwriting to %s\n", him, histty+5);
	}
	if(histty[0] == 0) {
		printf(him);
		if(logcnt)
			printf(" not on that tty\n"); else
			printf(" not logged in\n");
		exit(1);
	}
	if (me[0] == 0) {		/* Uh oh */
		register char *s;
		register struct passwd *p = getpwuid (getuid ());
		if (p) s = p -> pw_name;
		else s = getlogin ();
		if (s) strcpy (me, s);
	}
#ifdef	MPXcode
	strcpy (histtyt, "/tmp");
	strcat (histtyt, histty);
	histtyt[8] = '_';
	if (stat (histtyt, &stbuf) == 0 &&
	   ((stbuf.st_mode & S_IFMT) == S_IFMPC)) {
		if ((stbuf.st_mode&02) == 0) goto perm;
		signal(SIGALRM, foo);	/* So we can break out of the open */
		alarm(2);
		if ((tf = fopen(histtyt, "w")) == NULL)
			goto stopped;
		alarm(0);
		NoCR++;
		goto announce;
	}
stopped:
#endif
#ifdef	TTYconnect
	if ((i = ttyconnect (histty)) != -1) {
	    if ((tf = fdopen (i, "w")) == NULL)
		printf("no free file descriptors -- you lose big\n"),
		    exit(1);
	    NoCR++;
	    goto announce;
	}
#endif
	if (access(histty, 0) < 0) {
		printf("No such tty\n");
		exit(1);
	}

if ((int)(p = getpwnam(him))) {
	strcpy(writeprog, p->pw_dir);
	strcat(writeprog, "/.write");
	if (!access(writeprog, 1)) {
		pipe(pipe_file);
		if (fork() == 0) {
			close(0);
			dup(pipe_file[0]);
			close(pipe_file[0]);
			close(pipe_file[1]);
			*write_argp++ = writeprog;
			*write_argp++ = histty;
			*write_argp++ = (char *)0;
			execv(writeprog, write_args);
			exit(1);
			}
		tf = fdopen(pipe_file[1], "w");
		close(pipe_file[0]);
		NoCR++;
		goto announce;
		}
	}

	signal(SIGALRM, timout);
	alarm(5);
	if ((tf = fopen(histty, "w")) == NULL)
		goto perm;
	alarm(0);
	if (fstat(fileno(tf), &stbuf) < 0)
		goto perm;
	if ((stbuf.st_mode&02) == 0)
		goto perm;
announce:
	sigs(eof);
	CRstr = NoCR ? "" : "\r";
	fprintf(tf, "%s\nMessage from ", CRstr);
#ifdef interdata
	fprintf(tf, "(Interdata) " );
#endif
	fprintf(tf, "%s on %s at %d:%02d ...%s\n",
		me, mytty, localclock -> tm_hour, localclock -> tm_min,
		NoCR ? "" : "\7\7\7", CRstr);
	fflush(tf);
	for(;;) {
		char buf[128];
		i = read(0, buf, 128);
		if(i <= 0)
			eof();
		if(buf[0] == '!' && buf[1]) {
			buf[i] = 0;
			ex(buf);
			continue;
		}
		write (fileno (tf), buf, i);
		if (buf[ i - 1 ] == '\n' && ! NoCR)
		    write (fileno (tf), "\r", 1 );
	}

perm:
	printf("Permission denied\n");
	exit(1);
}

timout()
{

	printf("Timeout opening his tty\n");
	exit(1);
}

eof()
{

	fprintf(tf, "EOF%s\n", CRstr);
	exit(0);
}

ex(bp)
char *bp;
{
	register i;

	sigs(SIG_IGN);
	i = fork();
	if(i < 0) {
		printf("Try again\n");
		goto out;
	}
	if(i == 0) {
		sigs((int (*)())0);
		execl(getenv("SHELL") ? getenv("SHELL") : "/bin/sh", "sh", "-c", bp+1, 0);
		exit(0);
	}
	while(wait((int *)NULL) != i)
		;
	printf("!\n");
out:
	sigs(eof);
}

sigs(sig)
int (*sig)();
{
	register i;

	for(i=0;signum[i];i++)
		signal(signum[i],sig);
}
