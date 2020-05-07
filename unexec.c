/* 
 * unexec.c - Convert a running program into an a.out file.
 * 
 * Author:	Spencer W. Thomas
 * 		Computer Science Dept.
 * 		University of Utah
 * Date:	Tue Mar  2 1982
 * Copyright (c) 1982 Spencer W. Thomas
 *
 * Synopsis:
 *	unexec( new_name, a_name, data_start, bss_start )
 *	char *new_name, *a_name;
 *	unsigned data_start, bss_start;
 *
 * Takes a snapshot of the program and makes an a.out format file in the
 * file named by the string argument new_name.
 * If a_name is non-NULL, the symbol table will be taken from the given file.
 * 
 * The boundaries within the a.out file may be adjusted with the data_start 
 * and bss_start arguments.  Either or both may be given as 0 for defaults.
 * 
 * Data_start gives the boundary between the text segment and the data
 * segment of the program.  The text segment can contain shared, read-only
 * program code and literal data, while the data segment is always unshared
 * and unprotected.  Data_start gives the lowest unprotected address.  Since
 * the granularity of write-protection is on 1k page boundaries on the VAX, a
 * given data_start value which is not on a page boundary is rounded down to
 * the beginning of the page it is on.  The default when 0 is given leaves the
 * number of protected pages the same as it was before.
 * 
 * Bss_start indicates how much of the data segment is to be saved in the
 * a.out file and restored when the program is executed.  It gives the lowest
 * unsaved address, and is rounded up to a page boundary.  The default when 0
 * is given assumes that the entire data segment is to be stored, including
 * the previous data and bss as well as any additional storage allocated with
 * break (2).
 * 
 * This routine is expected to only work on a VAX running 4.1 bsd UNIX and
 * will probably require substantial conversion effort for other systems.
 * In particular, it depends on the fact that a process' _u structure is
 * accessible directly from the user program.
 *
 * If you make improvements I'd like to get them too.
 * harpo!utah-cs!thomas, thomas@Utah-20
 *
 */
#include <stdio.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <a.out.h>
/* GROSS HACK. UGH WRONG DEATH DON"T EXECUTE THE CODE UGH */
#define NBPG 512
/* ^^^^^^^^^^^^ AWFUL */
#define PAGEMASK    (NBPG - 1)
#define PAGEUP(x)   (((int)(x) + PAGEMASK) & ~PAGEMASK)


#define PSIZE	    10240

extern etext;
extern edata;
extern end;

static struct exec hdr, ohdr;

static int unexeced;

/* ****************************************************************
 * unexec
 *
 * driving logic.
 */
#ifndef vax
unexec( new_name, a_name, data_start, bss_start )
char *new_name, *a_name;
unsigned data_start, bss_start;
{
    perror( "dump-emacs doesn't work on this system" );
}

#else

/* this ifdef ends at the end of this file */

unexec( new_name, a_name, data_start, bss_start )
char *new_name, *a_name;
unsigned data_start, bss_start;
{
    FILE *newf;
    int new, a_out = -1;

    if ( a_name && (a_out = open( a_name, 0 )) < 0 )
    {
	perror( a_name );
	return -1;
    }
    if ( (newf = fopen( new_name, "w" )) == NULL )
    {
	perror( new_name );
	return -1;
    }
    fclose(newf);
    new = open( new_name, 1);
    unexeced = 1;

    if (make_hdr( new, a_out, data_start, bss_start ) < 0 ||
	copy_text_and_data( new ) < 0 ||
	copy_sym( new, a_out ) < 0)
    {
	close( new );
	unlink( new_name );	    	/* Failed, unlink new a.out */
	return -1;	
    }

    close( new );
    if ( a_out >= 0 )
	close( a_out );
    mark_x( new_name );
    return 0;
}

/* ****************************************************************
 * make_hdr
 *
 * Make the header in the new a.out from the header in core.
 * Modify the text and data sizes.
 */
