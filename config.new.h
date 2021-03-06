/* Emacs configuration file -- all site-dependant definitions should be made
   here.  Each site should only have to edit this file. */

char	usysname[9];
#define SystemName (gethostname(usysname), usysname)
				/* Define this symbol to be a string that
				   represents the name of your site */
#define BackupExtension ","	/* This string gets appended to filenames to
				   generate the file name used for making
				   backups.  The folks at BBN like to use the
				   string "~" because it takes up fewer
				   characters. */
#define CheckpointExtension ".," /* This string gets appended to
				   filenames to generate the file
				   name used for making checkpoints. */
#define PrependExtension	/* If this is defined then the backup and
				   checkpoint extensions will be prepended to
				   the file name, rather than appended.  Some
				   folks like to use (for example) # as the
				   first character of a filename to indicate
				   that it can be deleted if it's more than
				   a few days old. */
#undef	MPXcode			/* Define this symbol to use MPXio */
#define subprocesses		/* Define this symbol if you want the
				   subprocess control stuff. */
#define PATH_LOADSEARCH ":/a3/kent/emacs/lib/maclib/local:/a3/kent/emacs/lib/maclib:/a3/kent/emacs/lib/maclib/stanford"
				/* the default search path for loading macro
				   packages */
#define DefaultProfile "/usr/local/lib/emacs/profile.ml"
				/* If a user doesn't have a ".emacs_pro" in
				   their home directory, then the
				   DefaultProfile file is used as their
				   profile instead */
#ifdef MPXcode
#define OneEmacsPerTty		/* Define this symbol if only one Emacs is
				   allowed to run per tty.  This is usually
				   only necessary to get around an obnoxious
				   bug in the MPXio facility which is used
				   when the subprocess control feature is
				   used.  If you define subprocesses, then
				   you should define this symbol -- unless
				   you have fixed the kernel bug */
#define	OneEmacsWarning		/* Define this to warn people about the one
				   Emacs business if they can run more than
				   one */
#endif
#ifndef	MPXcode
#define	TTYconnect		/* Define this symbol if you are going to use
				   IP/TCP to implement unexpected process
				   handling */
#endif
#define MailOriginator pw->pw_name
				/* MailOriginator should be an expression
				   that will evaluate to the name of the
				   originator of a message.  "pw" is set to
				   point to a passwd struct for the current
				   user.  At CMU we put a users full name in
				   the pw_gecos field, so we use that as the
				   name for the originator -- our mail system
				   understands such full names as message
				   destinations.  Other folks might want to
				   use pw->pw_name.  This is also used to
				   evaluate users-full-name. */
#define AddSiteName		/* Define this if you want the name of the
				   origninating site to be added to the
				   "from" field of outgoing mail. */
#define UciFeatures		/* Define this if you want to enable UCI 
				   hackery */
#define	UmcpFeatures		/* Define this if you want to enable UMCP
				   hackery */
#define	UtahFeatures		/* Define this if you want to enable UTAH
				   hackery */
#define	SuFeatures		/* Define this if you want to enable Stanford
				   hackery */
#define	ECHOKEYS		/* Define this to enable to echo'ing
				   keystrokes */
#undef	CatchSig		/* Define this to enable signal catching to
				   interrupt MLisp routines */
#define HalfBaked		/* Define this if half baked IO is to be
				   done, it's advantage is that it allows the
				   ^G command to interrupt Emacs.  But it has
				   a major bug: all pending output gets lost
				   so Emacs will lose track of what the
				   display looks like. */
#ifdef HalfBaked		/* Disable conflicting interrupt strategies */
#undef CatchSig
#endif
#define	BSD41c
