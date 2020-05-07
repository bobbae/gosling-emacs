/* process the simple commands */

/*		Copyright (c) 1981,1980 James Gosling		*/

/* Modified DJH 7-Dec-80	Make EndOfLine not back up at end of buffer
				Destatize EndOfLine for Meta-Period
 */

#include "buffer.h"
#include "window.h"
#include "keyboard.h"
#include "syntax.h"
#include "mlisp.h"
#include "macros.h"
#include <ctype.h>

static
BeginningOfLine () {
    SetDot (ScanBf ('\n', dot, -1));
    return 0;
}

static
BackwardCharacter () {
    DotLeft (arg);
    if (dot < FirstCharacter){
	SetDot (FirstCharacter);
	error("You're are the beginning of the buffer");
    }
    return 0;
}

static
ExitEmacs () {
    return -1;
}

static
DeleteNextCharacter () {
    DelFrwd (dot, arg);
    return 0;
}

/* DJH -- Don't back up at end of buffer
	  Removed "static" for Meta-Period use
 */
EndOfLine () {
    register ndot = ScanBf ('\n', dot, 1);
    if (dot != ndot) {
	SetDot(ndot);
	if (CharAt (ndot - 1) == '\n')
	    BackwardCharacter ();
    }
    return 0;
}

static
ForwardCharacter () {
    DotRight (arg);
    if (dot > NumCharacters + 1){
	SetDot (NumCharacters + 1);
	error("You're at the end of the buffer.");
    }
    return 0;
}

IllegalOperation () {
    err++;
    return 0;
}

static
DeletePreviousCharacter () {
    DelBack (dot, arg);
    DotLeft (arg);
    return 0;
}

static
NewlineAndIndent () {
    register    DC = CurIndent ();
    SelfInsert ('\n');
    ToCol (DC);
    return 0;
}

static
KillToEndOfLine () {
    register    nd;
    register count = arg;
    register merge = LastProc == KillToEndOfLine;
    register struct buffer *bf;
    do {
	arg = 1;
	nd = dot;
	EndOfLine ();
	nd = dot - nd;
	if (nd <= 0)
	    nd = -1;
	bf = DelToBuf (-nd, merge, 1, "Kill buffer");
	merge = 1;
    } while (--count > 0);
    if (bf) bf->b_mode.md_NeedsCheckpointing = 0;
    return 0;
}

static
RedrawDisplay () {
    extern  ScreenGarbaged;
    ScreenGarbaged++;
    return 0;
}

static
Newline () {
    SelfInsert ('\n');
    return 0;
}

int TrackEol;			/* true iff ^n and ^p should stick with
				   eol's */

static
NextLine() {
    LineMove (0);
    return 0;
}

static  PreviousLine() {
    LineMove (1);
    return 0;
}

static  LineMove (up) {
    register    n = arg;
    static  lastcol;
    register    ndot;
    register    col = 1;
    register    lim = NumCharacters + 1;
    if (n == 0) return;
    if (n < 0) n = -n, up = !up;
    if (up)
	n = -n - 1;
    if (LastProc != NextLine && LastProc != PreviousLine)
	lastcol = TrackEol && dot<lim && CharAt(dot)=='\n' ? 9999 : CurCol;
    ndot = ScanBf ('\n', dot, n);
    while (col < lastcol && ndot < lim) {
	n = CharAt (ndot);
	if (n == '\n')
	    break;
	if (n == 011)
	    col = ((col - 1) / bf_mode.md_TabSize + 1)
				* bf_mode.md_TabSize + 1;
	else
	    if (n < 040 || n >= 0177)
		col += CtlArrow? 2 : 4;
	    else
		col += 1;
	ndot++;
    }
    SetDot (ndot);
    DotCol = col;
    ColValid = 1;
    return 0;
}

static
NewlineAndBackup () {
    register int larg = arg;
    SelfInsert ('\n');		/* SelfInsert () zeros arg... */
    DotLeft (larg);
    return 0;
}

static
QuoteCharacter () {
    register abbrev = bf_mode.md_AbbrevOn;
    bf_mode.md_AbbrevOn = 0;
    SelfInsert (GetChar ());
    bf_mode.md_AbbrevOn = abbrev;
    return 0;
}

