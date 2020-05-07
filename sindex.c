/* Sindex searches for a substring of big which matches small,
   and returns a pointer to this substring.  If no matching
   substring is found, 0 is returned. */

char *sindex (big,small)
register char *big, *small;{
    if (*small==0) return big;
    while (*big) {
	if (*big++ == *small) {
	    register char  *cur = big,
	                   *sp = small;
	    while ((*++sp) && (*sp == *cur++));
	    if (*sp == '\0')
		return (big-1);
	}
    }
    return (0);
}
