@Section(process -- high level process manipulation)
@index(processes, high level access)@index(shell)@index(lisp)
@Label(ProcessPackage)
The process package provides high level access to the process control
features of Unix @Value(Emacs).  It allows you to interact with a shell
through an @Value(Emacs) window, just as though you were talking to the
shell normally.
@begin(description)
shell@\The @i[shell] command is used to either start or reenter a shell
process.  When the shell command is executed, if a shell process doesn't
exist then one is created (running the standard ``sh'') tied to a buffer
named ``shell'.  In any case, the shell buffer becomes the current one and
dot is positioned at the end of it.  In that buffer output from the shell
and programs run with it will appear.  Anything typed into it will get sent
to the subprocess when the @i[return] key is struck.  This lets you interact
with a shell using @Value(Emacs), and all of it's editing capability, as an
intermediary.  You can scroll backwards over a session, pick up pieces of
text from other places and use them as input, edit while watching the
execution of some program, and much more...

lisp@\The @i[lisp] command is exactly the same as the @i[shell] command
except that it starts up ``cmulisp'' in the ``lisp'' buffer.  You can have
both a shell and a lisp process going at the same time.  You can even have
as many shells going as you want, but this package doesn't support it.

@Comref[grab-last-line]@\(@b[ESC-=]) This command takes the last string
typed as input to the process and brings it back, as though you had typed it
again. So if you muff a command, just type @b[ESC-=], edit the line, and hit
@i[return] again.

@Comref[lisp-kill-output]@\(@b[^X^K]) [this only applies to @i[lisp]
processes] Erases the output from the last command.  If you don't want to
see the output of the last command any more, just type @b[^X^K] and it will
go away.

@Comref[pr-newline]@\(^M -- return) Takes the text of the current line and
sends it as input to the process tied to the current buffer.  Actually, if
dot is on the last line of the buffer, it takes the region from mark to the
end of the buffer and sends it as input (output from a process causes the
mark to be set after the inserted text); if dot is not on the last line,
just the text of that line is shipped (presuming that your prompt is "$ ").

@Comref[send-eot]@\(^D) If dot is at the end of the buffer, then @b[^D]
behaves just as it does outside of @Value(Emacs) -- it sends an EOT to the
subprocess (end of file to some folks).  If dot isn't at the end of the
buffer, then it does the usual character deletion.

@Comref[send-int-signal]@\(\177 -- rubout) Sends an INT (Interrupt) signal
to the subprocess, which should make it stop whatever it is doing.

@Comref[send-quit-signal]@\(^\) Sends a QUIT signal to the subprocess,
making it stop whatever it is doing and produce a core dump.
@end(description)
