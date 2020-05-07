/* Stuff to do with the manipulation of macros.
   For silly historical reasons, several routines that should be here
   are actually in options.c (eg. the command level callers). */

/*		Copyright (c) 1981,1980 James Gosling		*/

#include "keyboard.h"
#include "macros.h"
#include "buffer.h"
char  *malloc();

static MacrosAreSorted;		/* true iff the macro table is known to
				   be sorted */

/* Find the index of the named macro or command; -(index of where the
   name should have been if it isn't found)-1. */
FindMac (s)
char   *s; {
    register    hi,
                lo,
                mid;
    register char *s1, *s2;
    int         cmp;
    lo = 0;
    hi = NMacs - 1;
    if (!MacrosAreSorted) SortMacros();
    while (lo <= hi) {
	mid = (lo + hi) >> 1;
	s1 = s;
	s2 = MacNames[mid];
	while (*s1 == *s2++)
	  if(*s1++==0) return mid;
	if (*s1 < *--s2)
	    hi = mid - 1;
	else
	    lo = mid + 1;
    }
    return - lo - 1;
}

/* define the named macro to have the given body
   (or mlisp proc) */
DefMac (s, bodyparm, IsMLisp)
char *s, *bodyparm;
{
    register int    i = FindMac (s);
    register struct BoundName  *p;
    union {
        struct keymap * b_keymap;
        struct ProgNode * b_ProgNode;
        char * b_string;
    } body;
    body.b_string = bodyparm;
    if (i < 0) {
	register j;
	if (NMacs >= maxmacs) {
	    error ("Too many macro definitions.");
	    return;
	}
	j = NMacs++;
	i = -i - 1;
	while (j > i) {
	    MacNames[j] = MacNames[j-1];
	    MacBodies[j] = MacBodies[j-1];
	    j--;
	}
	MacNames[NMacs] = 0;
	p = MacBodies[i] =
	    (struct BoundName  *) malloc (sizeof (struct BoundName));
	p -> b_name = MacNames[i] = savestr (s);
	p -> b_active = 0;
    }
    else {
	if ((p = MacBodies[i]) -> b_binding == ProcBound) {
	    error ("%s is already bound to a wired procedure!", s);
	    return;
	}
	if (p -> b_binding == MLispBound)
	    LispFree (p -> b_bound.b_prog);
	else if (p -> b_binding == KeyBound) {
	    register struct buffer *b;
	    for (b = buffers; b; b = b->b_next)
		if (b->b_mode.md_keys == p -> b_bound.b_keymap)
		    b -> b_mode.md_keys = 0;
	    if (CurrentGlobalMap == p -> b_bound.b_keymap)
		CurrentGlobalMap == &GlobalMap;
	    if (bf_mode.md_keys == p -> b_bound.b_keymap)
		bf_mode.md_keys == 0;
	    NextLocalKeymap = NextGlobalKeymap = 0;
	    free (p -> b_bound.b_keymap);
	}
	else
	    free (p -> b_bound.b_body);
    }
    if (IsMLisp == -1) {
	p -> b_binding = AutoLoadBound;
	p -> b_bound.b_body = savestr (body.b_string);
    }
    else if (IsMLisp == -2) {
	p -> b_binding = KeyBound;
	p -> b_bound.b_keymap = body.b_keymap;
    }
    else if (IsMLisp) {
	p -> b_binding = MLispBound;
	p -> b_bound.b_prog = body.b_ProgNode;
    }
    else {
	p -> b_binding = MacroBound;
	p -> b_bound.b_body = savestr (body.b_string);
    }
}

EditMacro () {
    register    i = getword (MacNames, ": edit-macro ");
    register struct BoundName  *p;
    if (i < 0)
	return 0;
    p = MacBodies[i];
    if (p -> b_binding != MacroBound)
	error ("%s is a procedure, not a macro!", p -> b_name);
    else {
	SetBfn ("Macro edit");
	EraseBf (bf_cur);
	if(bf_cur->b_fname) free(bf_cur->b_fname);
	bf_cur->b_fname = savestr (p->b_name);
	bf_cur->b_kind = MacroBuffer;
	WindowOn (bf_cur);
	InsStr (p -> b_bound.b_body);
	bf_modified = 0;
	BeginningOfFile ();
    }
    return 0;
}

DefineBufferMacro () {
    if (bf_cur -> b_kind != MacroBuffer || bf_cur -> b_name == 0)
	error ("This buffer doesn't contain a named macro.");
    else {
	GapTo (bf_s1 + bf_s2 + 1);	/* ignoring our abstract data type
					   hiding!! */
	*(bf_p1 + bf_s1 + 1) = 0;
	DefMac (bf_cur -> b_fname, (bf_p1 + 1), 0);
	bf_modified = 0;
    }
}

/* Sort the macro table */
SortMacros () {
    register    i,
                j;
    int     lnmacs = NMacs;
    if (MacrosAreSorted)
	return;
    MacrosAreSorted++;
    for (NMacs = 0; (j = NMacs) < lnmacs;) {
	register char  *p = MacNames[j];
	register struct BoundName  *b = MacBodies[j];
	i = FindMac (p);
	NMacs++;
	i = -i - 1;
	while (j > i) {
	    MacNames[j] = MacNames[j - 1];
	    MacBodies[j] = MacBodies[j - 1];
	    j--;
	}
	MacNames[i] = p;
	MacBodies[i] = b;
    }
    MacNames[NMacs] = 0;
}

static
ScanMap (map)
register struct keymap *map; {
    register struct BoundName  *p,
                              **scan;
    register i;
    for (i = 0; i < 0200; i++)
	if (p = map -> k_binding[i]) {
	    register char   c = i & 0177;
	    for (scan = MacBodies; scan < NewNames;)
		if (*scan++ == p)
		    goto SkipIt;
	    *NewNames++ = p;
    SkipIt: 
	    if ('a' <= c && c <= 'z')
		map -> k_binding[i & 0737] = p;
	}
}

InitMacros () {
    register int    i;
    register struct BoundName *p;
    if (! Once)
    {
	defproc (EditMacro, "edit-macro");
	defproc (DefineBufferMacro, "define-buffer-macro");
	ScanMap (&GlobalMap);
	ScanMap (&ESCmap);
	ScanMap (&CtlXmap);
	for(i=0; p = MacBodies[i]; i++)
	    MacNames[i] = p->b_name;
	MacNames[i] = "nothing";
	MacBodies[i++] = 0;
	NMacs = i;
	SortMacros ();
    }
}
