/* A random assortment of commands: help facilities, macros, key bindings
   and package loading. */

/*		Copyright (c) 1981,1980 James Gosling		*/

/* Modified DJH 7-Dec-80	Added way to turn off automatic help
				window on command-completion errors */

/* Modified 8-Sept-81 Jeffrey Mogul (JCM) at Stanford
 *	- if we can't load "filename", try loading "filename.ml"
 */

#include "buffer.h"
#include "window.h"
#include "keyboard.h"
#include "config.h"
#include "macros.h"
#include "mlisp.h"
#include <ctype.h>
#include <sys/param.h>

char  *malloc(), *getenv();

static
ChangeDirectory () {
    register char  *nd = getstr (": change-directory ");
    if (nd == 0)
	return 0;
    if (e_chdir (nd) < 0)
	error ("Can't change to directory %s", nd);
    return 0;
}

static  Load () {
    ExecuteMLispFile (getstr (": load "), 0);
    return 0;
}

LoadFile(fn)
register char *fn; {
    register FILE *oldfd;
    struct ProgNode *oldExec = CurExec;
    char   *oldMem;
    register rv = 0;
    static char *path;
    char    fnb[MAXPATHLEN];
    char    Xfn[MAXPATHLEN];

    if(fn==0) return rv;
    oldfd = InputFD;
    oldMem = MemPtr;
    if (fn == 0)
	return rv;
    if (path == 0) {
	FluidStatic(&path, sizeof(path));
	path = (char *) getenv ("EPATH");
	if (path == 0)
	    path = PATH_LOADSEARCH;
    }
    if ((InputFD = fopenp (path, fn, fnb, "r")) == NULL){
	/* couldn't open fn; let's try fn.ml */
	strcpy(Xfn,fn);
	strcat(Xfn,".ml");
	InputFD = fopenp (path, Xfn, fnb, "r");
    }

    if (InputFD == NULL) {
    	/* still null?  Guess file isn't there */
	error ("Can't read %s",fn);
	rv++;
    }
    else {
	MemPtr = 0;
	CurExec = 0;
	ProcessKeys ();
	fclose (InputFD);
    }
    InputFD = oldfd;
    CurExec = oldExec;
    MemPtr = oldMem;
    return rv;
}

/* Given a sequence of keystrokes (at "keys" for "len" characters) return a
   printable representation of them -- with ESC's for escapes, and similar
   rot */
char   *KeyToStr (keys, len)
register char *keys;
register    len; {
    static char buf[30];
    register char  *p = buf;
    if (keys == 0 || len == 0)
	return "[Bogus keys]";
    while (--len >= 0) {
	if (p > &buf[sizeof buf - 5]) return ("[long key sequence]");
	if (*keys == 033) {
	    *p++ = 'E';
	    *p++ = 'S';
	    *p++ = 'C';
	}
	else
	    if (*keys < 040 || *keys == 0177) {
		*p++ = '^';
		*p++ = *keys == 0177 ? '?' : *keys | 0100;
	    }
	    else
		*p++ = *keys;
	keys++;
	if (len > 0)
	    *p++ = '-';
    }
    *p++ = '\0';
    return buf;
}

static
DescribeKey () {
    register    char key = *getkey (CurrentGlobalMap, ": describe-key ");
    register struct BoundName  **p;
    register char *WhereBound = "globally";
    if (key == 0 || err)
	return 0;
    p = LookupKeys (bf_mode.md_keys, MLvalue -> exp_v.v_string, MLvalue -> exp_int);
    if (p && !*p) p = 0;
    if (p)
	WhereBound = "locally";
    else
	p = LookupKeys (CurrentGlobalMap, MLvalue -> exp_v.v_string, MLvalue -> exp_int);
    if (p == 0 || *p == 0)
	message ("%s isn't bound to anything",
		 KeyToStr (MLvalue -> exp_v.v_string, MLvalue -> exp_int));
    else
	message ("%s is %s bound to the %s called \"%s\"",
		KeyToStr (MLvalue -> exp_v.v_string, MLvalue -> exp_int),
		WhereBound,
		(*p) -> b_binding == MacroBound ?	"macro" :
		(*p) -> b_binding == AutoLoadBound ?	"autoloaded function" :
		(*p) -> b_binding == MLispBound ?	"MLisp function" :
		(*p) -> b_binding == KeyBound ?		"keymap" :
							"wired procedure",
		(*p) -> b_name);
    VoidResult ();
    return 0;
}

