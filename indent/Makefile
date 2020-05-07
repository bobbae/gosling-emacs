indent: indent.o io.o lexi.o parse.o pr_comment.o
	cc indent.o io.o lexi.o parse.o pr_comment.o -o indent
indent.o: indent.c
	cc -c -g indent.c
io.o: io.c
	cc -c -g io.c
lexi.o: lexi.c
	cc -c -g lexi.c
parse.o: parse.c
	cc -c -g parse.c
pr_comment.o: pr_comment.c
	cc -c -g pr_comment.c
