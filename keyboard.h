/* key->procedure mapping table definitions */

/*		Copyright (c) 1981,1980 James Gosling		*/

#define Ctl(c) ((c)&037)

struct ProgNode {		/* a node in an MLisp (minimal lisp)
				   program node */
    struct BoundName *p_proc;	/* The dude that executes this node */
    short p_nargs;		/* The number of arguments to this node */
    int p_active:1;		/* True iff this node is being executed. */
    struct ProgNode *p_args[1];	/* The actual arguments -- this is really
				   an extensible array (!!!) */
};

/* The things that an executable symbol can be bound to */
enum BindingKind {
    ProcBound,			/* a wired-in procedure */
    MacroBound,			/* a macro (string) */
    MLispBound,			/* an MLisp function */
    AutoLoadBound,		/* a function to be autoloaded */
    KeyBound,			/* bound to a keymap */
};

struct BoundName {		/* a name-procedure/macro binding */
    union {
	char   *b_body;		/* body of the macro to which this name
				   is bound */
	int     (*b_proc) ();	/* pointer to the procedure to which
				   this name is bound */
	struct ProgNode *b_prog;	/* The MLisp program node to which
					   this name is bound */
	struct keymap *b_keymap;	/* The keymap to which this name is
					   bound */
    } b_bound;
    char   *b_name;		/* the name to which this procedure or
				   macro is bound */
    enum BindingKind b_binding;	/* The kind of thing this symbol is bound
				   to */
    int     b_active:1;		/* true iff this (macro) is active --
				   prevents recursive macro calls */
};

#ifdef NewC
struct BoundNameProc {		/* a name-procedure binding */
				/* needed because C won't let us statically
				   initialize unions */
/*  union {
	char   *b_body;		/* body of the macro to which this name
				   is bound */
	int     (*b_proc) ();	/* pointer to the procedure to which
				   this name is bound
    } b_bound; */
    char   *b_name;		/* the name to which this procedure or
				   macro is bound */
    enum BindingKind b_binding;	/* The kind of thing this symbol is bound
				   to */
};
#endif

struct keymap {
    struct BoundName *k_binding[0200];
};

/* keymaps are structured as trees: an entry in a keymap can point to yet
   another keymap -- this is how prefix keys are handled.  Looking up a key
   in a keymap is an FSM-like traversal.  The global and local maps are
   traversed in parallel when reading keystrokes. */
struct keymap *NextGlobalKeymap;	/* The "global" keymap to be used for
					   the next key lookup; null=>use
					   Globalmap */
struct keymap *NextLocalKeymap;	/* The "local" keymap to be used for the next
				   key lookup; null=>use the map associated
				   with the current buffer. */
struct keymap GlobalMap;	/* default global key bindings */
struct keymap *CurrentGlobalMap;	/* Current global keymap */
struct keymap ESCmap;		/* The keymap used for globally bound
				   ESC-prefixed default commands */
struct keymap MinibufLocalMap;	/* The keymap used by the minibuf for local
				   bindings when spaces are allowed in the
				   minibuf */
struct keymap MinibufLocalNSMap;/* The keymap used by the minibuf for local
				   bindings when spaces are not allowed in
				   the minibuf */
struct keymap CtlXmap;		/* The keymap used for globally bound
				   ^X-prefixed default commands */
struct BoundName **NewNames;	/* points into the list of bound macro
				   names; used for initialization */
int (*LastProc)();		/* the last procedure called -- used by
				   folks like ^N and ^P to decide whether
				   or not they should calculate a new
				   column */
int arg;			/* argument to this command */
enum ArgStates {		/* the possible states that the
				   prefix-argument scanning could be in */
	NoArg, HaveArg, PreparedArg
} ArgState;

#define MemLen 1000
int MemUsed;			/* the length of the keyboard macro */
char KeyMem[MemLen];		/* the contents of the keyboard macro */
int Remembering;		/* true iff we're in "remember" mode */

char ttydev[30];		/* name of tty dev, set in main */
				/* used to fix idle time problem */

#ifndef FILE
#include <stdio.h>
#endif
FILE *InputFD;			/* file structure from which commands are
				   to be read */
FILE *fopenp();			/* open a file given a search path */
struct BoundName **LookupKeys();	/* Lookup a bound name given the
					   sequence of keystrokes that is
					   supposed to invoke it */
char *KeyToStr ();		/* Given a sequence of keystrokes, return it
				   as something printable (eg. as "ESC-F") */
char *MemPtr;			/* pointer into the currently-being-expanded
				   macro body */
struct ProgNode *CurExec;	/* the program node that is currently being
				   executed */
int LastArgUsed;		/* the index (in CurExec->p_args) of the last
				   argument fetched via getstr. */

/* true iff we're processing interactive input */
#define interactive (InputFD==stdin && MemPtr==0 && CurExec==0)


#ifdef NewC
#define setkey(map, k, proc, nm) { static struct BoundNameProc b \
		= {proc, nm, ProcBound}; \
	map.k_binding[k] = (struct BoundName *) &b; }
#else
#define setkey(map, k, proc, nm) { static struct BoundName b; \
	b.b_name = nm; b.b_bound.b_proc = proc; \
	map.k_binding[k] = &b; }
#endif
#define synkey(map1,new,map2,old) map1.k_binding[new] = map2.k_binding[old]
	
#ifdef NewC
#define defproc(proc, nm) { static struct BoundNameProc b \
		= {proc, nm, ProcBound}; \
	*NewNames++ = (struct BoundName *) &b; }
#else
#define defproc(proc, nm) { static struct BoundName b; \
	b.b_name = nm; b.b_bound.b_proc = proc; \
	*NewNames++ = &b; }
#endif

/* Defines an MLisp callable function whose value will be the given integer */
#define IntFunc(name,val) static name () { \
	MLvalue -> exp_type = IsInteger; \
	MLvalue -> exp_int = val; \
	return 0; \
}

/* Defines an MLisp callable function whose value will be the given marker */
#define MarkFunc(name,val) static name () { \
	MLvalue -> exp_type = IsMarker; \
	MLvalue -> exp_v.v_marker = NewMark(); \
	SetMark (MLvalue -> exp_v.v_marker, bf_cur, val); \
	MLvalue -> exp_release = 1; \
	return 0; \
}

/* Defines an MLisp callable function whose value will be the given string */
#define StrFunc(name,val) static name () { \
	MLvalue -> exp_type = IsString; \
	MLvalue -> exp_v.v_string = val; \
	MLvalue -> exp_release = 0; \
	MLvalue -> exp_int = strlen(MLvalue -> exp_v.v_string); \
	return 0; \
}

char LastKeyStruck;		/* The last key struck as a command */
int MetaFlag;			/* True iff keyboard has a meta key */
int InputPending;		/* True iff keyboard input is known to be
				   pending */
int RecurseDepth;		/* Depth of recursion in recursive edits */
int MinibufDepth;		/* Depth of recursion in minibuf edits */
int PreviousCommand;		/* This is the value of last-key-struck for
				   the previous command.  It can be set by
				   assigning to the variable
				   previous-command, but this change will not
				   actually occur until the next command is
				   executed.  Useful for kill commands that
				   are supposed to chain together */
int ThisCommand;		/* The value returned for (previous-command)
				   in this command, it is the value of the
				   previous-command variable set by the
				   previous command */
int LastRedisplayPaused;	/* True iff the last redisplay paused
				   because input from the keyboard was
				   seen. */
int Once;			/* Flag for things that should only be
				   done the first time Emacs is invoked */
