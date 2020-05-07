@Section(capword -- different behavior for word capitalizations)
@index(case-word-upper)
@index(upper-case-word)
The built-in @value(Emacs) functions @i[case-word-upper],
@i[case-word-lower], and @i[case-word-capitalize] all leave the cursor where
it began, and perform their operation on the word containing the cursor.
Many people prefer to have these functions skip forward over a word after
capitalizing or uncapitalizing it. These functions provide that service.

The @i[capword] package defines three functions, @i[upper-case-word],
@i[lower-case-word], and @i[capitalize-word]. Normally they are bound to
@b(ESC-U), @b(ESC-L), and @i(ESC-C) respectively, though this package does
not set up those bindings.
