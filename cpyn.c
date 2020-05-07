/* 
 * cpyn.c - Copy characters.
 * 
 * Author:	Spencer W. Thomas
 * 		Computer Science Dept.
 * 		University of Utah
 * Date:	Tue Sep 21 1982
 * Copyright (c) 1982 Spencer W. Thomas
 */

/*****************************************************************
 * TAG( cpyn )
 * 
 * Copy n characters from one place to another.
 */

char *
cpyn(s1, s2, n )
register char *s1;
register char *s2;
{
    char *rv = s1;
    while (n-- > 0)
	*s1++ = *s2++;
    return rv;
}
