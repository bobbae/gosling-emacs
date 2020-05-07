#include	"ndbm.h"
#include	<sys/types.h>
#include	<sys/stat.h>

char  *malloc();
static datum nulldatum;

database *open_db (file)
char   *file;
{
    struct stat statb;
    register    database * db = (database *) malloc (sizeof *db);
    register int    len;

    len = strlen (file);
    db -> dirnm = (char *) malloc (4 * (len + 5));
    db -> pagnm = db -> dirnm + len + 5;
    db -> datnm = db -> pagnm + len + 5;
    db -> dbnm  = db -> datnm + len + 5;
    strcpy (db -> dirnm, file);
    strcpy (db -> dirnm + len, ".dir");
    strcpy (db -> pagnm, file);
    strcpy (db -> pagnm + len, ".pag");
    strcpy (db -> datnm, file);
    strcpy (db -> datnm + len, ".dat");
    strcpy (db -> dbnm,  file);
    db -> oldpagb = -1;
    db -> olddirb = -1;
    if (setup_db (db) < 0) {
	free (db -> dirnm);
	free (db);
	return 0;
    }
    fstat (db -> dirf, &statb);
    db -> maxbno = statb.st_size * BYTESIZ - 1;
    return (db);
}

free_db (db)
register    database * db; {
    if (db == 0)
	return 40;
    if (lastdatabase == db) {
	if (db -> dirf > 0)
	    close (db -> dirf);
	if (db -> pagf > 0)
	    close (db -> pagf);
	if (db -> datf > 0)
	    close (db -> datf);
	db -> dirf = -1;
	db -> pagf = -1;
	db -> datf = -1;
	lastdatabase = 0;
    }
    free (db -> dirnm);
    free (db);
    return 0;
}

static setup_db (db)
register    database * db; {
    if (db==0) return -1;
    if (lastdatabase == db)
	return 0;
    if (lastdatabase) {
	if (lastdatabase -> dirf > 0)
	    close (lastdatabase -> dirf);
	if (lastdatabase -> pagf > 0)
	    close (lastdatabase -> pagf);
	if (lastdatabase -> datf > 0)
	    close (lastdatabase -> datf);
	lastdatabase -> dirf = -1;
	lastdatabase -> pagf = -1;
	lastdatabase -> datf = -1;
	lastdatabase = 0;
    }
    db -> dirf = open (db -> dirnm, 2);
    db -> dbrdonly = 0;
    if (db -> dirf < 0) {
	db -> dbrdonly = 1;
	db -> dirf = open (db -> dirnm, 0);
    }
    db -> pagf = open (db -> pagnm, db -> dbrdonly ? 0 : 2);
    db -> datf = open (db -> datnm, db -> dbrdonly ? 0 : 2);
    if (db -> dirf < 0 || db -> pagf < 0 || db -> datf < 0) {
	close (db -> dirf);
	close (db -> pagf);
	close (db -> datf);
	return - 1;
    }
    lastdatabase = db;
    return 0;
}

long
        forder (key, db)
register    database * db;
datum key;
{
    long    hash;

/*  if (setup_db (db)<0) return -1; */
    hash = calchash (key);
    for (db -> hmask = 0;; db -> hmask = (db -> hmask << 1) + 1) {
	db -> blkno = hash & db -> hmask;
	db -> bitno = db -> blkno + db -> hmask;
	if (getbit (db) == 0)
	    break;
    }
    return (db -> blkno);
}

datum
fetch (key, db)
register    database * db;
datum key;
{
    register    i;
    datum item;

/*  if (setup_db (db) < 0) return nulldatum; */
    ndbm_access (calchash (key), db);
    for (i = 0;; i ++) {
	item = makdatum (db -> pagbuf, i);
	if (item.dptr == 0)
	    return (item);
	if (cmpdatum (key, item) == 0) {
	    return (item);
	}
    }
}

delete (key, db)
register    database * db;
datum key;
{
    register    i;
    datum item;

/*  if (setup_db (db) < 0) return -1; */
    if (db -> dbrdonly)
	return - 1;
    ndbm_access (calchash (key), db);
    for (i = 0;; i ++) {
	item = makdatum (db -> pagbuf, i);
	if (item.dptr == 0)
	    return (-1);
	if (cmpdatum (key, item) == 0) {
	    delitem (db -> pagbuf, i);
	    break;
	}
    }
    setup_db (db);
    lseek (db -> pagf, db -> blkno * PBLKSIZ, 0);
    write (db -> pagf, db -> pagbuf, PBLKSIZ);
    return (0);
}

