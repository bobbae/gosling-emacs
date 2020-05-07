/* Emacs routines to deal with syntax tables */
/*		Copyright (c) 1980 James Gosling		*/

#include <ctype.h>
#include "keyboard.h"
#include "buffer.h"
#include "window.h"
#include "mlisp.h"
#include "syntax.h"

char  *malloc();


#define MaxSyntaxTables 40	/* the maximum number of syntax tables */

static
char *SyntaxTableNames[MaxSyntaxTables];
static
struct SyntaxTable *SyntaxTables[MaxSyntaxTables];
static
int NumberOfSyntaxTables;

static				/* given the name of a syntax table, return
				   a pointer to it.  If it doesn't exist,
				   create it */
struct SyntaxTable *locate(name)
char *name;
{
    register    i = 0;
    register struct SyntaxTable *p;
    if(name==0 || *name==0) return 0;
    while (i < NumberOfSyntaxTables)
	if (strcmp (SyntaxTableNames[i], name) == 0)
	    return SyntaxTables[i];
	else i++;
    if (NumberOfSyntaxTables >= MaxSyntaxTables) {
	error ("Too many syntax tables!");
	return 0;
    }
    p = (struct SyntaxTable *) malloc (sizeof *p);
    SyntaxTables[NumberOfSyntaxTables] = p;
    *p = GlobalSyntaxTable;
    SyntaxTableNames[NumberOfSyntaxTables] = p -> s_name = savestr (name);
    NumberOfSyntaxTables++;
    return p;
}

static
UseSyntaxTable () {		/* select a named syntax table for this
				   buffer and turn on syntax mode if it
				   or the global syntax table is
				   non-empty */
    register struct SyntaxTable *p = 
	locate (getnbstr (": use-syntax-table "));
    if (p == 0)
	return 0;
    bf_cur -> b_mode.md_syntax = bf_mode.md_syntax = p;
    return 0;
}

ModifySyntaxEntry () {
    register char  *p;
    if (bf_mode.md_syntax == &GlobalSyntaxTable)
	error ("You'll have to specify a syntax table.");
    else
	if (p = getstr (": modify-syntax-entry ")) {
	    struct SyntaxTableEntry s;
	    switch (*p++) {
		case ' ': 
		case '-': 
		    s.s_kind = DullChar;
		    break;
		case 'w': 
		    s.s_kind = WordChar;
		    break;
		case '(': 
		    s.s_kind = BeginParen;
		    break;
		case ')': 
		    s.s_kind = EndParen;
		    break;
		case '"': 
		    s.s_kind = PairedQuote;
		    break;
		case '\\':s.s_kind = PrefixQuote;
		    break;
		default: 
		    goto syntax_error;
	    }
	    if (strlen (p) < 5)
		goto syntax_error;
	    s.MatchingParen = *p++;
	    s.BeginComment = *p++ == '{';
	    s.EndComment = *p++ == '}';
	    s.CommentAux = *p++;
	    while (*p) {
		register char   c = *p++,
		                lim;
		if (*p != '-')
		    lim = c;
		else
		    if (*++p)
			lim = *p++;
		    else
			goto syntax_error;
		while (c <= lim)
		    bf_mode.md_syntax -> s_table[c++] = s;
	    }
	}
    return 0;
syntax_error: error ("Bogus modify-syntax-table directive.   [TP{}Cc]");
    return 0;
}


/* Primitive function for paren matching.  Leaves dot at enclosing left
   paren, or at top of buffer if none.  Stops at a zero-level newline if
   StopAtNewline is set.  Returns (to MLisp) 1 if it finds
   a match, 0 if not  */
/* Bugs: doesn't correctly handle comments (it'll never really handle them
   correctly... */

