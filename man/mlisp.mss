@Section(MLisp -- @i[Mock Lisp])
Unix @Value(Emacs) contains an interpreter for a language that in many
respects resembles Lisp.  The primary (some would say only) resemblance
between @i[Mock Lisp] and any real Lisp is the general syntax of a program,
which many feel is Lisp's weakest point.  The differences include such
things as the lack of a @b[cons] function and a rather peculiar method of
passing parameters.

@SubSection(The syntax of MLisp expressions)
There are four basic syntactic entities out of which MLisp expressions are
built. The two simplest are integer constants (which are optionally signed
strings of digits) and string constants (which are sequences of characters
bounded by double quote [``"''] characters -- double quotes are included by
doubling them: """" is a one character string. The third are names which
are used to refer to things: variables or procedures.  These three are all
tied together by the use of procedure calls.  A procedure call is written as a
left parenthesis, ``('', a name which refers to the procedure, a list of
whitespace separated expressions which serve as arguments, and a closing
right parenthesis, ``)''.  An expression is simply one of these four
things: an integer constant, a string constant, a name, or a call which may
itself be recursivly composed of other expressions.

String constants may contain the usual @b[C] excape sequences, "\n" is a
newline, "\t" is a tab, "\r" is a carriage return, "\b" is a backspace,
"\e" is the escape (033) character,
"\@i[nnn]" is the character whose octal representation is @i[nnn], and
"^\@i[c]" is the control version of the character @i[c].

For example, the following are legal MLisp expressions:
@begin(description)
1@\The integer constant 1.

"hi"@\A two character string constant

"\^X\^F"@\A two character string constant

"""what?"""@\A seven character string constant

(+ 2 2)@\An invocation of the "+" function with integer arguments 2 and 2.
"+" is the usual addition function.  This expression evaluates to the
integer 4.

(setq bert (* 4 12))@\An invocation of the function @i[setq] with the
variable @i[bert] as its first argument and and expression that evaluates
the product of 4 and 12 as its second argument.  The evaluation of this
expression assigns the integer 48 to the variable @i[bert].

(visit-file "mbox")@\An invocation of the function @i[visit-file] with the
string "mbox" as its first argument@Index[visit-file].  Normally the
@i[visit-file] function is tied to the key @b[^X^B].  When it is invoked
interactively, either by typing @b[^X^B] or @b[ESC-Xvisit-file], it will
prompt in the minibuf for the name of the file.  When called from MLisp it
takes the file name from the parameter list.  All of the keyboard-callable
function behave this way.
@end(description)

Names may contain virtually any character, except whitespace or parens and
they cannot begin with a digit, ``"'' or ``-''.

@SubSection(The evaluation of MLisp expressions)
Variables must be declared (@i[bound]) before they can be used.  The
@Index[declare-global]
declare-global command can be used to declare a global variable; a local is
@Index[progn]
declared by listing it at the beginning of a @b[progn] or a function body (ie.
immediatly after the function name or the word @b[progn] and before the
executable statements).  For example:
@begin(example)
(defun
    (foo i
	(setq i 5)
    )
)
@end(example)
defines a rather pointless function called @i[foo] which declares a
single local variable @i[i] and assigns it the value 5.  Unlike real Lisp
systems, the list of declared variables is not surrounded by parenthesis.

Expressions evaluate to values that are either integers, strings or markers.
Integers and strings are converted automaticly from one to the other type
as needed: if a function requires an integer parameter you can pass it a
string and the characters that make it up will be parsed as an integer;
similarly passing an integer where a string is required will cause the
integer to be converted.  Variables may have either type and their type is
decided dynamically when the assignment is made.

Marker values indicate a position in a buffer.  They are not a character
number.  As insertions and deletions are performed in a buffer, markers
automatically follow along, maintaining their position.  Only the functions
@i[mark] and @i[dot] return markers; the user may define ones that do and
may assign markers to variables.  If a marker is used in a context that
requires an integer value then the ordinal of the position within the buffer
is used; if a marker is used in a context that requires a string value then
the name of the marked buffer is used.  For example, if @t[there] has been
assigned some marker, then @t[(pop-to-buffer there)] will pop to the marked
buffer.  @t[(goto-character there)] will set dot to the marked position.

A procedure written in MLisp is simply an expression that is bound to a
name.  Invoking the name causes the associated expression to be evaluated.
Invocation may be triggered either by the evaluation of some expression
which calls the procedure, by the user typing it's name to the @b[ESC-X]
command, or by striking a key to which the procedure name has been bound.

All of the commands listed in section @ref(CommandDescription) (page
@pageref(CommandDescription)) may be called as MLisp procedures.  Any
parameters that they normally prompt the user for are taken as string
expressions from the argument list in the same order as they are asked
@Index[switch-to-buffer]
for interactivly.  For example, the @i[switch-to-buffer] command, which
is normally tied to the @b[^XB] key, normally prompts for a buffer name
and may be called from MLisp like this:
@w[(switch-to-buffer @i[string-expression])].

@SubSection(Scope issues)
There are several sorts of names that may appear in MLisp programs.
Procedure, buffer and abbrev table names are all global and occupy distinct
name space. For variables there are three cases:
@begin(enumerate)
Global variables: these variables have a single instance and are created
either by using @i[declare-global], @i[set-default] or @i[setq-default].
@index(declare-global)@index(set-default)@index(setq-default)
Their lifetime is the entire editing session from the time they are created.

Local variables: these have an instance for each declaration in a procedure
body or local block (@i[progn]).  Their lifetime is the lifetime of the
block which declares them.  Local declarations nest and hide inner local or
global declarations.

@index(declare-buffer-specific)@index(buffer-specific)
Buffer-specific variables: these have a default instance and an instance for
each buffer in which they have been explicitly given a value.  They are
created by using @i[declare-buffer-specific].  When a variable which has
been declared to be buffer specific is assigned a value, if an instance for
the current buffer hasn't been created then it will be.  The value is
assigned to the instance associated with the current buffer.  If a buffer
specific variable is referenced and an instance doesn't exist for this
buffer then the default value is used.  This default value may be set with
either @i[setq-default] or @i[set-default].  If a global instance exists
when a variable is declared buffer-specific then the global value becomes
the default.
@end(enumerate)

@SubSection(MLisp functions)
An MLisp function is defined by executing the @i[defun] function.  For
example:
@begin(example)
@Index(defun)
(defun
    (silly
	(insert-string "Silly!")
    )
)
@end(example)
defines a function called @i[silly] which, when invoked, just inserts the
string "Silly!" into the current buffer.

MLisp has a rather strange (relative to other languages) parameter passing
mechanism.  The @i[arg] function, invoked as
@w[(arg @i[i] @i[prompt])] evaluates the @i[i]'th argument of the invoking
function if the invoking function was called interactivly or, if the
invoking function was not called interactivly, @i[arg] uses the prompt to
ask you for the value.  Consider the following function:
@begin(example)
(defun
    (in-parens
	(insert-string "(")
	(insert-string (arg 1 "String to insert? "))
	(insert-string ")")
    )
)
@end(example)
If you type @b[ESC-Xin-parens] to invoke @i[in-parens] interactivly then
@Value(Emacs) will ask in the minibuffer "String to insert? " and then insert
the string typed into the current buffer surrounded by parenthesis.  If
@i[in-parens] is invoked from an MLisp function by
@w[@b[(in-parens "foo")]] then the invocation of @i[arg] inside
@i[in-parens] will evaluate the expression "foo" and the end result will be
that the string "(foo)" will be inserted into the buffer.

The function @i[interactive] may be used to determine whether or not the
invoking function was called interactivly.  @i[Nargs] will return the number
of arguments passed to the invoking function.

This parameter passing mechanism may be used to do some primitive language
extension.  For example, if you wanted a statement that executed a statement
@i[n] times, you could use the following:
@begin(example)
(defun
    (dotimes n
	(setq n (arg 1))
	(while (> n 0)
	    (setq n (- n 1))
	    (arg 2)
	)
    )
)
@end(example)
Given this, the expression @w[@b[(dotimes 10 (insert-string "<>"))]] will
insert the string "<>" 10 times.
[@i[Note]: The prompt argument may be omitted if the function can never be
called interactivly] .

@SubSection(Debugging)
Unfortunatly, debugging MLisp functions is something of a black art.  The
biggest problem right now is that if an MLisp function goes into an infinite
loop there is no way to stop it.

There is no breakpoint facility.  All that you can do is get a stack trace
whenever an error occurs by setting the @i[stack-trace-on-error] variable.
With this set, any time that an error occurs a dump of the MLisp execution
call stack and some other information is dumped to the "Stack trace" buffer.

@Section(A Sample MLisp Program)
The following piece of MLisp code is the Scribe mode package.  Other
implementations of @Value(Emacs), on ITS and on Multics have @i[modes] that
influence the behaviour of @Value(Emacs) on a file.  This behaviour is usually
some sort of language-specific assistance.  In Unix @Value(Emacs) a @i[mode]
is no more that a set of functions, variables and key-bindings.  This mode
package is designed to be useful when editing Scribe source files.
@begin(example,leftmargin +0, use NoteStyle, use T, BlankLines Hinge)
@define(exnote=text,leftmargin +2in, use I)
(defun
@exnote<The apply-look function makes the current word "look" different by
changing the font that it is printed in.  It positions dot at the beginning
of the word so you can see where the change will be made and reads a
character from the tty.  Then it inserts "@@@b[c][" (where @b[c] is the
character typed) at the front of the word and "]" at the back.  Apply-look
gets tied to the key @b[ESC-l] so typing @b[ESC-l] @b[i] when the cursor is
positioned on the word "begin" will change the word to "@@i[begin]".>
    (apply-look go-forward
	(save-excursion c
	    (if (! (eolp)) (forward-character))
	    (setq go-forward -1)
	    (backward-word)
	    (setq c (get-tty-character))
	    (if (> c ' ')
		(progn (insert-character '@@')
		    (insert-character c)
		    (insert-character '[')
		    (forward-word)
		    (setq go-forward (dot))
		    (insert-character ']')
		)
	    )
	)
	(if (= go-forward (dot)) (forward-character))
    )
)

(defun
@exnote<This function is called to set a buffer into Scribe mode>
    (scribe-mode
	(remove-all-local-bindings)
@exnote<If the string "LastEditDate=""" exists in the first 2000 characters of
the document then the following string constant is changed to the current
date.  The intent of this is that you should stick at the beginning of your
file a line like: ``@w[@@string(LastEditDate="Sat Jul 11 17:59:01 1981")]''.
This will automatically get changed each time you edit the file to reflect
that last date on which the file was edited.>
	(if (! buffer-is-modified)
	    (save-excursion
		(error-occurred
		    (goto-character 2000)
		    (search-reverse "LastEditDate=""")
		    (search-forward """")
		    (set-mark)
		    (search-forward """")
		    (backward-character)
		    (delete-to-killbuffer)
		    (insert-string (current-time))
		    (setq buffer-is-modified 0)
		)
	    )
	)
	(local-bind-to-key "justify-paragraph" "\ej")
	(local-bind-to-key "apply-look" "\el")
	(setq right-margin 77)
	(setq mode-string "Scribe")
	(setq case-fold-search 1)
	(use-syntax-table "text-mode")
	(modify-syntax-entry "w    -'")
	(use-abbrev-table "text-mode")
	(setq left-margin 1)
	(novalue)
    )
)

(novalue)
@end(example)
