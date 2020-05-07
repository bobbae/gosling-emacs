@Section(occur -- find occurances of a string)
@index(occur)@index(occurances of a string)
The @i[occur] package allows one to find the occurances of
a string in a buffer.  It contains one function
@begin(description)
@index(Occurances)
@i[Occurances]@\When invoked, prompts with "Search for all
occurances of: ".  It then lists (in a new buffer) all lines
contain the string you type following @i[dot].  Possible
options (listed at the bottom of the screen) allow you to
page through the listing buffer or abort the function.
@end(description)

In addition, a global variable controls the action of the
function:
@begin(description)
@index(&Occurances-Extra-Lines)
@i[&Occurances-Extra-Lines]@\is a global variable that controls how many extra
surrounding lines are printed in addition to the line containing the
string found.  If this variable is 0 then NO additional lines are printed.
If this variable is greater than 0 then it will print that many lines
above and below the line on which the string was found.  When printing
more than one line per match in this fashion, it will also print a
seperator of '----------------' so you can tell where the different
matches begin and end.  At the end of the buffer it prints
'<<<End of Occur>>>'.
@end(description)
