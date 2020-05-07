#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
# isnewer FileA FileB
# used from a shell script
# returns TRUE (0) if the 1st file's modification date is newer
# than the modification date of the 2nd file.
# Richard Swan 1992
# compile with: cc -o isnewer  isnewer.c

main(argc, argv)
  int argc;
  char *argv[];
  { 
  struct stat sbuf1, sbuf2, *sb1, *sb2;
  sb1 = &sbuf1; sb2 = &sbuf2;
 
  /* st_mtime is data modification time */
  if (stat(argv[1],sb1) || stat(argv[2],sb2))
	return(-1);
	else
	{ if ((sb1->st_mtime) > (sb2->st_mtime)) /* true if newer */
		return( 0);
	  else  return (1);
	}
}