static
ParenScan (StopAtNewline, forward) {
    register    ParenLevel = 0;
    register char   c,
                    pc;
    char    parenstack[200];
    int     InString = 0;
    char    MatchingQuote = 0;
    register struct SyntaxTable *s = bf_mode.md_syntax;
    register    enum SyntaxKinds k;
    register on_on = 1;
    int start = (forward ? (dot+1) : dot);

    parenstack[0] = 0;
    MLvalue -> exp_type = IsInteger;
    MLvalue -> exp_int = 0;
    if (StopAtNewline)
        {register p1, p2, dp;
	 for (p1 = dot - 1, p2 = (forward ? NumCharacters : FirstCharacter), 
	 		    dp = (forward ? 1 : -1);
		(forward ? p1<p2 : p1>p2)
		&& ((c = CharAt(p1)) == ' ' || c == '\t' || c == '\n');
	     p1 += dp) ;
	 SetDot(p1+1);
	}
    while (on_on && !err) 
       {if (forward) 
           {if (dot > NumCharacters)
		return 0;
	    DotRight (1);
	   }
	if (dot > 2)
	    pc = CharAt (dot - 2);
	else {
	    pc = 0;
	    if (dot <= FirstCharacter)
		return 0;
	}
	k = s -> s_table[c = CharAt (dot - 1)].s_kind;
	if (s -> s_table[pc].s_kind == PrefixQuote)
	    k = WordChar;
	if ((!InString || c == MatchingQuote) && k == PairedQuote) {
	    InString = !InString;
	    MatchingQuote = c;
	}
	if (InString && c == '\n')
	    return 0;
	if (StopAtNewline && c == '\n' && ParenLevel == 0)
	    return 0;
	if (!InString && (k == EndParen || k == BeginParen))
	   {
	    if ((forward == 0) == (k == EndParen)) {
		ParenLevel++;
		parenstack[ParenLevel] = s -> s_table[c].MatchingParen;
	    }
	    else {
		if (ParenLevel > 0 && parenstack[ParenLevel] != c)
		    error ("Parenthesis mismatch.");
		ParenLevel--;
	    }
	    if (pc == '\n' && ParenLevel > 0 && dot != start)
	        {error("Parenthesis context across function boundary");
		 return 0;
		}
	    if (ParenLevel < 0 || (ParenLevel == 0 && !StopAtNewline))
	        on_on = 0;
	   }
	if (!forward)
	    DotLeft (1);
    }
    MLvalue -> exp_int = 1;
    return 0;
}

/*  Primitive function for lisp indenting.   Searches backward till it finds
    the matching left paren, or a line that begins with zero paren-balance.
    Returns the paren level at termination to mlisp.  */
static
BackwardParenBL () {
    ParenScan (1, 0);
    return 0;
}

/* Searches backward until it find the matching left paren */
static
BackwardParen () {
    ParenScan (0, 0);
    return 0;
}

static
ForwardParenBL () {
    ParenScan (1, 1);
    return 0;
}

/* Searches forward until it find the matching left paren */
static
ForwardParen () {
    ParenScan (0, 1);
    return 0;
}

/* Function to dump syntax table to buffer in human-readable format */
DumpSyntaxTable() {
    register struct SyntaxTable *p;
    register i, j;
    register struct SyntaxTableEntry *ip, *jp;
    register struct buffer *old = bf_cur;
    char line[300];
    char c;
    
    p = locate (getnbstr (": dump-syntax-table "));
    if (p == 0)
	return 0;
    SetBfn ("Syntax table");
    if (interactive) WindowOn (bf_cur);
    WidenRegion ();
    EraseBf (bf_cur);
    InsStr ("Chars	TP MP BC EC CA\n----------------------\n");
    for (i=0; i<128; i = j+1) {
	ip = &p->s_table[i];
	for (j = i; j<127
		&& ip->s_kind  == (jp = &p->s_table[j+1])->s_kind
		&& ip->BeginComment == jp->BeginComment
		&& ip->MatchingParen == jp->MatchingParen
		&& ip->EndComment == jp->EndComment
		&& ip->CommentAux == jp->CommentAux; j++);
	switch(ip->s_kind) {
	    case DullChar:
		c = ' ';
		break;
	    case WordChar:
		c = 'w';
		break;
	    case BeginParen:
		c = '(';
		break;
	    case EndParen:
		c = ')';
		break;
	    case PairedQuote:
		c = '"';
		break;
	    case PrefixQuote:
		c = '\\';
		break;
	}
	sprintfl(line, sizeof line, i<040 ? "'\\%o" : "'%c", i);
	if (i!=j) sprintf(line+strlen(line),j<040 ? "'-'\\%o" : "'-'%c",j);
	sprintf(line+strlen(line),"'	 %c  %c  %c  %c  %c\n",
		c,
		ip->MatchingParen ? ip->MatchingParen:' ',
		ip->BeginComment ? '{' : ' ',
		ip->EndComment ? '}' : ' ',
		ip->CommentAux ? ip->CommentAux :' ');
	InsStr (line);
    }
    bf_cur -> b_mode.md_NeedsCheckpointing = 0;
    bf_modified = 0;
    SetDot (1);
    SetBfp (old);
    WindowOn (bf_cur);
    return 0;
}

InitSyntax () {
    register    i;
    if (!Once)
    {
	GlobalSyntaxTable.s_name = "global-syntax-table";
	for (i = 0; i < 128; i++)
	    GlobalSyntaxTable.s_table[i].s_kind =
		isalnum (i) ? WordChar : DullChar;
	defproc (UseSyntaxTable, "use-syntax-table");
	defproc (DumpSyntaxTable, "dump-syntax-table");
	defproc (BackwardParenBL, "backward-balanced-paren-line");
	defproc (BackwardParen, "backward-paren"); /* APW */
	defproc (ForwardParenBL, "forward-balanced-paren-line");
	defproc (ForwardParen, "forward-paren");
	defproc (ModifySyntaxEntry, "modify-syntax-entry");
    }
}
