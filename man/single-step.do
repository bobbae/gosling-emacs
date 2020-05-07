






1.  The Single Stepper

     Setting  the  variable  "single-step-execution"  to   1
enables the single stepper.  This causes all mlisp functions
to execute a piece at a time.  Immediately before execution,
the message "Single Step Mode: about to execute <something>"
appears in the bottom line, and you have control  over  what
happens  next.   At  this point you can type a space to con-
tinue single stepping, 's' to execute a "superstep", 'r' for
a  recursive  edit, 'x' for an execute-extended-command, '!'
for a "go", or '=' to redisplay the "about to execute"  mes-
sage.

     Within a recursive edit you can examine and alter vari-
ables,  move the buffer's "dot" around, and make any changes
you like, then exit the recursive edit  to  continue  single
stepping.

     A "superstep" consists of executing all of  the  state-
ments  inside  the  one that is about to be executed without
single stepping them.  For example, if  you  are  "about  to
execute  'progn'"  you  can  superstep everything inside the
progn.  The "go" goes a bit further: it turns off all single
stepping  until the current level is exited.  Note that this
can turn off single stepping.  (If you "go" the first  thing
that  starts  to single step, single stepping will be turned
off.  The correct action there is to "superstep"  the  func-
tion.)

     Before attempting to debug a package by single stepping
it, you should probably kill all active processes, as a pro-
cess filter will also be single stepped --  this  can  cause
strange  results.   Also, entering a recursive edit can undo
the effect of a temp-use-buffer, since  the  window  manager
insists  on  the  current  window and buffer being the same.
(This problem does not occur  with  execute-extended-command
(unless of course the command is "recursive-edit"!).)

     Single stepping  often  shows  strange  functions  like
"execute-string"  or  "execute-number".   These are names of
internal routines, not available from MLisp, but used by the
system  to evaluate strings and numbers.  For the most part,
these can be ignored.

     The single stepper can also be used as a tracer.   Set-
ting  single-step-execution  to 2 causes a line to be dumped
to the buffer "Trace Buffer" for  each  statement  executed.
The  format  is the same as that on the message line.  It is
possible to use both modes -- set  single-step-execution  to
three.


call-interactively













     (call-interactively (foo)) makes Emacs behave as if you
had  typed  ESC-x  foo from the keyboard.  Only one function
name may appear inside the interactive call, and  any  argu-
ments provided will be ignored.  A function that calls other
functions will not call them interactively (unless  they  do
call-interactivelys).














































9

9



