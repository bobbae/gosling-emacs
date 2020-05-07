/* File IO for Emacs */

/*		Copyright (c) 1981,1980 James Gosling		*/

#include "keyboard.h"
#include "mlisp.h"
#include "buffer.h"
#include "window.h"
#include "config.h"
#include "macros.h"
#include <sys/types.h>
#include <stat.h>

struct AutoMode {		/* information for automatic mode
				   recognition */
    char   *a_pattern;		/* the pattern that the name must match */
    int     a_len;		/* the length of the pattern string */
    struct BoundName *a_what;	/* what to do if we find it */
    struct AutoMode *a_next;	/* the next thing to try */
};

static struct AutoMode *AutoList;/* the list of filename-pattern pairs that
				    have been specified by auto-execute */
static FilesShouldEndWithNewline;/* If true, then if the user trys to write
				    out a buffer that doesn't end in a
				    newline then they'll get asked about it.
				    I almost called this variable
				    "kazar-mode" but good taste prevaled */
static BackupBeforeWriting;	/* if true, then file being written will be
				   backed up just before the first time that
				   it is written. */
static BackupByCopying;		/* if true, then when a backup is made, it
				   will be made by copying the file, rather
				   than by fancy footwork with links (this
				   is for folks who like to preserve links
				   to files) */
static BackupByCopyingWhenLinked;/* if true, then when a backup for a file
				    with multiple links is made, it will be
				    made by copying */
static UnlinkCheckpointFiles;	/* if true, then when a file is written out
				   the corresponding checkpoint file is
				   deleted -- some people don't like to have
				   .CKP files cluttering up their
				   directories, but some people like the
				   added security. */
static AskAboutBufferNames;	/* If true (the default) Emacs will ask
				   instead of synthesizing a unique name in
				   the case where visit-file encounters a
				   conflict in generated buffer names. */
static Umask;			/* the current umask() */

DoAuto (filename)		/* Perform the auto-execute action (if any)
				   for the specified filename */
char   *filename; {
    register struct AutoMode   *p;
    register    len = strlen (filename);
    register saverr = err;
    err = 0;
    for (p = AutoList; p; p = p -> a_next)
	if ( len+1 >= p->a_len && (*p -> a_pattern == '*'
		    ? strcmpn (p -> a_pattern + 1,
			filename + len - p -> a_len + 1,
			p -> a_len - 1)
		    : strcmpn (p -> a_pattern, filename, p -> a_len - 1)
		) == 0) {
	    ExecuteBound (p->a_what);
	    break;
	}
    err |= saverr;
}

AutoExecute () {
    int     what = getword (MacNames, ": auto-execute ");
    char   *pattern;
    register struct AutoMode   *p;
    if (what < 0)
	return 0;
    pattern = getstr (": auto-execute %s when name matches ",
	    MacNames[what]);
    if (pattern == 0)
	return 0;
    if ((*pattern == '*') == (pattern[strlen (pattern) - 1] == '*'))
	error ("Improper pattern \"%s\"; should either be of the form \"*X\" or \"X*\"", pattern);
    else {
	p = (struct AutoMode   *) malloc (sizeof *p);
	p -> a_pattern = savestr (pattern);
	p -> a_len = strlen (p -> a_pattern);
	p -> a_what = MacBodies[what];
	p -> a_next = AutoList;
	AutoList = p;
    }
    return 0;
}

static
WriteFileExit () {
    return ModWrite () ? -1 : 0;
}

static  WriteThis () {
    register    rv = 0;
    if (!bf_cur -> b_fname)
	error ("No file name assocated with buffer");
    else
	if (WriteFile (bf_cur -> b_fname, 0))
	    rv = -1;
    if (UnlinkCheckpointFiles) {
	if (!err && bf_cur -> b_checkpointfn)
	    unlink (bf_cur -> b_checkpointfn);
	bf_cur -> b_checkpointed = 0;
    }
    return rv;
}

static InsertFile () {
	readfile (SaveAbs (getstr("Insert file: ")), 0, 0);
	bf_modified++;
	return 0;
}

static
WriteModifiedFiles () {
    ModWrite ();
    return 0;
}

static
ReadFile () {
    register char  *fn = getstr (": read-file ");
    if (fn == 0)
	return 0;
    readfile (SaveAbs(*fn ? fn : bf_cur->b_fname), 1, 0);
    DoAuto (fn);
    return 0;
}

