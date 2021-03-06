/* convert a pathname to an absolute one, if it is absolute already,
   it is returned in the buffer unchanged, otherwise leading "./"s
   will be removed, the name of the current working directory will be
   prepended, and "../"s will be resolved.

   In a moment of weakness, I have implemented the cshell ~ filename
   convention.  ~/foobar will have the ~ replaced by the home directory of
   the current user.  ~user/foobar will have the ~user replaced by the
   home directory of the named user.  This should really be in the kernel
   (or be replaced by a better kernel mechanism).  Doing file name
   expansion like this in a user-level program leads to some very
   distasteful non-uniformities.

   Another fit of dementia has led me to implement the expansion of shell
   environment variables.  $HOME/mbox is the same as ~/mbox.  If the
   environment variable a = "foo" and b = "bar" then:
	$a	=>	foo
	$a$b	=>	foobar
	$a.c	=>	foo.c
	xxx$a	=>	xxxfoo
	${a}!	=>	foo!

				James Gosling @ CMU
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#include "keyboard.h"
#include "mlisp.h"
#include "ctype.h"
#include <dirent.h>
#include <sys/param.h>

#ifdef titan
#define CHDIR(dirname) chdir(dirname)
#else
/* Hack! */
#define CHDIR(dirname) syscall(12,dirname)
#endif titan

char *sprintfl(), *getenv();

static char curwd[2000];	/* the current working directory is
				   remembered here.  chdir()'s are trapped
				   and this gets updated. */


abspath (nm, buf)		/* input name in nm, absolute pathname
				   output to buf.  returns -1 if the
				   pathname cannot be successfully
				   converted (only happens if the
				   current directory cannot be found) */
char	*nm,
* buf; {
    register char  *s,
                   *d;
    char    lnm[MAXPATHLEN];
    s = nm;
    d = lnm;
    while (*d++ = *s)
	if (*s++ == '$') {
	    register char  *start = d;
	    register    braces = *s == '{';
	    register char  *value;
	    while (*d++ = *s)
		if (braces ? *s == '}' : !isalnum (*s))
		    break;
		else
		    s++;
	    *--d = 0;
	    value = (char *) getenv (braces ? start + 1 : start);
	    if (value) {
		for (d = start - 1; *d++ = *value++;);
		d--;
		if (braces && *s)
		    s++;
	    }
	}
    d = buf;
    s = curwd;
    nm = lnm;
    if (nm[0] == '~') {		/* prefix ~ */
	if (nm[1] == '/' || nm[1] == 0)/* ~/filename */
	    if (s = (char *) getenv ("HOME")) {
		if (*++nm)
		    nm++;
	    }
	    else
		s = "";
	else {			/* ~user/filename */
	    register char  *nnm;
	    register struct passwd *pw;
	    for (s = nm; *s && *s != '/'; s++);
	    nnm = *s ? s + 1 : s;
	    *s = 0;
	    pw = (struct passwd *) getpwnam (nm + 1);
	    if (pw == 0) {
		error ("\"%s\" isn't a registered user.", nm+1);
		s = "";
	    }
	    else {
		nm = nnm;
		s = pw -> pw_dir;
	    }
	}
    } else {			/* look for ibis. ie., machinename: */
        register char *nnm;
	for (nnm = nm; *nnm; nnm++) if (*nnm == ':') s = "";
    }
    if (*s) {
        while (*d++ = *s++);
        *(d - 1) = '/';
    }
    s = nm;
    if (*s == '/')
	d = buf;
    while (*d++ = *s++);
    *(d - 1) = '/';
    *d = '\0';
    d = buf;
    s = buf;
    while (*s)
	if ((*d++ = *s++) == '/' && d > buf + 1) {
	    register char  *t = d - 2;
	    switch (*t) {
		case '/': 		/* found // in the name */
		    --d;
		    break;
		case '.': 
		    switch (*--t) {
			case '/':	/* found /./ in the name */
			    d -= 2;
			    break;

			case '.':	/* look for /../ */
			    if (*--t == '/') {
				while (t > buf && *--t != '/');
				d = t + 1;
			    }
			    break;
		    }
		    break;
	    }
	}
    if (*(d - 1) == '/')
	d--;
    *d = '\0';
    return 0;
}

