/* functions to handle MLisp arithmetic */
/* $Header: arithmetic.c,v 1.1 86/04/16 13:52:24 mcdaniel Exp $ */
/*		Copyright (c) 1981,1980 James Gosling		*/
/* $Log:	arithmetic.c,v $
 * Revision 1.1  86/04/16  13:52:24  mcdaniel
 * Initial revision
 * 
 * Revision 1.3  83/05/17  01:41:49  thomas
 * Add bitwise logical functions: ~ (not), bit&, bit| and bit^ (xor).
 * 
 */

#include "window.h"
#include "buffer.h"
#include "keyboard.h"
#include "mlisp.h"
#include <ctype.h>


/* Check that we were given at least min and at most max arguments.
   Returns true iff there was an error. */
CheckArgs (min, max) {
    register struct ProgNode   *p = CurExec;
    if(err) return 1;
    if (p == 0)
	if (min != 0 || max != 0) {
	    error ("No arguments provided to MLisp function!");
	    return 1;
	}
	else
	    return 0;
    if (p -> p_nargs < min || p -> p_nargs > max && min <= max) {
	error ("Too %s arguments to \"%s\"",
		p -> p_nargs < min ? "few" : "many",
		p -> p_proc -> b_name);
	return 1;
    }
    return 0;
}

/* Evaluate the n'th argument.  Returns true if the evaluation was
   successful */
EvalArg (n) {
    register struct ProgNode   *p = CurExec;
    if (err)
	return 0;
    if (p == 0 || p -> p_nargs < n) {
	error ("Missing argument %d to %s", n,
		p ? p -> p_proc -> b_name : "MLisp function");
	return 0;
    }
    ExecProg (p -> p_args[n - 1]);
    if (err)
	return 0;
    if (MLvalue -> exp_type == IsVoid) {
	error ("\"%s\" didn't return a value; \"%s\" was expecting it to.",
		p -> p_args[n - 1] -> p_proc -> b_name,
		p -> p_proc -> b_name);
	return 0;
    }
    return 1;
}

/* Evaluate and return the n'th numeric argument */
NumericArg (n) {
    if (!EvalArg (n))
	return 0;
    switch (MLvalue -> exp_type) {
	default: 
	    error ("Numeric argument expected.");
	    return 0;
	case IsInteger: 
	    return MLvalue -> exp_int;
	case IsString: 		/* this is a cop-out */
	    {
		register char *p = MLvalue -> exp_v.v_string;
		register neg = 0;
		while (isspace(*p)) p++;
		if (*p=='+' || *p=='-') {
		    neg = *p=='-';
		    p++;
		}
		while (isspace(*p)) p++;
		n = 0;
		while (isdigit(*p) || isspace(*p)) {
		    if (isdigit(*p)) n = n*10 + *p-'0';
		    p++;
		}
		if (*p) error ("String to integer conversion error: \"%s\"",
				MLvalue -> exp_v.v_string);
		if (neg) n = -n;
	    }
	    ReleaseExpr (MLvalue);
	    MLvalue -> exp_type = IsInteger;
	    return n;
	case IsMarker: 
	    {
		register struct buffer *old = bf_cur;
		n = ToMark (MLvalue -> exp_v.v_marker);
		ReleaseExpr (MLvalue);
		MLvalue -> exp_type = IsInteger;
		SetBfp (old);
		return n;
	    }
    }
}

/* Evaluate and return the n'th string argument in MLvalue (returns
   true if all is well) */
StringArg (n) {
    if (!EvalArg (n))
	return 0;
    switch (MLvalue -> exp_type) {
	default: 
	    return 0;
	case IsMarker: 
	    {
		register struct marker *m = MLvalue -> exp_v.v_marker;
		register struct buffer *b = m ? m -> m_buf : 0;
		ReleaseExpr (MLvalue);
		MLvalue -> exp_v.v_string = b
				? b -> b_name
				: "<Bizarre marker>";
		MLvalue -> exp_int = strlen (MLvalue -> exp_v.v_string);
		MLvalue -> exp_type = IsString;
		MLvalue -> exp_release = 0;
		return 1;
	    }
	case IsInteger: 
	    {
		static char buf[20];/* swine!  using static again */
		sprintfl (buf, sizeof buf, "%d", MLvalue -> exp_int);
		MLvalue -> exp_type = IsString;
		MLvalue -> exp_int = strlen (buf);
		MLvalue -> exp_v.v_string = buf;
		MLvalue -> exp_release = 0;
	    }
	case IsString:
	    return 1;
    }
}