static
UnlinkFile () {
    register char *fn = getstr (": unlink-file ");
    MLvalue -> exp_int = fn ? unlink (fn) : -1;
    MLvalue -> exp_type = IsInteger;
    return 0;
}

static
FileExists () {
    register char *fn = (char *) SaveAbs (getstr (": file-exists "));
    if (fn==0) return 0;
    MLvalue -> exp_int = *fn == 0 ? 0
		: access (fn, 2)>=0 ? 1
		: access(fn, 4)>=0 ? -1
		: 0;
    MLvalue -> exp_type = IsInteger;
    return 0;
}

static
WriteCurrentFile () {
    if (!bf_cur -> b_fname)
	error ("No file name assocated with buffer");
    else
	WriteFile (bf_cur -> b_fname, 0);
    if (UnlinkCheckpointFiles) {
	if (!err && bf_cur -> b_checkpointfn)
	    unlink (bf_cur -> b_checkpointfn);
	bf_cur -> b_checkpointed = 0;
    }
    return 0;
}

static  VisitFileCommand () {
    VisitFile (getstr ("Visit file: "), 1, 1);
    return 0;
}

static  WriteNamedFile () {
    register char  *fn = getstr ("Write file: ");
    if (fn == 0)
	return 0;
    if (*fn == '\0') {
	if (bf_cur -> b_fname == 0) {
	    error ("I don't like empty file names!");
	    return 0;
	}
    }
    else {
	if (bf_cur -> b_fname && strcmp(bf_cur -> b_fname, fn) != 0)
	{
	    bf_cur->b_modtime = 0;
	    bf_modtime = 0;
	}
	if (bf_cur -> b_fname)
	    free (bf_cur -> b_fname);
	bf_cur -> b_fname = savestr ((char *) SaveAbs (fn));
    }
    if (bf_cur -> b_checkpointfn) {
	free (bf_cur -> b_checkpointfn);
	bf_cur -> b_checkpointfn = 0;
	bf_cur -> b_checkpointed = 0;
    }
    Cant1WinOpt++;
    bf_cur -> b_kind = FileBuffer;
    WriteCurrentFile ();
    return 0;
}

static  ChangeFileName () {
    register char  *fn = getstr ("Change file name to: ");
    if (fn == 0)
	return 0;
    if (*fn == '\0') {
	if (bf_cur -> b_fname)
	    free(bf_cur->b_fname);
	bf_cur->b_fname = 0;
	bf_cur->b_modtime = 0;
	bf_modtime = 0;
	bf_cur->b_kind = ScratchBuffer;
    }
    else {
	struct stat st;
	fn = (char *) SaveAbs(fn);
	if ((!bf_cur->b_fname || strcmp(bf_cur->b_fname, fn) != 0) &&
	    stat(fn, &st) == 0)
	{
	    bf_cur->b_modtime = st.st_mtime;
	    bf_modtime = bf_cur->b_modtime;
	}
	if (bf_cur -> b_fname)
	    free (bf_cur -> b_fname);
	bf_cur -> b_fname = savestr (fn);
	bf_cur -> b_kind = FileBuffer;
    }
    if (bf_cur -> b_checkpointfn) {
	free (bf_cur -> b_checkpointfn);
	bf_cur -> b_checkpointfn = 0;
	bf_cur -> b_checkpointed = 0;
    }

    return 0;
}

static  AppendToFile () {
    register char  *fn = getstr (": append-to-file ");
    char fnbuf[300];		/* if only C had real strings...  Then I
				   wouldn't have to resort to returning
				   strings in static & getting bitten by
				   later overwrites. */
    if (fn == 0)
	return 0;
    if (*fn=='\0'){
	error("I don't like empty file names!");
	return 0;
    }
    strcpy(fnbuf, SaveAbs (fn));
    WriteFile (fnbuf, 1);
    return 0;
}

