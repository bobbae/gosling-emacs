/* Build a prototype mail header.  This is used by Emacs RMail.
 *
 * Modifications by Jim Rees at U of Washington for Berkeley style
 * password file and mailers.  The password file mod could be incorporated
 * into the rest of Emacs for evaluation of users-full-name, and the
 * #defines could be incorporated into config.h.  I have not done this.
 *
 * You should define one of AddUucpName, AddArpaName, or AddNoName depending
 * on which if any network you are on.  In any case, you should have
 * AddSiteName #defined in config.h.
 */

#include "config.h"
#include <stdio.h>
#include <pwd.h>
#include <time.h>
#include <sys/types.h>
#include <sys/timeb.h>

#define BerkPasswd		/* If you use Berkeley style password file */
/*#define AddUucpName		/* For uucp style return addresses */
/*#define AddArpaName		/* For Arpanet style return addresses */
#define AddNoName		/* For a return address with no site name */

char *arpatime ();
char *MessageId ();

#ifdef BerkPasswd
char *UsersRealName();
#endif

struct passwd *getpwuid();

struct timeb now;
char me[100];

main (argc, argv)
char  **argv; {
    register struct passwd *pw = getpwuid (getuid ());
    register char  *p;
    char    subj[200],
            dest[200];
    char   *body = "hErE<!}";
    register char *SendersName;
    time (&now);
    if (fgets (subj, sizeof subj, stdin) == NULL)
	subj[0] = 0;
    if (fgets (dest, sizeof dest, stdin) == NULL)
	dest[0] = 0;
    strcpy (me, SystemName);
    for (p = me; *p; p++)
	if (*p == ' ')
	    *p = '-';
    for (p = subj; *p; p++)
	if (*p == '\n')
	    *p = 0;
    for (p = dest; *p; p++)
	if (*p == ',')
	    *p = ' ';
	else if (*p=='\n') *p = 0;
    if (subj[0] == 0)
	strcpy (subj, body), body = "";
    else
	if (dest[0] == 0)
	    strcpy (dest, body), body = "";

#ifdef BerkPasswd
    SendersName = UsersRealName(pw->pw_name, pw->pw_gecos);
#else
    SendersName = MailOriginator;
    if(SendersName==0 || *SendersName==0)
	SendersName = pw->pw_name;
    for (p = SendersName; *p; p++)
	if (*p == ' ')
	    *p = '.';
#endif
    printf ("Date: %s\nFrom: %s", arpatime(), SendersName);

#ifdef AddUucpName
    printf ("  <%s!%s>", me, pw->pw_name);
#endif

#ifdef AddArpaName
    printf ("  <%s at %s>", pw->pw_name, me);
#endif

#ifdef AddNoName
    printf ("  <%s>", pw->pw_name);
#endif

#if 0
    printf("\nSubject: %s\nTo: %s\nMessage-Id: <%s>\n",
#else
    printf("\nSubject: %s\nTo: %s\n",
#endif
	subj, dest, MessageId ());
    while(fgets(dest, sizeof dest, stdin)) fputs(dest, stdout);

#ifdef AddSiteName
    printf ("\n%s", body);
#else
    printf ("Origin: %s\n\n%s", me, body);
#endif
}

char *arpatime() {
	register struct tm *tm = (struct tm *) localtime(&now.time);
	static char *month[] = {
	"Jan", "Feb", "Mar", "Apr", "May", "Jun",
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
	};
	static char buf[100];
#ifdef	__osf__
	tzset();
#endif	__osf__
	sprintf(buf, "%d %s %d %d:%02d %s",
		tm->tm_mday,
		month[tm->tm_mon],
		tm->tm_year,
		tm->tm_hour,
		tm->tm_min,
#ifdef	__osf__
		tzname[daylight]);
#else
		timezone (now.timezone, tm->tm_isdst));
#endif	__osf__
	return buf;
}

char *MessageId () {
	register struct tm *tm = (struct tm *) localtime(&now.time);
	static char buf[100];
	sprintf(buf, "%02d/%02d/%02d %02d%02d.%03d@%s",
		tm->tm_year,
		tm->tm_mon+1,
		tm->tm_mday,
		tm->tm_hour,
		tm->tm_min,
		now.millitm,
		me);
	return buf;
}

#ifdef BerkPasswd
char *
UsersRealName(name, gecos)
char *name, *gecos;
{
	char *p, *s;
	static char b[80];

	p = b;
	while (*gecos != ',' && *gecos != ':' && *gecos != '\0') {
		if (*gecos == '&') {
			s = name;
			*p = *s++;
			if (*p >= 'a' && *p <= 'z')
				*p -= ('a' - 'A');
			p++;
			while (*s)
				*p++ = *s++;
		} else
			*p++ = *gecos;
		gecos++;
	}
	*p = '\0';
	return(*b ? b : name);
}
#endif
