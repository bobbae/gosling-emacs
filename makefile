all:
	make -f makefile.`uname -m` all

install:
	make -f makefile.`uname -m` install

clean:
	make -f makefile.`uname -m` clean