VisitFile (fn, CreateNew, WindowFiddle)
char   *fn; {
    register struct window *w,
                           *oldw = wn_cur;
    char    fullname[500];
    register struct buffer *b,
                           *oldb = bf_cur;
    if (fn == 0 || *fn == 0)
	return 0;
    strcpy (fullname, SaveAbs (fn));
    for (b = buffers;
	    b && (b -> b_fname == 0 || strcmp (fullname, b -> b_fname) != 0);
	    b = b -> b_next);
    if (b)
	SetBfp (b);
    else {
	char   *bufname;
	register char  *p = fullname;
	bufname = fullname;
	while (*p)
	    if (*p++ == '/' && *p)
		bufname = p;
	if (FindBf (bufname)) {
	    if (interactive && AskAboutBufferNames) {
		p = getstr (
"Buffer name %s is in use, type a new name or <CR> to clobber: ", bufname);
		if (p == 0)
		    return 0;
		if (*p)
		    bufname = p;
	    }
	    else {
		static char SynthName[100];
		register    seq = 1;
	    /* I'm making the (perhaps) brash assumption that the
	       following loop is guaranteed to terminate.  To those who
	       think that this is an inefficient technique: you have
	       been deluded. */
		do sprintf (SynthName, "%s<%d>", bufname, ++seq);
		while (FindBf (SynthName));
		bufname = SynthName;
	    }
	}
	SetBfn (bufname);
	if (!readfile (fullname, 1, CreateNew) && !CreateNew) {
	    SetBfp (oldb);
	    return 0;
	}
	else {
	    bf_cur -> b_kind = FileBuffer;
	    if (bf_cur -> b_fname)
		free (bf_cur -> b_fname);
	    if (bf_cur -> b_checkpointfn)
		free (bf_cur -> b_checkpointfn);
	    bf_cur -> b_checkpointfn = 0;
	    bf_cur -> b_checkpointed = 0;
	    bf_cur -> b_fname = savestr (fullname);
	}
    }
    if (WindowFiddle) WindowOn (bf_cur);
    if (b == 0)
	DoAuto (fn);
    return 1;
}

readfile (fn, erase, CreateNew)
char   *fn; {
    struct stat st;
    register int    fd;
    register int    n,
                    i;
    if (fn == 0)
	return 0;
    if (*fn == 0) {
	error ("Aw come on, if you want me to read something I need file name");
	return 0;
    }
    if (stat (fn, &st) < 0 || (fd = open (fn, 0)) < 0) {
	error (CreateNew ? "New file: %s" : "Can't find \"%s\"", fn);
	return 0;
    }
    Cant1LineOpt++;
    RedoModes++;
    WidenRegion ();
    if (erase)
	EraseBf (bf_cur);
    GapTo (dot);
    DoneIsDone ();
    if (GapRoom (st.st_size))
	return 0;
    n = 0;
    while ((i = read (fd, bf_p1 + bf_s1 + 1 + n, st.st_size - n)) > 0)
	n += i;
    close (fd);
    if (n > 0) {
	bf_s1 += n;
	bf_gap -= n;
	bf_p2 -= n;
    }
    if (n == 0)
	message ("Empty file.");
    if (i < 0)
	error ("Error reading file \"%s\"", fn);
    if (erase) {
	if (bf_cur -> b_fname)
	    free (bf_cur -> b_fname);
	if (bf_cur -> b_checkpointfn) {
	    free (bf_cur -> b_checkpointfn);
	    bf_cur -> b_checkpointfn = 0;
	    bf_cur -> b_checkpointed = 0;
	}
	bf_cur -> b_fname = savestr (fn);
	bf_cur -> b_kind = FileBuffer;
	bf_cur -> b_modtime = st.st_mtime;
	bf_modtime = bf_cur->b_modtime;
    }
    return i >= 0;
}

/* Given a file name and an extension to be forced, concoct a new file name
   which is their concatenation, accounting for the restricton on the length
   of the last component of a file name begin 14 characters. */
char *ConcoctName (fn, extension)
char *fn, *extension;
{
    static  char name[200];
    register    extlen;
    register char  *p,
                   *s,
                   *tail;
    for (p = extension, extlen = 0; *p++;)
	extlen++;
    for (s = fn, p = tail = name; *p = *s++; p++)
	if (*p == '/')
	    tail = p + 1;
#ifdef PrependExtension
    /* put the extension at the beginning and let system truncate
     * name
     */
    for( ; p >= tail ; *(p+extlen) = *p, p-- );	/* shift right */
    for( p = extension ; *p ; *tail++ = *p++);  /* insert extension */
#else
    if (p - tail > 10)
	p = tail + 10;
    for(s=extension; *p++ = *s++; );
#endif
    return name;
}

/* write the current buffer to the named file; returns true iff
   successful.  Appends to the file if AppendIt is >0, does a checkpoint
   style write if AppendIt is <0. */
