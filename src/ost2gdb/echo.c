// echo.c: A simple program to take input on the command line and echo it back
// out
#include <stdio.h>
// main should return int and the string comparasing is not defined
void main(int argc, char **argv) {
  if (argv[1] != NULL && argv[1] != "") {
    printf("You entered %s for argv[1]\n", argv[1]);
  } else {
    printf("You didn't enter an argv[1]\n");
  }
}
