#include <stdio.h>
main() {
char buf[1024];
char *InsLines, DelLines;
char *fill = buf;

if (tgetent (buf, getenv ("TERM")) <=0) {
  fprintf(stderr, "no TERM entry\n");
}
InsLines = tgetstr ("Al", &fill);
DelLines = tgetstr ("Dl", &fill);



}