WriteFile (fn, AppendIt)
register char  *fn; {
    register    fd;
    register    nc = bf_s1 + bf_s2;
    int     mode = 0666 & ~Umask;
    int     TempFile =	   fn[0] == '/' && fn[1] == 't' && fn[2] == 'm'
			&& fn[3] == 'p' && fn[4] == '/';
    struct stat st;

    if(AppendIt<0) mode = 0600 & ~Umask;
    if(AppendIt>=0 && !access(fn,0) && access(fn,2)) {
	error("File %s cannot be written",fn);
	return 0;
    }
    if (fn == 0 || *fn == 0)
	return 0;
    if (AppendIt == 0 && stat(fn, &st) == 0 && bf_modtime != 0 &&
	st.st_mtime > bf_modtime)
    {
	FILE *LInputFD = InputFD;
	struct ProgNode *LCurExec = CurExec;
	InputFD = stdin;
	CurExec = 0;
	if ((*getnbstr("\"%s\" has been changed on disk, write anyway? ",
		    bf_cur->b_fname) | 0x60) != 'y')
	{
	    error("Not written");
	    InputFD = LInputFD;
	    CurExec = LCurExec;
	    return 0;
	}
	InputFD = LInputFD;
	CurExec = LCurExec;
    }

    if (AppendIt>0) {
	fd = open (fn, 1);
	if (fd < 0)
	    fd = creat (fn, mode);
	if (fd >= 0)
	    if (lseek (fd, 0, 2) < 0)
		close (fd), fd = -1;
    }
    else {
	if (AppendIt>=0 && BackupBeforeWriting && !TempFile
		&& !bf_cur -> b_BackedUp) {
	    int symlink = 0;
	    register char  *p,
	                   *tail;
	    char    *name = ConcoctName (fn, BackupExtension);
	    bf_cur -> b_BackedUp++;
	    if (lstat(fn, &st) == 0)
		if ((st.st_mode & S_IFMT) == S_IFLNK)
		    symlink = 1;

	    if (stat (fn, &st) == 0)
		mode = st.st_mode;
	    if (BackupByCopying || symlink
		    || st.st_nlink>1 && BackupByCopyingWhenLinked) {
		int     ifd,
		        ofd = -1,
		        n;
		char    buf[2048];
		if ((ifd = open (fn, 0)) >= 0
			&& (ofd = creat (name, 0600)) >= 0)
		    while ((n = read (ifd, buf, sizeof buf)) > 0)
			write (ofd, buf, n);
		if (ifd >= 0)
		    close (ifd);
		if (ofd >= 0)
		    close (ofd);
	    }
	    else {
		unlink (name);
		link (fn, name);
		unlink (fn);
	    }
	}
	fd = creat (fn, mode);
	if (fd >=0 && (mode & ~Umask) != mode)
	    chmod (fn,mode);
    }
    if (fd < 0) {
	error ("Can't write %s", fn);
	return 0;
    }
    if (FilesShouldEndWithNewline
	&& nc > 0 && CharAt (nc) != '\n' && interactive && AppendIt>=0 &&
	    *getnbstr (
		"\"%s\" doesn't end with a newline, should I add one? ",
		bf_cur->b_name) == 'y')
	InsertAt (nc + 1, '\n');
    if (write (fd, bf_p1 + 1, bf_s1) < 0
	    || write (fd, bf_p1 + 1 + bf_s1 + bf_gap, bf_s2) < 0) {
	error ("IO error writing %s", fn);
	close (fd);
	return 0;
    }
    close (fd);
    if(!err) {
	bf_modified = 0;
	bf_cur -> b_modtime = time(0);	/* close enough */
	bf_modtime = bf_cur->b_modtime;
	bf_cur -> b_checkpointed = 0;
	if (!TempFile)
	    message ("Wrote %s", fn);
    }
    Cant1LineOpt++;		/* Force update of the mode line */
    return 1;
}

/* fopenp opens the file fn with the given IO mode using the given
   search path.  The actual file name is returned in fnb.  The search
   path is interpreted in the same way as the PATH environment variable
   is interpreted by exec?p().  This routine normally comes from the CMU
   C library, but since Emacs is being distributed I have to roll-my-own.
   */
