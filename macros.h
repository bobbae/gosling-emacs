/* header file for stuff that has to do with macros */

/*		Copyright (c) 1981,1980 James Gosling		*/

#define maxmacs 800		/* Maximum number of macros that may be
				   defined.  Sorry; can't really use a
				   dynamic structure. */
char *MacNames[maxmacs+1];	/* The names of the macros */
struct BoundName *MacBodies[maxmacs];	/* their bodies */
int NMacs;			/* the number of macros defined */
