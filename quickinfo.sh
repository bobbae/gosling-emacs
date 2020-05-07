dbadd quickinfo "copysymbol" <<"</FoO ThE bAr/>"
(copysymbol 's_arg 'g_pred)
</FoO ThE bAr/>
dbadd quickinfo "putaccess" <<"</FoO ThE bAr/>"
(putaccess 'a_array 's_func)
</FoO ThE bAr/>
dbadd quickinfo "namestack" <<"</FoO ThE bAr/>"
(namestack)
</FoO ThE bAr/>
dbadd quickinfo "fillarray" <<"</FoO ThE bAr/>"
(fillarray 's_array 'l_itms)
</FoO ThE bAr/>
dbadd quickinfo "eval-when" <<"</FoO ThE bAr/>"
(eval-when l_time g_exp1 ...)
</FoO ThE bAr/>
dbadd quickinfo "bindstack" <<"</FoO ThE bAr/>"
(bindstack)
</FoO ThE bAr/>
dbadd quickinfo "arraycall" <<"</FoO ThE bAr/>"
(arraycall 's_type 'a_array 'x_ind1 ...)
</FoO ThE bAr/>
dbadd quickinfo "aexploden" <<"</FoO ThE bAr/>"
(aexploden 's_arg)
</FoO ThE bAr/>
dbadd quickinfo "tgetflag" <<"</FoO ThE bAr/>"
tgetflag(id)
</FoO ThE bAr/>
dbadd quickinfo "setpwent" <<"</FoO ThE bAr/>"
int setpwent();
</FoO ThE bAr/>
dbadd quickinfo "setplist" <<"</FoO ThE bAr/>"
(setplist 's_atm 'l_plist)
</FoO ThE bAr/>
dbadd quickinfo "setgrent" <<"</FoO ThE bAr/>"
int setgrent();
</FoO ThE bAr/>
dbadd quickinfo "putdelta" <<"</FoO ThE bAr/>"
(putdelta 'a_array 'x_delta)
</FoO ThE bAr/>
dbadd quickinfo "nreverse" <<"</FoO ThE bAr/>"
(nreverse 'l_arg)
</FoO ThE bAr/>
dbadd quickinfo "flatsize" <<"</FoO ThE bAr/>"
(flatsize 'g_form ['x_max])
</FoO ThE bAr/>
dbadd quickinfo "features" <<"</FoO ThE bAr/>"
(status features)
</FoO ThE bAr/>
dbadd quickinfo "exploden" <<"</FoO ThE bAr/>"
(exploden 'g_val)
</FoO ThE bAr/>
dbadd quickinfo "explodec" <<"</FoO ThE bAr/>"
(explodec 'g_val)
</FoO ThE bAr/>
dbadd quickinfo "dumpmode" <<"</FoO ThE bAr/>"
(sstatus dumpmode x_val)
</FoO ThE bAr/>
dbadd quickinfo "clearerr" <<"</FoO ThE bAr/>"
clearerr(stream)
</FoO ThE bAr/>
dbadd quickinfo "arrayref" <<"</FoO ThE bAr/>"
(arrayref 's_name 'x_ind)
</FoO ThE bAr/>
dbadd quickinfo "allocate" <<"</FoO ThE bAr/>"
(allocate 's_type 'x_pages)
</FoO ThE bAr/>
dbadd quickinfo "aexplode" <<"</FoO ThE bAr/>"
(aexplode 's_arg)
</FoO ThE bAr/>
dbadd quickinfo "TIOCSETN" <<"</FoO ThE bAr/>"
TIOCSETN: Set the parameters but do not delay or flush input.
</FoO ThE bAr/>
dbadd quickinfo "TIOCEXCL" <<"</FoO ThE bAr/>"
TIOCEXCL: Set 'exclusive-use' mode: no further opens are permitted.
</FoO ThE bAr/>
dbadd quickinfo "tyipeek" <<"</FoO ThE bAr/>"
(tyipeek ['p_port])
</FoO ThE bAr/>
dbadd quickinfo "ttyname" <<"</FoO ThE bAr/>"
char *ttyname(fildes)
</FoO ThE bAr/>
dbadd quickinfo "syscall" <<"</FoO ThE bAr/>"
(syscall)
</FoO ThE bAr/>
dbadd quickinfo "strcatn" <<"</FoO ThE bAr/>"
char *strcatn(s1, s2, n)
</FoO ThE bAr/>
dbadd quickinfo "sprintf" <<"</FoO ThE bAr/>"
char	*sprintf(string, format, args) -- generate a formatted string.
</FoO ThE bAr/>
dbadd quickinfo "reverse" <<"</FoO ThE bAr/>"
(reverse 'l_arg)
</FoO ThE bAr/>
dbadd quickinfo "remprop" <<"</FoO ThE bAr/>"
(remprop 's_name 'g_ind)
</FoO ThE bAr/>
dbadd quickinfo "putprop" <<"</FoO ThE bAr/>"
(putprop 's_name 'g_val 'g_ind)
</FoO ThE bAr/>
dbadd quickinfo "putdisc" <<"</FoO ThE bAr/>"
(putdisc 'y_func 's_discipline)
</FoO ThE bAr/>
dbadd quickinfo "putchar" <<"</FoO ThE bAr/>"
putchar(c)
</FoO ThE bAr/>
dbadd quickinfo "product" <<"</FoO ThE bAr/>"
(product ['n_arg1 ... ])
</FoO ThE bAr/>
dbadd quickinfo "outfile" <<"</FoO ThE bAr/>"
(outfile 's_filename)
</FoO ThE bAr/>
dbadd quickinfo "mpxcall" <<"</FoO ThE bAr/>"
mpxcall(cmd, vec)
</FoO ThE bAr/>
dbadd quickinfo "maplist" <<"</FoO ThE bAr/>"
(maplist 'u_func 'l_arg1 ...)
</FoO ThE bAr/>
dbadd quickinfo "linemod" <<"</FoO ThE bAr/>"
linemod(s) char s[ ];
</FoO ThE bAr/>
dbadd quickinfo "implode" <<"</FoO ThE bAr/>"
(implode 'l_arg)
</FoO ThE bAr/>
dbadd quickinfo "geteuid" <<"</FoO ThE bAr/>"
int	geteuid() { return(1); }
</FoO ThE bAr/>
dbadd quickinfo "getdisc" <<"</FoO ThE bAr/>"
(getdisc 't_func)
</FoO ThE bAr/>
dbadd quickinfo "freopen" <<"</FoO ThE bAr/>"
FILE	*freopen(s, m, f) char *s, *m; FILE *f; { return(stdin); }
</FoO ThE bAr/>
dbadd quickinfo "extract" <<"</FoO ThE bAr/>"
extract(i, xd)
</FoO ThE bAr/>
dbadd quickinfo "encrypt" <<"</FoO ThE bAr/>"
encrypt(s, i) char *s; {}
</FoO ThE bAr/>
dbadd quickinfo "defprop" <<"</FoO ThE bAr/>"
(defprop s_atm g_val g_ind)
</FoO ThE bAr/>
dbadd quickinfo "declare" <<"</FoO ThE bAr/>"
(declare [g_arg ...])
</FoO ThE bAr/>
dbadd quickinfo "connect" <<"</FoO ThE bAr/>"
connect(fd, cd, end)
</FoO ThE bAr/>
dbadd quickinfo "asctime" <<"</FoO ThE bAr/>"
char	*asctime(t) struct tm *t; { return(); }
</FoO ThE bAr/>
dbadd quickinfo "VTDELAY" <<"</FoO ThE bAr/>"
VTDELAY  0040000 Select form-feed and vertical-tab delays
</FoO ThE bAr/>
dbadd quickinfo "TBDELAY" <<"</FoO ThE bAr/>"
TBDELAY  0006000 Select tab delays
</FoO ThE bAr/>
dbadd quickinfo "SIGTERM" <<"</FoO ThE bAr/>"
SIGTERM 15   software termination signal
</FoO ThE bAr/>
dbadd quickinfo "SIGSEGV" <<"</FoO ThE bAr/>"
SIGSEGV 11*  segmentation violation
</FoO ThE bAr/>
dbadd quickinfo "SIGKILL" <<"</FoO ThE bAr/>"
SIGKILL 9    kill (cannot be caught or ignored)
</FoO ThE bAr/>
dbadd quickinfo "CRDELAY" <<"</FoO ThE bAr/>"
CRDELAY  0030000 Select carriage-return delays
</FoO ThE bAr/>
dbadd quickinfo "wdleng" <<"</FoO ThE bAr/>"
wdleng(){return(0); }
</FoO ThE bAr/>
dbadd quickinfo "valloc" <<"</FoO ThE bAr/>"
char *valloc(size)
</FoO ThE bAr/>
dbadd quickinfo "unlink" <<"</FoO ThE bAr/>"
int	unlink(s) char *s; { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "strlen" <<"</FoO ThE bAr/>"
int	strlen(s) char *s; { return(1); }
</FoO ThE bAr/>
dbadd quickinfo "strcpy" <<"</FoO ThE bAr/>"
char	*strcpy(a, b) char *a, *b; { ; }
</FoO ThE bAr/>
dbadd quickinfo "signal" <<"</FoO ThE bAr/>"
(signal 'x_signum 's_name)
</FoO ThE bAr/>
dbadd quickinfo "setjmp" <<"</FoO ThE bAr/>"
setjmp(e) int e[3]; { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "setbuf" <<"</FoO ThE bAr/>"
setbuf( f, b ) FILE *f; char *b; {;}
</FoO ThE bAr/>
dbadd quickinfo "rplaca" <<"</FoO ThE bAr/>"
(rplaca 'l_arg1 'g_arg2)
</FoO ThE bAr/>
dbadd quickinfo "rindex" <<"</FoO ThE bAr/>"
char *rindex(s, c)
</FoO ThE bAr/>
dbadd quickinfo "retbrk" <<"</FoO ThE bAr/>"
(retbrk ['x_level])
</FoO ThE bAr/>
dbadd quickinfo "profil" <<"</FoO ThE bAr/>"
profil(b, s, o, i) char *b; {;}
</FoO ThE bAr/>
dbadd quickinfo "printf" <<"</FoO ThE bAr/>"
printf(format, args) -- formatted print routine
</FoO ThE bAr/>
dbadd quickinfo "pclose" <<"</FoO ThE bAr/>"
pclose(stream)
</FoO ThE bAr/>
dbadd quickinfo "openpl" <<"</FoO ThE bAr/>"
openpl( )
</FoO ThE bAr/>
dbadd quickinfo "oblist" <<"</FoO ThE bAr/>"
(oblist)
</FoO ThE bAr/>
dbadd quickinfo "nwritn" <<"</FoO ThE bAr/>"
(nwritn ['p_port])
</FoO ThE bAr/>
dbadd quickinfo "mktemp" <<"</FoO ThE bAr/>"
char	*mktemp(p) char *p; { return(p);}
</FoO ThE bAr/>
dbadd quickinfo "mapcon" <<"</FoO ThE bAr/>"
(mapcon 'u_func 'l_arg1 ...)
</FoO ThE bAr/>
dbadd quickinfo "mapcar" <<"</FoO ThE bAr/>"
(mapcar 'u_func 'l_arg1 ...)
</FoO ThE bAr/>
dbadd quickinfo "length" <<"</FoO ThE bAr/>"
(length 'l_arg)
</FoO ThE bAr/>
dbadd quickinfo "isatty" <<"</FoO ThE bAr/>"
isatty(fildes)
</FoO ThE bAr/>
dbadd quickinfo "infile" <<"</FoO ThE bAr/>"
(infile 's_filename)
</FoO ThE bAr/>
dbadd quickinfo "getpid" <<"</FoO ThE bAr/>"
int	getpid() { return(1); }
</FoO ThE bAr/>
dbadd quickinfo "getenv" <<"</FoO ThE bAr/>"
(getenv 's_name)
</FoO ThE bAr/>
dbadd quickinfo "getaux" <<"</FoO ThE bAr/>"
(getaux 'a_array)
</FoO ThE bAr/>
dbadd quickinfo "gensym" <<"</FoO ThE bAr/>"
(gensym 's_leader)
</FoO ThE bAr/>
dbadd quickinfo "g_code" <<"</FoO ThE bAr/>"
(status g_code)
</FoO ThE bAr/>
dbadd quickinfo "fwrite" <<"</FoO ThE bAr/>"
int	fwrite( p, s, n, f ) char *p; FILE *f; {return(0);}
</FoO ThE bAr/>
dbadd quickinfo "fscanf" <<"</FoO ThE bAr/>"
fscanf( f, s ) FILE *f; char *s; {return(1);}
</FoO ThE bAr/>
dbadd quickinfo "floatp" <<"</FoO ThE bAr/>"
(floatp 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "fileno" <<"</FoO ThE bAr/>"
fileno(stream)
</FoO ThE bAr/>
dbadd quickinfo "fflush" <<"</FoO ThE bAr/>"
fflush(f) FILE *f; {return(0);}
</FoO ThE bAr/>
dbadd quickinfo "fclose" <<"</FoO ThE bAr/>"
fclose(f) FILE *f; {return(0);}
</FoO ThE bAr/>
dbadd quickinfo "execve" <<"</FoO ThE bAr/>"
execve(name, argv, envp);
</FoO ThE bAr/>
dbadd quickinfo "execle" <<"</FoO ThE bAr/>"
execle(name, arg0, arg1, ..., argn, 0,
</FoO ThE bAr/>
dbadd quickinfo "errset" <<"</FoO ThE bAr/>"
(errset ???)
</FoO ThE bAr/>
dbadd quickinfo "double" <<"</FoO ThE bAr/>"
double(x);
</FoO ThE bAr/>
dbadd quickinfo "detach" <<"</FoO ThE bAr/>"
detach(i, xd)
</FoO ThE bAr/>
dbadd quickinfo "concat" <<"</FoO ThE bAr/>"
(concat ['s_arg1 ... ])
</FoO ThE bAr/>
dbadd quickinfo "attach" <<"</FoO ThE bAr/>"
attach(i, xd)
</FoO ThE bAr/>
dbadd quickinfo "assert" <<"</FoO ThE bAr/>"
assert (expression)
</FoO ThE bAr/>
dbadd quickinfo "access" <<"</FoO ThE bAr/>"
access(name, mode)
</FoO ThE bAr/>
dbadd quickinfo "absval" <<"</FoO ThE bAr/>"
(absval 'n_arg)
</FoO ThE bAr/>
dbadd quickinfo "SIGSYS" <<"</FoO ThE bAr/>"
SIGSYS  12*  bad argument to system call
</FoO ThE bAr/>
dbadd quickinfo "SIGIOT" <<"</FoO ThE bAr/>"
SIGIOT  6*   IOT instruction
</FoO ThE bAr/>
dbadd quickinfo "SIGINT" <<"</FoO ThE bAr/>"
SIGINT  2    interrupt
</FoO ThE bAr/>
dbadd quickinfo "SIGILL" <<"</FoO ThE bAr/>"
SIGILL  4*   illegal instruction (not reset when caught)
</FoO ThE bAr/>
dbadd quickinfo "SIGHUP" <<"</FoO ThE bAr/>"
SIGHUP  1    hangup
</FoO ThE bAr/>
dbadd quickinfo "Divide" <<"</FoO ThE bAr/>"
(Divide 'i_dividend 'i_divisor)
</FoO ThE bAr/>
dbadd quickinfo "CBREAK" <<"</FoO ThE bAr/>"
CBREAK   0000002 Return each character as soon as it is tped
</FoO ThE bAr/>
dbadd quickinfo "write" <<"</FoO ThE bAr/>"
int	write(f, b, l) char *b; { return(l); }
</FoO ThE bAr/>
dbadd quickinfo "vread" <<"</FoO ThE bAr/>"
vread(fildes, buffer, nbytes)
</FoO ThE bAr/>
dbadd quickinfo "vfree" <<"</FoO ThE bAr/>"
vfree(cp)
</FoO ThE bAr/>
dbadd quickinfo "tputs" <<"</FoO ThE bAr/>"
tputs(cp, affcnt, outc)
</FoO ThE bAr/>
dbadd quickinfo "times" <<"</FoO ThE bAr/>"
(times ['n_arg1 ... ])
</FoO ThE bAr/>
dbadd quickinfo "space" <<"</FoO ThE bAr/>"
space(x0, y0, x1, y1)
</FoO ThE bAr/>
dbadd quickinfo "shell" <<"</FoO ThE bAr/>"
(shell)
</FoO ThE bAr/>
dbadd quickinfo "scanf" <<"</FoO ThE bAr/>"
scanf( f ) char *f; {return(1); }
</FoO ThE bAr/>
dbadd quickinfo "sassq" <<"</FoO ThE bAr/>"
(sassq 'g_arg1 'l_arg2 'sl_func)
</FoO ThE bAr/>
dbadd quickinfo "reset" <<"</FoO ThE bAr/>"
(reset)
</FoO ThE bAr/>
dbadd quickinfo "ratom" <<"</FoO ThE bAr/>"
(ratom ['p_port])
</FoO ThE bAr/>
dbadd quickinfo "quote" <<"</FoO ThE bAr/>"
(quote g_arg)
</FoO ThE bAr/>
dbadd quickinfo "qsort" <<"</FoO ThE bAr/>"
qsort(base, nel, width, compar)
</FoO ThE bAr/>
dbadd quickinfo "ptime" <<"</FoO ThE bAr/>"
(ptime)
</FoO ThE bAr/>
dbadd quickinfo "progv" <<"</FoO ThE bAr/>"
(progv 'l_locv 'l_initv g_exp1 ...)
</FoO ThE bAr/>
dbadd quickinfo "prog2" <<"</FoO ThE bAr/>"
(prog2 g_exp1 g_exp2 [g_exp3 ...])
</FoO ThE bAr/>
dbadd quickinfo "princ" <<"</FoO ThE bAr/>"
(princ 'g_arg ['p_port])
</FoO ThE bAr/>
dbadd quickinfo "portp" <<"</FoO ThE bAr/>"
(portp 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "point" <<"</FoO ThE bAr/>"
point(x, y)
</FoO ThE bAr/>
dbadd quickinfo "pause" <<"</FoO ThE bAr/>"
pause() {;}
</FoO ThE bAr/>
dbadd quickinfo "patom" <<"</FoO ThE bAr/>"
(patom 'g_exp ['p_port])
</FoO ThE bAr/>
dbadd quickinfo "opval" <<"</FoO ThE bAr/>"
(opval 's_arg ['g_newval])
</FoO ThE bAr/>
dbadd quickinfo "npgrp" <<"</FoO ThE bAr/>"
npgrp(i, xd, pgrp)
</FoO ThE bAr/>
dbadd quickinfo "nlist" <<"</FoO ThE bAr/>"
nlist(filename, nl)
</FoO ThE bAr/>
dbadd quickinfo "nconc" <<"</FoO ThE bAr/>"
(nconc 'l_arg1 'l_arg2)
</FoO ThE bAr/>
dbadd quickinfo "mount" <<"</FoO ThE bAr/>"
int	mount(s, n, f) char *s, *n; { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "lseek" <<"</FoO ThE bAr/>"
long	lseek(f, o, d) long o; { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "ldexp" <<"</FoO ThE bAr/>"
double ldexp(value, exp)
</FoO ThE bAr/>
dbadd quickinfo "l3tol" <<"</FoO ThE bAr/>"
l3tol(lp, cp, n)
</FoO ThE bAr/>
dbadd quickinfo "intss" <<"</FoO ThE bAr/>"
intss(){return(1); }
</FoO ThE bAr/>
dbadd quickinfo "hypot" <<"</FoO ThE bAr/>"
double hypot(x, y)
</FoO ThE bAr/>
dbadd quickinfo "gamma" <<"</FoO ThE bAr/>"
double gamma(x)
</FoO ThE bAr/>
dbadd quickinfo "ftell" <<"</FoO ThE bAr/>"
long ftell(stream)
</FoO ThE bAr/>
dbadd quickinfo "fstat" <<"</FoO ThE bAr/>"
int	fstat(f, b) struct stat *b; { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "fread" <<"</FoO ThE bAr/>"
fread( p, s, n, f ) char *p; FILE *f; {return(1);}
</FoO ThE bAr/>
dbadd quickinfo "fputs" <<"</FoO ThE bAr/>"
fputs(s,f) char *s; FILE *f; {;}
</FoO ThE bAr/>
dbadd quickinfo "fputc" <<"</FoO ThE bAr/>"
fputc(c, stream)
</FoO ThE bAr/>
dbadd quickinfo "fopen" <<"</FoO ThE bAr/>"
FILE	*fopen(s,m) char *s, *m; { return(stdin); }
</FoO ThE bAr/>
dbadd quickinfo "fgets" <<"</FoO ThE bAr/>"
char	*fgets( s, l, f ) char *s; FILE *f; { return(s); }
</FoO ThE bAr/>
dbadd quickinfo "execv" <<"</FoO ThE bAr/>"
execv(s, v) char *s, *v[]; {;}
</FoO ThE bAr/>
dbadd quickinfo "execl" <<"</FoO ThE bAr/>"
execl(f, a) char *f, *a; {;}
</FoO ThE bAr/>
dbadd quickinfo "erase" <<"</FoO ThE bAr/>"
erase( )
</FoO ThE bAr/>
dbadd quickinfo "equal" <<"</FoO ThE bAr/>"
(equal 'g_arg1 'g_arg2)
</FoO ThE bAr/>
dbadd quickinfo "defun" <<"</FoO ThE bAr/>"
(defun s_name [s_mtype] ls_argl g_exp1 ...)
</FoO ThE bAr/>
dbadd quickinfo "datum" <<"</FoO ThE bAr/>"
datum: typedef struct { char *dptr; int dsize; };
</FoO ThE bAr/>
dbadd quickinfo "ctime" <<"</FoO ThE bAr/>"
char	*ctime(c) time_t *c;{ return(); }
</FoO ThE bAr/>
dbadd quickinfo "creat" <<"</FoO ThE bAr/>"
int	creat(s, m) char *s; { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "chown" <<"</FoO ThE bAr/>"
int	chown(s, u, g) char *s; { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "chdir" <<"</FoO ThE bAr/>"
(chdir 's_path)
</FoO ThE bAr/>
dbadd quickinfo "cfasl" <<"</FoO ThE bAr/>"
(cfasl 'st_file 'st_entry 's_funcname ['st_library])
</FoO ThE bAr/>
dbadd quickinfo "boole" <<"</FoO ThE bAr/>"
(boole 'x_key 'x_v1 'x_v2 ...)
</FoO ThE bAr/>
dbadd quickinfo "atan2" <<"</FoO ThE bAr/>"
double atan2(x, y)
</FoO ThE bAr/>
dbadd quickinfo "assoc" <<"</FoO ThE bAr/>"
(assoc 'g_arg1 'l_arg2)
</FoO ThE bAr/>
dbadd quickinfo "ascii" <<"</FoO ThE bAr/>"
(ascii x_charnum)
</FoO ThE bAr/>
dbadd quickinfo "array" <<"</FoO ThE bAr/>"
(array s_name s_type x_dim1 ... x_dimi)
</FoO ThE bAr/>
dbadd quickinfo "_exit" <<"</FoO ThE bAr/>"
_exit(status)
</FoO ThE bAr/>
dbadd quickinfo "CRMOD" <<"</FoO ThE bAr/>"
CRMOD    0000020 Map CR into LF; echo LF or CR as CR-LF
</FoO ThE bAr/>
dbadd quickinfo "B1800" <<"</FoO ThE bAr/>"
B1800   10   1800 baud
</FoO ThE bAr/>
dbadd quickinfo "B1200" <<"</FoO ThE bAr/>"
B1200   9    1200 baud
</FoO ThE bAr/>
dbadd quickinfo "what" <<"</FoO ThE bAr/>"
(what 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "type" <<"</FoO ThE bAr/>"
(type 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "time" <<"</FoO ThE bAr/>"
long	time(t) long *t; { return(0);}
</FoO ThE bAr/>
dbadd quickinfo "tell" <<"</FoO ThE bAr/>"
long	tell(f) { return((long)0); }
</FoO ThE bAr/>
dbadd quickinfo "tanh" <<"</FoO ThE bAr/>"
double tanh(x)
</FoO ThE bAr/>
dbadd quickinfo "sub1" <<"</FoO ThE bAr/>"
(sub1 'n_arg)
</FoO ThE bAr/>
dbadd quickinfo "sqrt" <<"</FoO ThE bAr/>"
(sqrt 'fx_arg)
</FoO ThE bAr/>
dbadd quickinfo "setq" <<"</FoO ThE bAr/>"
(setq s_atm1 'g_val1 [ s_atm2 'g_val2 ... ... ])
</FoO ThE bAr/>
dbadd quickinfo "sbrk" <<"</FoO ThE bAr/>"
char	*sbrk(i) { return((char *)0); }
</FoO ThE bAr/>
dbadd quickinfo "rand" <<"</FoO ThE bAr/>"
rand( )
</FoO ThE bAr/>
dbadd quickinfo "pipe" <<"</FoO ThE bAr/>"
int	pipe(f) int f[2]; { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "onep" <<"</FoO ThE bAr/>"
(onep 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "null" <<"</FoO ThE bAr/>"
(null 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "move" <<"</FoO ThE bAr/>"
move(x, y)
</FoO ThE bAr/>
dbadd quickinfo "modf" <<"</FoO ThE bAr/>"
double modf(value, iptr)
</FoO ThE bAr/>
dbadd quickinfo "memq" <<"</FoO ThE bAr/>"
(memq 'g_arg1 'l_arg2)
</FoO ThE bAr/>
dbadd quickinfo "load" <<"</FoO ThE bAr/>"
(load 's_filename)
</FoO ThE bAr/>
dbadd quickinfo "line" <<"</FoO ThE bAr/>"
line(x1, y1, x2, y2)
</FoO ThE bAr/>
dbadd quickinfo "last" <<"</FoO ThE bAr/>"
(last 'l_arg)
</FoO ThE bAr/>
dbadd quickinfo "join" <<"</FoO ThE bAr/>"
join(fd, xd)
</FoO ThE bAr/>
dbadd quickinfo "gtty" <<"</FoO ThE bAr/>"
int	gtty(f, b) struct sgttyb *b; { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "getw" <<"</FoO ThE bAr/>"
int getw(stream)
</FoO ThE bAr/>
dbadd quickinfo "gets" <<"</FoO ThE bAr/>"
char *gets(s)
</FoO ThE bAr/>
dbadd quickinfo "free" <<"</FoO ThE bAr/>"
free(p) char *p; {;}
</FoO ThE bAr/>
dbadd quickinfo "fixp" <<"</FoO ThE bAr/>"
(fixp 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "fcvt" <<"</FoO ThE bAr/>"
char	*fcvt(v, n, d, s) double v; int *d, *s; { return(); }
</FoO ThE bAr/>
dbadd quickinfo "fabs" <<"</FoO ThE bAr/>"
double fabs(x)
</FoO ThE bAr/>
dbadd quickinfo "exit" <<"</FoO ThE bAr/>"
(exit ['x_code])
</FoO ThE bAr/>
dbadd quickinfo "eval" <<"</FoO ThE bAr/>"
(eval 'g_val)
</FoO ThE bAr/>
dbadd quickinfo "ecvt" <<"</FoO ThE bAr/>"
char	*ecvt(v, n, d, s) double v; int *d, *s; { return(); }
</FoO ThE bAr/>
dbadd quickinfo "dup2" <<"</FoO ThE bAr/>"
dup2(fildes, fildes2)
</FoO ThE bAr/>
dbadd quickinfo "dtpr" <<"</FoO ThE bAr/>"
(dtpr 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "diff" <<"</FoO ThE bAr/>"
(diff ['n_arg1 ... ])
</FoO ThE bAr/>
dbadd quickinfo "delq" <<"</FoO ThE bAr/>"
(delq 'g_val 'l_list ['x_count])
</FoO ThE bAr/>
dbadd quickinfo "cpy1" <<"</FoO ThE bAr/>"
(cpy1 'xvt_arg)
</FoO ThE bAr/>
dbadd quickinfo "cons" <<"</FoO ThE bAr/>"
(cons 'g_arg1 'g_arg2)
</FoO ThE bAr/>
dbadd quickinfo "cond" <<"</FoO ThE bAr/>"
(cond [l_clause1 ...])
</FoO ThE bAr/>
dbadd quickinfo "chan" <<"</FoO ThE bAr/>"
chan(xd)
</FoO ThE bAr/>
dbadd quickinfo "cabs" <<"</FoO ThE bAr/>"
double cabs(z)
</FoO ThE bAr/>
dbadd quickinfo "c..r" <<"</FoO ThE bAr/>"
(c..r 'l_arg)
</FoO ThE bAr/>
dbadd quickinfo "bigp" <<"</FoO ThE bAr/>"
(bigp 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "bcdp" <<"</FoO ThE bAr/>"
(bcdp 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "atol" <<"</FoO ThE bAr/>"
long atol(nptr)
</FoO ThE bAr/>
dbadd quickinfo "acos" <<"</FoO ThE bAr/>"
(acos 'fx_arg)
</FoO ThE bAr/>
dbadd quickinfo "acct" <<"</FoO ThE bAr/>"
acct(file)
</FoO ThE bAr/>
dbadd quickinfo "TAB3" <<"</FoO ThE bAr/>"
TAB3     0006000
</FoO ThE bAr/>
dbadd quickinfo "TAB2" <<"</FoO ThE bAr/>"
TAB2     0004000
</FoO ThE bAr/>
dbadd quickinfo "TAB1" <<"</FoO ThE bAr/>"
TAB1     0002000
</FoO ThE bAr/>
dbadd quickinfo "TAB0" <<"</FoO ThE bAr/>"
TAB0     0
</FoO ThE bAr/>
dbadd quickinfo "ODDP" <<"</FoO ThE bAr/>"
ODDP     0000100 Odd parity allowed on input
</FoO ThE bAr/>
dbadd quickinfo "EXTB" <<"</FoO ThE bAr/>"
EXTB    15   External B
</FoO ThE bAr/>
dbadd quickinfo "EXTA" <<"</FoO ThE bAr/>"
EXTA    14   External A
</FoO ThE bAr/>
dbadd quickinfo "ECHO" <<"</FoO ThE bAr/>"
ECHO     0000010 Echo (full duplex)
</FoO ThE bAr/>
dbadd quickinfo "B300" <<"</FoO ThE bAr/>"
B300    7    300 baud
</FoO ThE bAr/>
dbadd quickinfo "B134" <<"</FoO ThE bAr/>"
B134    4    134.5 baud
</FoO ThE bAr/>
dbadd quickinfo "tyi" <<"</FoO ThE bAr/>"
(tyi ['p_port])
</FoO ThE bAr/>
dbadd quickinfo "sum" <<"</FoO ThE bAr/>"
(sum ['n_arg1 ...])
</FoO ThE bAr/>
dbadd quickinfo "pow" <<"</FoO ThE bAr/>"
double pow(x, y)
</FoO ThE bAr/>
dbadd quickinfo "not" <<"</FoO ThE bAr/>"
(not 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "mpx" <<"</FoO ThE bAr/>"
mpx(name, access) char *name;
</FoO ThE bAr/>
dbadd quickinfo "mod" <<"</FoO ThE bAr/>"
(mod 'i_dividend 'i_divisor)
</FoO ThE bAr/>
dbadd quickinfo "min" <<"</FoO ThE bAr/>"
(min 'n_arg1 ...)
</FoO ThE bAr/>
dbadd quickinfo "max" <<"</FoO ThE bAr/>"
(max 'n_arg1 ...)
</FoO ThE bAr/>
dbadd quickinfo "map" <<"</FoO ThE bAr/>"
(map 'u_func 'l_arg1 ...)
</FoO ThE bAr/>
dbadd quickinfo "log" <<"</FoO ThE bAr/>"
(log 'fx_arg)
</FoO ThE bAr/>
dbadd quickinfo "get" <<"</FoO ThE bAr/>"
(get 's_name 'g_ind)
</FoO ThE bAr/>
dbadd quickinfo "fix" <<"</FoO ThE bAr/>"
(fix 'n_arg)
</FoO ThE bAr/>
dbadd quickinfo "exp" <<"</FoO ThE bAr/>"
(exp 'fx_arg)
</FoO ThE bAr/>
dbadd quickinfo "err" <<"</FoO ThE bAr/>"
(err ???)
</FoO ThE bAr/>
dbadd quickinfo "dup" <<"</FoO ThE bAr/>"
int	dup(f) { return(f); }
</FoO ThE bAr/>
dbadd quickinfo "cos" <<"</FoO ThE bAr/>"
(cos 'fx_angle)
</FoO ThE bAr/>
dbadd quickinfo "brk" <<"</FoO ThE bAr/>"
char	*brk(a) char *a; { return(a); }
</FoO ThE bAr/>
dbadd quickinfo "arg" <<"</FoO ThE bAr/>"
(arg ['x_numb])
</FoO ThE bAr/>
dbadd quickinfo "abs" <<"</FoO ThE bAr/>"
(abs 'n_arg)
</FoO ThE bAr/>
dbadd quickinfo "NL2" <<"</FoO ThE bAr/>"
NL2      0001000
</FoO ThE bAr/>
dbadd quickinfo "NL0" <<"</FoO ThE bAr/>"
NL0      0
</FoO ThE bAr/>
dbadd quickinfo "FF1" <<"</FoO ThE bAr/>"
FF1      0040000
</FoO ThE bAr/>
dbadd quickinfo "CR2" <<"</FoO ThE bAr/>"
CR2      0020000
</FoO ThE bAr/>
dbadd quickinfo "CR1" <<"</FoO ThE bAr/>"
CR1      0010000
</FoO ThE bAr/>
dbadd quickinfo "CR0" <<"</FoO ThE bAr/>"
CR0      0
</FoO ThE bAr/>
dbadd quickinfo "or" <<"</FoO ThE bAr/>"
(or [g_arg1 ... ])
</FoO ThE bAr/>
dbadd quickinfo "go" <<"</FoO ThE bAr/>"
(go g_labexp)
</FoO ThE bAr/>
dbadd quickinfo "B0" <<"</FoO ThE bAr/>"
B0      0    (hang up dataphone)
</FoO ThE bAr/>
dbadd quickinfo "1+" <<"</FoO ThE bAr/>"
(1+ 'n_arg)
</FoO ThE bAr/>
dbadd quickinfo "<" <<"</FoO ThE bAr/>"
(< 'n_arg1 'n_arg2)
</FoO ThE bAr/>
dbadd quickinfo "/" <<"</FoO ThE bAr/>"
(/ 'n_arg1 'n_arg2)
</FoO ThE bAr/>
dbadd quickinfo "-" <<"</FoO ThE bAr/>"
(- 'n_arg)
</FoO ThE bAr/>
dbadd quickinfo "+" <<"</FoO ThE bAr/>"
(+ 'n_arg)
</FoO ThE bAr/>
dbadd quickinfo "*" <<"</FoO ThE bAr/>"
(* 'n_arg)
</FoO ThE bAr/>
dbadd quickinfo "alphalessp" <<"</FoO ThE bAr/>"
(alphalessp 's_arg1 's_arg2)
</FoO ThE bAr/>
dbadd quickinfo "top-level" <<"</FoO ThE bAr/>"
(top-level)
</FoO ThE bAr/>
dbadd quickinfo "showstack" <<"</FoO ThE bAr/>"
(showstack)
</FoO ThE bAr/>
dbadd quickinfo "remainder" <<"</FoO ThE bAr/>"
(remainder 'i_dividend 'i_divisor)
</FoO ThE bAr/>
dbadd quickinfo "putlength" <<"</FoO ThE bAr/>"
(putlength 'a_array 'x_length)
</FoO ThE bAr/>
dbadd quickinfo "mfunction" <<"</FoO ThE bAr/>"
(mfunction entry 's_disc)
</FoO ThE bAr/>
dbadd quickinfo "get_pname" <<"</FoO ThE bAr/>"
(get_pname 's_arg)
</FoO ThE bAr/>
dbadd quickinfo "arraydims" <<"</FoO ThE bAr/>"
(arraydims 's_name)
</FoO ThE bAr/>
dbadd quickinfo "aexplodec" <<"</FoO ThE bAr/>"
(aexplodec 's_arg)
</FoO ThE bAr/>
dbadd quickinfo "TIOCFLUSH" <<"</FoO ThE bAr/>"
TIOCFLUSH: All characters waiting in input or output queues are flushed.
</FoO ThE bAr/>
dbadd quickinfo "quotient" <<"</FoO ThE bAr/>"
(quotient ['n_arg1 ...])
</FoO ThE bAr/>
dbadd quickinfo "getlogin" <<"</FoO ThE bAr/>"
char *getlogin();
</FoO ThE bAr/>
dbadd quickinfo "getdelta" <<"</FoO ThE bAr/>"
(getdelta 'a_array)
</FoO ThE bAr/>
dbadd quickinfo "function" <<"</FoO ThE bAr/>"
(function u_func)
</FoO ThE bAr/>
dbadd quickinfo "firstkey" <<"</FoO ThE bAr/>"
datum firstkey();
</FoO ThE bAr/>
dbadd quickinfo "endgrent" <<"</FoO ThE bAr/>"
int endgrent();
</FoO ThE bAr/>
dbadd quickinfo "dumplisp" <<"</FoO ThE bAr/>"
(dumplisp s_name)
</FoO ThE bAr/>
dbadd quickinfo "baktrace" <<"</FoO ThE bAr/>"
(baktrace)
</FoO ThE bAr/>
dbadd quickinfo "TIOCNXCL" <<"</FoO ThE bAr/>"
TIOCNXCL: Turn off 'exclusive-use' mode.
</FoO ThE bAr/>
dbadd quickinfo "TIOCHPCL" <<"</FoO ThE bAr/>"
TIOCHPCL: When the file is closed for the last time, hang up.
</FoO ThE bAr/>
dbadd quickinfo "TIOCGETP" <<"</FoO ThE bAr/>"
TIOCGETP: Fetch the parameters associated with the terminal.
</FoO ThE bAr/>
dbadd quickinfo "ALLDELAY" <<"</FoO ThE bAr/>"
ALLDELAY 0177400 Delay algorithm selection
</FoO ThE bAr/>
dbadd quickinfo "uconcat" <<"</FoO ThE bAr/>"
(uconcat ['s_arg1 ... ])
</FoO ThE bAr/>
dbadd quickinfo "ttyslot" <<"</FoO ThE bAr/>"
ttyslot()
</FoO ThE bAr/>
dbadd quickinfo "tgetstr" <<"</FoO ThE bAr/>"
tgetstr(id, area)
</FoO ThE bAr/>
dbadd quickinfo "tgetent" <<"</FoO ThE bAr/>"
tgetent(bp, name)
</FoO ThE bAr/>
dbadd quickinfo "stringp" <<"</FoO ThE bAr/>"
(stringp 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "strcmpn" <<"</FoO ThE bAr/>"
strcmpn(s1, s2, n)
</FoO ThE bAr/>
dbadd quickinfo "resetio" <<"</FoO ThE bAr/>"
(resetio)
</FoO ThE bAr/>
dbadd quickinfo "rematom" <<"</FoO ThE bAr/>"
(rematom 's_symb)
</FoO ThE bAr/>
dbadd quickinfo "numberp" <<"</FoO ThE bAr/>"
(numberp 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "nextkey" <<"</FoO ThE bAr/>"
datum nextkey(key);
</FoO ThE bAr/>
dbadd quickinfo "monitor" <<"</FoO ThE bAr/>"
monitor(l, h, b, s, n) int (*l)(), (*h)(); short *b; {}
</FoO ThE bAr/>
dbadd quickinfo "isalpha" <<"</FoO ThE bAr/>"
isalpha(c)
</FoO ThE bAr/>
dbadd quickinfo "getpass" <<"</FoO ThE bAr/>"
char *getpass(prompt)
</FoO ThE bAr/>
dbadd quickinfo "gcafter" <<"</FoO ThE bAr/>"
(gcafter s_type)
</FoO ThE bAr/>
dbadd quickinfo "fprintf" <<"</FoO ThE bAr/>"
fprintf( f, s ) FILE *f; char *s; {;}
</FoO ThE bAr/>
dbadd quickinfo "feature" <<"</FoO ThE bAr/>"
(status feature g_val)
</FoO ThE bAr/>
dbadd quickinfo "explode" <<"</FoO ThE bAr/>"
(explode 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "dbminit" <<"</FoO ThE bAr/>"
dbminit(file)
</FoO ThE bAr/>
dbadd quickinfo "closepl" <<"</FoO ThE bAr/>"
closepl( )
</FoO ThE bAr/>
dbadd quickinfo "SIGTRAP" <<"</FoO ThE bAr/>"
SIGTRAP 5*   trace trap (not reset when caught)
</FoO ThE bAr/>
dbadd quickinfo "SIGQUIT" <<"</FoO ThE bAr/>"
SIGQUIT 3*   quit
</FoO ThE bAr/>
dbadd quickinfo "SIGPIPE" <<"</FoO ThE bAr/>"
SIGPIPE 13   write on a pipe with no one to read it
</FoO ThE bAr/>
dbadd quickinfo "SIGALRM" <<"</FoO ThE bAr/>"
SIGALRM 14   alarm clock
</FoO ThE bAr/>
dbadd quickinfo "NLDELAY" <<"</FoO ThE bAr/>"
NLDELAY  0001400 Select new-line delays
</FoO ThE bAr/>
dbadd quickinfo "Emuldiv" <<"</FoO ThE bAr/>"
(Emuldiv 'x_fact1 'x_fact2 'x_addn 'x_divisor)
</FoO ThE bAr/>
dbadd quickinfo "ungetc" <<"</FoO ThE bAr/>"
ungetc( c, f ) FILE *f; {  return(c); }
</FoO ThE bAr/>
dbadd quickinfo "umount" <<"</FoO ThE bAr/>"
umount(special)
</FoO ThE bAr/>
dbadd quickinfo "strcmp" <<"</FoO ThE bAr/>"
int	strcmp(a, b) char *a, *b; { return(1); }
</FoO ThE bAr/>
dbadd quickinfo "strcat" <<"</FoO ThE bAr/>"
char	*strcat(a, b) char *a, *b; { ; }
</FoO ThE bAr/>
dbadd quickinfo "sscanf" <<"</FoO ThE bAr/>"
sscanf( s, f ) char *s, *f; { return(1); }
</FoO ThE bAr/>
dbadd quickinfo "setkey" <<"</FoO ThE bAr/>"
setkey(k) char *k; {}
</FoO ThE bAr/>
dbadd quickinfo "setgid" <<"</FoO ThE bAr/>"
int	setgid(g) { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "rewind" <<"</FoO ThE bAr/>"
rewind(f) FILE *f; {;}
</FoO ThE bAr/>
dbadd quickinfo "random" <<"</FoO ThE bAr/>"
(random ['x_limit])
</FoO ThE bAr/>
dbadd quickinfo "ptrace" <<"</FoO ThE bAr/>"
int	ptrace(r, p, a, d) { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "member" <<"</FoO ThE bAr/>"
(member 'g_arg1 'l_arg2)
</FoO ThE bAr/>
dbadd quickinfo "mapcan" <<"</FoO ThE bAr/>"
(mapcan 'u_func 'l_arg1 ...)
</FoO ThE bAr/>
dbadd quickinfo "maknam" <<"</FoO ThE bAr/>"
(maknam 'l_arg)
</FoO ThE bAr/>
dbadd quickinfo "gmtime" <<"</FoO ThE bAr/>"
struct	tm *gmtime(c) time_t *c; { return gmtime(c); }
</FoO ThE bAr/>
dbadd quickinfo "getgid" <<"</FoO ThE bAr/>"
int	getgid() { return(1); }
</FoO ThE bAr/>
dbadd quickinfo "ferror" <<"</FoO ThE bAr/>"
ferror(stream)
</FoO ThE bAr/>
dbadd quickinfo "calloc" <<"</FoO ThE bAr/>"
char	*calloc(n,s) unsigned n, s; { static char c[1]; return(c); }
</FoO ThE bAr/>
dbadd quickinfo "boundp" <<"</FoO ThE bAr/>"
(boundp 's_name)
</FoO ThE bAr/>
dbadd quickinfo "SIGFPE" <<"</FoO ThE bAr/>"
SIGFPE  8*   floating point exception
</FoO ThE bAr/>
dbadd quickinfo "*throw" <<"</FoO ThE bAr/>"
(*throw 's_tag 'g_val)
</FoO ThE bAr/>
dbadd quickinfo "*catch" <<"</FoO ThE bAr/>"
(*catch 'ls_tag g_exp)
</FoO ThE bAr/>
dbadd quickinfo "vfork" <<"</FoO ThE bAr/>"
vfork()
</FoO ThE bAr/>
dbadd quickinfo "throw" <<"</FoO ThE bAr/>"
(throw 'g_val [s_tag])
</FoO ThE bAr/>
dbadd quickinfo "tgoto" <<"</FoO ThE bAr/>"
tgoto(cm, destcol, destline)
</FoO ThE bAr/>
dbadd quickinfo "terpr" <<"</FoO ThE bAr/>"
(terpr ['p_port])
</FoO ThE bAr/>
dbadd quickinfo "stime" <<"</FoO ThE bAr/>"
stime(tp)
</FoO ThE bAr/>
dbadd quickinfo "srand" <<"</FoO ThE bAr/>"
srand(seed)
</FoO ThE bAr/>
dbadd quickinfo "print" <<"</FoO ThE bAr/>"
(print 'g_arg ['p_port])
</FoO ThE bAr/>
dbadd quickinfo "popen" <<"</FoO ThE bAr/>"
FILE *popen(command, type)
</FoO ThE bAr/>
dbadd quickinfo "plist" <<"</FoO ThE bAr/>"
(plist 's_name)
</FoO ThE bAr/>
dbadd quickinfo "ncons" <<"</FoO ThE bAr/>"
(ncons 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "mknod" <<"</FoO ThE bAr/>"
int	mknod(n, m, a) char *n; { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "minus" <<"</FoO ThE bAr/>"
(minus 'n_arg)
</FoO ThE bAr/>
dbadd quickinfo "ltol3" <<"</FoO ThE bAr/>"
ltol3(cp, lp, n)
</FoO ThE bAr/>
dbadd quickinfo "log10" <<"</FoO ThE bAr/>"
double log10(x)
</FoO ThE bAr/>
dbadd quickinfo "label" <<"</FoO ThE bAr/>"
label(s) char s[ ];
</FoO ThE bAr/>
dbadd quickinfo "ioctl" <<"</FoO ThE bAr/>"
ioctl(fildes, request, argp)
</FoO ThE bAr/>
dbadd quickinfo "index" <<"</FoO ThE bAr/>"
char *index(s, c)
</FoO ThE bAr/>
dbadd quickinfo "iargc" <<"</FoO ThE bAr/>"
iargc()
</FoO ThE bAr/>
dbadd quickinfo "getpw" <<"</FoO ThE bAr/>"
getpw(uid, buf)
</FoO ThE bAr/>
dbadd quickinfo "fseek" <<"</FoO ThE bAr/>"
(fseek 'p_port 'x_offset 'x_flag)
</FoO ThE bAr/>
dbadd quickinfo "frexp" <<"</FoO ThE bAr/>"
double frexp(value, eptr)
</FoO ThE bAr/>
dbadd quickinfo "floor" <<"</FoO ThE bAr/>"
double floor(x)
</FoO ThE bAr/>
dbadd quickinfo "float" <<"</FoO ThE bAr/>"
(float 'n_arg)
</FoO ThE bAr/>
dbadd quickinfo "flatc" <<"</FoO ThE bAr/>"
(flatc 'g_form ['x_max])
</FoO ThE bAr/>
dbadd quickinfo "fgetc" <<"</FoO ThE bAr/>"
int fgetc(stream)
</FoO ThE bAr/>
dbadd quickinfo "ffasl" <<"</FoO ThE bAr/>"
(ffasl 'st_file 'st_entry 'st_funcname)
</FoO ThE bAr/>
dbadd quickinfo "ckill" <<"</FoO ThE bAr/>"
ckill(i, xd, signal)
</FoO ThE bAr/>
dbadd quickinfo "catch" <<"</FoO ThE bAr/>"
(catch g_exp [ls_tag])
</FoO ThE bAr/>
dbadd quickinfo "break" <<"</FoO ThE bAr/>"
(break [g_message ['g_pred]])
</FoO ThE bAr/>
dbadd quickinfo "apply" <<"</FoO ThE bAr/>"
(apply 'u_func 'l_args)
</FoO ThE bAr/>
dbadd quickinfo "alarm" <<"</FoO ThE bAr/>"
int	alarm(s) unsigned s; { return(s); }
</FoO ThE bAr/>
dbadd quickinfo "abort" <<"</FoO ThE bAr/>"
abort() {}
</FoO ThE bAr/>
dbadd quickinfo "B9600" <<"</FoO ThE bAr/>"
B9600   13   9600 baud
</FoO ThE bAr/>
dbadd quickinfo "B4800" <<"</FoO ThE bAr/>"
B4800   12   4800 baud
</FoO ThE bAr/>
dbadd quickinfo "B2400" <<"</FoO ThE bAr/>"
B2400   11   2400 baud
</FoO ThE bAr/>
dbadd quickinfo "wait" <<"</FoO ThE bAr/>"
int	wait(s) int *s; { return(1); }
</FoO ThE bAr/>
dbadd quickinfo "swab" <<"</FoO ThE bAr/>"
swab(from, to, nbytes)
</FoO ThE bAr/>
dbadd quickinfo "sinh" <<"</FoO ThE bAr/>"
double sinh(x)
</FoO ThE bAr/>
dbadd quickinfo "seek" <<"</FoO ThE bAr/>"
int	seek(f, o, p) { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "putw" <<"</FoO ThE bAr/>"
putw(w, stream)
</FoO ThE bAr/>
dbadd quickinfo "puts" <<"</FoO ThE bAr/>"
puts(s)
</FoO ThE bAr/>
dbadd quickinfo "putd" <<"</FoO ThE bAr/>"
(putd 's_name 'u_func)
</FoO ThE bAr/>
dbadd quickinfo "prog" <<"</FoO ThE bAr/>"
(prog l_vrbls g_exp1 ...)
</FoO ThE bAr/>
dbadd quickinfo "plus" <<"</FoO ThE bAr/>"
(plus ['n_arg ...])
</FoO ThE bAr/>
dbadd quickinfo "outc" <<"</FoO ThE bAr/>"
int (*outc)();
</FoO ThE bAr/>
dbadd quickinfo "open" <<"</FoO ThE bAr/>"
int	open(f, m) char *f; { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "nice" <<"</FoO ThE bAr/>"
int	nice(p) { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "list" <<"</FoO ThE bAr/>"
(list ['g_arg1 ... ])
</FoO ThE bAr/>
dbadd quickinfo "getc" <<"</FoO ThE bAr/>"
int getc(stream)
</FoO ThE bAr/>
dbadd quickinfo "fork" <<"</FoO ThE bAr/>"
int	fork() { return(0); }
</FoO ThE bAr/>
dbadd quickinfo "fake" <<"</FoO ThE bAr/>"
(fake 'x_addr)
</FoO ThE bAr/>
dbadd quickinfo "copy" <<"</FoO ThE bAr/>"
(copy 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "atom" <<"</FoO ThE bAr/>"
(atom 'g_arg)
</FoO ThE bAr/>
dbadd quickinfo "assq" <<"</FoO ThE bAr/>"
(assq 'g_arg1 'l_arg2)
</FoO ThE bAr/>
dbadd quickinfo "B600" <<"</FoO ThE bAr/>"
B600    8    600 baud
</FoO ThE bAr/>
dbadd quickinfo "B150" <<"</FoO ThE bAr/>"
B150    5    150 baud
</FoO ThE bAr/>
dbadd quickinfo "B110" <<"</FoO ThE bAr/>"
B110    3    110 baud
</FoO ThE bAr/>
dbadd quickinfo "tyo" <<"</FoO ThE bAr/>"
(tyo 'x_char ['p_port])
</FoO ThE bAr/>
dbadd quickinfo "def" <<"</FoO ThE bAr/>"
(def s_name (s_type l_argl g_exp1 ...))
</FoO ThE bAr/>
dbadd quickinfo "NL3" <<"</FoO ThE bAr/>"
NL3      0001400
</FoO ThE bAr/>
dbadd quickinfo "NL1" <<"</FoO ThE bAr/>"
NL1      0000400
</FoO ThE bAr/>
dbadd quickinfo "FF0" <<"</FoO ThE bAr/>"
FF0      0
</FoO ThE bAr/>
dbadd quickinfo "CR3" <<"</FoO ThE bAr/>"
CR3      0030000
</FoO ThE bAr/>
dbadd quickinfo "BS1" <<"</FoO ThE bAr/>"
BS1      0100000
</FoO ThE bAr/>
dbadd quickinfo "BS0" <<"</FoO ThE bAr/>"
BS0      0
</FoO ThE bAr/>
dbadd quickinfo "yn" <<"</FoO ThE bAr/>"
double yn(n, x)
</FoO ThE bAr/>
dbadd quickinfo "y1" <<"</FoO ThE bAr/>"
double y1(x)
</FoO ThE bAr/>
dbadd quickinfo "y0" <<"</FoO ThE bAr/>"
double y0(x)
</FoO ThE bAr/>
dbadd quickinfo "jn" <<"</FoO ThE bAr/>"
double jn(n, x);
</FoO ThE bAr/>
dbadd quickinfo "j1" <<"</FoO ThE bAr/>"
double j1(x)
</FoO ThE bAr/>
dbadd quickinfo "j0" <<"</FoO ThE bAr/>"
double j0(x)
</FoO ThE bAr/>
dbadd quickinfo "gc" <<"</FoO ThE bAr/>"
(gc)
</FoO ThE bAr/>
dbadd quickinfo "eq" <<"</FoO ThE bAr/>"
(eq 'g_arg1 'g_arg2)
</FoO ThE bAr/>
dbadd quickinfo "do" <<"</FoO ThE bAr/>"
(do s_name g_init g_repeat g_test g_exp1 ...)
</FoO ThE bAr/>
dbadd quickinfo ">" <<"</FoO ThE bAr/>"
(> 'n_arg1 'n_arg2)
</FoO ThE bAr/>
dbadd quickinfo "=" <<"</FoO ThE bAr/>"
(= 'g_arg1 'g_arg2)
</FoO ThE bAr/>



------- End of Forwarded Message

----------