static
TransposeCharacters () {
    if (dot >= 3) {
	register char   c = CharAt (dot - 1);
	DelBack (dot, 1);
	InsertAt (dot-2, c);
    }
    return 0;
}

static ArgumentPrefixcnt;

static ArgumentPrefix () {
    if (ArgState == NoArg) {
	arg = 4;
	ArgumentPrefixcnt = 1;
    }
    else {
	arg *= 4;
	ArgumentPrefixcnt++;
    }
    ArgState = PreparedArg;
    return 0;
}

CopyRegionToBuffer () {
    register char *name;
    if (bf_cur -> b_mark == 0) {
	error ("Mark not set");
	return 0;
    }
    name = getnbstr(": copy-region-to-buffer ");
    if(name)
	DelToBuf (ToMark (bf_cur -> b_mark) - dot, 0, 0, name);
    return 0;
}

AppendRegionToBuffer () {
    register char *name;
    if (bf_cur -> b_mark == 0) {
	error ("Mark not set");
	return 0;
    }
    name = getnbstr(": append-region-to-buffer ");
    if(name)
	DelToBuf (ToMark (bf_cur -> b_mark) - dot, 1, 0, name);
    return 0;
}

PrependRegionToBuffer () {
    register char *name;
    if (bf_cur -> b_mark == 0) {
	error ("Mark not set");
	return 0;
    }
    name = getnbstr(": prepend-region-to-buffer ");
    if(name)
	DelToBuf (ToMark (bf_cur -> b_mark) - dot, -1, 0, name);
    return 0;
}

DeleteToKillbuffer () {
    register struct buffer *bf;
    if (bf_cur -> b_mark == 0) {
	error ("Mark not set");
	return 0;
    }
    bf = DelToBuf (ToMark (bf_cur -> b_mark) - dot, 0, 1, "Kill buffer");
    if (bf) bf->b_mode.md_NeedsCheckpointing = 0;
    return 0;
}

YankFromKillbuffer () {
    InsertBuffer ("Kill buffer");
    return 0;
}


Minus () {
    if (ArgState == HaveArg && ArgumentPrefixcnt > 0) {
	arg = -arg;
	ArgumentPrefixcnt = -1;
	ArgState = PreparedArg;
	return 0;
    }
    SelfInsert (-1);
    return 0;
}

MetaMinus () {
    ArgumentPrefixcnt = -1;
    arg = -arg;
    ArgState = PreparedArg;
    return 0;
}

Digit () {
    if (ArgState==HaveArg) {
	if (ArgumentPrefixcnt)
	    arg = 0;
	if (arg < 0 || ArgumentPrefixcnt < 0)
	    arg = arg * 10 - (LastKeyStruck - '0');
	else
	    arg = arg * 10 + LastKeyStruck - '0';
	ArgumentPrefixcnt = 0;
	ArgState = PreparedArg;
	return 0;
    }
    SelfInsert (-1);
    return 0;
}

MetaDigit (c)
{
    if (ArgState == HaveArg) {
	if (ArgumentPrefixcnt)
	    arg = 0;
	if (arg < 0 || ArgumentPrefixcnt < 0)
	    arg = arg * 10 - (LastKeyStruck - '0');
	else
	    arg = arg * 10 + LastKeyStruck - '0';
	ArgumentPrefixcnt = 0;
	ArgState = PreparedArg;
	return 0;
    }
    else {
	arg = LastKeyStruck - '0';
	ArgumentPrefixcnt = 0;
	ArgState = PreparedArg;
	return 0;
    }
}

ArgDigit () {
    if (ArgState==HaveArg) {
	if (ArgumentPrefixcnt)
	    arg = 0;
	if (arg < 0 || ArgumentPrefixcnt < 0)
	    arg = arg * 10 - (LastKeyStruck - '0');
	else
	    arg = arg * 10 + LastKeyStruck - '0';
	ArgumentPrefixcnt = 0;
	ArgState = PreparedArg;
	return 0;
    }
    ArgState == NoArg;
    arg = 1;
    return 0;
}