static int
make_hdr( new, a_out, data_start, bss_start )
int new, a_out;
unsigned data_start, bss_start;
{
    /* Get symbol table info from header of a.out file if given one. */
    if ( a_out >= 0 )
    {
	if ( read( a_out, &hdr, sizeof hdr ) != sizeof hdr )
	{
	    perror( "Couldn't read header from a.out file" );
	    return -1;
	}

	if N_BADMAG( hdr )
	{
	    fprintf( stderr, "a.out file doesn't have legal magic number\n" );
	    return -1;
	}
    
	/* Check for agreement between a.out file and program. */
    /* This is not valid when the symbol table can come from
     * an oload incremental load file... */
#    ifdef CHECK_A_OUT
	if (  hdr.a_magic != u->u_exdata.ux_mag  ||

	      ( (hdr.a_magic != OMAGIC) &&
	        (hdr.a_text != u->u_exdata.ux_tsize ||
	         hdr.a_data != u->u_exdata.ux_dsize) )  ||

	      ( (hdr.a_magic == OMAGIC) &&
		(hdr.a_data + hdr.a_text != u->u_exdata.ux_dsize) )  ||

	      hdr.a_entry != u->u_exdata.ux_entloc  )
	{
	    fprintf( stderr,
		"unexec: Program didn't come from given a.out\n" );
	    return -1;
	}
#    endif CHECK_A_OUT
    }
    else
	hdr.a_syms = 0;			/* No a.out, so no symbol info. */

    hdr.a_magic = ZMAGIC;
    hdr.a_text = PAGEUP(&etext);
    hdr.a_data = PAGEUP(sbrk(0)) - hdr.a_text;
    hdr.a_bss = 0;
    hdr.a_entry = 0;
    hdr.a_trsize = 0;
    hdr.a_drsize = 0;

    printf( "Text %u, Data was %u, is now %u\n",
	hdr.a_text, &edata - &etext, hdr.a_data - hdr.a_text);

    if ( write( new, &hdr, sizeof hdr ) != sizeof hdr )
    {
	perror( "Couldn't write header to new a.out file" );
	return -1;
    }
    return 0;
}

/* ****************************************************************
 * copy_text_and_data
 *
 * Copy the text and data segments from memory to the new a.out
 */
static int
copy_text_and_data( new )
int new;
{
    lseek( new, (long)N_TXTOFF(hdr), 0 );

    if ( write( new, 0, hdr.a_text + hdr.a_data ) != hdr.a_text + hdr.a_data )
    {
	perror( "Write failure in text/data segments" );
	return -1;
    }
    return 0;
}

/* ****************************************************************
 * copy_sym
 *
 * Copy the relocation information and symbol table from the a.out to the new
 */
static int
copy_sym( new, a_out )
int new, a_out;
{
    char page[PSIZE];
    int n;

    if ( a_out < 0 )
	return 0;

    lseek( a_out, (long)N_SYMOFF(ohdr), 0 );	/* Position a.out to symtab.*/
    while ( (n = read( a_out, page, PSIZE )) > 0 )
    {
	if ( write( new, page, n ) != n )
	{
	    perror( "Error writing symbol table to new a.out" );
	    fprintf( stderr, "new a.out should be ok otherwise\n" );
	    return 0;
	}
    }
    if ( n < 0 )
    {
	perror( "Error reading symbol table from a.out,\n" );
	fprintf( stderr, "new a.out should be ok otherwise\n" );
    }
    return 0;
}

/* ****************************************************************
 * mark_x
 *
 * After succesfully building the new a.out, mark it executable
 */
static
mark_x( name )
char *name;
{
    struct stat sbuf;
    int um;

    um = umask( 0777 );
    umask( um );
    if ( stat( name, &sbuf ) == -1 )
    {
	perror ( "Can't stat new a.out" );
	fprintf( stderr, "Setting protection to %o\n", 0777 & ~um );
	sbuf.st_mode = 0777;
    }
    sbuf.st_mode |= 0111 & ~um;
    if ( chmod( name, sbuf.st_mode ) == -1 )
	perror( "Couldn't change mode of new a.out to executable" );

}
#endif
