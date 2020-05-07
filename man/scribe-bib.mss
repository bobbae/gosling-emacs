
@Section(scribe-bib -- Scribe bibliography creation mode)
@index(Scribe bibliography support)
@index(Bibliography support for Scribe)
@index(scribe-bib)
Scribe-bib mode provides a set of functions that create Scribe bibliography
database entries. For each bibliography type scribe-bib mode provides a
function that when executed prompts the user for appropriate fields and
constructs a new entry of the proper type. The name of each of these
functions is identical to the name of the corresponding bibliography type.
Once the entry is created it can be edited using standard Emacs commands.
The bibliography creation functions are invoked by name using ESC-X and are
listed below:

@begin(description)
@@article	@\	Create an @@Article bibliography entry.

@@book	@\	Create an @@Book bibliography entry.

@@booklet	@\	Create an @@Booklet bibliography entry.

@@inbook	@\	Create an @@InBook bibliography entry.

@@incollection	@\	Create an @@InCollection bibliography entry.

@@inproceedings	@\	Create an @@InProceedings bibliography entry.

@@manual	@\	Create an @@Manual bibliography entry.

@@mastersthesis	@\	Create an @@MastersThesis bibliography entry.

@@misc	@\	Create an @@Misc bibliography entry.

@@phdthesis	@\	Create an @@PhdThesis bibliography entry.

@@proceedings	@\	Create an @@Proceedings bibliography entry.

@@techreport	@\	Create an @@TechReport bibliography entry.

@@unpublished	@\	Create an @@Unpublished bibliography entry.
@end(description)



