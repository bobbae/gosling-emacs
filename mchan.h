#ifndef SystemName		/* to get UciFeatures */
#include "config.h"
#endif

#define debug(x) fprintf(stderr,"x:%d\n",x);fflush(stderr)
#define debugh(x) fprintf(stderr,"x");fflush(stderr)

#ifdef ECHOKEYS
#define mpx_getc(p,t) (--(p)->ch_count>=0? *(p)->ch_ptr++&0377:fill_chan(p,t))
#else
#define mpx_getc(p) (--(p)->ch_count>=0? *(p)->ch_ptr++&0377:fill_chan(p))
#endif
#define mpxin (&stdin_chan)
#ifdef MPXcode
#define index_t unsigned short	/* Was `int' but is `short' in <sys/mx.h> */
#else
#define	index_t int		/* Is `int' again for 4.1a */
#endif

#define STOPPED		(1<<0)
#define RUNNING		(1<<1)
#define EXITED		(1<<2)
#define	SIGNALED	(1<<3)
#define	COREDUMPED	(1<<4)
#define CHANGED		(1<<6)

#define active_process(x) ((x!=NULL)&& (x->p_flag&(RUNNING|STOPPED)))

extern int errno;

#ifdef MPXcode
/* mpx_msg is the structure of a mpx control message read from the mpx file
*/
struct mpx_msg {
    short mpx_code, mpx_arg;
    struct sgttyb mpx_ioctl;
};
#else
struct wh {
    short    index, count, ccount;
    char    *data;
};
#endif
/* Structure records pertinent information about channels open on the mpx file
   There is one channel associated with each process.
*/
struct channel_blk
    {index_t ch_index;
     struct wh ch_outrec;	/* Output record */
     char *ch_ptr;		/* Pointer to next input character */
     short ch_count;		/* Count of characters remaining in buffer */
     struct buffer *ch_buffer;	/* Process is bound to this buffer */
     struct BoundName *ch_proc;	/* Procedure which gets called on output */
     struct BoundName *ch_sent;	/* Procedure which gets called on exit */
    };       

/* Standard input is connected to the multiplexed file using a channel 
   described by stdin_chan.
*/
extern struct channel_blk stdin_chan;

/* Structure for information needed for each sub process started */

struct process_blk {
    struct process_blk *next_process;	/* link to next process */
    char *p_name;			/* command that started process */
/* these two became ints for 4.2 */
    int  p_pid;				/* process id */
    int  p_gid;				/* process pgrp */
    char p_flag;			/* RUNNING, STOPPED, etc */
    char p_reason;			/* signal causing p_flag */
    struct channel_blk p_chan;		/* process i/o connected to channel */
};

struct process_blk *process_list,	/* all existing processes */
                   *current_process;	/* the one that we're currently
					   dealing with */
int sflag;			/* the -s command line switch (enables the
				   share-emacs facility) */
