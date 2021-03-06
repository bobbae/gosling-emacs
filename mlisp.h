/* Header file for dealing with values returned by mlisp functions */

/*		Copyright (c) 1981,1980 James Gosling		*/

struct VariableName {		/* a name for a variable with a pointer
				   to it's chain of interpretations. */
    char   *v_name;		/* the name of the variable */
    struct Binding *v_binding;	/* the most recent binding of this
				   variable */
};

enum Kinds {			/* The data types possible for MLisp values */
    IsVoid, IsInteger, IsString, IsMarker, IsArray
};

typedef struct {		/* a value that can be returned from the
				   evaluation of a MLisp expression */
    enum Kinds exp_type;	/* the kind of expression we're dealing
				   with */
    int     exp_int;		/* an integer value */
    union res_union {
	char *v_string;		/* if IsString */
	struct marker *v_marker;/* if IsMarker */
	struct array *v_array;	/* if IsArray */
    } exp_v;
    int     exp_release:1;	/* true iff this fellow points to a string
				   in managed memory */
    int     exp_refcnt;		/* reference count for some very simple
				   garbage collection */
}               Expression;

struct Binding {		/* a particular (name,value) binding */
    struct Binding *b_inner;	/* the next inner binding for the same
				   name */
    Expression *b_exp;		/* The value held by this variable */
    union {
	struct buffer *b_LocalTo;	/* The buffer that this binding is
					   local too */
	struct Binding *b_Default;	/* The default value for this system
					   variable */
    } b;
    int     IsSystem:1;		/* true iff this is a system variable,
				   in which case b_string points to the
				   variable, be it string or integer. */
    int	    BufferSpecific:1;	/* True iff the variable is buffer specific */
    int     IsDefault:1;	/* True iff this is the default value entry */
};

char **VarNames;		/* variable name table */
struct VariableName **VarDesc;	/* the corresponding descriptions */
int NVars;			/* the number of variables declared */
int VarTSize;			/* the size of the variable table */
char **NextInitVarName;		/* where to stick the next variable name
				   when initializing Emacs */
struct VariableName **NextInitVarDesc;
				/* where to stick the next variable
				   descriptor when initializing Emacs */

#define DefIntVar(name, addr) { \
    static Expression e; \
    static struct Binding b; \
    static struct VariableName v; \
    *NextInitVarName++ = v.v_name = name; \
    b.b_exp = &e; \
    b.IsSystem = 1; \
    v.v_binding = &b; \
    e.exp_type = IsInteger; \
    e.exp_v.v_string =  (char *) (addr); \
    *NextInitVarDesc++ = &v; \
}

#define DefStrVar(name, addr) { \
    static Expression e; \
    static struct Binding b; \
    static struct VariableName v; \
    *NextInitVarName++ = v.v_name = name; \
    b.b_exp = &e; \
    b.IsSystem = 1; \
    v.v_binding = &b; \
    e.exp_v.v_string =  addr; \
    e.exp_int = sizeof addr; \
    e.exp_type = IsString; \
    *NextInitVarDesc++ = &v; \
}

#define SetSysDefault NextInitVarDesc[-1]->v_binding->b.b_Default \
		= NextInitVarDesc[-2]->v_binding

/* Release any storage associated with Expression block e */
#define ReleaseExpr(e) (e && ((e) -> exp_release || --(e) -> exp_refcnt<=0) \
		? DoRelease (e) : 0)

Expression *MLvalue;		/* the value returned from the last
				   evaluation */
Expression GlobalValue;		/* The thing that MLvalue usually points to */

struct ExecutionStack {		/* traceback/argument-evaluation stack for
				   MLisp functions */
    struct ProgNode *CurExec;	/* the expression being executed at this
				   level */
    struct ExecutionStack *DynParent;	/* pointer to the dynamically
					   enclosing parent of this execution
					   frame */
    int PrefixArgument;		/* The argument prefixed to this invocation */
    int PrefixArgumentProvided;	/* true iff there really was an argument
				   prefixed to this invocation.  If there
				   wasn't, then the value of PrefixArgument
				   will be 1 */
};

struct ExecutionStack ExecutionRoot;	/* The root of the execution stack.
					   As MLisp functions are executed
					   their environment info (an
					   ExecutionStack struct) is built
					   here after copying its parents
					   information into a local struct. */
