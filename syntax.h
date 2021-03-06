/* Declarations having to do with Emacs syntax tables */

/*		Copyright (c) 1980 James Gosling		*/

/* A syntax table contains an array of information, one entry per ASCII
   character. */

struct SyntaxTable {
    struct SyntaxTableEntry {
	enum SyntaxKinds {
	    DullChar,		/* a dull (punctuation) character */
	    WordChar,		/* a word character for ESC-F and
				   friends */
	    BeginParen,		/* a begin paren: (<[{ */
	    EndParen,		/* an end paren: )>]} */
	    PairedQuote,	/* like " or ' in C */
	    PrefixQuote,	/* like \ in C */
	} s_kind:4;
	char    MatchingParen;	/* contains the matching paren if this
				   is a beginning or ending parenthesis 
				*/
    /* The following fields are used in scanning comments.  They handle
       single and double character comment delimiters */
	unsigned
            BeginComment:1,	/* true iff this character begins a
				   comment */
            EndComment:1;	/* true iff this character ends a
				   comment */
	char    CommentAux;	/* the second character in a
				   two-character sequence */
    }                       s_table[128];
    char   *s_name;
};

struct SyntaxTable GlobalSyntaxTable;

#define CharIs(c, prop) (bf_mode.md_syntax->s_table[c].s_kind == (prop))
