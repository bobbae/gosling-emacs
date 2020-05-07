#include "ndbm.h"

main(argc,argv)
char  **argv; {
    datum key;
    register    database * db;
    char    safe[200];
    char *ndb;
    register char  *p;
    int     listlens = 0,
            makeproc = 0;

    if (argc<2) {
	printf ("Usage: %s database [ -l ] [ -p newdatabase ]\n", argv[0]);
	exit (1);
    }
    if ((db = open_db (argv[1])) == 0) {
	printf ("Data base not found\n");
	exit (1);
    }
    if (argc > 2) {
	p = argv[2];
	while (*p)
	    switch (*p++) {
		default: 
		    printf ("Bogus switch: -%c\n", *--p);
		    exit (1);
		case 'l': 
		    listlens++;
		    break;
		case 'p': 
		    makeproc++;
		    ndb = argc>3 ? argv[3] : argv[1];
		    break;
		case '-': 
		    break;
	    }
    }

    for (key = firstkey (db); key.dptr != 0; key = nextkey (key, db))
	if (makeproc) {
	    char buf[200];
	    char *ret;
	    int retlen;
	    strcpyn (buf, key.dptr, key.dsize);
	    get_db (buf, key.dsize, &ret, &retlen, 0, db);
	    printf ("dbadd %s \"%.*s\" <<\"</FoO ThE bAr/>\"\n%.*s",
		    ndb, key.dsize, key.dptr, retlen, ret);
	    if (ret[retlen-1] != '\n') printf("\n");
	    printf ("</FoO ThE bAr/>\n");
	}
	else
	    printf (listlens ? "%-12.*s %d,%d\n" : "%.*s\n",
		    key.dsize, key.dptr, key.val1, key.val2);
}
