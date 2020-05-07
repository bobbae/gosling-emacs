#! /bin/csh -f
# ns-spell  text_file  ns-mywords > sorted_wrong_spellings
# created Richard Swan 1992

set  stop = /usr/dict/hstop
set  primary = /usr/dict/hlista
set  temp =  /tmp/tmp.spell.$$
set  libspell = /usr/lib/spell
set  isnewer = ~swan/emacs/isnewer
set dict = $primary
set  personal = $2
set stext = $1





# if there is a personal spell list, AND
# it is newer than a personal hashtable, create a new dictionary hashtable
if (-r $personal) then
	$isnewer  ${personal}.hlist $personal
	if ( $status != 0) then 
	     tr -cs A-Za-z0-9 '\012'  < $personal | sort -u -f | \
		grep -i '[a-z][a-z]' > ${temp}.mywords
	     mv  ${temp}.mywords  $personal
	     spellin $primary < $personal  > ${personal}.hlist
	     endif
	set dict = ${personal}.hlist
	endif

# get words only from source file
# then sort and eliminate replicated words
# then spell check aginst stop list, offending words go to ${temp}.stop
# then spell against selected dictionary and save result.


tr -cs A-Za-z0-9 '\012' < $stext | sort -u -f | grep -i  '[a-z][a-z]' | \
        $libspell $stop ${temp}.stop | $libspell $dict /dev/null > ${temp}.x 

# now comined stop list and main list, and sort
cat ${temp}.x | sort -u -f +0f +0 - ${temp}.stop

/bin/rm -f ${temp}.*


