#include "ndbm.h"

main(argc,argv)
char  **argv; {
    register    database * db;
    char   *content;
    int     contentlen;

    if (argc != 3) {
	printf ("Usage: %s database key\n", argv[0]);
	exit (1);
    }
    if ((db = open_db (argv[1])) == 0) {
	printf ("Data base not found\n");
	exit (1);
    }
    if (get_db (argv[2], strlen (argv[2]), &content, &contentlen, 0, db) < 0)
	printf ("Not found\n");
    else
	write (1, content, contentlen);
}
