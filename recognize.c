static char *SCCSid =
    "@(#)tenex.c	1.17 - 3/6/82 12:04:08 - CSH Version, Ken Greer, HP/CRC";
/*
 * Tenex style file name recognition, .. and more.
 * History:
 *	Author: Ken Greer, Sept. 1975, CMU.
 *	Finally got around to adding to the Cshell., Ken Greer, Dec. 1981.
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <sgtty.h>
#include <dir.h>
#include <signal.h>
#include <pwd.h>
/* Don't include stdio.h!  Csh doesn't like it!! */
#ifdef TEST
#include <stdio.h>
#define flush()		fflush(stdout)
#endif

extern short SHIN, SHOUT;

#define TRUE	1
#define FALSE	0
#define ON	1
#define OFF	0
#define NULL	0
#define FILSIZ	128			/* Max reasonable file name length */

#define ESC	'\033'

typedef enum {LIST, RECOGNIZE} COMMAND;

#define equal(a, b)	(strcmp(a, b) == 0)

static struct tchars  tchars;		/* INT, QUIT, XON, XOFF, EOF, BRK */

static
setup_tty (on)
{
    sigignore (SIGINT);
    if (on)
    {
	struct sgttyb sgtty;
	ioctl (SHIN, TIOCGETC, &tchars);
	tchars.t_brkc = ESC;
	ioctl (SHIN, TIOCSETC, &tchars);
	/*
	 * This is a useful feature in it's own right...
	 * The shell makes sure that the tty is not in some weird state
	 * and fixes it if it is.  But it should be noted that the
	 * tenex routine will not work correctly in CBREAK or RAW mode
	 * so this code below is, therefore, mandatory.
	 */
	ioctl (SHIN, TIOCGETP, &sgtty);
	if ((sgtty.sg_flags & (RAW | CBREAK)) ||
	   ((sgtty.sg_flags & ECHO) == 0))	/* not manditory, but nice */
	{
	    sgtty.sg_flags &= ~(RAW | CBREAK);
	    sgtty.sg_flags |= ECHO;
	    ioctl (SHIN, TIOCSETP, &sgtty);
	}
    }
    else
    {
	tchars.t_brkc = -1;
	ioctl (SHIN, TIOCSETC, &tchars);
    }
    sigrelse (SIGINT);
}

/*
 * Move back to beginning of current line
 */
static
back_to_col_1 ()
{
    struct sgttyb tty, tty_normal;
    sigignore (SIGINT);
    ioctl (SHIN, TIOCGETP, &tty);
    tty_normal = tty;
    tty.sg_flags &= ~CRMOD;
    ioctl (SHIN, TIOCSETN, &tty);
    (void) write (SHOUT, "\r", 1);
    ioctl (SHIN, TIOCSETN, &tty_normal);
    sigrelse (SIGINT);
}

/*
 * Push string contents back into tty queue
 */
static
pushback (string)
char  *string;
{
    register char  *p;
    struct sgttyb   tty, tty_normal;

    sigignore (SIGINT);
    ioctl (SHOUT, TIOCGETP, &tty);
    tty_normal = tty;
    tty.sg_flags &= ~ECHO;
    ioctl (SHOUT, TIOCSETN, &tty);

    for (p = string; *p; p++)
	ioctl (SHOUT, TIOCSTI, p);
    ioctl (SHOUT, TIOCSETN, &tty_normal);
    sigrelse (SIGINT);
}

/*
 * like strncpy but always null terminate
 */
static
copyn (des, src, count)
register char *des, *src;
register count;
{
    while (--count >= 0)
	if ((*des++ = *src++) == 0)
	    return;
    *des = '\0';
}

static
max (a, b)
{
    if (a > b)
	return (a);
    return (b);
}

/*
 * For qsort()
 */
static
fcompare (file1, file2)
char  **file1, **file2;
{
    return (strcmp (*file1, *file2));
}

static char
filetype (dir, file)
char *dir, *file;
{
    if (dir)
    {
	char path[MAXPATHLEN];
	struct stat statb;
	extern char *strcpy ();
	(void) strcat (strcpy (path, dir), file);
	if (stat (path, &statb) >= 0)
	{
	    if (statb.st_mode & S_IFDIR)
		return ('/');
	    if (statb.st_mode & 0111)
		return ('*');
	}
    }
    return (' ');
}

/*
 * Print sorted down columns
 */