/*
 *  getwd - get current working directory  (algorithm from /bin/pwd)
 *
 *  Author:  Mike Accetta, 19-May-78
 *
 **********************************************************************
 * HISTORY
 * 20-Nov-79  Steven Shafer (sas) at Carnegie-Mellon University
 *	Modified (by Mike Accetta) for VAX.  I tried using a "popen" on "pwd"
 *	to achieve the same effect; there's less risk since errors in pwd
 *	don't trash the current directory of the calling program; however,
 *	it takes about two full seconds (this routine takes about zero time).
 *	This routine wins.
 * 10-Jun-83 Chris Kent (cak) at DecWRL
 *	Upgraded to new directory access routines for 4.1cBSD.
 * 21 May 91	Jeff Mogul 	DECWRL
 *	Uses lstat() to avoid long waits on auto-mounted filesystems
 *
 **********************************************************************
 *
 *  Remarks:
 *
 *     The name of the current working directory is copied into
 *  the supplied string `wdir'.  The current working directory
 *  is changed during the execution of the routine and restored
 *  at the end by a chdir(wdir).  If an error occurs the current
 *  working directory is undefined.
 */

getwd (wdir)
char   *wdir;
{

    struct stat sb,
                sbc,
                root;
    register int    fd,
                    found;
    char temp[2000];
    DIR *filed;
    struct dirent *dirp;

 /*  Initially root  */
    strcpy (wdir, "/");
    stat ("/", &root);

    for (;;) {
	if ((filed = opendir ("..")) == NULL)
	    return (-1);
	if (stat (".", &sbc) < 0 || stat ("..", &sb) < 0)
	    goto out;
	if (sbc.st_ino == root.st_ino && sbc.st_dev == root.st_dev) {
	    closedir (filed);
	    return CHDIR (wdir);
	}

	if (sbc.st_ino == sb.st_ino && sbc.st_dev == sb.st_dev) {
	    close (filed);
	    CHDIR ("/");
	    if ((filed = opendir (".")) == NULL)
		return (-1);
	    if (stat (".", &sb) < 0)
		goto out;
	/*  scan the root directory for directory with same device  */
	    if (sbc.st_dev != sb.st_dev)
		while ((dirp = readdir (filed)) != NULL) {
		    if (lstat (dirp->d_name, &sb) < 0)
			goto out;
		    if (sbc.st_dev == sb.st_dev) {
			strcpy (temp, dirp->d_name);
			strcat (temp,  wdir);
			strcpy (wdir + 1, temp);
			closedir (filed);
			return (CHDIR (wdir));
		    }
		}
	    else {
		close (filed);
		return (CHDIR (wdir));
	    }
	}

    /*  scan parent directory for file with inode of current directory  
    */
	found = 0;
	while ((dirp = readdir (filed)) != NULL) {
	    char    fnb[MAXNAMLEN+4];
	    if ( lstat (sprintfl (fnb, sizeof fnb, "../%s", dirp->d_name), &sb) >= 0
		    && sb.st_ino == sbc.st_ino
		    && sb.st_dev == sbc.st_dev) {
		closedir (filed);
		found++;
		CHDIR ("..");
		strcpy (temp, dirp->d_name);
		strcat (temp, wdir);
		strcpy (wdir + 1, temp);
		break;
	    }
	}
	if (!found)
	    goto out;
    }
out: 
    closedir (filed);
    return (-1);
}

/* A chdir() that fiddles the global record */
e_chdir (dirname)
    char   *dirname; {
    int    ret;
    char *p;
    char path1[MAXPATHLEN], path2[MAXPATHLEN];
    for (p = path1; *p++ = *dirname++; ) ;
    *(p-1) = '/';		/* append a '/' so that "cd ~" works */
    *p = 0;
    ret = abspath (path1, path2);
    if (ret == 0 && (ret = CHDIR (path2)) == 0)
	strcpy (curwd, path2);
    return ret;
}

/* return a pointer to a copy of a file name that has been
   converted to absolute form.  This routine cannot return failure. */
char *SaveAbs (fn)
char   *fn; {
    static char    buf[MAXPATHLEN];
    if (fn==0) return 0;
    if (abspath (fn, buf) < 0) {
	write (1, "\r\nFailed to find current directory\r\n\n", 37);
	exit (-1);
    }
    return buf;
}

WorkingDirectory () {
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_v.v_string = curwd;
    MLvalue -> exp_release = 0;
    MLvalue -> exp_int = strlen(MLvalue -> exp_v.v_string);
    return 0;
}

InitAbs () {
    if (getwd (curwd) < 0) {
	char *p;
	if (CHDIR (p = (char *) getenv ("HOME")))
	    CHDIR (p = "/");
	strcpy (curwd, p);
	fprintf (stderr, "[NOTE: Changed to directory %s]\r\n", curwd);
	fflush (stderr);
    }

    if (!Once)
    {
	defproc (WorkingDirectory, "working-directory");
    }
}
