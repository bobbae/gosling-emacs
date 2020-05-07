/* Routines for parsing an error log */

/*		Copyright (c) 1981,1980 James Gosling		*/

#include "buffer.h"
#include "window.h"
#include "keyboard.h"
#include <sys/param.h>

char  *malloc();

struct err {			/* a single error message */
    struct marker  *e_mess;	/* points to the error message */
    struct marker  *e_text;	/* points to the position in the text
				   where the compiler thinks the error
				   is */
    struct err *e_next;		/* the next error in the chain */
};

static struct err
                   *errors,	/* the list of all error messages */
                   *ThisErr;	/* the current error */

/* delete the error list */
DelErl () {
    register struct err *e;
    while (errors) {
	e = errors;
	DestMark (e -> e_mess);
	DestMark (e -> e_text);
	errors = e -> e_next;
    }
}

/* Parse error messages from the current buffer from character pos to limit */
ParseErb (pos, limit)
register pos; {
    register struct buffer *erb = bf_cur;
    char old_fn[MAXPATHLEN];
    int old_ln = -1;
    DelErl ();
    for (;;) {
	register    ln = 0;
	char    fn[MAXPATHLEN];
	register    fnend;
	register char  *p,
	                c;
	int     fnl = 0,
	        quoted = 0,
	        bol;
	SetBfp (erb);
	pos = search (", line ", 1, pos, 0);
	if (pos <= 0 || pos >= limit) {
	    ThisErr = 0;
	    return errors != 0;
	}
	fnend = pos - 8;
	while (pos <= NumCharacters && (c = CharAt (pos)) >= '0' && c <= '9'){
	    pos++;
	    ln = ln * 10 + c - '0';
	}
	if (ln == 0)
	    continue;
	if (CharAt (fnend) == '"')
	    quoted++, fnend--;
	while (fnend >= 1) {
	    c = CharAt (fnend);
	    if (quoted) {
		if (c == '"') {
		    fnend++;
		    break;
		}
	    }
	    else
		if (c <= ' ') {
		    fnend++;
		    break;
		}
	    fnl++;
	    if(fnend<=1) break;
	    fnend--;
	}
	if (fnl == 0)
	    continue;
	for (p = fn; --fnl >= 0; fnend++)
	    *p++ = CharAt (fnend);
	*p++ = 0;
	if (old_ln == ln && strcmp (old_fn, fn)==0)
	    continue;
	old_ln = ln;
	strcpy (old_fn, fn);
	bol = ScanBf ('\n', fnend, -1);
	if (!VisitFile (fn, 0, 0))
	    continue;
	if (errors) {
	    ThisErr -> e_next
		= (struct err  *) malloc (sizeof (struct err));
	    ThisErr = ThisErr -> e_next;
	}
	else
	    errors = ThisErr
		= (struct err  *) malloc (sizeof (struct err));
	ThisErr -> e_next = 0;
	ThisErr -> e_mess = NewMark ();
	ThisErr -> e_text = NewMark ();
	SetMark (ThisErr -> e_mess, erb, bol);
	SetMark (ThisErr -> e_text, bf_cur, ScanBf ('\n', 1, ln - 1));
    }
}

/* move to the next error message in the log */
NextErr () {
    register    n;
    if (!errors) {
	error ("No errors!");
	return 0;
    }
    if (ThisErr == 0)
	ThisErr = errors;
    else {
	ThisErr = ThisErr -> e_next;
	if (ThisErr == 0) {
	    error ("No more errors...");
	    return 0;
	}
    }
    n = ToMark (ThisErr -> e_mess);
    WindowOn (bf_cur);
    SetDot (n);
    SetMark (wn_cur -> w_start, bf_cur, dot);
    n = ToMark (ThisErr -> e_text);
    WindowOn (bf_cur);
    SetDot (n);
    return 1;
}
