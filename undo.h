/* Definitions of objects used by the undo facility */

enum Ukinds {			/* The events that can exist in the undo
				   queue. */
    Uboundary,			/* A boundary between sets of undoable things
				   */
    Unundoable,			/* What's done is done -- some things can't
				   be undone */
    Udelete,			/* Delete characters to perform the undo */
    Uinsert,			/* Insert .... */
};

struct UndoRec {		/* A record of a single undo action */
    enum Ukinds kind;		/* the kind of action to be undone */
    struct buffer *buffer;	/* the buffer where the action takes place */
    int dot;			/* Where dot is */
    int len;			/* The extent of the undo (characters
				   inserted or deleted) */
};

/* The undo history consists of two circular queues, one of characters and
   one of UndoRecs.  When Uinsert recs are added to UndoRQ characters get
   added to UndoCQ.  The position of the characters can be reconstructed by
   subtracting len from the fill pointer. */

#define NUndoR	1000
#define NUndoC	10000