static
print_by_column (dir, items, count)
char *dir, *items[];
{
    register int i, rows, r, c, maxwidth = 0, columns;
    for (i = 0; i < count; i++)
	maxwidth = max (maxwidth, strlen (items[i]));
    maxwidth += 2;				/* for the file tag and space */
    columns = 80 / maxwidth;
    rows = (count + (columns - 1)) / columns;
    for (r = 0; r < rows; r++)
    {
	for (c = 0; c < columns; c++)
	{
	    i = c * rows + r;
	    if (i < count)
	    {
		register int w;
		printf("%s", items[i]);
		putchar (filetype (dir, items[i]));	/* '/' or '*' or ' ' */
		if (c < (columns - 1))			/* Not last column? */
		    for (w = strlen (items[i]) + 1; w < maxwidth; w++)
			printf (" ");
	    }
	}
	printf ("\n");
    }
}

/*
 * expand file name with possible tilde usage
 *		~person/mumble
 * expands to
 *		home_directory_of_person/mumble
 *
 * Usage: tilde (new, old) char *new, *old;
 */

char *
tilde (new, old)
char *new, *old;
{
    extern char *strcpy ();
    extern struct passwd *getpwuid (), *getpwnam ();

    register char *o, *p;
    register struct passwd *pw;
    static char person[20] = {0};

    if (old[0] != '~')
	return (strcpy (new, old));

    for (p = person, o = &old[1]; *o && *o != '/'; *p++ = *o++);
    *p = '\0';

    if (person[0] == '\0')			/* then use current uid */
	pw = getpwuid (getuid ());
    else
	pw = getpwnam (person);

    if (pw == NULL)
	return (NULL);

    strcpy (new, pw -> pw_dir);
    (void) strcat (new, o);
    return (new);
}

/*
 * Cause pending line to be printed
 */
static
retype ()
{
    int     pending_input = LPENDIN;
    ioctl (SHOUT, TIOCLBIS, &pending_input);
}

static
beep ()
{
    (void) write (SHOUT, "\07", 1);
}

/*
 * parse full path in file into 2 parts: directory and file names
 * Should leave final slash (/) at end of dir.
 */
static
df_parse (path, dir, name)
char   *path, *dir, *name;
{
    extern char *rindex ();
    register char  *p;
    p = rindex (path, '/');
    if (p == NULL)
    {
	copyn (name, path, DIRSIZ);
	dir[0] = '\0';
    }
    else
    {
	p++;
	copyn (name, p, DIRSIZ);
	copyn (dir, path, p - path);
    }
}

static dir_fd = -1;

/*
 * Open the directory, performing tilde expansion first
 * if necessary.  Return -1 on failure, 0 otherwise
 */
static
opendir (dir)
char *dir;
{
    struct stat statb;

    if ((dir_fd = open (*dir ? dir:".", 0)) < 0)
	return (-1);

     /* Is it really a directory? */
    if (fstat (dir_fd, &statb) < 0 || (statb.st_mode & S_IFDIR) == 0)
    {
	(void) close (dir_fd);
	dir_fd = -1;
	return (-1);
    }
    return (0);
}

static
closedir ()
{
    (void) close (dir_fd);
    dir_fd = -1;
}

static
getdirentry (name)
char *name;
{
    struct dir  block;
    do
    {
	if (read (dir_fd, &block, sizeof (struct dir)) != sizeof (struct dir))
	    return (0);
    } while (block.d_ino == 0);
    copyn (name, block.d_name, sizeof (block.d_name));
    return (1);
}

static
getentry (lognames, name)
char *name;
{
    if (lognames)				/* Is it lognames we want? */
    {
	extern struct passwd *getpwent ();
	register struct passwd *pw;
	if ((pw = getpwent ()) == NULL)
	    return (0);
	copyn (name, pw -> pw_name, DIRSIZ);
	return (1);
    }
    else
	return (getdirentry (name));
}

/*
 * Perform a RECOGNIZE or LIST command on string "word".
 */
