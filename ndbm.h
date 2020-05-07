/* This set of data base routines was ripped off from the Unix standard ones,
   with a few changes: data base entries aren't (key,value) pairs, they are
   simply datum's which have two imbedded longs which for the value.  Also,
   you can deal with multiple data bases */

#define	PBLKSIZ	4096		/* Page block size */
#define	DBLKSIZ	4096		/* directory block size */
#define	BYTESIZ	8		/* bits per byte */

typedef struct {
    long    bitno;
    long    maxbno;
    long    blkno;
    long    hmask;

    long    oldpagb;
    long    olddirb;
    char    pagbuf[PBLKSIZ];
    char    dirbuf[DBLKSIZ];

    int     dirf;
    int     pagf;
    int     datf;
    char   *dbnm,
           *dirnm,
           *datnm,
           *pagnm;
    int     dbrdonly;
}               database;

database * lastdatabase;

typedef struct {
    char   *dptr;
    int     dsize;
    long    val1,
            val2;
}               datum;

datum fetch ();
datum makdatum ();
datum firstkey ();
datum nextkey ();
datum firsthash ();
long    calchash ();
long    hashinc ();
database *open_db ();
