@case(Device,	Dover <@Use(AuxFile "emacs1.aux")>,
		else  <@Use(AuxFile "emacs2.aux")>)
@make(EmacsManual)
@device(dover)
@style(Hyphenation=On)
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
@end(OnDover)
@begin(NotDover)
@b[UNIX EMACS]
@end(NotDover)


@p[James Gosling @b[@@] CMU]
May, 1982


Copyright (c) 1982 James Gosling
@end(Center)
@begin(format,RightMargin -2in)
@begin(OnDover)
@tabs(+1.5in)
@\<==<rosegarden.press<
@end(OnDover)


@end(format)
@begin(OnDover)
@include(contents.mss)
@end(OnDover)
@begin(NotDover)
@include(lcontents.mss)
@end(NotDover)
@newpage
@include(introduction.mss)
@comment[@include(tutorial.mss)]
@include(basics.mss)
@include(hints.mss)
@include(process.mss)
@include(database.mss)
@include(packages.mss)
@Chapter(Command Description)
This chapter describes (in alphabetical order) all of the commands which are
defined in the basic Unix @Value(Emacs) system.  Other commands may be
defined by loading packages.  Each description names the command and indicates
the default binding.
@label(CommandDescription)
@include(commands.mss)
@Chapter(Options)
This chapter describes (in alpahbetical order) all of the variables which
the user may set to configure @Value(Emacs) to taste.
@label(OptionDescription)
@include(variables.mss)
@newpage
@index(Summary)
@index(Reference Card)
@send(Contents "@tc1[Reference Card]")
@label(CommandSummary)
@include(refcard.mss)
@form(command="foo")
