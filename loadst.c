/*
 * loadst -- print current time and load statistics.
 *				-- James Gosling @ CMU, May 1981
 *  loadst [ -n ] [ interval ]
 *	07/29/81 jag -- also print info on presence of mail.
 *	05/05/82 jag -- add disk drive utilization Statistics.
 *	08/05/82 jtk & rlb -- rearranged message order and added ONSUSP code
 *	07/18/84 rjb -- add option for disk drive statistics
 *	07/18/84 rjb -- fix exec prompt bug by running twice at startup
 */
#include <setjmp.h>
#include <signal.h>
#include <nlist.h>
#include <stdio.h>
#include <time.h>
#include <pwd.h>
/* #include <sys/types.h> */
#include <sys/param.h>
#ifdef i386
#else  i386
#include <sys/cpustats.h>
#include <sys/dk.h>
#endif i386
#include <sys/stat.h>

struct tm *localtime ();

struct nlist    nl[] = {
    { "_avenrun" },
#define	X_CPTIME	1
	{ "_cp_time" },
#define	X_DKXFER	2
	{ "_dk_xfer" },
    { 0 },
};

#ifndef i386
struct {
    long	time[CPUSTATES];
    long	xfer[DK_NDRIVE];
} s, s1;
#endif i386

double	etime;

int startup = 1;		/* true the first time we run */
int nflag = 0;			/* -n flag -- no newline */
int sflag = 0;			/* -s flag -- newline at start of output */
int uflag = 0;			/* -u flag -- user current user ID rather
				   than login user ID */
int dflag = 0;			/* -d no disk statistics, +d yes */
				/* default = no */
int repetition;			/* repetition interval */

#ifdef ONSUSP		/*  not really necessary, here as an exercise */
jmp_buf env;
int onsusp();
#endif ONSUSP

main (argc, argv)
char  **argv;
{
    register    kmem, i;
    char mail[300];
    struct stat st;
    if ((kmem = open ("/dev/kmem", 0)) < 0) {
	fprintf (stderr, "Can't access /dev/kmem\n");
	exit (1);
    }
    nlist ("/vmunix", nl);
    while (--argc > 0) {
	argv++;
	if (strcmp (*argv, "-n") == 0)
	    nflag++;
	else if (strcmp (*argv, "-s") == 0)
	    sflag++;
	else if (strcmp (*argv, "-u") == 0)
	    uflag++;
	else if (strcmp (*argv, "-d") == 0)
	    dflag = 0;
	else if (strcmp (*argv, "+d") == 0)
	    dflag = 1;
	else
	    if ((repetition = atoi (*argv)) <= 0) {
		fprintf (stderr, "Bogus agument: %s\n", *argv);
		exit (1);
	    }
    }
    sprintf (mail, "/usr/spool/mail/%s",
	  uflag ? ((struct passwd *) getpwuid(getuid())) -> pw_name
		: (char *) getenv("USER"));

#ifdef ONSUSP
    signal(SIGTSTP, onsusp);
#endif ONSUSP
    while (1) {
	register struct tm *nowt;
	long    now;
	float   avenrun[3];
#ifdef ONSUSP
	setjmp(env);
#endif ONSUSP
	time (&now);
	nowt = localtime (&now);
	lseek (kmem, (long) nl[0].n_value, 0);
	read (kmem, avenrun, sizeof (avenrun));
	if (sflag)
	    putchar ('\n');
	printf ("%d:%02d%s %.2f",
	    nowt -> tm_hour == 0 ? 12
	    : nowt ->tm_hour>12 ? nowt->tm_hour-12 : nowt->tm_hour,
	    nowt -> tm_min,
	    nowt -> tm_hour>=12 ? "pm" : "am",
	    avenrun[0]);
#ifndef i386
	lseek(kmem, (long)nl[X_CPTIME].n_value, 0);
 	read(kmem, s.time, sizeof s.time);
	lseek(kmem, (long)nl[X_DKXFER].n_value, 0);
	read(kmem, s.xfer, sizeof s.xfer);
	etime = 0;
	for (i=0; i < DK_NDRIVE; i++) {
		register t = s.xfer[i];
		s.xfer[i] -= s1.xfer[i];
		s1.xfer[i] = t;
	}
	for (i=0; i < CPUSTATES; i++) {
		register t = s.time[i];
		s.time[i] -= s1.time[i];
		s1.time[i] = t;
		etime += s.time[i];
	}
	if(etime == 0.)
		etime = 1.;
	etime /= 60.;
	if (dflag)
	    {   register max = s.xfer[0];
		for(i=1; i<DK_NDRIVE; i++)
		    if (s.xfer[i]>max) max = s.xfer[i];
		printf (" [%d]", (int) (max/etime + 0.5));
	    
	}
#endif i386
	printf("%s", stat (mail, &st)>=0 && st.st_size ? " Mail" : "");
	if (!nflag)
	    putchar ('\n');
	fflush (stdout);
	if (repetition <= 0)
	    break;
	if (startup) {
	    startup = 0;
	} else {
	    sleep (repetition);
	};
    }
}

#ifdef ONSUSP
onsusp()
{
    signal (SIGTSTP, SIG_DFL);
    kill (0, SIGTSTP);
    signal (SIGTSTP, onsusp);
    longjmp (env, 0);
}
#endif ONSUSP