store (key, db)
register    database * db;
datum key;
{
    register    i;
    datum item;
    char    ovfbuf[PBLKSIZ];

    if (setup_db (db) < 0) return -1;
    if (db -> dbrdonly)
	return - 1;
loop: 
    ndbm_access (calchash (key), db);
    for (i = 0;; i ++) {
	item = makdatum (db -> pagbuf, i);
	if (item.dptr == 0)
	    break;
	if (cmpdatum (key, item) == 0) {
	    delitem (db -> pagbuf, i);
	    break;
	}
    }
    i = additem (db -> pagbuf, key);
    if (i < 0)
	goto split;
    lseek (db -> pagf, db -> blkno * PBLKSIZ, 0);
    write (db -> pagf, db -> pagbuf, PBLKSIZ);
    return (0);

split: 
    if (key.dsize + 2*sizeof (long) + 2 * sizeof (short) >= PBLKSIZ)
	return (-1);
    clrbuf (ovfbuf, PBLKSIZ);
    for (i = 0;;) {
	item = makdatum (db -> pagbuf, i);
	if (item.dptr == 0)
	    break;
	if (calchash (item) & (db -> hmask + 1)) {
	    additem (ovfbuf, item);
	    delitem (db -> pagbuf, i);
	    continue;
	}
	i ++;
    }
    lseek (db -> pagf, db -> blkno * PBLKSIZ, 0);
    write (db -> pagf, db -> pagbuf, PBLKSIZ);
    lseek (db -> pagf, (db -> blkno + db -> hmask + 1) * PBLKSIZ, 0);
    write (db -> pagf, ovfbuf, PBLKSIZ);
    setbit (db);
    goto loop;
}

datum
firstkey (db)
register database *db;
{
/*  return setup_db (db)<0 ? nulldatum : (firsthash (0L, db)); */
    return firsthash (0L, db);
}

datum
nextkey (key, db)
register    database * db;
datum key;
{
    register    i;
    datum item, bitem;
    long    hash;
    int     f;

/*  if (setup_db (db) < 0) return nulldatum; */
    hash = calchash (key);
    ndbm_access (hash, db);
    f = 1;
    for (i = 0;; i ++) {
	item = makdatum (db -> pagbuf, i);
	if (item.dptr == 0)
	    break;
	if (cmpdatum (key, item) <= 0)
	    continue;
	if (f || cmpdatum (bitem, item) < 0) {
	    bitem = item;
	    f = 0;
	}
    }
    if (f == 0)
	return (bitem);
    hash = hashinc (hash, db);
    if (hash == 0)
	return (item);
    return (firsthash (hash, db));
}

datum
firsthash (hash, db)
register    database * db;
long    hash;
{
    register    i;
    datum item, bitem;

loop: 
    ndbm_access (hash, db);
    bitem = makdatum (db -> pagbuf, 0);
    for (i = 0;; i ++) {
	item = makdatum (db -> pagbuf, i);
	if (item.dptr == 0)
	    break;
	if (cmpdatum (bitem, item) < 0)
	    bitem = item;
    }
    if (bitem.dptr != 0)
	return (bitem);
    hash = hashinc (hash, db);
    if (hash == 0)
	return (item);
    goto loop;
}

static
ndbm_access (hash, db)
register    database * db;
long    hash;
{
    for (db -> hmask = 0;; db -> hmask = (db -> hmask << 1) + 1) {
	db -> blkno = hash & db -> hmask;
	db -> bitno = db -> blkno + db -> hmask;
	if (getbit (db) == 0)
	    break;
    }
    if (db -> blkno != db -> oldpagb) {
	clrbuf (db -> pagbuf, PBLKSIZ);
	setup_db (db);
	lseek (db -> pagf, db -> blkno * PBLKSIZ, 0);
	read (db -> pagf, db -> pagbuf, PBLKSIZ);
	chkblk (db -> pagbuf);
	db -> oldpagb = db -> blkno;
    }
}