static
ProcedureType ()
{
    register int i = getword (MacNames, ": procedure-type (of) ");
    static char yetAnotherHack[100];

    if (i <= 0)
	return 0;
    switch (MacBodies[i] -> b_binding)
    {
    case ProcBound:
	strcpy(yetAnotherHack, "wired");
	break;
    case MacroBound:
	strcpy(yetAnotherHack, "macro");
	break;
    case MLispBound:
	strcpy(yetAnotherHack, "mlisp");
	break;
    case AutoLoadBound:
	sprintf(yetAnotherHack, "autoload: %s", MacBodies[i]->b_bound.b_body);
	break;
    case KeyBound:
	sprintf(yetAnotherHack, "keymap");
	break;
    default:
	strcpy(yetAnotherHack, "Bizarre!");
	break;
    }

    MLvalue -> exp_type = IsString;
    MLvalue -> exp_v.v_string = yetAnotherHack;
    MLvalue -> exp_release = 0;
    MLvalue -> exp_int = strlen(yetAnotherHack);
    return 0;
}

static
LocalBindingOf () {
    register char   key = *getkey (CurrentGlobalMap, ": local-binding-of ");
    register struct BoundName **p;
    if (key == 0 || err)
	return 0;
    p = LookupKeys (bf_mode.md_keys, MLvalue -> exp_v.v_string,
		    MLvalue -> exp_int);
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_v.v_string = p == 0 || *p == 0 ? "nothing" : (*p) -> b_name;
    MLvalue -> exp_release = 0;
    MLvalue -> exp_int = strlen (MLvalue -> exp_v.v_string);
    return 0;
}

static
GlobalBindingOf () {
    register char   key = *getkey (CurrentGlobalMap, ": global-binding-of ");
    register struct BoundName **p;
    if (key == 0 || err)
	return 0;
    p = LookupKeys (CurrentGlobalMap, MLvalue -> exp_v.v_string,
		     MLvalue -> exp_int);
    MLvalue -> exp_type = IsString;
    MLvalue -> exp_v.v_string = p == 0 || *p == 0 ? "nothing" : (*p) -> b_name;
    MLvalue -> exp_release = 0;
    MLvalue -> exp_int = strlen (MLvalue -> exp_v.v_string);
    return 0;
}

/* Recursively scan a keymap tree.  It gets passed a pointer to a map and a
   function.  For each BoundName the function is called with these
   parameters: the BoundName, the keystrokes leading to it (as a char * and
   an int) and a count of the number of following keys that are bound to the
   same BoundName.  A run of equal BoundNames in a keymap is only passed to
   the procedure once. */
ScanMap (map, proc, FoldCase)
register struct keymap *map;
int (*proc) ();
{
    char    keys[100];
    if (map)
	ScanMapInner (map, proc, 0, keys, 0, FoldCase);
}

ScanMapInner (map, proc, history, keys, len, FoldCase)
register struct keymap *map;
int (*proc)();
struct hist {           /* To catch recursive invocations we
                                   thread through the stack a list of
                                   the keymaps that we've seen. */
        struct hist *prev;
        struct keymap  *this;
} *history;
char *keys;
{
    struct hist hist;
    register struct BoundName  *b;
    register c;
    int c2;
    hist.prev = history;
    hist.this = map;
    for (c = 0; c <= 0177; c = c2) {
	c2 = c + 1;
	if ((b = map -> k_binding[c])
		&& (!FoldCase || !isupper(c)
		    || b != map -> k_binding[tolower(c)])) {
	    keys[len] = c;
	    for (; c2 <= 0177 && map -> k_binding[c2] == b; c2++);
	    (*proc) (b, keys, len+1, c2 - c);
	    if (b -> b_binding == KeyBound && b -> b_bound.b_keymap) {
		register struct hist   *h;
		for (h = history; h && h -> this != map; h = h -> prev);
		if (!h)
		    ScanMapInner (b -> b_bound.b_keymap, proc, &hist, keys, len + 1, FoldCase);
	    }
	}
    }
}

