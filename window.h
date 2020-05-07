/* header file for the window manipulation primitives */

/*		Copyright (c) 1981,1980 James Gosling		*/

/* structure that defines a window */
struct window {
/* windows are organized in a double linked list.  Each window has
   its own value of 'dot' and is tied to some buffer */
    struct window *w_prev,	/* preceeding window */
		  *w_next;	/* next window */
    struct buffer *w_buf;	/* buffer tied to this window */
    struct marker *w_dot;	/* value of "dot" for this buffer */
    struct marker *w_start;	/* start character position in the tied
				   buffer of the display */
    int w_height;		/* number of screen lines devoted to
				   this window; includes space for
				   the mode line */
    int w_lastuse;		/* sequence counter for LRU window
				   finding */
    int w_force;		/* true iff the value of start MUST
				   be used on the next redisplay */
};

struct window *wn_cur;		/* current window */
int dot;			/* value of dot from the current
				   window */
int DotCol;			/* print column for the character immediatly
				   to the right of dot (the one that
				   CharAt(dot) gives you) */
int ColValid;			/* true iff DotCol is valid */

/* CurCol returns the current print column number for dot, which may
   have to be calculated */
#define CurCol (ColValid ? DotCol : CalcCol())

/* dot should ONLY be given a value by calling SetDot(new) -- it ensures
   that all associated bookkeeping is done. */
#define SetDot(n) (ColValid = 0, dot = (n))

/* dot should be moved left or right using the following macros -- they
   attempt (or will, eventually) to keep DotCol valid.  They don't check
   the new valid of dot: you have to do that. */
#define DotRight(n) (ColValid = 0, dot += (n))
#define  DotLeft(n) (ColValid = 0, dot -= (n))

struct window *windows;		/* the root of the list of windows */
char *MiniBuf;			/* text to appear in the minibuffer */
char *ResetMiniBuf;		/* the text that the minibuf contents are to
				   be reset to with each display cycle */
int InMiniBuf;			/* true iff the cursor is in the minibuffer */
int err;			/* true iff MiniBuff represents an
				   error message */
char *BrGetstr();		/* get a string from the minibuffer */
char *getstr();			/* get a string from the minibuffer,
				   terminating on CR or ESC */
char *getnbstr();		/* get a string from the minibuffer,
				   terminating on CR, ESC or whitespace */
char *getkey();			/* get a keystroke sequence, where the limits
				   of the sequence are determined by the
				   current keymaps */

/* the following variables are all involved in a rather lamentable
   compromising of principles: doing the full-blown redisplay is just too
   expensive, so we drop hints for later optimization.  These hints
   had better be right!  */
int Cant1LineOpt;		/* true if can't use the one line optimized
				   redisplay */
int Cant1WinOpt;		/* true if can't use the one window optimized
				   redisplay */
int CantEverOpt;		/* true if can't ever use any optimized
				   redisplay (eg. two windows on same
				   buffer) */
int RedoModes;			/* true iff we should redraw the mode lines
				   on the next redisplay */
int DumpMiniBuf;		/* true iff the MiniBuf has changed */
int CtlArrow;			/* true iff control characters are to be
				   displayed with ^'s rather than \nnn */
