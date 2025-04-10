#include <stdio.h>
#include <stdlib.h>

int recursive(int a){
  if(a == 0 | a == 1) return 1;
  return recursive(a-1) + recursive(a-2);
}

int main(){
  printf("%i", recursive(5));
}