/****
Digit () {
    if (ArgState==HaveArg) {
	if (ArgumentPrefixcnt)
	    arg = 0;
	ArgumentPrefixcnt = 0;
	arg = arg * 10 + LastKeyStruck - '0';
	ArgState = PreparedArg;
	return 0;
    }
    SelfInsert (-1);
    return 0;
}
*/

DeleteWhiteSpace () {
    register char   c;
    register    p1,
                p2;
    for (p1 = dot, p2 = NumCharacters;
	    p1 <= p2 && ((c = CharAt (p1)) == ' ' || c == '\t');
	    p1++);
    for (p2 = dot; --p2 >= FirstCharacter && ((c = CharAt (p2)) == ' ' || c == '\t'););
    SetDot (p2 + 1);
    if ((p1 = p1 - p2 - 1) > 0)
	DelFrwd (dot, p1);
    return 0;
}

SelfInsert(c)
register    c; {
    register int    p;
    register int    rep = arg;
    if (InputFD != stdin)
	return 0;
    arg = 1;
    if (c < 0)
	c = LastKeyStruck;
    if (bf_mode.md_AbbrevOn && !CharIs (c, WordChar)
	    && (p = dot - 1) >= FirstCharacter && CharIs (CharAt (p), WordChar))
	if (AbbrevExpand ()) return 0;
    do {
	if (c > ' ' && ((p = dot) > NumCharacters || CharAt (p) == '\n'))
	    if (p > FirstCharacter && CurCol > bf_mode.md_RightMargin) {
		register char   bfc;
		if (bf_cur -> b_AutoFillHook) {
		    ExecuteBound (bf_cur -> b_AutoFillHook);
		    if (MLvalue -> exp_type == IsInteger
				&& MLvalue ->exp_int == 0)
			return 0;
		}
		else {
		    while ((p = dot - 1) >= FirstCharacter) {
			bfc = CharAt (p);
			if (bfc == '\n') {
			    p = 0;
			    break;
			}
			if (bfc >= 040 && bfc < 0177)
			    DotCol--, dot--;
			else
			    DotLeft (1);
			if ((bfc == ' ' || bfc == '\t')
				&& CurCol <= bf_mode.md_RightMargin)
			    break;
		    }
		    if (p >= FirstCharacter) {
			DeleteWhiteSpace ();
			arg = 1;
			InsertAt (dot, '\n');
			DotRight (1);
			ToCol (bf_mode.md_LeftMargin);
			if (bf_mode.md_PrefixString[0])
			    InsStr (bf_mode.md_PrefixString);
		    }
		    EndOfLine ();
		}
	    }
	InsertAt (dot, c);
	DotRight (1);
    } while (--rep > 0);
    return 0;
}

static
SetAutoFillHook () {
    int proc = getword (MacNames, ": set-auto-fill-hook to procedure ");
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_v.v_string = bf_cur -> b_AutoFillHook == 0 ?
				"nothing" :
				bf_cur -> b_AutoFillHook -> b_name;
    MLvalue -> exp_release = 0;
    MLvalue -> exp_int = strlen (MLvalue -> exp_v.v_string);
    if (proc >= 0)
	bf_cur -> b_AutoFillHook = MacBodies[proc];
    return 0;
}

SetMarkCommand () {
    if (bf_cur -> b_mark == 0)
	bf_cur -> b_mark = NewMark ();
    SetMark (bf_cur -> b_mark, bf_cur, dot);
    if(interactive) message ("Mark set.");
    return 0;
}

ExchangeDotAndMark () {
    register    old_dot = dot;
    if (bf_cur -> b_mark == 0)
	error ("No mark set in this buffer!");
    else {
	SetDot (ToMark (bf_cur -> b_mark));
	SetMark (bf_cur -> b_mark, bf_cur, old_dot);
    }
    return 0;
}

EraseRegion () {
    if (bf_cur -> b_mark == 0)
	error ("No mark set in this buffer!");
    else {
	register n = ToMark (bf_cur -> b_mark) - dot;
	if (n<0) {
	    n = -n;
	    DotLeft (n);
	}
	DelFrwd (dot, n);
    }
    return 0;
}