FILE *
fopenp (path, fn, fnb, mode)
register char *path;
char *fn, *fnb, *mode;
{
    register FILE *fd;
    char AbsForm[300];
    register char  *dst,
                   *src;
    if (path == 0)
	path = "";
    if (*fn=='~') {
	abspath (fn, AbsForm);
	fn = AbsForm;
    }
    if (*fn=='/'){
	if(( fd = fopen(fn, mode)) != NULL) {
	    strcpy(fnb, fn);
	    return fd;
	}
	return NULL;
    }
    do {
	dst = fnb;
	while (*path && *path != ':')
	    *dst++ = *path++;
	if (dst != fnb)
	    *dst++ = '/';
	for (src = fn; *dst++ = *src++;);
	if ((fd = fopen (fnb, mode)) != NULL)
	    return fd;
    } while (*path++);
    return NULL;
}

/* returns true if modified buffers exist */
ModExist () {
    register struct buffer *b;
    SetBfp (bf_cur);
    for (b = buffers; b; b = b -> b_next)
	if (b -> b_modified && b -> b_kind == FileBuffer)
	    return 1;
    return 0;
}

/* write all modified buffers; return true iff OK */
ModWrite () {
    register struct buffer *b;
    struct buffer  *old = bf_cur;
    register WriteErrors = 0;
    for (b = buffers; b; b = b -> b_next) {
	SetBfp (b);
	if (bf_cur->b_kind==FileBuffer && bf_modified
	    && WriteThis () == 0
	    && 'y' != *getnbstr ("Can't write buffer %s, can I ignore it? ",
				b -> b_name)){
	    WriteErrors++;
	}
    }
    SetBfp (old);
    return !err && !WriteErrors;
}

CheckpointEverything () {
    register struct buffer *b;
    struct buffer  *old = bf_cur;
    register    WriteErrors = 0, modcnt;
    int Checkpointed = 0;
    for (b = buffers; b; b = b -> b_next)
	if ((b -> b_mode.md_NeedsCheckpointing > 0 ||
		(b->b_kind == FileBuffer && b->b_mode.md_NeedsCheckpointing))
		&& b -> b_checkpointed < (modcnt = b == bf_cur ? bf_modified
						: b -> b_modified)) {
	    SetBfp (b);
	    if (b -> b_checkpointfn == 0)
		b -> b_checkpointfn =
		    savestr (ConcoctName (b -> b_fname ? b -> b_fname
						    : b -> b_name,
					  CheckpointExtension));
	    WriteErrors |= WriteFile (b -> b_checkpointfn, -1) == 0;
	    Checkpointed++;
	    b ->b_checkpointed = bf_modified = modcnt;
	}
    SetBfp (old);
    if(!WriteErrors && Checkpointed) message("Checkpointed...");
    if (WriteErrors) err = 0;	/* to avoid having errors during checkpoints
				   blow away functions in the middle of
				   execution. */
    return 0;
}

InitFIO () {
    umask(Umask = umask(077));
    if (!Once)
    {
	DefIntVar ("backup-before-writing", &BackupBeforeWriting);
	DefIntVar ("backup-by-copying", &BackupByCopying);
	DefIntVar ("backup-by-copying-when-linked", &BackupByCopyingWhenLinked);
	DefIntVar ("unlink-checkpoint-files", &UnlinkCheckpointFiles);
	DefIntVar ("files-should-end-with-newline", &FilesShouldEndWithNewline);
	FilesShouldEndWithNewline = 1;
	DefIntVar ("ask-about-buffer-names", &AskAboutBufferNames);
	AskAboutBufferNames = 1;
	setkey (CtlXmap, (Ctl ('F')), WriteFileExit, "write-file-exit");
	setkey (CtlXmap, (Ctl ('R')), ReadFile, "read-file");
	setkey (CtlXmap, (Ctl ('I')), InsertFile, "insert-file");
	setkey (CtlXmap, (Ctl ('V')), VisitFileCommand, "visit-file");
	setkey (CtlXmap, (Ctl ('W')), WriteNamedFile, "write-named-file");
	setkey (CtlXmap, (Ctl ('M')), WriteModifiedFiles, "write-modified-files");
	setkey (CtlXmap, (Ctl ('S')), WriteCurrentFile, "write-current-file");
	defproc (AppendToFile, "append-to-file");
	defproc (UnlinkFile, "unlink-file");
	defproc (FileExists, "file-exists");
	defproc (CheckpointEverything, "checkpoint");
	defproc (AutoExecute, "auto-execute");
	defproc (ChangeFileName, "change-file-name");
    }
}