/* Helper function for DescribeBindings -- inserts one line of info for the
   given boundname */
static
Describe1 (b, keys, len, range)
register struct BoundName *b;
char *keys;
{
    register indent;
    char *s = KeyToStr (keys, len);
    indent = strlen(s);
    InsCStr (s, indent);
    if (range>1) {
	register k;
	keys[len-1] += range-1;
	InsCStr ("..", 2);
	s = KeyToStr (keys, len);
	k = strlen (s);
	InsCStr (s, k);
	indent += k + 2;
	keys[len-1] -= range-1;
    }
    InsCStr ("                    ", indent<16 ? 16-indent : 1);
    InsStr (b->b_name);
    InsCStr ("\n", 1);
}

static
DescribeBindings () {
    register struct keymap *LocalMap = bf_mode.md_keys;
    SetBfn ("Help");
    EraseBf (bf_cur);
    WindowOn (bf_cur);
    InsStr ("Global Bindings:\n\
key		binding\n---		-------\n");
    ScanMap (CurrentGlobalMap, Describe1, 1);
    if (LocalMap) {
	InsStr ("\nLocal Bindings:\n");
	ScanMap (LocalMap, Describe1, 0);
    }
    BeginningOfFile ();
    bf_cur -> b_mode.md_NeedsCheckpointing = 0;
    bf_modified = 0;
    return 0;
}

static
DefineKeyboardMacro () {
    register char  *name;
    if (Remembering) {
	error ("Not allowed to define a macro while remembering.");
	return 0;
    }
    if (MemUsed <= 0) {
	error ("No keyboard macro defined.");
	return 0;
    }
    name = getnbstr (": define-keyboard-macro ");
    if (name == 0)
	return 0;
    DefMac (name, KeyMem, 0);
    MemUsed = 0;
    return 0;
}

static
DefineStringMacro () {
    char    name[200],
           *p;
    if (Remembering) {
	error ("Not allowed to define a macro while remembering.");
	return 0;
    }
    p = getnbstr (": define-string-macro ");
    if (p == 0)
	return 0;
    strcpy (name, p);
    p = getstr (": define-string-macro %s body: ", name);
    if (p == 0)
	return 0;
    DefMac (name, p, 0);
    return 0;
}

static
BindToKey () {
    register    i = getword (MacNames, ": bind-to-key name: ");
    register    char *c;
    struct keymap *p;
    if (i < 0)
	return 0;
    c = getkey (CurrentGlobalMap, ": bind-to-key name: %s key: ", MacNames[i]);
    if (c == 0)
	return 0;
    p = CurrentGlobalMap;
    PerformBind (&p, MacBodies[i]);
    return 0;
}

static
RemoveBinding () {
    register char c = *getkey (CurrentGlobalMap, ": remove-binding ");
    register struct BoundName **b;
    if (!err) {
	b = LookupKeys (CurrentGlobalMap, MLvalue -> exp_v.v_string, MLvalue -> exp_int);
	if (b)
	    *b = 0;
    }
    VoidResult ();
    return 0;
}

static
LocalBindToKey () {
    register    i = getword (MacNames, ": local-bind-to-key name: ");
    register    char *c;
    register struct keymap *m;
    if (i < 0)
	return 0;
    InitializeLocalMap ();
    m = bf_mode.md_keys;
    c = getkey (bf_mode.md_keys, ": local-bind-to-key name: %s key: ", MacNames[i]);
    if (c == 0)
	return 0;
    PerformBind (&bf_mode.md_keys,MacBodies[i]);
    return 0;
}

