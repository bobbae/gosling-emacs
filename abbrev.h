/* Definitions for Unix Emacs Abbrev mode */

/*		Copyright (c) 1981,1980 James Gosling		*/

/* An abbrev table contains an array of pointers to abbrev entries.  When a
   word is to be looked up in a abbrev table it is hashed to a long value and
   that value is taken mod the array size to get the head of the appropriate
   chain.  The chain is scanned for an entry whose hash matches (comparing
   hash values is faster than comparins strings) and whose string matches. */

#define AbbrevSize 87

struct AbbrevEnt {		/* a phrase-abbreve pair in an abbrev table */
     struct AbbrevEnt *a_next;	/* the next pair in this chain */
     char *a_abbrev;		/* the abbreviation */
     char *a_phrase;		/* the expanded phrase */
     long a_hash;		/* a_abbrev hashed */
     struct BoundName *a_ExpansionHook;	/* the command that will be executed
					   when this abbrev is expanded */
};

struct AbbrevTable {		/* a table of abbreviations and their
				   expansions */
    char *a_name;		/* the name of this abbrev table */
    int a_NumberDefined;	/* the number of abbrevs defined in this
				   abbrev table */
    struct AbbrevEnt *a_table[AbbrevSize];
				/* the array of pointers to chains of name
				   pairs */
};

struct AbbrevTable GlobalAbbrev;
