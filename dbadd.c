#include "ndbm.h"

main(argc,argv)
char  **argv; {
    datum key;
    register    database * db;
    char    buf[40000];
    register    len = 0,
                n;
    if (argc != 3) {
	printf ("Usage: %s database key\n", argv[0]);
	exit (1);
    }
    if ((db = open_db (argv[1])) == 0) {
	printf ("Data base not found\n");
	exit (1);
    }
    while ((n = read (0, buf + len, sizeof buf - len)) > 0)
	len += n;
    if (put_db (argv[2], strlen (argv[2]), buf, len, db) < 0)
	printf ("Database update failed\n");
}
