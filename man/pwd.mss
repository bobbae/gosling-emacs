@Section(pwd -- print and change the working directory)
@index(pwd)@index(cd)@index(directory)
@begin(description)
@Comref[pwd]@\Prints the current working directory in the mode line, just
like the shell command ``pwd''.

@Comref[cd]@\Changes the current working directory, just like the shell
command ``cd''.  You should beware that @i[cd] only changes the current
directory for @Value(Emacs), if it has already spawned a subprocess (a
shell, for example) then a @i[cd] from within @Value(Emacs) has no effect on
the shell.
@end(description)

