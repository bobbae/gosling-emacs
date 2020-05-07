/* Routines to handle most of the "Meta" commands */

/*		Copyright (c) 1981,1980 James Gosling		*/

/* Modified DJH 7-Dec-80	Add end-of-window = Meta-Period	*/

#include "macros.h"
#include "window.h"
#include "buffer.h"
#include "keyboard.h"
#include "syntax.h"

DeleteRegionToBuffer () {
    register char *fn = getnbstr("Move region to buffer: ");
    if(fn==0) return 0;
    if (bf_cur -> b_mark == 0) {
	error ("Mark not set");
	return 0;
    }
    DelToBuf (ToMark (bf_cur -> b_mark) - dot, 0, 1, fn);
    return 0;
}

YankBuffer () {
    register int i = getword(BufNames, "Insert contents of buffer: ");
    register char *fn = i < 0 ? 0 : BufNames[i];
    if(fn==0) return 0;
    InsertBuffer (fn);
    return 0;
}

BeginningOfFile () {		/* $< */
    SetDot (FirstCharacter);
    return 0;
}

EndOfFile () {			/* $> */
    SetDot (NumCharacters + 1);
    return 0;
}

/* DJH -- go to end of window.	*/
EndOfWindow () {		/* $. */
    SetDot (ScanBf ('\n', ToMark (wn_cur -> w_start),
		wn_cur -> w_height - 2));
    EndOfLine ();
    return 0;
}

BeginningOfWindow () {		/* $, */
    SetDot (ToMark (wn_cur -> w_start));
    return 0;
}

/* skip over (non) punctuation characters; punct=1 => skip punctuation,
   0 => skip non-punctuation; incr=1 => forward, -1 => backward.
   returns number of characters skipped (signed) */
SkipOver (punct, incr, dot)
register    incr,
	    dot; {
    register    n = 0;
    if (incr < 0)
	dot--;
    while ((bf_mode.md_syntax->s_table[CharAt (dot)].s_kind != WordChar)
		== punct
	    && dot >= FirstCharacter && dot <= NumCharacters) {
	dot += incr;
	n += incr;
    }
    return n;
}

WordOperation (direction, delete) {
    register    incr,
                n;
    do {
	incr = direction;
	n = SkipOver (1, incr, dot);
	if ((n += SkipOver (0, incr, dot + n)) == 0)
	    return 0;
	if (direction < 0 && delete)
	    DelBack (dot, -n), DotLeft (-n);
	else
	    if (delete)
		DelFrwd (dot, n);
	    else
		DotRight (n);
    } while (--arg > 0 && !err);
    return 0;
}

ForwardWord() {
    WordOperation (1, 0);
}

BackwardWord() {
    WordOperation (-1, 0);
}

DeleteNextWord() {
    WordOperation (1, 1);
}

DeletePreviousWord() {
    WordOperation (-1, 1);
}

static struct BoundName *AproposTarget;
static char *AproposPointer;

AproposHelper (b, keys, len, range)
register struct BoundName *b;
char *keys;
{
    register    k;
    char   *s;
    if (b != AproposTarget) return;
    s = KeyToStr (keys, len);
    k = strlen (s);
    strcpy (AproposPointer, ", ");
    strcpy (AproposPointer + 2, s);
    AproposPointer += k + 2;
    if (range > 1) {
	keys[len - 1] += range-1;
	strcpy (AproposPointer, "..");
	s = KeyToStr (keys, len);
	k = strlen (s);
	strcpy (AproposPointer + 2, s);
	AproposPointer += k + 2;
	keys[len - 1] -= range-1;
    }
    *AproposPointer = 0;
}

Apropos () {			/* $? */
    register char  *keyword = getnbstr (": apropos keyword: ");
    register struct buffer *old = bf_cur;
    register    i;
    char    buf[4000];
    if (keyword == 0)
	return 0;
    SetBfn ("Help");
    WindowOn (bf_cur);
    WidenRegion ();
    EraseBf (bf_cur);
    for (i = 0; MacNames[i]; i++)
	if (sindex (MacNames[i], keyword)) {
	    char    keys[3000];
	    keys[0] = 0;
	    AproposPointer = keys;
	    AproposTarget = MacBodies[i];
	    ScanMap (CurrentGlobalMap, AproposHelper, 1);
	    ScanMap (old -> b_mode.md_keys, AproposHelper, 1);
	    InsStr (sprintfl (buf, sizeof buf, keys[0] ? "%-30s(%s)\n" : "%s\n",
			MacNames[i], keys + 2));
	}
    SetDot (1);
    bf_cur -> b_mode.md_NeedsCheckpointing = 0;
    bf_modified = 0;
    SetBfp (old);
    WindowOn (bf_cur);
    return 0;
}

InitMeta () {
    if (!Once)
    {
	setkey (ESCmap, (Ctl ('W')), DeleteRegionToBuffer, "delete-region-to-buffer");
	setkey (ESCmap, (Ctl ('Y')), YankBuffer, "yank-buffer");
	setkey (ESCmap, ('<'), BeginningOfFile, "beginning-of-file");
	setkey (ESCmap, ('>'), EndOfFile, "end-of-file");
	setkey (ESCmap, ('.'), EndOfWindow, "end-of-window");	/* DJH */
	setkey (ESCmap, (','), BeginningOfWindow, "beginning-of-window");
	setkey (ESCmap, ('?'), Apropos, "apropos");
	setkey (ESCmap, ('f'), ForwardWord, "forward-word");
	setkey (ESCmap, ('b'), BackwardWord, "backward-word");
	setkey (ESCmap, ('h'), DeletePreviousWord, "delete-previous-word");
	setkey (ESCmap, ('d'), DeleteNextWord, "delete-next-word");
    }
}
