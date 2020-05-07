/*
To: decwrl!mcdaniel (Gene McDaniel) <decwrl!mcdaniel@su-shasta>
From: Christopher A Kent <cak@Purdue>
Return-Path: <Purdue!su-shas!cak>
Date: 27 Jan 1984 1611-EST (Friday)
Subject: Re: 4.2 & emacs
Message-Id: <8401272111.AA00493@merlin>
In-Reply-To: Your message of 27 Jan 1984 1128-PST (Friday).
             <8401271928.AA10744@DECWRL>

Right, mainly because the signal stuff has changed. If you compile with
this as the last object module, though, it will all work OK. 

Except that the ttyaccept/ttyconnect stuff doesn't work (this is used
by the fancy write that pops up a window in your emacs). Comment that
line out in config.h.

Cheers,
chris
*/

/*
 *	Date: Fri, 30 Sep 83 17:37:21 EST
 *	To: cak@Purdue
 *	Subject: sigkludge.c
 */

/*	This is a kludge for to get emacs running quickly under 4.2 bsd */

#include <signal.h>

/*	Got compile errors with this in the ointment			
signal(sig, func)

	int 	sig,func;
{
	sigsys(sig,func);
	return;
}*/


sigsys (sig, func)

	int 	sig;
	void (*func)();
{
	struct sigvec invec, outvec;
	register struct sigvec *ivecp = &invec;

/*	This works only because the only use of sigsys is to set the 
	"handler" to SIG_DFL						*/

	ivecp->sv_handler=func;
	ivecp->sv_mask=0;
	ivecp->sv_onstack=0;
	sigvec(sig, ivecp, &outvec);
	return;
}

sigrelse(sig)

	int	sig;
{
	long	amask;

	amask=sigblock(1<<sig);
	sigsetmask(amask & ~(1<<(sig-1)));
	return;
}

sighold(sig)

	int	sig;
{
	long	amask;

	amask=sigblock(1<<(sig-1));
	return;
}
 
sigset(sig, func)

	int 	sig;
	void (*func)();
{
	sigsys(sig,func);
	return;
}

sigpaws(sig)

	int	sig;

{
	long	amask;

	amask=sigblock(0);
	sigpause(amask & ~(1<<(sig-1)));
	return;
}