static
getbit (db)
register    database * db;
{
    long    bn;
    register    b,
                i,
                n;

    if (db -> bitno > db -> maxbno)
	return (0);
    n = db -> bitno % BYTESIZ;
    bn = db -> bitno / BYTESIZ;
    i = bn % DBLKSIZ;
    b = bn / DBLKSIZ;
    if (b != db -> olddirb) {
	clrbuf (db -> dirbuf, DBLKSIZ);
	setup_db (db);
	lseek (db -> dirf, (long) b * DBLKSIZ, 0);
	read (db -> dirf, db -> dirbuf, DBLKSIZ);
	db -> olddirb = b;
    }
    if (db -> dirbuf[i] & (1 << n))
	return (1);
    return (0);
}

static
setbit (db)
register    database * db;
{
    long    bn;
    register    i,
                n,
                b;

    if (db -> dbrdonly)
	return - 1;
    if (db -> bitno > db -> maxbno) {
	db -> maxbno = db -> bitno;
	getbit (db);
    }
    n = db -> bitno % BYTESIZ;
    bn = db -> bitno / BYTESIZ;
    i = bn % DBLKSIZ;
    b = bn / DBLKSIZ;
    db -> dirbuf[i] |= 1 << n;
    setup_db (db);
    lseek (db -> dirf, (long) b * DBLKSIZ, 0);
    write (db -> dirf, db -> dirbuf, DBLKSIZ);
    return 0;
}

static
clrbuf (cp, n)
register char  *cp;
register    n;
{

    do
	*cp++ = 0;
    while (--n);
}

static datum
makdatum (buf, n)
char    buf[PBLKSIZ];
{
    register short *sp;
    register    t;
    register long *lp;
    datum item;
    long temp;

    sp = (short *) buf;
    if (n < 0 || n >= sp[0])
	goto null;
    t = PBLKSIZ;
    if (n > 0)
	t = sp[n + 1 - 1];
    lp = (long *) (buf + sp[n + 1]);
#ifdef	notdef
    /* doing it this way causes alignment errors */
    item.val1 = *lp++;
    item.val2 = *lp++;
#else
    bcopy(lp, &temp, sizeof(long));
    item.val1 = temp;
    lp++;
    bcopy(lp, &temp, sizeof(long));
    item.val2 = temp;
    lp++;
#endif
    item.dptr = (char *) lp;
    item.dsize = t - sp[n + 1] - 2*sizeof(long);
    return (item);

null: 
    item.dptr = 0;
    item.dsize = 0;
    return (item);
}

static
cmpdatum (d1, d2)
datum d1, d2;
{
    register    n;
    register char  *p1,
                   *p2;

    n = d1.dsize;
    if (n != d2.dsize)
	return (n - d2.dsize);
    if (n == 0)
	return (0);
    p1 = d1.dptr;
    p2 = d2.dptr;
    do
	if (*p1++ != *p2++)
	    return (*--p1 - *--p2);
    while (--n);
    return (0);
}

int     hitab[16]
/* ken's {
   055,043,036,054,063,014,004,005,
   010,064,077,000,035,027,025,071, }; */
= {
    61, 57, 53, 49, 45, 41, 37, 33,
    29, 25, 21, 17, 13, 9, 5, 1,
};
long    hltab[64]
= {
    06100151277L, 06106161736L, 06452611562L, 05001724107L,
    02614772546L, 04120731531L, 04665262210L, 07347467531L,
    06735253126L, 06042345173L, 03072226605L, 01464164730L,
    03247435524L, 07652510057L, 01546775256L, 05714532133L,
    06173260402L, 07517101630L, 02431460343L, 01743245566L,
    00261675137L, 02433103631L, 03421772437L, 04447707466L,
    04435620103L, 03757017115L, 03641531772L, 06767633246L,
    02673230344L, 00260612216L, 04133454451L, 00615531516L,
    06137717526L, 02574116560L, 02304023373L, 07061702261L,
    05153031405L, 05322056705L, 07401116734L, 06552375715L,
    06165233473L, 05311063631L, 01212221723L, 01052267235L,
    06000615237L, 01075222665L, 06330216006L, 04402355630L,
    01451177262L, 02000133436L, 06025467062L, 07121076461L,
    03123433522L, 01010635225L, 01716177066L, 05161746527L,
    01736635071L, 06243505026L, 03637211610L, 01756474365L,
    04723077174L, 03642763134L, 05750130273L, 03655541561L,
};

static long
        hashinc (hash, db)
register    database * db;
long    hash;
{
    long    bit;

    hash &= db -> hmask;
    bit = db -> hmask + 1;
    for (;;) {
	bit >>= 1;
	if (bit == 0)
	    return (0L);
	if ((hash & bit) == 0)
	    return (hash | bit);
	hash &= ~bit;
    }
}