/* set up for a simple binary operator */
binsetup () {
    if (CheckArgs (1, 0))
	return 0;
    return NumericArg (1);
}

static plus () {
    register result = binsetup ();
    register i;
    for (i=2; !err && i <= CurExec->p_nargs; i++)
	result += NumericArg(i);
    MLvalue -> exp_int = result;
    return 0;
}

static not () {
    MLvalue -> exp_int = ! NumericArg (1);
    return 0;
}

static bitnot () {
    MLvalue -> exp_int = ~ NumericArg (1);
    return 0;
}

static  minus () {
    register    result = binsetup ();
    register    i;
    if (!err && CurExec -> p_nargs == 1)
	result = -result;
    else
	for (i = 2; !err && i <= CurExec -> p_nargs; i++)
	    result -= NumericArg (i);
    MLvalue -> exp_int = result;
    return 0;
}

static times () {
    register result = binsetup ();
    register i;
    for (i=2; !err && i <= CurExec->p_nargs; i++)
	result *= NumericArg(i);
    MLvalue -> exp_int = result;
    return 0;
}

static  divide () {
    register    result = binsetup ();
    register    i;
    for (i = 2; !err && i <= CurExec -> p_nargs; i++) {
	register    denom = NumericArg (i);
	if (denom == 0 && !err)
	    error ("Division by zero");
	else
	    result /= denom ? denom : 1;
    }
    MLvalue -> exp_int = result;
    return 0;
}

static  mod () {
    register    result = binsetup ();
    register    i;
    for (i = 2; !err && i <= CurExec -> p_nargs; i++) {
	register    denom = NumericArg (i);
	if (denom == 0 && !err)
	    error ("Mod by zero");
	else
	    result %= denom ? denom : 1;
    }
    MLvalue -> exp_int = result;
    return 0;
}

static shiftleft () {
    register result = binsetup ();
    register i;
    for (i=2; !err && i <= CurExec->p_nargs; i++)
	result <<= NumericArg(i);
    MLvalue -> exp_int = result;
    return 0;
}

static shiftright () {
    register result = binsetup ();
    register i;
    for (i=2; !err && i <= CurExec->p_nargs; i++)
	result >>= NumericArg(i);
    MLvalue -> exp_int = result;
    return 0;
}

static
and () {
    register result = binsetup ();
    register i;
    for (i=2; !err && result && i <= CurExec->p_nargs; i++)
	result = NumericArg(i);
    MLvalue -> exp_int = result;
    return 0;
}

static or () {
    register result = binsetup ();
    register i;
    for (i=2; !err && result==0 && i <= CurExec->p_nargs; i++)
	result = NumericArg(i);
    MLvalue -> exp_int = result;
    return 0;
}

static xor () {
    register result = binsetup ();
    register i;
    for (i=2; !err && i <= CurExec->p_nargs; i++)
	result ^= NumericArg(i);
    MLvalue -> exp_int = result;
    return 0;
}

static
bitand () {
    register result = binsetup ();
    register i;
    for (i=2; !err && i <= CurExec->p_nargs; i++)
	result &= NumericArg(i);
    MLvalue->exp_int = result;
}

static
bitor () {
    register result = binsetup ();
    register i;
    for (i=2; !err && i <= CurExec->p_nargs; i++)
	result |= NumericArg(i);
    MLvalue->exp_int = result;
}

static
bitxor () {
    register result = binsetup ();
    register i;
    for (i=2; !err && i <= CurExec->p_nargs; i++)
	result ^= NumericArg(i);
    MLvalue->exp_int = result;
}

static
char *GLeftS;			/* left string operand to a comparison
				   operator */
int GLeftI;			/* left integer operand to a comparison
				   operator */

/* Setup to do a comparison operator.  Comparison is
   lexicographic if both operands are strings, numeric
   otherwise */