UseGlobalMap () {
    register    i = getword (MacNames, ": use-global-map ");
    if (i < 0)
	return 0;
    if (MacBodies[i] -> b_binding != KeyBound)
	error ("%s isn't a keymap.", MacNames[i]);
    else
	CurrentGlobalMap = MacBodies[i] -> b_bound.b_keymap;
    NextGlobalKeymap = NextLocalKeymap = 0;
    return 0;
}

UseLocalMap () {
    register    i = getword (MacNames, ": use-local-map ");
    if (i < 0)
	return 0;
    if (MacBodies[i] -> b_binding != KeyBound)
	error ("%s isn't a keymap.", MacNames[i]);
    else
	bf_mode.md_keys = bf_cur->b_mode.md_keys =
		MacBodies[i] -> b_bound.b_keymap;
    NextGlobalKeymap = NextLocalKeymap = 0;
    return 0;
}

/* The following procedure is a horrible compatibility hack.  It
   is called to ensure that the local map exists and that the ESC and ^X
   slots in it are non-empty.  If they are empty, then they are forced to be
   bound to keymaps. */
InitializeLocalMap () {
    if (bf_mode.md_keys == 0 || bf_mode.md_keys -> k_binding[033] == 0
	    || bf_mode.md_keys -> k_binding[030] == 0) {
	char    HorribleHack[2];
	HorribleHack[1] = 0;
	ReleaseExpr (MLvalue);
	HorribleHack[0] = 033;
	MLvalue -> exp_v.v_string = HorribleHack;
	MLvalue -> exp_int = 2;
	if (bf_mode.md_keys == 0 || bf_mode.md_keys -> k_binding[033] == 0)
	    PerformBind (&bf_mode.md_keys, (struct BoundName *) 0);
	HorribleHack[0] = 030;
	MLvalue -> exp_v.v_string = HorribleHack;
	MLvalue -> exp_int = 2;
	if (bf_mode.md_keys == 0 || bf_mode.md_keys -> k_binding[030] == 0)
	    PerformBind (&bf_mode.md_keys, (struct BoundName *) 0);
    }
}

PrintBoundName(b)
  struct BoundName *b;
  {
    int i;
    fprintf(stderr, "BoundName at %x=>",b);
    switch (b->b_binding)
    {
    case ProcBound:
        fprintf(stderr, "wired (%x), %s, %s\n\r",
	    b->b_bound.b_proc, b->b_name, b->b_active? "active": "noactive");
        break;
    case MacroBound:
        fprintf(stderr, "MacroBound (%x), %s, %s %s\n\r",
	    b->b_bound.b_body, b->b_name, b->b_bound.b_body, b->b_active? "active": "noactive");
        break;
    case AutoLoadBound:
        fprintf(stderr, "AutoLoadBound (%x), %s, %s %s\n\r",
            b->b_bound.b_body, b->b_name, b->b_bound.b_body, b->b_active?"active":"noactive");
        break;
    case MLispBound:
        fprintf(stderr, "MLispBound (%x), %s, %s\n\r",
            b->b_bound.b_prog, b->b_name, b->b_active? "active": "noactive");
    case KeyBound:
        fprintf(stderr, "KeyBound (%x)\n\r",
	    b->b_bound.b_keymap);
	for (i=0; i++; i<0200){
	    fprintf(stderr, "%x ",b->b_bound.b_keymap[i]);
	    if ( ((i+1)/8)==0) fprintf(stderr, "\n\r");
	}
        break;
    default:
        break;
    }
  }

PerformBind (tbl, name)
register struct keymap **tbl;
register struct BoundName *name;
{
    register char  *p = MLvalue -> exp_v.v_string;
    register    level = MLvalue -> exp_int;
    while (--level >= 0) {
	if (*tbl == 0) {
	    register int    n;
	    *tbl = (struct keymap  *) malloc (sizeof **tbl);
	    if (tbl == &bf_mode.md_keys)
		bf_cur -> b_mode.md_keys = bf_mode.md_keys;
	    for (n = 0; n < 0200; n++)
		(*tbl) -> k_binding[n] = 0;
	}
	if (level>0 && ((*tbl)->k_binding[*p]==0
			|| (*tbl)->k_binding[*p]->b_binding != KeyBound)) {
	    register struct BoundName *nm =
		(struct BoundName *) malloc (sizeof (struct BoundName));
	    nm -> b_name = "BOGUS!";
	    nm -> b_binding = KeyBound;
	    nm -> b_bound.b_keymap = 0;
	    (*tbl) -> k_binding[*p] = nm;
	}
	if (level>0) tbl = &(*tbl)->k_binding[*p++]->b_bound.b_keymap;
    }
    (*tbl) -> k_binding[*p] = name;
    VoidResult ();
}

