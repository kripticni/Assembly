#include <stdio.h>
int main(){
  int array[] = {10, 2, 14, 7, 8, 12, 15, 11, 0, 4, 1, 13, 3, 9, 6, 5};
  int sum = 0;
  int index = 0;
  for(int i = 0; i < 15; ++i){
    index = array[index];
    sum = sum + index;
  }
  printf("%i", sum);
}
