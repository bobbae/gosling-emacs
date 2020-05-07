@case(Device,	Dover <@Use(AuxFile "pack1.aux")>,
		else  <@Use(AuxFile "pack2.aux")>)
@make(EmacsManual)
@device(dover)
@define(comform,break around,nofill,above 0.3in,below 0,need 1.5in,
	indent -.25in)
@form(command="@comform(@Index@parmquote(name)@i@parmquote(name)@>@b@parmquote(key))")
@form(variable="@comform(@Index@parmquote(name)@i@parmquote(name))")
@textform(comref="@Index@parmquote(text)@i@parmquote(text)")
@define(ParaEnv, Break Before, above 0.3in, need 1.5in, indent -0.5in)
@define(CommandList, Break Around, Above 0.3in, Below 0.3in, 
	leftmargin +.5in)
@form(ComPara="@ParaEnv[@Index@parmquote(name)@i@parmquote(name) @b@parmquote(key): ]")
@form(VarPara="@ParaEnv[@Index@parmquote(name)Variable @i@parmquote(name): ]")
@set(Page=1)
@case(Device,
Dover <
@SpecialFont(F1="Monastary10")
@SpecialFont(F2="TimesRomanD24MRR")
@equate(NotDover=comment)
@define(OnDover)
>,
else <
@equate(OnDover=comment)
@define(Notdover)
>)
@case(Device,	Dover <@string(Emacs="E@c[macs]")>,
		else  <@string(Emacs="Emacs")>)
@begin(center,LeftMargin +3in, above 1.5in, below .25in)
@begin(OnDover)
@F2[Unix Emacs]

@heading[Packages]
@end(OnDover)
@begin(NotDover)
@b[UNIX EMACS]

@heading[Packages]
@end(NotDover)


@p[James Gosling @b[@@] CMU]
December, 1981


Copyright (c) 1980,1981 James Gosling
@end(Center)
@begin(format,RightMargin -2in)
@begin(OnDover)
@tabs(+1.5in)
@\<==<rosegarden.press<
@end(OnDover)


@end(format)
@begin(OnDover)
@include(pcontents.mss)
@end(OnDover)
@begin(NotDover)
@include(plcontents.mss)
@end(NotDover)
@newpage
@include(packages.mss)