static
RemoveLocalBinding () {
    register char   c;
    register struct BoundName **b;
    InitializeLocalMap ();
    c = *getkey (bf_mode.md_keys, ": remove-local-binding ");
    if (!err) {
	b = LookupKeys (bf_mode.md_keys, MLvalue -> exp_v.v_string, MLvalue -> exp_int);
	if (b)
	    *b = 0;
    }
    VoidResult ();
    return 0;
}

static
RemoveAllLocalBindings () {
    register c;
    register struct keymap *m;
    if (m = bf_mode.md_keys)
	for (c = 0; c < 0200; c++)
	    m -> k_binding[c] = 0;
    return 0;
}


ExecuteExtendedCommand () {
    register    ind;
    register struct BoundName  *p;
    register    rv = 0;
    SortMacros ();
    ind = getword (MacNames, ": ");
    if (ind < 0)
	return 0;
    p = MacBodies[ind];
    rv = ExecuteBound (p);
    if (interactive && !err && MLvalue -> exp_type != IsVoid)
	switch (MLvalue -> exp_type) {
	    default: 
		error ("MLisp function returned a bizarre result!");
		break;
	    case IsInteger: 
		message ("MLisp function returned %d",
			 MLvalue -> exp_int);
		break;
	    case IsString: 
		message ("MLisp function returned \"%s\"",
			 MLvalue -> exp_v.v_string);
		break;
	}
    return rv;
}

DefineKeymap () {
    register char  *mapname = getnbstr (": define-keymap ");
    register struct keymap *m;
    register i;
    if (mapname == 0)
	return 0;
    m = (struct keymap *) malloc(sizeof (struct keymap));
    DefMac (mapname, m, -2);
    for (i = 0; i<=0177; i++) m->k_binding[i] = 0;
    return 0;
}

Autoload () {
    register char  *comname = getnbstr (": autoload procedure ");
    char combuf[MAXPATHLEN];
    register char  *filename;
    if (comname == 0)
	return 0;
    strcpy (combuf, comname);
    filename = getnbstr (": autoload procedure %s from file ", combuf);
    if (filename == 0)
	return 0;
    DefMac (combuf, filename, -1);
    return 0;
}

ExecuteBound (p)		/* execute whatever is bound to p */
register struct BoundName *p;
{
    register    rv = 0;
    register    larg;
    if (ArgState == NoArg)
	arg = 1;
    if (ArgState == PreparedArg)
	ArgState = HaveArg;
    larg = arg;
    ReleaseExpr (MLvalue);
    MLvalue = &GlobalValue;
    GlobalValue.exp_type = IsVoid;
    GlobalValue.exp_refcnt = 99;
    if (p)
	switch (p -> b_binding) {
	    case MacroBound: 
		{
		    struct ProgNode *LCurExec = CurExec;
		    CurExec = 0;
		    do
			ExecStr (p -> b_bound.b_body);
		    while (!err && --larg > 0);
		    CurExec = LCurExec;
		}
		break;
	    case MLispBound: 
		{
		    struct ExecutionStack   parent;
		    parent = ExecutionRoot;
		    ExecutionRoot.PrefixArgument = larg;
		    ExecutionRoot.PrefixArgumentProvided = ArgState != NoArg;
		    ExecutionRoot.CurExec = CurExec;
		    ExecutionRoot.DynParent = &parent;
		    ArgState = NoArg;
		    rv = ExecProg (p -> b_bound.b_prog);
		    ExecutionRoot = parent;
		    break;
		}
	    case AutoLoadBound: 
		{
		    int     larg = arg;
		    enum ArgStates lstate = ArgState;
		    arg = 0;
		    ArgState = NoArg;
		    ExecuteMLispFile (p -> b_bound.b_body, 0);
		    if (!err)
			if (p -> b_binding == AutoLoadBound)
			    error ("%s was supposed to be defined by autoloading %s, but it wasn't.",
				    p -> b_name, p -> b_bound.b_body);
			else {
			    arg = larg;
			    ArgState = lstate;
			    rv = ExecuteBound (p);
			}
		    break;
		}
	    case KeyBound: 
		NextLocalKeymap = p -> b_bound.b_keymap;
		break;
	    case ProcBound: 
		rv = (*p -> b_bound.b_proc) (-1);
		if (ArgState != PreparedArg)
#ifdef titan
		    LastProc =  p -> b_bound.b_proc;
#else
		    LastProc = *p -> b_bound.b_proc;
#endif
		if (dot < FirstCharacter)
		    SetDot (FirstCharacter);
		if (dot > NumCharacters)
		    SetDot (NumCharacters + 1);
	}
    if (p -> b_binding != KeyBound && ArgState != PreparedArg) {
	ArgState = NoArg;
	arg = 1;
    }
    return rv;
}

