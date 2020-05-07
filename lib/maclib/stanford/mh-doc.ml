; This is "mhe", the Emacs-based front end to "mh", which is the Rand Mail
; Handler. MH is a set of programs designed to be called as commands from the
; shell. This system uses single-keystroke commands and maintains a visual
; display of the contents of the message file. I initially wrote it because I
; was drowning in mail and I needed some way to pare out the junk, and it has
; just sort of mushroomed into a real system. 
; 
; Brian K. Reid, Stanford University
; April 1982
; 
; ------------------------------------------------------------------------
; GETTING IT INSTALLED AT YOUR SITE:
; 
; Mhe consists of about a dozen mlisp files. The primary file is mh-e.ml,
; which in turn loads the others as needed. All of them must be in the
; directory where your Emacs will look for its library files. 
; 
; The file mh-e.ml must be edited to reflect the filename paths on your
; system:
; 	mh-progs	must be set to the name of the directory
; 			in which the MH programs are stored, i.e.
; 			"/usr/local/lib/mh" if the "scan" command
; 			is /usr/local/lib/mh/scan.
; 	bboard-path	must be set to the name of the directory
; 			that is the root of your "readnews" tree.
; 			If your "fa.human-nets" newsgroup is stored
; 			in /usr/spool/news/fa.human-nets/*, then
; 			you should set this variable to
; 			"/usr/spool/news". If you don't use
; 			readnews, then set it to "/dev/null".
; 
; The MH programs "comp", "repl", and "forw" have to be modified to include
; the option "-build", which causes them not to ask the "What now?"
; question at the end, but instead just exit (having built the file). Mhe will
; also be a lot more tolerable if you remove a lot of the warning messages
; from adrparse.c; there's no point making them fatal errors. If you aren't up
; to hacking directly on the MH programs, contact me as Reid@SU-SCORE or
; ucbvax!Shasta!reid, and I will provide you with the needed modifications.
; If I weren't so lazy I would propagate these changes back to Rand, but I've
; forgotten the name of the contact there and I can't find our licensing
; agreement to look his name up. Besides, they have probably changed their
; sources out from under me anyhow.
; 
; Mhe requires Emacs #45 of Fri May 21 1982 or later, because it uses
; buffer-local variables.
; ----------------------------------------------------------------------------
; SETTING UP A NEW MHE USER.
; 
; If you are an mh user, then you can just run mhe with no further ado.
; However, you can speed things up substantially by putting an alias into your
; .cshrc file so that you won't need to spawn a new subshell when you run it:
; 
; alias mhe /usr/local/bin/emacs -lmh-e.ml -estartup $*
; 
; The shell syntax for mhe is
; 	mhe
; or
; 	mhe +inbox		first argument is folder name
; or
; 	mhe +inbox 200:300	second argument is message range
; 
; The folder name defaults to current-folder, and the message range defaults
; to "all".
; ------------------------------------------------------------------------
; HOW MHE WORKS
; 
; Mhe uses the Emacs subprocess facility to run mh commands in a subshell.
; Normally when you use mh, it runs the editor in a subshell; this inverted
; scheme of the editor running mh in the subshell is actually much much
; faster, because editors are slow in starting up but the mh programs are
; pretty fast. When you start mhe, it builds a buffer whose name equals the
; name of the current folder (e.g. "+inbox"), and places a "scan" listing into
; that buffer. Then as you edit your mail, deleting and moving messages, mhe
; builds up a set of shell commands in a buffer called "cmd-buffer". When you
; exit from mhe, it passes the contents of cmd-buffer off to the shell, and
; the deletes and moves are actually processed. If you open another mail file,
; its header is given its own buffer ("+carbons", "+bugs", etc.), and you can
; switch back and forth to them as needed. The Emacs buffer-local context
; mechanism makes everything happen almost perfectly. 
; ------------------------------------------------------------------------
; these functions let me edit the above documentation without the semicolons.
(defun
    (add-semicolons
	(beginning-of-file)
	(while (! (| (eobp) (looking-at "^(defun")))
	       (insert-string "; ")
	       (next-line) (beginning-of-line)
	)
    )
    
    (remove-semicolons
	(beginning-of-file)
	(while (! (| (eobp) (looking-at "^(defun")))
	       (while (| (looking-at "^; ") (looking-at "^;$"))
		      (delete-next-character)
		      (if (! (eolp))
		          (delete-next-character))
	       )
	       (next-line)
	)
    )
)
