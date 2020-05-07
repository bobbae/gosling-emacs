/* The types for search globals to be saved by SaveExcursion */

#define	ESIZE	500		/* the maximum size of an RE */
#define	NBRA	9		/* the maximum number of meta-brackets in an
				   RE -- \( \) -- cant handle >9 */
#define NALTS	10		/* the maximum number of \|'s */

struct search_globals {	
    int  expbuf[ESIZE + 4];	/* The most recently compiled search string */
    int  *alternatives[NALTS];	/* The list of \| seperated alternatives */
    int braslist[NBRA];		/* RE meta-bracket start list */
    int braelist[NBRA];		/* RE meta-bracket end list */
    int loc1;			/* The buffer position of the first
				   character of the most recently found
				   string */
    int loc2;			/* The buffer position of the character
				   following the most recently found string */
    int nbra;			/* The number of meta-brackets in the most
				   recently compiled RE */
    int *TRT;			/* The current translation table */
} search_globals;