/* Delete n (signed) characters from the region around dot, moving them to
   the named buffer.  The text will be prepended to the buffer if where<0,
   will replace the buffer contents if where==0, and will be appended to
   the buffer if where>0.
   The deletion is only actually performed if doit is true.
   DelToBuf returns a pointer to the buffer to which the text was moved. */
struct buffer *
DelToBuf (n, where, doit, name)
char   *name; {
    register    p = dot;
    register struct buffer *old = bf_cur,
                           *kill = FindBf (name);
    if (kill == 0)
	kill = NewBf (name);
    if (where==0)
	EraseBf (kill);
    if (n < 0) {
	n = -n;
	p = p - n;
    }
    if (p < FirstCharacter) {
	n = n + p - FirstCharacter;
	p = FirstCharacter;
    }
    if (p + n > NumCharacters + 1) {
	n = NumCharacters + 1 - p;
    }
    if (n <= 0)
	return kill;
    GapTo (p);
    SetBfp (kill);
    SetDot (where <= 0 ? FirstCharacter : NumCharacters + 1);
    InsCStr (old -> b_base + old -> b_size1 + old -> b_gap, n);
    SetBfp (old);
    if (doit){
	DelFrwd (p, n);
	SetDot (p);
    }
    return kill;
}

/* insert the contents of the named buffer at the current position */
InsertBuffer (name)
char   *name; {
    register struct buffer *who = FindBf (name);
    if (who == 0) {
	error ("non-existant buffer: \"%s\"", name);
	return;
    }
    if (who == bf_cur) {
	error ("Inserting a buffer into itself!");
	return;
    }
    InsCStr (who -> b_base, who -> b_size1);
    InsCStr (who -> b_base + who -> b_size1 + who -> b_gap, who -> b_size2);
}

MoveToCommentColumn () {
    bf_cur->b_mode.md_LeftMargin =
	bf_mode.md_LeftMargin = CurCol == 1 ? 1 : bf_mode.md_CommentColumn;
    ToCol (bf_mode.md_LeftMargin);
    return 0;
}

/* Region restriction manipulation */

WidenRegion () {
    bf_cur -> b_mode.md_HeadClip = bf_mode.md_HeadClip = 1;
    bf_cur -> b_mode.md_TailClip = bf_mode.md_TailClip = 0;
    Cant1WinOpt++;
    return 0;
}

NarrowRegion () {
    if (bf_cur -> b_mark == 0)
	error ("No mark set in this buffer!");
    else {
	register    lo = ToMark (bf_cur -> b_mark);
	register    hi = dot;
	if (hi < lo) {
	    register    t = hi;
	    hi = lo;
	    lo = t;
	}
	bf_cur -> b_mode.md_HeadClip = bf_mode.md_HeadClip = lo;
	bf_cur -> b_mode.md_TailClip = bf_mode.md_TailClip =
		bf_s1 + bf_s2 + 1 - hi;
	Cant1WinOpt++;
    }
    return 0;
}

SaveRestriction () {
    register struct marker
                           *ml = NewMark (),
                           *mh = NewMark ();
    register    rv;
    register struct buffer *b = bf_cur,
                           *b2;
    SetMark (ml, bf_cur, bf_mode.md_HeadClip);
    SetMark (mh, bf_cur, bf_s1 + bf_s2 + 1 - bf_mode.md_TailClip);
    rv = ProgN ();
    b2 = bf_cur;
    b -> b_mode.md_HeadClip = ToMark (ml);
    b -> b_mode.md_TailClip = bf_s1 + bf_s2 + 1 - ToMark (mh);
    DestMark (ml);
    DestMark (mh);
    if (dot < FirstCharacter)
	SetDot (FirstCharacter);
    if (dot > NumCharacters)
	SetDot (NumCharacters + 1);
    if (bf_cur == b2) {
	bf_mode.md_HeadClip = b -> b_mode.md_HeadClip;
	bf_mode.md_TailClip = b -> b_mode.md_TailClip;
    }
    else
	SetBfp (b2);
    Cant1WinOpt++;
    return rv;
}

/* module initialization */

