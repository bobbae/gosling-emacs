@Marker(Make,EmacsManual,Press)

@Define(BodyStyle,Font BodyFont,Spacing 1.1,Spread 0.8)
@Define(NoteStyle,Font SmallBodyFont,FaceCode R,Spacing 1)
@Font(Times Roman 10)

@Enable(Outline,Index,Contents="cont")
@Style(DoubleSided,BindingMargin=0.3inch)
@send(#Index	"@UnNumbered(Index)",
      #Index	"@Begin(IndexEnv)")
@SendEnd(#Index "@End(IndexEnv)")

@Define	(HDX,LeftMargin 0,Indent 0,Fill,Spaces compact,Above 1,Below 0,
	  break,need 4,Justification Off)
@Define	(Hd0,Use HdX,Font TitleFont5,FaceCode R,Above 1inch,Below 0.5inch)
@Define(Hd1,Use HdX,Font TitleFont5,FaceCode R,Above .5inch)
@Define(HD1A=HD1,Centered)
@Define(Hd2,Use HdX,Font TitleFont3,FaceCode R,Above 0.4inch)
@Define(Hd3,Use HdX,Font TitleFont3,FaceCode R,Above 0.4inch)
@Define(Hd4,Use HdX,Font TitleFont3,FaceCode R,Above 0.3inch)
@Define(TcX,LeftMargin 5,Indent -5,RightMargin 5,Fill,Spaces compact,
	Need 4,
	Above 0,Spacing 1,Below 0,Break,Spread 0,Justification off)
@Define(Tc0=TcX,Font TitleFont3,FaceCode R)
@Define(Tc1=TcX,Font TitleFont1,FaceCode R,Above 0.1inch,
	Below 0.1inch,Need 1inch)
@Define(Tc2=TcX,LeftMargin 8,Font TitleFont0,FaceCode R)
@Define(Tc3=TcX,LeftMargin 12,Font TitleFont0,FaceCode R)
@Define(Tc4=TcX,LeftMargin 16,Font TitleFont0,FaceCode R)
@Counter(MajorPart,TitleEnv HD0,ContentsEnv tc0,Numbered [@I],
	  IncrementedBy Use,Announced)
@Counter(Chapter,TitleEnv HD1,ContentsEnv tc1,Numbered [@1.],
	  IncrementedBy Use,Referenced [@1],Announced)
@Counter(Appendix,TitleEnv HD1,ContentsEnv tc1,Numbered [@I.],
	 ContentsForm "@Tc1(Appendix @parm(referenced). @rfstr(@parm(page))@parm(Title))",
	 TitleForm "@Hd1(@=Appendix @parm(referenced)@*@=@Parm(Title))",

	  IncrementedBy,Referenced [@I],Announced,Alias Chapter)
@Counter(UnNumbered,TitleEnv HD1,ContentsEnv tc1,Announced,Alias Chapter)
@Counter(Section,Within Chapter,TitleEnv HD2,ContentsEnv tc2,
	  Numbered [@#@:.@1.],Referenced [@#@:.@1],IncrementedBy Use,Announced)
@Counter(AppendixSection,Within Appendix,TitleEnv HD2,ContentsEnv tc2,
	  Numbered [@#@:.@1.],Referenced [@#@:.@1],IncrementedBy Use,Announced)
@Counter(SubSection,Within Section,TitleEnv HD3,ContentsEnv tc3,
	  Numbered [@#@:.@1.],IncrementedBy Use,Referenced [@#@:.@1])
@Counter(AppendixSubsec,Within AppendixSection,TitleEnv Hd3,ContentsEnv Tc3,
	Numbered [@#@:.@1.],IncrementedBy USe,Referenced [@#@:.@1])
@Counter(Paragraph,Within SubSection,TitleEnv HD4,ContentsEnv tc4,
	  Numbered [@#@:.@1.],Referenced [@#@:.@1],IncrementedBy Use)

@Counter(PrefaceSection,TitleEnv HD1A,Alias Chapter)
@Define(IndexEnv,Break,CRBreak,Fill,BlankLines Kept,Font SmallBodyFont,
	Columns 2,Boxed,
	FaceCode R,Spread 0,Spacing 1,Spaces Kept,LeftMargin 18,Indent -8)

@LibraryFile(Figures)
@LibraryFile(Math)
@LibraryFile(TitlePage)

@Modify(EquationCounter,Within Chapter)
@Modify(TheoremCounter,Within Chapter)

@Equate(Sec=Section,Subsec=SubSection,Chap=Chapter,Para=Paragraph,
	SubSubSec=Paragraph,AppendixSec=AppendixSection)
@Begin(Text,Indent 1Quad,LeftMargin 1inch,TopMargin 1inch,BottomMargin 1inch,
	LineWidth 6.5inches,Spread 0.075inch,
	Use BodyStyle,Justification,FaceCode R,Spaces Compact)
@Set(Page=0)

@PageHeading(Even,Left "@value(Page)")
@PageHeading(Odd,Right "@value(Page)")
@Marker(Make,EmacsManual,Diablo)
@Define(BodyStyle,Spacing 1,Spread 0.8)
@Define(TitleStyle,Spacing 1,Spread 0)
@Define(NoteStyle,Spacing 1,Spread 0.3)
@Typewheel(Elite 12)

@Enable(Outline,Index,Contents="lcnt")
@Style(DoubleSided,BindingMargin=0.3inch)
@Send(Contents "@PrefaceSection(Table of Contents)")
@send(#Index	"@UnNumbered(Index)",
      #Index	"@Begin(IndexEnv)")
@SendEnd(#Index "@End(IndexEnv)")

@Define	(HDX,LeftMargin 0,Indent 0,Fill,Spaces compact,Above 1,Below 0,
	  break,need 4,Justification Off)
@Define	(Hd0,Use HdX,Above 1inch,Below 0.5inch)
@Define(Hd1,Use HdX,,Above .5inch)
@Define(HD1A=HD1,Centered)
@Define(Hd2,Use HdX,Above 0.4inch)
@Define(Hd3,Use HdX,Above 0.4inch)
@Define(Hd4,Use HdX,Above 0.3inch)
@Define(TcX,LeftMargin 5,Indent -5,RightMargin 5,Fill,Spaces compact,
	Above 0,Spacing 1,Below 0,Break,Spread 0,Justification off)
@Define(Tc0=TcX)
@Define(Tc1=TcX,Above 0.2,Below 0.2,Need 1inch)
@Define(Tc2=TcX,LeftMargin 5)
@Define(Tc3=TcX,LeftMargin 10)
@Define(Tc4=TcX,LeftMargin 15)
@Counter(MajorPart,TitleEnv HD0,ContentsEnv tc0,Numbered [@I],
	  IncrementedBy Use,Announced)
@Counter(Chapter,TitleEnv HD1,ContentsEnv tc1,Numbered [@1.],
	  IncrementedBy Use,Referenced [@1],Announced)
@Counter(Appendix,TitleEnv HD1,ContentsEnv tc1,Numbered [@I.],
	  IncrementedBy,Referenced [@I],Announced,Alias Chapter)
@Counter(UnNumbered,TitleEnv HD1,ContentsEnv tc1,Announced,Alias Chapter)
@Counter(Section,Within Chapter,TitleEnv HD2,ContentsEnv tc2,
	  Numbered [@#@:.@1.],Referenced [@#@:.@1],IncrementedBy Use,Announced)
@Counter(AppendixSection,Within Appendix,TitleEnv HD2,ContentsEnv tc2,
	  Numbered [@#@:.@1.],Referenced [@#@:.@1],IncrementedBy Use,Announced)
@Counter(SubSection,Within Section,TitleEnv HD3,ContentsEnv tc3,
	  Numbered [@#@:.@1.],IncrementedBy Use,Referenced [@#@:.@1])
@Counter(AppendixSubsec,Within AppendixSection,TitleEnv Hd3,ContentsEnv Tc3,
	Numbered [@#@:.@1.],IncrementedBy USe,Referenced [@#@:.@1])
@Counter(Paragraph,Within SubSection,TitleEnv HD4,ContentsEnv tc4,
	  Numbered [@#@:.@1.],Referenced [@#@:.@1],IncrementedBy Use)

@Counter(PrefaceSection,TitleEnv HD1A,Alias Chapter)
@Define(IndexEnv,Break,CRBreak,Fill,BlankLines Kept,
	Spread 0,Spacing 1,Spaces Kept,LeftMargin 18,Indent -8)

@LibraryFile(Figures)
@LibraryFile(Math)
@LibraryFile(TitlePage)

@Modify(EquationCounter,Within Chapter)
@Modify(TheoremCounter,Within Chapter)

@Equate(Sec=Section,Subsec=SubSection,Chap=Chapter,Para=Paragraph,
	SubSubSec=Paragraph,AppendixSec=AppendixSection)
@Begin(Text,Indent 3,Use BodyStyle,LeftMargin 1inch,TopMargin 1inch,
	BottomMargin 1inch,LineWidth 6.5inches,Justification,
	Spaces Compact,Font CharDef,FaceCode R)
@set(page=0)

@PageHeading(Even,Left "@value(Page)")
@PageHeading(Odd,Right "@value(Page)")
@Marker(Make,EmacsManual,File,PagedFile,CRT)
@Define(BodyStyle,Spacing 1)
@Define(TitleStyle,Spacing 1)
@Define(NoteStyle,Spacing 1)

@Enable(Outline,Index,Contents="lcnt")
@Style(DoubleSided,BindingMargin=0.3inch)
@Send(Contents "@PrefaceSection(Table of Contents)")
@send(#Index	"@UnNumbered(Index)",
      #Index	"@Begin(IndexEnv)")
@SendEnd(#Index "@End(IndexEnv)")

@Define	(HDX,LeftMargin 0,Indent 0,Fill,Spaces compact,Above 1,Below 0,
	  break,need 4,Justification Off)
@Define	(Hd0,Use HdX,Above 1inch,Below 0.5inch)
@Define(Hd1,Use HdX,Above 3,PageBreak Before)
@Define(HD1A=HD1,Centered)
@Define(Hd2,Use HdX,Above 1)
@Define(Hd3,Use HdX,Above 3)
@Define(Hd4,Use HdX,Above 2)
@Define(TcX,LeftMargin 5,Indent -5,RightMargin 5,Fill,Spaces compact,
	Above 0,Spacing 1,Below 0,Break,Spread 0,Justification off)
@Define(Tc0=TcX)
@Define(Tc1=TcX,Above 1,Below 1,Need 1inch)
@Define(Tc2=TcX,LeftMargin 5,Need 1inch)
@Define(Tc3=TcX,LeftMargin 10)
@Define(Tc4=TcX,LeftMargin 15)
@Counter(MajorPart,TitleEnv HD0,ContentsEnv tc0,Numbered [@I],
	  IncrementedBy Use,Announced)
@Counter(Chapter,TitleEnv HD1,ContentsEnv tc1,Numbered [@1.],
	  IncrementedBy Use,Referenced [@1],Announced)
@Counter(Appendix,TitleEnv HD1,ContentsEnv tc1,Numbered [@I.],
	  IncrementedBy,Referenced [@I],Announced,Alias Chapter)
@Counter(UnNumbered,TitleEnv HD1,ContentsEnv tc1,Announced,Alias Chapter)
@Counter(Section,Within Chapter,TitleEnv HD2,ContentsEnv tc2,
	  Numbered [@#@:.@1.],Referenced [@#@:.@1],IncrementedBy Use,Announced)
@Counter(AppendixSection,Within Appendix,TitleEnv HD2,ContentsEnv tc2,
	  Numbered [@#@:.@1.],Referenced [@#@:.@1],IncrementedBy Use,Announced)
@Counter(SubSection,Within Section,TitleEnv HD3,ContentsEnv tc3,
	  Numbered [@#@:.@1.],IncrementedBy Use,Referenced [@#@:.@1])
@Counter(AppendixSubsec,Within AppendixSection,TitleEnv Hd3,ContentsEnv Tc3,
	Numbered [@#@:.@1.],IncrementedBy USe,Referenced [@#@:.@1])
@Counter(Paragraph,Within SubSection,TitleEnv HD4,ContentsEnv tc4,
	  Numbered [@#@:.@1.],Referenced [@#@:.@1],IncrementedBy Use)

@Counter(PrefaceSection,TitleEnv HD1A,Alias Chapter)
@Define(IndexEnv,Break,CRBreak,Fill,BlankLines Kept,
	Spread 0,Spacing 1,Spaces Kept,LeftMargin 18,Indent -8)

@LibraryFile(Figures)
@LibraryFile(Math)
@LibraryFile(TitlePage)

@Modify(EquationCounter,Within Chapter)
@Modify(TheoremCounter,Within Chapter)

@Equate(Sec=Section,Subsec=SubSection,Chap=Chapter,Para=Paragraph,
	SubSubSec=Paragraph,AppendixSec=AppendixSection)
@Begin(Text,Indent 2,Spread 1,Use BodyStyle,LineWidth 7.9inches,
	Spaces Compact,
	Justification,Font CharDef,FaceCode R)
@set(page=0)

@PageHeading(Even,Left "@value(Page)")
@PageHeading(Odd,Right "@value(Page)")
@Marker(Make,EmacsManual)
@Define(BodyStyle,Spacing 1)
@Define(TitleStyle,Spacing 1)
@Define(NoteStyle,Spacing 1)

@Enable(Outline,Index,Contents="lcnt")
@Style(DoubleSided,BindingMargin=0.3inch)
@Send(Contents "@PrefaceSection(Table of Contents)")
@send(#Index	"@UnNumbered(Index)",
      #Index	"@Begin(IndexEnv)")
@SendEnd(#Index "@End(IndexEnv)")

@Define	(HDX,LeftMargin 0,RightMargin 0,Indent 0,Fill,Spaces compact,
	Above 2,Below 0,break,need 4,Justification Off)
@Define	(Hd0,Use HdX,Above 1inch,Below 0.5inch,Use B)
@Define(Hd1,Use HdX,Below 1,Use B,above 1in,need 3in)
@Define(HD1A=HD1)
@Define(Hd2,Use HdX,Above 3,Below 1,Use B)
@Define(Hd3,Use HdX,Use B)
@Define(Hd4,Use HdX,Use B)
@Define(TcX,LeftMargin 5,Indent -5,RightMargin 5,Fill,Spaces compact,
	Above 0,Spacing 1,Below 0,Break,Spread 0,Justification off)
@Define(Tc0=TcX,Use B)
@Define(Tc1=TcX,Above 1,Below 1,Use b,Need 1inch)
@Define(Tc2=TcX,LeftMargin 10)
@Define(Tc3=TcX,LeftMargin 15)
@Define(Tc4=TcX,LeftMargin 20)
@Counter(MajorPart,TitleEnv HD0,ContentsEnv tc0,Numbered [@I],
	  IncrementedBy Use,Announced)
@Counter(Chapter,TitleEnv HD1,ContentsEnv tc1,Numbered [@1.],
	TitleForm "@begin(Hd1)@=Chapter @parm(referenced)@*@=@Parm(Title)@end(Hd1)",
	  IncrementedBy Use,Referenced [@1],Announced)
@Counter(Appendix,TitleEnv HD1,ContentsEnv tc1,Numbered [@I.],
	  IncrementedBy,Referenced [@I],Announced,Alias Chapter)
@Counter(UnNumbered,TitleEnv HD1,ContentsEnv tc1,Announced,Alias Chapter)
@Counter(Section,Within Chapter,TitleEnv HD2,ContentsEnv tc2,
	  Numbered [@#@:.@1.],Referenced [@#@:.@1],IncrementedBy Use,Announced)
@Counter(AppendixSection,Within Appendix,TitleEnv HD2,ContentsEnv tc2,
	  Numbered [@#@:.@1.],Referenced [@#@:.@1],IncrementedBy Use,Announced)
@Counter(SubSection,Within Section,TitleEnv HD3,ContentsEnv tc3,
	  Numbered [@#@:.@1.],IncrementedBy Use,Referenced [@#@:.@1])
@Counter(Paragraph,Within SubSection,TitleEnv HD4,ContentsEnv tc4,
	  Numbered [@#@:.@1.],Referenced [@#@:.@1],IncrementedBy Use)

@Counter(PrefaceSection,TitleEnv HD1A,Alias Chapter)
@Define(IndexEnv,Break,CRBreak,Fill,BlankLines Kept,
	Spread 0,Spacing 1,Spaces Kept,LeftMargin 18,Indent -8)

@LibraryFile(Figures)
@LibraryFile(Math)
@LibraryFile(TitlePage)

@Modify(EquationCounter,Within Chapter)
@Modify(TheoremCounter,Within Chapter)

@Equate(Sec=Section,Subsec=SubSection,Chap=Chapter,Para=Paragraph,
	SubSubSec=Paragraph,AppendixSec=AppendixSection)
@Begin(Text,Indent 2,Spread 1,Use BodyStyle,LineWidth 7.5inches,
	Spaces Compact,
	Justification,Font CharDef,FaceCode R)
@set(page=0)


@PageHeading(Even,Left "@value(Page)")
@PageHeading(Odd,Right "@value(Page)")
