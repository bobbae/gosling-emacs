/* Support routines for the undo facility */

#include "buffer.h"
#include "window.h"
#include "keyboard.h"
#include "undo.h"

static struct UndoRec UndoRQ[NUndoR];	/* The undo records */
static char	      UndoCQ[NUndoC];	/* And the characters associated with
					   them */

static FillRQ;
static FillCQ;
static NUndone;
static NCharsLeft;
static LastUndoneC;
static struct UndoRec *LastUndone;
static struct UndoRec *LastUndoRec;

struct UndoRec *NewUndo (kind, dot, len)
enum Ukinds kind; {
    register struct UndoRec *p = &UndoRQ[FillRQ];
    register struct UndoRec *np;
    if (FillRQ >= NUndoR) {
	FillRQ = 0;
	np = UndoRQ;
    } else {
	FillRQ++;
	np = p+1;
    }
    np -> kind = Unundoable;
    p -> kind = kind;
    p -> buffer = bf_cur;
    p -> dot = dot;
    p -> len = len;
    LastUndoRec = p;
    if (kind != Uboundary)
	LastUndone = 0;
    return p;
}

RecordInsert (dot, n) {
    register struct UndoRec *p = LastUndoRec;
    if (p && p -> kind == Udelete && p -> dot + p -> len == dot)
	p -> len += n;
    else
	NewUndo (Udelete, dot, n);
}

RecordDelete (dot, n)
register    dot; {
    register struct UndoRec *p = LastUndoRec;
    if (p && p -> kind == Uinsert && p -> dot + p -> len == dot)
	p -> len += n;
    else
	NewUndo (Uinsert, dot, n);
    NCharsLeft -= n;
    while (--n >= 0) {
	UndoCQ[FillCQ] = CharAt (dot);
	if (FillCQ >= NUndoC)
	    FillCQ = 0;
	else
	    ++FillCQ;
	dot++;
    }
}

DoneIsDone () {
    NewUndo (Unundoable, dot, 0);
    return 0;
}

UndoBoundary () {
    NewUndo (Uboundary, dot, 0);
    return 0;
}

Undo () {
    arg++;
    LastUndone = LastUndoRec;
    NCharsLeft = NUndoC;
    NUndone = 0;
    LastUndoneC = FillCQ;
    UndoMore ();
}

UndoMore () {
    register struct UndoRec *p = LastUndone;
    register    n = 0;
    register    chars;
    if (p == 0) {
	error ("Cannot undo more: changes have been made since the last undo");
	return 0;
    }
    while (1) {
	while (p -> kind != Uboundary) {
	    if (p -> kind == Uinsert && (NCharsLeft -= p -> len) < 0
		    || p -> kind == Unundoable || NUndone >= NUndoR) {
		error ("Sorry, I can't undo that.  What's done is done.");
		return 0;
	    }
	    NUndone++;
	    n++;
	    p--;
	    if (p < UndoRQ)
		p = &UndoRQ[NUndoR - 1];
	}
	NUndone++;
	n++;
	if (--arg <= 0)
	    break;
	p--;
	if (p < UndoRQ)
	    p = &UndoRQ[NUndoR - 1];
    }
    p = LastUndone;
    chars = LastUndoneC;
    while (--n >= 0) {
	if (bf_cur != p -> buffer)
	    SetBfp (p -> buffer);
	SetDot (p -> dot);
	switch (p -> kind) {
	    case Uboundary: 
		break;
	    case Udelete: 
		DelFrwd (dot, p -> len);
		break;
	    case Uinsert: {
		    register    len = p -> len;
		    chars -= len;
		    if (chars < 0) {
			InsCStr (UndoCQ, len + chars);
			len = -chars;
			chars += NUndoC;
		    }
		    InsCStr (UndoCQ + chars, len);
		}
		break;
	    default: 
		error ("Something rotten in undo");
		return 0;
	}
	p--;
	if (p < UndoRQ)
	    p = &UndoRQ[NUndoR - 1];
    }
    LastUndone = p;
    LastUndoneC = chars;
    return 0;
}

InitUndo () {
    if (!Once)
    {
	setkey (CtlXmap, Ctl ('u'), Undo, "undo");
	defproc (UndoBoundary, "undo-boundary");
	defproc (UndoMore, "undo-more");
    }
    DoneIsDone ();
}