static
CompareSetup () {
    register char  *LeftS;
    register struct buffer *old = bf_cur;
    int     LeftI;
    if (!EvalArg (1))
	return 0;
    LeftI = MLvalue -> exp_int;
    switch (MLvalue -> exp_type) {
    case IsInteger:
	LeftS = 0;
	break;
    case IsString:
	if (MLvalue -> exp_release) {
	    LeftS = MLvalue -> exp_v.v_string;
	    MLvalue -> exp_release = 0;
	}
	else
	    LeftS = savestr (MLvalue -> exp_v.v_string);
	break;
    case IsMarker:
	LeftI = ToMark (MLvalue -> exp_v.v_marker);
	LeftS = 0;
	ReleaseExpr (MLvalue);
	SetBfp (old);
	break;
    default:
	error ("Illegal operand to comparison operator");
    }
    if (!EvalArg (2)) {
	if(LeftS) free (LeftS);
	return 0;
    }
    if ((MLvalue -> exp_type == IsInteger || MLvalue -> exp_type == IsMarker)
	    && LeftS) {
	LeftI = atoi (LeftS);
	free (LeftS);
	LeftS = 0;
    }
    if (LeftS == 0 && MLvalue -> exp_type == IsString) {
	MLvalue -> exp_int = atoi (MLvalue -> exp_v.v_string);
	ReleaseExpr (MLvalue);
	MLvalue -> exp_type = IsInteger;
    }
    if (MLvalue -> exp_type == IsMarker) {
	register n = ToMark (MLvalue -> exp_v.v_marker);
	ReleaseExpr (MLvalue);
	SetBfp (old);
	MLvalue -> exp_int = n;
	MLvalue -> exp_type = IsInteger;
    }
    GLeftS = LeftS;
    GLeftI = LeftI;
    return 1;
}

static
CompareReturn (val) {
    ReleaseExpr (MLvalue);
    if(GLeftS) free(GLeftS);
    MLvalue -> exp_type = IsInteger;
    MLvalue -> exp_int = val;
}

static
equal () {
    if (CompareSetup ())
	CompareReturn (GLeftS
		? strcmp (GLeftS, MLvalue -> exp_v.v_string) == 0
		: GLeftI == MLvalue -> exp_int);
    return 0;
}

static
notequal () {
    if (CompareSetup ())
	CompareReturn (GLeftS
		? strcmp (GLeftS, MLvalue -> exp_v.v_string) != 0
		: GLeftI != MLvalue -> exp_int);
    return 0;
}

static
less () {
    if (CompareSetup ())
	CompareReturn (GLeftS
		? strcmp (GLeftS, MLvalue -> exp_v.v_string) < 0
		: GLeftI < MLvalue -> exp_int);
    return 0;
}

static
lessequal () {
    if (CompareSetup ())
	CompareReturn (GLeftS
		? strcmp (GLeftS, MLvalue -> exp_v.v_string) <= 0
		: GLeftI <= MLvalue -> exp_int);
    return 0;
}

static
greater () {
    if (CompareSetup ())
	CompareReturn (GLeftS
		? strcmp (GLeftS, MLvalue -> exp_v.v_string) > 0
		: GLeftI > MLvalue -> exp_int);
    return 0;
}

static
GreaterEqual () {
    if (CompareSetup ())
	CompareReturn (GLeftS
		? strcmp (GLeftS, MLvalue -> exp_v.v_string) >= 0
		: GLeftI >= MLvalue -> exp_int);
    return 0;
}

InitArith () {
    if (!Once)
    {
	defproc (plus, "+");
	defproc (minus, "-");
	defproc (times, "*");
	defproc (divide, "/");
	defproc (mod, "%");
	defproc (shiftleft, "<<");
	defproc (shiftright, ">>");
	defproc (and, "&");
	defproc (bitand, "bit&");
	defproc (or, "|");
	defproc (bitor, "bit|");
	defproc (xor, "^");
	defproc (bitxor, "bit^");
	defproc (equal, "=");
	defproc (notequal, "!=");
	defproc (less, "<");
	defproc (lessequal, "<=");
	defproc (greater, ">");
	defproc (GreaterEqual, ">=");
	defproc (not, "!");
	defproc (bitnot, "~");
    }
}
