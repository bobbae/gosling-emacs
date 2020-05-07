#! /bin/csh -f

set files = `ls -F | sed -e '/\.o\**$/d' -e '/\/$/d' -e '/@$/d' -e 's/\*$//'`

# echo $files

ar -cr emacs.ar $files