static
recognize (word, command)
char   *word;
COMMAND command;
{
#   define MAXITEMS 1024
    register numitems,
	    lognames;			/* True if looking for lognames */
    char    tilded_dir[FILSIZ + 1],	/* dir after ~ expansion */
	    dir[FILSIZ + 1],		/* /x/y/z/ part in /x/y/z/f */
            name[DIRSIZ + 1],		/* f part in /d/d/d/f */
            extended_name[DIRSIZ + 1],	/* the recognized (extended) name */
            entry[DIRSIZ + 1],		/* single directory entry or logname */
           *items[MAXITEMS];

    lognames = (*word == '~') && (index (word, '/') == NULL);
    if (lognames)				/* Just looking for log names?*/
    {
	setpwent ();				/* Open passwd file */
	copyn (name, &word[1], DIRSIZ);		/* name sans ~ */
    }
    else
    {						/* Open directory */
	df_parse (word, dir, name);
	if (tilde (tilded_dir, dir) == 0)
	    return (0);
	if (opendir (tilded_dir) < 0)
	   return (0);
    }

    for (numitems = 0; getentry (lognames, entry);)
    {
	if (!is_prefix (name, entry))
	    continue;
	if (command == LIST)		/* LIST command */
	{
	    extern char *malloc ();
	    /* Don't list . files if listing full directory */
	    if (!lognames && entry[0] == '.' && name[0] == '\0')
		continue;
	    if (numitems >= MAXITEMS)
	    {
		printf ("\nYikes!! Too many %s!!\n",
		    lognames ? "names in password file":"files");
		break;
	    }
	    if ((items[numitems] = malloc (strlen(entry) + 1)) == NULL)
	    {
		printf ("out of mem\n");
		break;
	    }
	    copyn (items[numitems], entry, DIRSIZ);
	    numitems++;
	}
	else					/* RECOGNIZE command */
	{
	    if (++numitems == 1)		/* 1st match */
		copyn (extended_name, entry, DIRSIZ);
	    else
	    {
		register char *x, *ent;
		for (x = extended_name, ent = entry; *x++ == *ent++;);
		*--x = '\0';
		/* 
		 * If extended_name has been shortened back to name,
		 * we might as well quit now and save time.
		 */
		if (equal (extended_name, name))
		    break;
	    }
	}
    }
    if (lognames)
	endpwent ();
    else
	closedir ();
    if (command == RECOGNIZE && numitems > 0)
    {
	if (lognames)
	    strcpy (word, "~");
	else
	    copyn (word, dir, FILSIZ - DIRSIZ);	/* put back dir part */
	(void) strcat (word, extended_name);	/* add extended name */
	return (numitems);
    }
    if (command == LIST)
    {
	register int i;
	qsort (items, numitems, sizeof (items[1]), fcompare);
	print_by_column (lognames ? NULL:tilded_dir, items, numitems);
	for (i = 0; i < numitems; i++)
	    free (items[i]);
    }
    return (0);
}

/*
 * return true if check items initial chars in template
 * This differs from PWB imatch in that if check is null
 * it items anything
 */
static
is_prefix (check, template)
char   *check,
       *template;
{
    register char  *check_char,
                   *template_char;

    check_char = check;
    template_char = template;
    do
	if (*check_char == 0)
	    return (TRUE);
    while (*check_char++ == *template_char++);
    return (FALSE);
}


tenex (inputline, inputline_size)
char   *inputline;
int     inputline_size;
{
    register int numitems, num_read;

    setup_tty (ON);
    while((num_read = read (SHIN, inputline, inputline_size)) > 0)
    {
	static char *delims = " '\"\t;&<>()|^%";
	register char *str_end, *word_start, last_char, should_retype;
	COMMAND command;

	last_char = inputline[num_read - 1] & 0177;

	if (last_char == '\n' || num_read == inputline_size)
	    break;

	command = (last_char == ESC) ? RECOGNIZE : LIST;

	if (command == LIST)
	    putchar ('\n');

	str_end = &inputline[num_read];
	if(last_char == ESC)
	    --str_end;			/* wipeout trailing command character */
	*str_end = '\0';
	/*
	 * Find LAST occurence of a delimiter in the inputline.
	 * The word start is one character past it.
	 */
	for (word_start = str_end; word_start > inputline; --word_start)
	    if (index (delims, word_start[-1]))
		break;

	if (strlen (word_start) >= (FILSIZ - DIRSIZ))
	{
	    beep (); continue;
	}
	numitems = recognize (word_start, command);

	if (command == RECOGNIZE)
	{
	    printf ("\210\210  \210\210");		/* Erase ^[ */
	    while (*str_end)				/* show extended part */
		putchar (*str_end++);
	    flush ();
	    if (numitems != 1) /* no match or ambiguous */
		beep ();
	}

	/*
	 * Tabs in the input line cause trouble after a pushback.
	 * tty driver won't backspace over them because column positions
	 * are now incorrect. This is solved by retyping over current line.
	 */
	should_retype = FALSE;
	if (index (inputline, '\t'))		/* tab char in input line? */
	{
	    back_to_col_1 ();
	    should_retype = TRUE;
	}
	if (command == LIST)			/* Always retype after a LIST */
	    should_retype = TRUE;

	if (should_retype)
	    printprompt ();

	pushback (inputline);

	if (should_retype)
	    retype ();
    }

    setup_tty (OFF);

    return (num_read);
}

#ifdef TEST

short SHIN = 0, SHOUT = 1;

printprompt ()
{
    (void) write (SHOUT, "-> ", 3);
    return (1);
}

main (argc, argv)
char **argv;
{
    char    string[128];
    int	    numitems;

    if (argc > 1)
    {
	copyn(string, argv[1], 127);
	numitems = recognize(string, RECOGNIZE);
	printf("%d: %s", numitems, string);
    }
    else
	while (printprompt () && tenex (string, 127))
	    printf (" I saw \"%s\"\n", string);
}
#endif
