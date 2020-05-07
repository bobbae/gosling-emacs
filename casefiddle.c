/* emacs routines to play with the case of words (invert; set upper; set
   lower; capitalize) */

/*		Copyright (c) 1981,1980 James Gosling		*/

#include "buffer.h"
#include "keyboard.h"
#include "window.h"
#include "syntax.h"
#include <ctype.h>

/* Perform a case translation on the region from character "first" to
   character "last".
	mode=0 => invert
	mode=1 => upper
	mode=2 => lower
	mode=3 => capitalize (upper case first letter; lower case rest)
 */
CaseFiddle (first, last, mode)
register	first,
		last,
mode; {
    register char  *p;
    register    firstlet = 1;
    while (first < last) {
	p = &CharAt (first);
	first++;
	if (!CharIs (*p, WordChar)) {
	    firstlet = 1;
	}
	else {
	    if (isalpha (*p))
		if (mode == 0 ||
			(isupper (*p) ? mode == 2 || mode == 3 && !firstlet
			    : mode == 1 || mode == 3 && firstlet)) {
		    InsertAt (first-1, *p ^ 040);
		    DelFrwd (first, 1);
		}
	    firstlet = 0;
	}
    }
    bf_modified++;
}

CaseWord (mode) {
    register    olddot = dot;
    register    left = arg;
    if(dot<=NumCharacters) DotRight(1);
    arg = 1;
    BackwardWord ();
    Cant1LineOpt++;
    arg = left;
    left = dot;
    ForwardWord ();
    CaseFiddle (left, dot, mode);
    SetDot (olddot);
}

CaseRegion (mode) {
    register    left,
                right = dot;
    if (bf_cur -> b_mark == 0)
	error ("Mark not set.");
    else {
	left = ToMark (bf_cur -> b_mark);
	if (left > right)
	    right = left, left = dot;
	CaseFiddle (left, right, mode);
    }
}

CaseWordInvert () {
    CaseWord (0);
    return 0;
}

CaseWordUpper () {
    CaseWord (1);
    return 0;
}

CaseWordLower () {
    CaseWord (2);
    return 0;
}

CaseWordCapitalize () {
    CaseWord (3);
    return 0;
}

CaseRegionInvert () {
    CaseRegion (0);
    return 0;
}

CaseRegionUpper () {
    CaseRegion (1);
    return 0;
}

CaseRegionLower () {
    CaseRegion (2);
    return 0;
}

CaseRegionCapitalize () {
    CaseRegion (3);
    return 0;
}

InitCase () {
    if (!Once)
    {
	setkey (ESCmap, ('^'), CaseWordInvert, "case-word-invert");
	setkey (ESCmap, ('u'), CaseWordUpper, "case-word-upper");
	setkey (ESCmap, ('l'), CaseWordLower, "case-word-lower");
	defproc (CaseWordCapitalize, "case-word-capitalize");
	setkey (ESCmap, (Ctl ('^')), CaseRegionInvert, "case-region-invert");
	defproc (CaseRegionUpper, "case-region-upper");
	defproc (CaseRegionLower, "case-region-lower");
	defproc (CaseRegionCapitalize, "case-region-capitalize");
    }
}