/* Dump a stack trace to the stack trace buffer -- handles recursive calls
   (eg. from error()) */
DumpStackTrace () {
    register struct buffer *old = bf_cur;
    register struct ExecutionStack *p;
    register SetWindow = wn_cur->w_buf == bf_cur;
    static DumpDepth;
    DumpDepth++;
    if (DumpDepth>1) return 0;
    SetBfn ("Stack trace");
    WindowOn (bf_cur);
    WidenRegion ();
    EraseBf (bf_cur);
    if (err) {
	InsCStr ("Message:   ", 11);
	InsStr (MiniBuf);
	InsCStr ("\n", 1);
    }
    InsCStr ("Executing: ", 11);
    PrintExpr (CurExec, 1);
    InsCStr ("\n", 1);
    for (p = &ExecutionRoot; p->DynParent && DumpDepth<=1; p = p->DynParent) {
	PrintExpr (p->CurExec, 1);
	InsCStr ("\n", 1);
    }
    InsStr (DumpDepth>1 ? "** error during stack trace **\n"
			: "--- bottom of stack ---\n");
    SetDot (1);
    DumpDepth = 0;
    bf_cur -> b_mode.md_NeedsCheckpointing = 0;
    bf_modified = 0;
    SetBfp (old);
    if (SetWindow) WindowOn (bf_cur);
    return 0;
}

InitOpt () {
    if (!Once)
    {
	setkey (ESCmap, ('x'), ExecuteExtendedCommand, "execute-extended-command");
	defproc (Load, "load");
	defproc (Autoload, "autoload");
	defproc (LocalBindingOf, "local-binding-of");
	defproc (GlobalBindingOf, "global-binding-of");
	defproc (ProcedureType, "procedure-type");
	defproc (ChangeDirectory, "change-directory");
	defproc (DescribeKey, "describe-key");
	defproc (DefineKeyboardMacro, "define-keyboard-macro");
	defproc (DefineStringMacro, "define-string-macro");
	defproc (BindToKey, "bind-to-key");
	defproc (LocalBindToKey, "local-bind-to-key");
	defproc (RemoveBinding, "remove-binding");
	defproc (RemoveLocalBinding, "remove-local-binding");
	defproc (RemoveAllLocalBindings, "remove-all-local-bindings");
	defproc (DescribeBindings, "describe-bindings");
	defproc (DumpStackTrace, "dump-stack-trace");
	defproc (DefineKeymap, "define-keymap");
	defproc (UseLocalMap, "use-local-map");
	defproc (UseGlobalMap, "use-global-map");
	DefIntVar ("prefix-argument", &ExecutionRoot.PrefixArgument);
	DefIntVar ("prefix-argument-provided",
		    &ExecutionRoot.PrefixArgumentProvided);
    }
}