InitSimp () {
    register    n;
    if (!Once)
    {
	setkey (GlobalMap, (Ctl('g')), IllegalOperation, "illegal-operation");
	setkey (GlobalMap, (Ctl('I')), SelfInsert, "self-insert");
	for (n = 040; n < 0177; n++)
	    GlobalMap.k_binding[n] = GlobalMap.k_binding[Ctl('I')];
	setkey (GlobalMap, ('0'), Digit, "digit");
	for (n = '0'; n<='9'; n++)
	    GlobalMap.k_binding[n] = GlobalMap.k_binding['0'];
	setkey (ESCmap, ('0'), MetaDigit, "meta-digit");
	for (n = '0'; n<='9'; n++)
	    ESCmap.k_binding[n] = ESCmap.k_binding['0'];
	setkey (GlobalMap, '-', Minus, "minus");
	setkey (ESCmap, '-', MetaMinus, "meta-minus");
	TrackEol = 1;		/* true => follow eols on ^n and ^P
				       commands */
	setkey (GlobalMap, (Ctl ('A')), BeginningOfLine, "beginning-of-line");
	setkey (GlobalMap, (Ctl ('B')), BackwardCharacter, "backward-character");
	setkey (GlobalMap, (Ctl ('C')), ExitEmacs, "exit-emacs");
	synkey (CtlXmap, (Ctl ('c')), GlobalMap, (Ctl ('C')));
	synkey (ESCmap, (Ctl ('c')), GlobalMap, (Ctl ('C')));
	setkey (GlobalMap, (Ctl ('D')), DeleteNextCharacter, "delete-next-character");
	setkey (GlobalMap, (Ctl ('E')), EndOfLine, "end-of-line");
	setkey (GlobalMap, (Ctl ('F')), ForwardCharacter, "forward-character");
	setkey (GlobalMap, (Ctl ('H')), DeletePreviousCharacter, "delete-previous-character");
	synkey (GlobalMap, (0177), GlobalMap, (Ctl('H')));
	setkey (GlobalMap, (Ctl ('J')), NewlineAndIndent, "newline-and-indent");
	setkey (GlobalMap, (Ctl ('K')), KillToEndOfLine, "kill-to-end-of-line");
	setkey (GlobalMap, (Ctl ('L')), RedrawDisplay, "redraw-display");
	setkey (GlobalMap, (Ctl ('M')), Newline, "newline");
	setkey (GlobalMap, (Ctl ('N')), NextLine, "next-line");
	setkey (GlobalMap, (Ctl ('O')), NewlineAndBackup, "newline-and-backup");
	setkey (GlobalMap, (Ctl ('P')), PreviousLine, "previous-line");
	setkey (GlobalMap, (Ctl ('Q')), QuoteCharacter, "quote-character");
	setkey (GlobalMap, (Ctl ('T')), TransposeCharacters, "transpose-characters");
	setkey (GlobalMap, (Ctl ('U')), ArgumentPrefix, "argument-prefix");
	setkey (GlobalMap, (Ctl ('W')), DeleteToKillbuffer, "delete-to-killbuffer");
	setkey (GlobalMap, (Ctl ('Y')), YankFromKillbuffer, "yank-from-killbuffer");
	setkey (GlobalMap, (Ctl ('@')), SetMarkCommand, "set-mark");
	setkey (CtlXmap, (Ctl('X')), ExchangeDotAndMark, "exchange-dot-and-mark");
	defproc (MoveToCommentColumn, "move-to-comment-column");
	defproc (SetAutoFillHook, "set-auto-fill-hook");
	defproc (DeleteWhiteSpace, "delete-white-space");
	defproc (CopyRegionToBuffer, "copy-region-to-buffer");
	defproc (AppendRegionToBuffer, "append-region-to-buffer");
	defproc (PrependRegionToBuffer, "prepend-region-to-buffer");
	defproc (EraseRegion, "erase-region");
	defproc (NarrowRegion, "narrow-region");
	defproc (WidenRegion, "widen-region");
	defproc (SaveRestriction, "save-restriction");
	defproc (ArgDigit, "arg-digit");
    }
}
