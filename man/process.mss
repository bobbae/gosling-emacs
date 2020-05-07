@Chapter(Multiple Processes under @Value(Emacs))
@Value(Emacs) has the ability to handle multiple interactive subprocesses.
The following is a sketchy description of this capability.

In general, you will @i[not] want to use any of the functions described in
the rest of this section.  Instead, you should be using one of the supplied
packages that invoke them, see @ref(ProcessPackage) page
 @pageref(ProcessPackage).  For example, the ``shell'' command provides you
with a window into an interactive shell and the ``time'' package puts the
current time and load average (continuously updated) into the mode line.

Multiple interactive processes can be started under @Value(Emacs) (using
"start-process" or "start-filtered-process").  Processes are tied to a
buffer at inception and are thereafter known by this buffer name.
Input can be sent to a process from the region or a string, and
output from processes is normally attached to the end of the process
buffer.  There is also the ability to have @Value(Emacs) call an arbitrary
MLISP procedure to process the output each time it arrives from a
process (see "start-filtered-process").

Many of the procedures dealing with process management use the concept
of "current-process" and "active-process".  The current-process is
usually the most recent process to have been started.  Two events can
cause the current-process to change:
@begin(enumerate)
When the present current-process dies, the most recent of the 
remaining processes is popped up to take its place.

The current-process can be explicitly changed using the
"change-current-process" command.
@end(enumerate)

The active-process refers to the current-process, unless the current buffer
is a live process in which case it refers to the current buffer.


Below is list of the current mlisp procedures for using processes:
@include(process.incl)

@Section(Blocking)
When too many characters are sent to a process in one gulp, the send will
be blocked until the process has removed sufficient characters from the
buffer. The send will then be automatically continued.  Normally this
process is invisible to the @Value(Emacs) user, but if the process has been
stopped, the send will not be unblocked and further attempts to send to the
process will result in an overwrite error message.

@Section(Buffer Truncation)
@Value(Emacs) does not allow process buffers to grow without bound.  When a
process buffer exceeds the value of the variable @i[process-buffer-size],
500 characters are erased from the beginning of the buffer.  The default
value for @i[process-buffer-size] is 10,000.

@Section(Problems)
The most obvious problem with allowing multiple interactive processes is
that it is too easy to start up useless jobs which drag everyone down.
Also when checkpointing is done, all buffers including the process buffers
are checkpointed.  So if you have a one line buffer keeping time, it will
take more system time to checkpoint it than it will to keep it updated once
a minute.

In addition to anti-social problems, there are some real bugs 
remaining:
@begin(itemize)
Sometimes when starting a process, it will inexplicably expire
immediately.  This often happens to the first process you fire up.

Subprocesses are assumed to not want to try fancy things with the terminal.
 @Value(Emacs) doesn't know how to handle this and for now more or less
ignores stty requests from processes.  This means that csh cannot be used
from within @Value(Emacs).  Running chat and ftp can also cause problems.
Someday, @Value(Emacs) should try to handle stty's.

The worst problem is that background processes started outside @Value(Emacs)
will cause @Value(Emacs) to hang when they finally finish.  This might get
fixed if I want to think about it.

If @Value(Emacs) does crash or hang, you will find several orphan processes
left hanging around.  It is best to do a ps and get rid of them.
@end(itemize)