static long
        calchash (item)
        datum item;
{
    register    i,
                j,
                f;
    long    hashl;
    int     hashi;

    hashl = 0;
    hashi = 0;
    for (i = 0; i < item.dsize; i++) {
	f = item.dptr[i];
	for (j = 0; j < BYTESIZ; j += 4) {
	    hashi += hitab[f & 017];
	    hashl += hltab[hashi & 63];
	    f >>= 4;
	}
    }
    return (hashl);
}

static
delitem (buf, n)
char    buf[PBLKSIZ];
{
    register short *sp;
    register    i1,
                i2,
                i3;

    sp = (short *) buf;
    if (n < 0 || n >= sp[0])
	goto bad;
    i1 = sp[n + 1];
    i2 = PBLKSIZ;
    if (n > 0)
	i2 = sp[n + 1 - 1];
    i3 = sp[sp[0] + 1 - 1];
    if (i2 > i1)
	while (i1 > i3) {
	    i1--;
	    i2--;
	    buf[i2] = buf[i1];
	    buf[i1] = 0;
	}
    i2 -= i1;
    for (i1 = n + 1; i1 < sp[0]; i1++)
	sp[i1 + 1 - 1] = sp[i1 + 1] + i2;
    sp[0]--;
    sp[sp[0] + 1] = 0;
    return 0;

bad: 
    return -1;
}

static
additem (buf, item)
char    buf[PBLKSIZ];
datum item;
{
    register short *sp;
    register char *p;
    register    i1,
                i2;

    sp = (short *) buf;
    i1 = PBLKSIZ;
    if (sp[0] > 0)
	i1 = sp[sp[0] + 1 - 1];
    i1 -= item.dsize + 2*sizeof(long);
    i2 = (sp[0] + 2) * sizeof (short);
    if (i1 <= i2)
	return (-1);
    sp[sp[0] + 1] = i1;
    p = &buf[i1];
    * ((long *) p) = item.val1;
    p += sizeof(long);
    * ((long *) p) = item.val2;
    p += sizeof(long);
    for (i2 = 0; i2 < item.dsize; i2++) {
	*p++ = item.dptr[i2];
    }
    sp[0]++;
    return (sp[0] - 1);
}

static
chkblk (buf)
char    buf[PBLKSIZ];
{
    register short *sp;
    register    t,
                i;

    sp = (short *) buf;
    t = PBLKSIZ;
    for (i = 0; i < sp[0]; i++) {
	if (sp[i + 1] > t)
	    goto bad;
	t = sp[i + 1];
    }
    if (t < (sp[0] + 1) * sizeof (short))
	goto bad;
    return 0;

bad: 
    clrbuf (buf, PBLKSIZ);
    return -1;
}

put_db (key, keylen, content, contentlen, db)
register database *db;
char   *key,
       *content; {
    datum keyd, value;
    keyd.dptr = key;
    keyd.dsize = keylen;
    value = fetch (keyd, db);
    keyd.val2 = contentlen;
    setup_db (db);
    keyd.val1 = value.dptr && value.val2 >= contentlen
	? lseek (db -> datf, value.val1, 0)
	: lseek (db -> datf, 0, 2);
    if (store (keyd, db) < 0)
	return -1;
    write (db -> datf, content, contentlen);
    return 0;
}

static char *DefaultSpacefunc (n) {
    static char *space;
    static  spacelen;
    if (spacelen >= n && space)
	return space;
    spacelen = spacelen * 3 / 2;
    if (n + 100 > spacelen)
	spacelen = n + 100;
    if (space)
	free (space);
    space = (char *) malloc (spacelen);
    return space;
}

get_db (key, keylen, content, contentlen, spacefunc, db)
char *key;
int keylen;
char **content;
int *contentlen;
char *(*spacefunc)();
register database *db;
{
    datum value;
    if (spacefunc == 0)
	spacefunc = DefaultSpacefunc;
    value.dptr = key;
    value.dsize = keylen;
    value = fetch (value, db);
    if (value.dptr == 0)
	return - 1;
    if (content==0 || contentlen==0) return 1;
    *contentlen = value.val2;
    if ((*content = (*spacefunc) (value.val2)) == 0)
	return - 1;
    setup_db (db);
    lseek (db -> datf, value.val1, 0);
    return read (db -> datf, *content, *contentlen) == *contentlen ? 0 : -1;
}
